 ------------------------------------------------------------------
------------------ Disparadores (Triggers) -----------------------
------------------------------------------------------------------

--------------------------------------------------------------
--MANTENER PROPIEDAD: Evitar cambios en ciudad, dirección y CHIP, y evitar eliminación si hay habitaciones asociadas
--------------------------------------------------------------

CREATE OR REPLACE FUNCTION fn_tg_actualizar_propiedad()
RETURNS TRIGGER AS $$
BEGIN
    -- Validar que no cambie ni la ciudad, ni la dirección, ni el CHIP (idPropiedad)
    IF NEW.idPropiedad <> OLD.idPropiedad OR 
       NEW.direccionPropiedad <> OLD.direccionPropiedad OR 
       NEW.ciudadPropiedad <> OLD.ciudadPropiedad THEN
                RAISE EXCEPTION 'Modificación denegada: Solo es mutable el nombre de la propiedad.';
    END IF;
    RETURN NEW;
    
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_actualizar_propiedad
BEFORE UPDATE ON Propiedades
FOR EACH ROW
EXECUTE FUNCTION fn_tg_actualizar_propiedad();

CREATE OR REPLACE FUNCTION fn_tg_eliminar_propiedad()
RETURNS TRIGGER AS $$
BEGIN
    -- Validar que no existan habitaciones asociadas a la propiedad antes de eliminar
    IF EXISTS (SELECT 1 FROM Habitaciones WHERE idPropiedad = OLD.idPropiedad) THEN
        RAISE EXCEPTION 'No se puede eliminar la propiedad: existen habitaciones asociadas.';
    END IF;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_eliminar_propiedad
BEFORE DELETE ON Propiedades
FOR EACH ROW
EXECUTE FUNCTION fn_tg_eliminar_propiedad();
--------------------------------------------------
-- REGISTRAR CONTRATO: Evitar que se registren contratos en habitaciones no disponibles, validar fechas y roles del personal
----------------------------------------------------


CREATE OR REPLACE FUNCTION fn_tg_ins_contrato()
RETURNS TRIGGER AS $$
DECLARE
    v_estado_hab     VARCHAR(30);
    v_cargo_personal VARCHAR(30);
    v_validar_hab    BOOLEAN;
BEGIN
    IF TG_OP = 'INSERT' THEN
        v_validar_hab := TRUE;
    ELSE
        v_validar_hab := NEW.idHabitacion IS DISTINCT FROM OLD.idHabitacion;
    END IF;

    IF v_validar_hab THEN
        SELECT estadoHabitacion INTO v_estado_hab
        FROM Habitaciones WHERE idHabitacion = NEW.idHabitacion;
        IF v_estado_hab IS DISTINCT FROM 'Disponible' THEN
            RAISE EXCEPTION 'La habitación % no se encuentra disponible.', NEW.idHabitacion;
        END IF;
    END IF;


    -- 2. Verificar que el residente esté registrado
    IF NOT EXISTS (SELECT 1 FROM Residentes WHERE idResidente = NEW.idResidente) THEN
        RAISE EXCEPTION 'El residente con ID % no está registrado en el sistema.', NEW.idResidente;
    END IF;

    -- 3. Verificar que el personal que registra tenga rol 'Recepcionista' o 'Administrador'
    SELECT cargoPersonal INTO v_cargo_personal FROM Personal WHERE idPersonal = NEW.idPersonal;
    IF v_cargo_personal NOT IN ('Recepcionista', 'Administrador') THEN
        RAISE EXCEPTION 'El personal registrador debe tener el cargo de Recepcionista o Administrador.';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tg_ins_contrato
BEFORE INSERT OR UPDATE ON ContratosOcupacion
FOR EACH ROW
EXECUTE FUNCTION fn_tg_ins_contrato();

CREATE OR REPLACE FUNCTION fn_tg_contrato_confirmado()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.estadoContrato = 'Vigente' THEN
        UPDATE Habitaciones SET estadoHabitacion = 'Ocupada'
        WHERE idHabitacion = NEW.idHabitacion;
    END IF;

    IF TG_OP = 'UPDATE' THEN
        IF OLD.estadoContrato = 'Vigente'
           AND NEW.estadoContrato IN ('Finalizado', 'Cancelado') THEN
            UPDATE Habitaciones SET estadoHabitacion = 'En Limpieza'
            WHERE idHabitacion = NEW.idHabitacion;
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tg_contrato_confirmado
AFTER INSERT OR UPDATE OF estadoContrato ON ContratosOcupacion
FOR EACH ROW
EXECUTE FUNCTION fn_tg_contrato_confirmado();

CREATE OR REPLACE FUNCTION fn_tg_asignacion_tcontratol()
RETURNS TRIGGER AS $$
BEGIN   
    -- Asignar tipo de contrato según la duración
    IF NEW.fechaFin IS NOT NULL AND (NEW.fechaFin - NEW.fechaInicio) > 31 THEN
        INSERT INTO ContratosLargoPlazo (idContrato, diaCorteMensual) 
        VALUES (NEW.idContrato, EXTRACT(DAY FROM NEW.fechaInicio));
    ELSE
        INSERT INTO ContratosCortoPlazo (idContrato, totalNoches) 
        VALUES (NEW.idContrato, (NEW.fechaFin - NEW.fechaInicio));
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tg_asignacion_tcontrato
AFTER INSERT OR UPDATE ON ContratosOcupacion
FOR EACH ROW
EXECUTE FUNCTION fn_tg_asignacion_tcontratol();



CREATE OR REPLACE FUNCTION fn_tg_limpieza_auditoria()
RETURNS TRIGGER AS $$
BEGIN
    -- Verificar si la fecha de fin del contrato supera los dos años desde la fecha de inicio
    IF OLD.fechaFin IS NOT NULL AND OLD.fechaFin > OLD.fechaInicio + INTERVAL '2 years' THEN
        IF OLD.estadoContrato NOT IN ('Cancelado', 'Finalizado') THEN
            RAISE EXCEPTION 'Los contratos con duración superior a dos años deben estar en estado Cancelado o Finalizado.';
        END IF;
    END IF;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tg_limpieza_auditoria
BEFORE DELETE ON ContratosOcupacion
FOR EACH ROW
EXECUTE FUNCTION fn_tg_limpieza_auditoria();


CREATE OR REPLACE FUNCTION fn_tg_habitacion_libre()
RETURNS TRIGGER AS $$
BEGIN
    -- Al eliminar un contrato, cambiar el estado de la habitación asociada a 'Disponible'
    UPDATE Habitaciones 
    SET estadoHabitacion = 'Disponible' 
    WHERE idHabitacion = OLD.idHabitacion;
    
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tg_habitacion_libre
AFTER DELETE ON ContratosOcupacion
FOR EACH ROW
EXECUTE FUNCTION fn_tg_habitacion_libre();

---------------------------------------------------
-- REGISTAR RESERVA: Evitar reservas en espacios no disponibles, validar aforo y solapamiento de horarios
---------------------------------------------------
 

CREATE OR REPLACE FUNCTION fn_tg_ins_reservaespacio()
RETURNS TRIGGER AS $$
DECLARE
    v_estado_espacio VARCHAR(30);
    v_aforo NUMERIC;
BEGIN 
    -- Verificar estado del espacio común (debe estar en 'Disponible')
    IF EXISTS (SELECT 1 FROM EspaciosComunes WHERE idEspacio = NEW.idEspacio AND estadoActualEspacio <> 'Disponible') THEN
        RAISE EXCEPTION 'El espacio común % no se encuentra disponible para reservas.', NEW.idEspacio;
    END IF;

    -- Verificar que el aforo solicitado no supere el aforo máximo del espacio
    IF EXISTS (SELECT 1 FROM EspaciosComunes WHERE idEspacio = NEW.idEspacio AND aforoespacio < NEW.cantidadPersonas) THEN
        RAISE EXCEPTION 'El aforo solicitado (%) supera el aforo máximo permitido para el espacio común %.', NEW.cantidadPersonas, NEW.idEspacio;  
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tg_ins_reservaespacio
BEFORE INSERT ON ReservasEspacios
FOR EACH ROW
EXECUTE FUNCTION fn_tg_ins_reservaespacio();


CREATE OR REPLACE FUNCTION fn_tg_espacio_ocupado()
RETURNS TRIGGER AS $$
BEGIN
    -- Verificar solapamiento de horarios para el mismo espacio y fecha
    IF EXISTS (
        SELECT 1 
        FROM ReservasEspacios 
        WHERE idEspacio = NEW.idEspacio
        AND fechaReserva = NEW.fechaReserva
        AND estadoReserva <> 'Cancelada'
        AND NEW.horaInicio < horaFin AND NEW.horaFin > horaInicio
    ) THEN
        RAISE EXCEPTION 'El espacio común % ya tiene una reserva en el rango horario solicitado para la fecha %.', NEW.idEspacio, NEW.fechaReserva;
            END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tg_espacio_ocupado
BEFORE INSERT ON ReservasEspacios
FOR EACH ROW
EXECUTE FUNCTION fn_tg_espacio_ocupado();



CREATE OR REPLACE FUNCTION fn_tg_eliminar_reserva()
RETURNS TRIGGER AS $$
BEGIN
    -- Verificar que la reserva esté en estado 'Cancelada' antes de eliminar
    IF OLD.estadoReserva <> 'Cancelado' THEN
        RAISE EXCEPTION 'Solo se pueden eliminar reservas que estén en estado Cancelada.';
    END IF;

    RETURN OLD;
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER tg_eliminar_reserva
BEFORE DELETE ON ReservasEspacios   
FOR EACH ROW
EXECUTE FUNCTION fn_tg_eliminar_reserva();

-- ======================
-- -- MANTENER PERSONA --
-- ======================

CREATE OR REPLACE FUNCTION fn_tg_agregar_contacto()
RETURNS TRIGGER AS $$
BEGIN
    -- Verificar si el residente ya tiene un contacto de emergencia principal
    IF NEW.esPrincipal THEN
        IF EXISTS (SELECT 1 FROM ContactosEmergencia WHERE idResidente = NEW.idResidente AND esPrincipal = TRUE) THEN
                RAISE EXCEPTION 'El residente % ya tiene un contacto de emergencia principal.', NEW.idResidente;
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tg_agregar_contacto
BEFORE INSERT ON ContactosEmergencia
FOR EACH ROW
EXECUTE FUNCTION fn_tg_agregar_contacto();



CREATE OR REPLACE FUNCTION fn_tg_contacto_principal()
RETURNS TRIGGER AS $$
BEGIN
    IF (SELECT COUNT(*) FROM ContactosEmergencia
        WHERE idResidente = NEW.idResidente) = 0 THEN
        NEW.esPrincipal := TRUE;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tg_contacto_principal
BEFORE INSERT ON ContactosEmergencia
FOR EACH ROW
EXECUTE FUNCTION fn_tg_contacto_principal();


CREATE OR REPLACE FUNCTION fn_tg_restricciones_actualizacion()
RETURNS TRIGGER AS $$
BEGIN
    -- Bloquear la modificación del documento de identidad principal
    IF NEW.tipoDocumento <> OLD.tipoDocumento OR NEW.numeroDocumento <> OLD.numeroDocumento THEN
        RAISE EXCEPTION 'No se puede modificar el documento de identidad principal.';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tg_restricciones_actualizacion
BEFORE UPDATE ON Personas
FOR EACH ROW
EXECUTE FUNCTION fn_tg_restricciones_actualizacion();



CREATE OR REPLACE FUNCTION fn_tg_roles_trabajadores()
RETURNS TRIGGER AS $$
DECLARE
    v_cargo_personal VARCHAR(30);
    v_cantidad_administradores INT;
    v_cantidad_recepcionistas INT;
BEGIN
    -- Verificar que el cargo del personal sea válido
    IF NEW.cargoPersonal NOT IN ('Administrador', 'Recepcionista', 'Mantenimiento') THEN
        RAISE EXCEPTION 'El cargo del personal debe ser Administrador, Recepcionista o Mantenimiento.';
    END IF;

    -- Contar la cantidad de administradores y recepcionistas existentes
    SELECT COUNT(*) INTO v_cantidad_administradores
    FROM Personal WHERE cargoPersonal = 'Administrador' AND idPersonal <> NEW.idPersonal;

    SELECT COUNT(*) INTO v_cantidad_recepcionistas
    FROM Personal WHERE cargoPersonal = 'Recepcionista' AND idPersonal <> NEW.idPersonal;

    IF NEW.cargoPersonal = 'Administrador' AND v_cantidad_administradores >= 1 THEN
        RAISE EXCEPTION 'No se puede asignar el cargo de Administrador: ya existe uno.';
    END IF;

    IF NEW.cargoPersonal = 'Recepcionista' AND v_cantidad_recepcionistas >= 2 THEN
        RAISE EXCEPTION 'No se puede asignar el cargo de Recepcionista: ya existen dos.';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tg_roles_trabajadores
BEFORE INSERT OR UPDATE ON Personal
FOR EACH ROW
EXECUTE FUNCTION fn_tg_roles_trabajadores();





CREATE OR REPLACE FUNCTION fn_tg_eliminar_residente()
RETURNS TRIGGER AS $$
DECLARE
    v_contratos_vigentes INT;
    v_deudas_pendientes INT;
    v_fecha_ultimo_contrato DATE;
BEGIN
    -- Verificar si el residente tiene contratos vigentes
    SELECT COUNT(*) INTO v_contratos_vigentes
    FROM ContratosOcupacion
    WHERE idResidente = OLD.idResidente AND estadoContrato = 'Vigente';

    IF v_contratos_vigentes > 0 THEN
        RAISE EXCEPTION 'El residente % no puede ser eliminado: tiene contratos vigentes.', OLD.idResidente;
    END IF;

    -- Verificar si el residentE Lleva al menos tres meses sin renovar un contrato
    SELECT MAX(fechaFin) INTO v_fecha_ultimo_contrato
    FROM ContratosOcupacion
    WHERE idResidente = OLD.idResidente;

    IF v_fecha_ultimo_contrato IS NOT NULL AND v_fecha_ultimo_contrato > CURRENT_DATE - INTERVAL '3 months' THEN
        RAISE EXCEPTION 'El residente % no puede ser eliminado: debe llevar al menos tres meses sin renovar un contrato.', OLD.idResidente;
    END IF;
    
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;    

CREATE TRIGGER tg_eliminar_residente
BEFORE DELETE ON Residentes
FOR EACH ROW
EXECUTE FUNCTION fn_tg_eliminar_residente();




-- ==========================================================================
-- -- MANTENER INVITADO (Límites, contratos vigentes y control de salidas) --
-- ==========================================================================


CREATE OR REPLACE FUNCTION fn_tg_ins_invitado()
RETURNS TRIGGER AS $$
DECLARE
    v_estado_contrato VARCHAR(20);
    v_cant_invitados INT;   
BEGIN
    -- 1. Verificar que el contrato asociado esté en estado 'Vigente'
    SELECT estadoContrato INTO v_estado_contrato FROM ContratosOcupacion WHERE idContrato = NEW.idContrato;
    IF v_estado_contrato != 'Vigente' THEN
        RAISE EXCEPTION 'El contrato asociado no se encuentra vigente.';
    END IF;
    -- 2. Validar límite máximo de dos invitados simultáneos en el mismo contrato
    SELECT COUNT(*) INTO v_cant_invitados
    FROM Invitado 
    WHERE idContrato = NEW.idContrato AND EstadoInvitado = 'En las instalaciones'; 
    IF v_cant_invitados >= 2 THEN
        RAISE EXCEPTION 'Se ha alcanzado el límite máximo de 2 invitados activos simultáneamente para este contrato.';
    END IF; 
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tg_ins_invitado
BEFORE INSERT ON Invitados
FOR EACH ROW
EXECUTE FUNCTION fn_tg_ins_invitado();

-- Despues de registrar al inivtado automaticamente se registra la fecha y hora del ingreso y estado cambia a en las instalaciones.tg_invtado_ingresado(tg.autoamtizacion)

CREATE OR REPLACE FUNCTION fn_tg_invitado_ingresado()
RETURNS TRIGGER AS $$
BEGIN
    -- Registrar automáticamente fecha/hora de ingreso y estado inicial
    NEW.fechaHoraIngreso := COALESCE(NEW.fechaHoraIngreso, CURRENT_TIMESTAMP);
    NEW.EstadoInvitado := 'En las instalaciones';
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tg_invitado_ingresado
BEFORE INSERT ON Invitados
FOR EACH ROW
EXECUTE FUNCTION fn_tg_invitado_ingresado();


CREATE OR REPLACE FUNCTION fn_tg_invitado_fuera()
RETURNS TRIGGER AS $$
BEGIN
    -- Si se actualiza la fecha de hora de salida, cambiar estado automático a 'Retirado'
    IF NEW.fechaHoraSalida IS NOT NULL AND OLD.fechaHoraSalida IS NULL THEN
        IF NEW.fechaHoraSalida <= NEW.fechaHoraIngreso THEN
            RAISE EXCEPTION 'La hora de salida debe ser estrictamente mayor a la hora de ingreso.';
        END IF;
        NEW.EstadoInvitado := 'Retirado';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tg_invitado_fuera   
BEFORE UPDATE ON Invitados
FOR EACH ROW
EXECUTE FUNCTION fn_tg_invitado_fuera();


CREATE OR REPLACE FUNCTION fn_tg_ele_invitado()
RETURNS TRIGGER AS $$   
DECLARE
    v_estado_invitado VARCHAR(25);
BEGIN
    -- Verificar que el invitado esté en estado 'Cancelado' antes de eliminar
    SELECT EstadoInvitado INTO v_estado_invitado FROM Invitados WHERE idInvitado = OLD.idInvitado;
    IF v_estado_invitado <> 'Cancelado' THEN
        RAISE EXCEPTION 'Solo se pueden eliminar invitados que estén en estado Cancelado.';
    END IF;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tg_ele_invitado
BEFORE DELETE ON Invitados
FOR EACH ROW    
EXECUTE FUNCTION fn_tg_ele_invitado();






-- ==========================================
-- -- MANTENER HABITACIÓN --    
-- ==========================================


CREATE OR REPLACE FUNCTION fn_tg_adicionar_habitacion()
RETURNS TRIGGER AS $$
BEGIN
    NEW.estadoHabitacion := 'Disponible';
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tg_adicionar_habitacion
BEFORE INSERT ON Habitaciones
FOR EACH ROW
EXECUTE FUNCTION fn_tg_adicionar_habitacion();

CREATE OR REPLACE FUNCTION fn_tg_validar_reduccion_capacidad()
RETURNS TRIGGER AS $$
DECLARE
    v_habitaciones_afectadas NUMERIC;
BEGIN
    IF NEW.capacidad_maxima < OLD.capacidad_maxima THEN

        SELECT COUNT(*) INTO v_habitaciones_afectadas
        FROM (
            SELECT h.idHabitacion
            FROM Habitaciones h
            JOIN ContratosOcupacion c
            ON c.idHabitacion = h.idHabitacion
            AND c.estadoContrato = 'Vigente'
            WHERE h.idTipoHabitacion = NEW.idTipoHabitacion
            GROUP BY h.idHabitacion
            HAVING COUNT(*) > NEW.capacidad_maxima
        ) AS excedidas;

        IF v_habitaciones_afectadas > 0 THEN
            RAISE EXCEPTION 'No se puede reducir la capacidad: hay habitaciones que ya superan el nuevo límite.';
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tg_validar_reduccion_capacidad
BEFORE UPDATE ON TiposdeHabitaciones
FOR EACH ROW
EXECUTE FUNCTION fn_tg_validar_reduccion_capacidad();


CREATE OR REPLACE FUNCTION fn_tg_eliminar_habitacion()
RETURNS TRIGGER AS $$
DECLARE
    v_contratos_activos NUMERIC;
    v_inventario_asociado NUMERIC;
BEGIN
    -- Verificar si hay contratos activos asociados a la habitación
    SELECT COUNT(*) INTO v_contratos_activos
    FROM ContratosOcupacion
    WHERE idHabitacion = OLD.idHabitacion AND estadoContrato = 'Vigente';

    IF v_contratos_activos > 0 THEN
        RAISE EXCEPTION 'No se puede eliminar la habitación: existen contratos activos asociados.';
    END IF;

    -- Verificar si hay inventario asociado a la habitación
    SELECT COUNT(*) INTO v_inventario_asociado
    FROM InventariosHabitaciones
    WHERE idHabitacion = OLD.idHabitacion;

    IF v_inventario_asociado > 0 THEN
        RAISE EXCEPTION 'No se puede eliminar la habitación: existen inventarios asociados.';
    END IF;

    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tg_eliminar_habitacion
BEFORE DELETE ON Habitaciones
FOR EACH ROW
EXECUTE FUNCTION fn_tg_eliminar_habitacion();

CREATE OR REPLACE FUNCTION fn_tg_eliminar_tipo_habitacion()
RETURNS TRIGGER AS $$
DECLARE
    v_habitaciones_asociadas NUMERIC;
BEGIN
    -- Verificar si hay habitaciones asociadas al tipo de habitación    
    SELECT COUNT(*) INTO v_habitaciones_asociadas
    FROM Habitaciones
    WHERE idTipoHabitacion = OLD.idTipoHabitacion;    

    IF v_habitaciones_asociadas > 0 THEN
        RAISE EXCEPTION 'No se puede eliminar el tipo de habitación: existen habitaciones asociadas.';
    END IF;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tg_eliminar_tipo_habitacion
BEFORE DELETE ON TiposdeHabitaciones
FOR EACH ROW
EXECUTE FUNCTION fn_tg_eliminar_tipo_habitacion();