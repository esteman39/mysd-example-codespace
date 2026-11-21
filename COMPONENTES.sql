-- ============================================================================
-- COMPONENTES:
--   PROPIEDADES, HABITACIONES, PERSONAS, CONTRATOS, RESERVAS, INVITADOS
-- ----------------------------------------------------------------------------



-- ============================================================================
-- PAQUETE PROPIEDADES  (incluye espacios comunes)
-- ============================================================================
CREATE SCHEMA IF NOT EXISTS propiedades;

-- AD_PROPIEDAD: formato de CHIP y direccion lo validan los dominios.
CREATE OR REPLACE PROCEDURE propiedades.ad_propiedad(
    p_id         VARCHAR,
    p_nombre     VARCHAR,
    p_direccion  VARCHAR,
    p_ciudad     VARCHAR)
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public, pg_temp AS $$
BEGIN
    INSERT INTO Propiedades
        (idPropiedad, nombrePropiedad, direccionPropiedad, ciudadPropiedad)
    VALUES
        (p_id, p_nombre, p_direccion, p_ciudad);
END;
$$;

-- MOD_PROPIEDAD: solo el nombre es modificable (trg_actualizar_propiedad
-- bloquea cualquier cambio de CHIP, direccion o ciudad).
CREATE OR REPLACE PROCEDURE propiedades.mod_propiedad(p_id VARCHAR, p_nombre VARCHAR)
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public, pg_temp AS $$
BEGIN
    UPDATE Propiedades SET nombrePropiedad = p_nombre WHERE idPropiedad = p_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'La propiedad % no existe.', p_id;
    END IF;
END;
$$;

-- ELI_PROPIEDAD: las FK (RESTRICT) impiden eliminarla si tiene habitaciones o espacios.
-- CORREGIDO: el mensaje menciona ambos casos (antes solo espacios comunes).
CREATE OR REPLACE PROCEDURE propiedades.eli_propiedad(p_id VARCHAR)
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public, pg_temp AS $$
BEGIN
    DELETE FROM Propiedades WHERE idPropiedad = p_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'La propiedad % no existe.', p_id;
    END IF;
EXCEPTION
    WHEN foreign_key_violation THEN
        RAISE EXCEPTION 'No se puede eliminar la propiedad %: tiene habitaciones o espacios comunes asociados.', p_id;
END;
$$;

CREATE OR REPLACE FUNCTION propiedades.co_propiedades()
RETURNS SETOF Propiedades
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public, pg_temp AS $$
    SELECT * FROM Propiedades ORDER BY ciudadPropiedad, nombrePropiedad;
$$;

CREATE OR REPLACE FUNCTION propiedades.co_propiedades_ciudad(p_ciudad VARCHAR)
RETURNS SETOF Propiedades
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public, pg_temp AS $$
    SELECT * FROM Propiedades
    WHERE LOWER(ciudadPropiedad) = LOWER(p_ciudad)
    ORDER BY nombrePropiedad;
$$;

-- AD_ESPACIO: el estado inicial 'Disponible' lo asigna el DEFAULT (Atributos.sql).
-- El aforo debe ser > 0 (dominio TCantidad).
CREATE OR REPLACE PROCEDURE propiedades.ad_espacio(
    p_id         VARCHAR,
    p_nombre     VARCHAR,
    p_aforo      INTEGER,
    p_propiedad  VARCHAR)
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public, pg_temp AS $$
BEGIN
    INSERT INTO EspaciosComunes (idEspacio, nombreEspacio, aforoEspacio, idPropiedad)
    VALUES (p_id, p_nombre, p_aforo, p_propiedad);
END;
$$;

-- MOD_ESPACIO: los estados validos los fija el dominio TEstadoEspacio.
CREATE OR REPLACE PROCEDURE propiedades.mod_espacio(
    p_id      VARCHAR,
    p_nombre  VARCHAR DEFAULT NULL,
    p_aforo   INTEGER DEFAULT NULL,
    p_estado  VARCHAR DEFAULT NULL)
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public, pg_temp AS $$
BEGIN
    UPDATE EspaciosComunes
       SET nombreEspacio       = COALESCE(p_nombre, nombreEspacio),
           aforoEspacio        = COALESCE(p_aforo, aforoEspacio),
           estadoActualEspacio = COALESCE(p_estado, estadoActualEspacio)
     WHERE idEspacio = p_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'El espacio común % no existe.', p_id;
    END IF;
END;
$$;

-- ELI_ESPACIO: no se elimina si tiene reservas (lo impide la FK; aqui solo se traduce el error).
CREATE OR REPLACE PROCEDURE propiedades.eli_espacio(p_id VARCHAR)
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public, pg_temp AS $$
BEGIN
    DELETE FROM EspaciosComunes WHERE idEspacio = p_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'El espacio común % no existe.', p_id;
    END IF;
EXCEPTION
    WHEN foreign_key_violation THEN
        RAISE EXCEPTION 'No se puede eliminar el espacio %: tiene reservas asociadas.', p_id;
END;
$$;

CREATE OR REPLACE FUNCTION propiedades.co_espacios_propiedad(p_propiedad VARCHAR)
RETURNS SETOF EspaciosComunes
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public, pg_temp AS $$
    SELECT * FROM EspaciosComunes
    WHERE idPropiedad = p_propiedad
    ORDER BY nombreEspacio;
$$;


-- ============================================================================
-- PAQUETE HABITACIONES  (incluye tipos de habitacion e inventario)
-- ============================================================================
CREATE SCHEMA IF NOT EXISTS habitaciones;

-- AD_HABITACION: nace 'Disponible' (tg_adicionar_habitacion). Propiedad y tipo deben existir (FK).
-- CORREGIDO: el tipo es el texto del catalogo (Individual, Doble, Compartida, Suite).
CREATE OR REPLACE PROCEDURE habitaciones.ad_habitacion(
    p_id         VARCHAR,
    p_propiedad  VARCHAR,
    p_tipo       VARCHAR)
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public, pg_temp AS $$
BEGIN
    INSERT INTO Habitaciones (idHabitacion, idPropiedad, tipoHabitacion)
    VALUES (p_id, p_propiedad, p_tipo);
END;
$$;

-- MOD_HABITACION: el estado 'Ocupada' solo lo gestionan los contratos (tg_contrato_confirmado).
CREATE OR REPLACE PROCEDURE habitaciones.mod_habitacion(
    p_id      VARCHAR,
    p_tipo    VARCHAR DEFAULT NULL,
    p_estado  VARCHAR DEFAULT NULL)
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public, pg_temp AS $$
DECLARE
    v_actual VARCHAR(20);
BEGIN
    SELECT estadoHabitacion INTO v_actual
    FROM Habitaciones
    WHERE idHabitacion = p_id
    FOR UPDATE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'La habitación % no existe.', p_id;
    END IF;

    IF p_estado IS NOT NULL
       AND p_estado IS DISTINCT FROM v_actual
       AND (p_estado = 'Ocupada' OR v_actual = 'Ocupada') THEN
        RAISE EXCEPTION 'El estado Ocupada solo lo gestionan los contratos.';
    END IF;

    UPDATE Habitaciones
       SET tipoHabitacion   = COALESCE(p_tipo, tipoHabitacion),
           estadoHabitacion = COALESCE(p_estado, estadoHabitacion)
     WHERE idHabitacion = p_id;
END;
$$;

-- ELI_HABITACION: las FK (RESTRICT) impiden eliminarla si tiene contratos o inventario.
CREATE OR REPLACE PROCEDURE habitaciones.eli_habitacion(p_id VARCHAR)
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public, pg_temp AS $$
BEGIN
    DELETE FROM Habitaciones WHERE idHabitacion = p_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'La habitación % no existe.', p_id;
    END IF;
EXCEPTION
    WHEN foreign_key_violation THEN
        RAISE EXCEPTION 'No se puede eliminar la habitación %: tiene contratos o inventario asociados.', p_id;
END;
$$;

CREATE OR REPLACE FUNCTION habitaciones.co_habitaciones()
RETURNS SETOF Habitaciones
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public, pg_temp AS $$
    SELECT * FROM Habitaciones ORDER BY idPropiedad, idHabitacion;
$$;

-- Usa la vista v_habitaciones_disponibles (Vistas.sql).
CREATE OR REPLACE FUNCTION habitaciones.co_habitaciones_disponibles()
RETURNS SETOF v_habitaciones_disponibles
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public, pg_temp AS $$
    SELECT * FROM v_habitaciones_disponibles;
$$;

-- Tipos de habitacion. CORREGIDO: la llave es el nombre del catalogo (dominio TTipoHabitacion),
-- por eso ad_tipo_habitacion recibe el id (antes lo generaba una columna identity que no existe).
CREATE OR REPLACE PROCEDURE habitaciones.ad_tipo_habitacion(
    p_id           VARCHAR,
    p_nombre       VARCHAR,
    p_descripcion  VARCHAR,
    p_capacidad    INTEGER,
    p_tarifa       NUMERIC,
    p_modalidad    VARCHAR)
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public, pg_temp AS $$
BEGIN
    INSERT INTO TiposDeHabitaciones
        (idTipoHabitacion, nombreTipoHabitacion, descripcionTipoHabitacion,
         capacidadMaxima, tarifaBase, modalidad)
    VALUES
        (p_id, p_nombre, p_descripcion, p_capacidad, p_tarifa, p_modalidad);
END;
$$;

CREATE OR REPLACE PROCEDURE habitaciones.mod_tipo_habitacion(
    p_id           VARCHAR,
    p_descripcion  VARCHAR DEFAULT NULL,
    p_capacidad    INTEGER DEFAULT NULL,
    p_tarifa       NUMERIC DEFAULT NULL,
    p_modalidad    VARCHAR DEFAULT NULL)
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public, pg_temp AS $$
BEGIN
    UPDATE TiposDeHabitaciones
       SET descripcionTipoHabitacion = COALESCE(p_descripcion, descripcionTipoHabitacion),
           capacidadMaxima           = COALESCE(p_capacidad, capacidadMaxima),
           tarifaBase                = COALESCE(p_tarifa, tarifaBase),
           modalidad                 = COALESCE(p_modalidad, modalidad)
     WHERE idTipoHabitacion = p_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'El tipo de habitación % no existe.', p_id;
    END IF;
END;
$$;

-- ELI_TIPO_HABITACION: la FK (RESTRICT) impide eliminarlo si hay habitaciones de ese tipo.
CREATE OR REPLACE PROCEDURE habitaciones.eli_tipo_habitacion(p_id VARCHAR)
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public, pg_temp AS $$
BEGIN
    DELETE FROM TiposDeHabitaciones WHERE idTipoHabitacion = p_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'El tipo de habitación % no existe.', p_id;
    END IF;
EXCEPTION
    WHEN foreign_key_violation THEN
        RAISE EXCEPTION 'No se puede eliminar el tipo de habitación %: existen habitaciones de ese tipo.', p_id;
END;
$$;

CREATE OR REPLACE FUNCTION habitaciones.co_tipos_habitacion()
RETURNS SETOF TiposDeHabitaciones
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public, pg_temp AS $$
    SELECT * FROM TiposDeHabitaciones ORDER BY nombreTipoHabitacion;
$$;

-- Inventario. La regla "el prefijo de idInventario coincide con la categoria"
-- la garantiza CHK_Inventario_Prefijo (Tuplas.sql).
CREATE OR REPLACE PROCEDURE habitaciones.ad_inventario(
    p_id              VARCHAR,
    p_nombre          VARCHAR,
    p_categoria       VARCHAR,
    p_descripcion     VARCHAR,
    p_estado_inicial  VARCHAR,
    p_habitacion      VARCHAR)
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public, pg_temp AS $$
BEGIN
    INSERT INTO InventariosHabitaciones
        (idInventario, nombreActivo, categoriaActivo, descripcionActivo,
         estadoInicial, idHabitacion)
    VALUES
        (p_id, p_nombre, p_categoria, p_descripcion,
         p_estado_inicial, p_habitacion);
END;
$$;

CREATE OR REPLACE PROCEDURE habitaciones.mod_inventario(p_id VARCHAR, p_estado_final VARCHAR)
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public, pg_temp AS $$
BEGIN
    UPDATE InventariosHabitaciones
       SET estadoFinal = p_estado_final
     WHERE idInventario = p_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'El activo % no existe en el inventario.', p_id;
    END IF;
END;
$$;

CREATE OR REPLACE PROCEDURE habitaciones.eli_inventario(p_id VARCHAR)
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public, pg_temp AS $$
BEGIN
    DELETE FROM InventariosHabitaciones WHERE idInventario = p_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'El activo % no existe en el inventario.', p_id;
    END IF;
END;
$$;

CREATE OR REPLACE FUNCTION habitaciones.co_inventario_habitacion(p_habitacion VARCHAR)
RETURNS SETOF InventariosHabitaciones
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public, pg_temp AS $$
    SELECT * FROM InventariosHabitaciones
    WHERE idHabitacion = p_habitacion
    ORDER BY categoriaActivo, nombreActivo;
$$;


-- ============================================================================
-- PAQUETE PERSONAS  (personas, residentes, personal y contactos de emergencia)
-- ============================================================================
CREATE SCHEMA IF NOT EXISTS personas;

-- AD_PERSONA / MOD_PERSONA
-- El documento (idPersona, TipoIdentificacion) no se modifica:
-- tg_restricciones_actualizacion lo impide, y por eso no es parametro.
CREATE OR REPLACE PROCEDURE personas.ad_persona(
    p_id        VARCHAR,
    p_nombre    VARCHAR,
    p_tipo_id   VARCHAR,
    p_telefono  VARCHAR,
    p_correo    VARCHAR)
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public, pg_temp AS $$
BEGIN
    INSERT INTO Personas
        (idPersona, nombrePersona, TipoIdentificacion, telefonoPersona, correoPersona)
    VALUES
        (p_id, p_nombre, p_tipo_id, p_telefono, p_correo);
END;
$$;

CREATE OR REPLACE PROCEDURE personas.mod_persona(
    p_id        VARCHAR,
    p_nombre    VARCHAR DEFAULT NULL,
    p_telefono  VARCHAR DEFAULT NULL,
    p_correo    VARCHAR DEFAULT NULL)
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public, pg_temp AS $$
BEGIN
    UPDATE Personas
       SET nombrePersona   = COALESCE(p_nombre, nombrePersona),
           telefonoPersona = COALESCE(p_telefono, telefonoPersona),
           correoPersona   = COALESCE(p_correo, correoPersona)
     WHERE idPersona = p_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'La persona % no existe.', p_id;
    END IF;
END;
$$;

CREATE OR REPLACE FUNCTION personas.co_personas()
RETURNS SETOF Personas
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public, pg_temp AS $$
    SELECT * FROM Personas ORDER BY nombrePersona;
$$;

-- Residentes. La persona debe existir antes (FK a Personas).
-- CORREGIDO: ELI_RESIDENTE ya no borra los contactos a mano: FK_ContactosEmergencia_Residentes
-- es ON DELETE CASCADE. Si el residente tiene contratos, la FK RESTRICT lo impide.
CREATE OR REPLACE PROCEDURE personas.ad_residente(p_persona VARCHAR)
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public, pg_temp AS $$
BEGIN
    INSERT INTO Residentes (idResidente) VALUES (p_persona);
END;
$$;

CREATE OR REPLACE PROCEDURE personas.eli_residente(p_id VARCHAR)
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public, pg_temp AS $$
BEGIN
    DELETE FROM Residentes WHERE idResidente = p_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'El residente % no existe.', p_id;
    END IF;
EXCEPTION
    WHEN foreign_key_violation THEN
        RAISE EXCEPTION 'No se puede eliminar el residente %: tiene contratos asociados.', p_id;
END;
$$;

CREATE OR REPLACE FUNCTION personas.co_residentes()
RETURNS TABLE (idResidente VARCHAR, nombrePersona VARCHAR, TipoIdentificacion VARCHAR,
               telefonoPersona VARCHAR, correoPersona VARCHAR)
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public, pg_temp AS $$
    SELECT r.idResidente, p.nombrePersona, p.TipoIdentificacion,
           p.telefonoPersona, p.correoPersona
    FROM Residentes r
    JOIN Personas p ON p.idPersona = r.idResidente
    ORDER BY p.nombrePersona;
$$;

-- Personal. Reglas de cargo (1 administrador, max. 2 recepcionistas): tg_roles_trabajadores.
CREATE OR REPLACE PROCEDURE personas.ad_personal(
    p_persona  VARCHAR,
    p_cargo    VARCHAR,
    p_salario  NUMERIC)
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public, pg_temp AS $$
BEGIN
    INSERT INTO Personal (idPersonal, cargoPersonal, salarioBase)
    VALUES (p_persona, p_cargo, p_salario);
END;
$$;

CREATE OR REPLACE PROCEDURE personas.mod_personal(
    p_id       VARCHAR,
    p_cargo    VARCHAR DEFAULT NULL,
    p_salario  NUMERIC DEFAULT NULL)
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public, pg_temp AS $$
BEGIN
    UPDATE Personal
       SET cargoPersonal = COALESCE(p_cargo, cargoPersonal),
           salarioBase   = COALESCE(p_salario, salarioBase)
     WHERE idPersonal = p_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'El empleado % no existe.', p_id;
    END IF;
END;
$$;

-- Usa la vista v_personal_publico (sin salario).
CREATE OR REPLACE FUNCTION personas.co_personal_cargo(p_cargo VARCHAR)
RETURNS SETOF v_personal_publico
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public, pg_temp AS $$
    SELECT * FROM v_personal_publico
    WHERE cargoPersonal = p_cargo
    ORDER BY nombrePersona;
$$;

-- Contactos de emergencia.
-- AD_CONTACTO: tg_agregar_contacto (un solo principal), tg_contacto_principal
-- (el primero queda principal) y tg_max_contactos (maximo 2).
CREATE OR REPLACE PROCEDURE personas.ad_contacto(
    p_contacto    VARCHAR,
    p_residente   VARCHAR,
    p_parentesco  VARCHAR,
    p_principal   BOOLEAN DEFAULT FALSE)
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public, pg_temp AS $$
BEGIN
    INSERT INTO ContactosEmergencia
        (idContactoEmergencia, idResidente, parentescoContacto, esPrincipal)
    VALUES
        (p_contacto, p_residente, p_parentesco, p_principal);
END;
$$;

-- MOD_CONTACTO: si se marca como principal, los demas contactos del residente
-- dejan de serlo (decision de negocio: el principal se "traspasa").
CREATE OR REPLACE PROCEDURE personas.mod_contacto(
    p_contacto    VARCHAR,
    p_residente   VARCHAR,
    p_parentesco  VARCHAR DEFAULT NULL,
    p_principal   BOOLEAN DEFAULT NULL)
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public, pg_temp AS $$
BEGIN
    IF p_principal IS TRUE THEN
        UPDATE ContactosEmergencia
           SET esPrincipal = FALSE
         WHERE idResidente = p_residente
           AND idContactoEmergencia <> p_contacto
           AND esPrincipal;
    END IF;

    UPDATE ContactosEmergencia
       SET parentescoContacto = COALESCE(p_parentesco, parentescoContacto),
           esPrincipal        = COALESCE(p_principal, esPrincipal)
     WHERE idContactoEmergencia = p_contacto
       AND idResidente = p_residente;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'El contacto % no existe para el residente %.', p_contacto, p_residente;
    END IF;
END;
$$;

CREATE OR REPLACE PROCEDURE personas.eli_contacto(p_contacto VARCHAR, p_residente VARCHAR)
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public, pg_temp AS $$
BEGIN
    DELETE FROM ContactosEmergencia
     WHERE idContactoEmergencia = p_contacto
       AND idResidente = p_residente;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'El contacto % no existe para el residente %.', p_contacto, p_residente;
    END IF;
END;
$$;

CREATE OR REPLACE FUNCTION personas.co_contactos_residente(p_residente VARCHAR)
RETURNS TABLE (idContactoEmergencia VARCHAR, nombrePersona VARCHAR, telefonoPersona VARCHAR,
               parentescoContacto VARCHAR, esPrincipal BOOLEAN)
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public, pg_temp AS $$
    SELECT ce.idContactoEmergencia, p.nombrePersona, p.telefonoPersona,
           ce.parentescoContacto, ce.esPrincipal
    FROM ContactosEmergencia ce
    JOIN Personas p ON p.idPersona = ce.idContactoEmergencia
    WHERE ce.idResidente = p_residente
    ORDER BY ce.esPrincipal DESC, p.nombrePersona;
$$;


-- ============================================================================
-- PAQUETE CONTRATOS
-- ============================================================================
CREATE SCHEMA IF NOT EXISTS contratos;

-- AD_CONTRATO
-- Reglas (en triggers/CHECK): habitacion disponible, residente registrado,
-- personal Recepcionista o Administrador, fechaFin > fechaInicio y <= 1 anio.
-- CORREGIDO: el subtipo (largo / corto plazo) lo crea tg_asignacion_tcontrato al insertar el
-- contrato; este servicio NO lo inserta (se eliminaron los triggers duplicados de este archivo).
CREATE OR REPLACE PROCEDURE contratos.ad_contrato(
    p_id          VARCHAR,
    p_numero      VARCHAR,
    p_inicio      DATE,
    p_fin         DATE,
    p_valor       NUMERIC,
    p_estado      VARCHAR,
    p_habitacion  VARCHAR,
    p_residente   VARCHAR,
    p_personal    VARCHAR)
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public, pg_temp AS $$
BEGIN
    INSERT INTO ContratosOcupacion
        (idContrato, numeroContrato, fechaInicio, fechaFin, valorContrato,
         estadoContrato, idHabitacion, idResidente, idPersonal)
    VALUES
        (p_id, p_numero, p_inicio, p_fin, p_valor,
         p_estado, p_habitacion, p_residente, p_personal);
END;
$$;

-- MOD_CONTRATO
-- Convencion: un parametro NULL significa "no cambiar ese campo".
-- CORREGIDO: (1) un contrato Finalizado o Cancelado ya no cambia de estado;
--            (2) si cambia fechaFin de un contrato de corto plazo, se recalcula totalNoches.
CREATE OR REPLACE PROCEDURE contratos.mod_contrato(
    p_id      VARCHAR,
    p_fin     DATE    DEFAULT NULL,
    p_estado  VARCHAR DEFAULT NULL)
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public, pg_temp AS $$
DECLARE
    v_actual VARCHAR(20);
BEGIN
    SELECT estadoContrato INTO v_actual
    FROM ContratosOcupacion
    WHERE idContrato = p_id
    FOR UPDATE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'El contrato % no existe.', p_id;
    END IF;

    IF v_actual IN ('Finalizado', 'Cancelado')
       AND p_estado IS NOT NULL AND p_estado <> v_actual THEN
        RAISE EXCEPTION 'El contrato % está % y no puede cambiar de estado.', p_id, v_actual;
    END IF;

    UPDATE ContratosOcupacion
       SET fechaFin       = COALESCE(p_fin, fechaFin),
           estadoContrato = COALESCE(p_estado, estadoContrato)
     WHERE idContrato = p_id;

    IF p_fin IS NOT NULL THEN
        UPDATE ContratosCortoPlazo cc
           SET totalNoches = c.fechaFin - c.fechaInicio
          FROM ContratosOcupacion c
         WHERE cc.idContrato = p_id AND c.idContrato = p_id;
    END IF;
END;
$$;

-- ELI_CONTRATO
-- CORREGIDO: un solo DELETE. El subtipo, las politicas y las clausulas se eliminan por
-- CASCADE; si el contrato tiene invitados o reservas, la FK (RESTRICT) lo impide.
-- Si el contrato estaba vigente, tg_habitacion_libre libera la habitacion.
CREATE OR REPLACE PROCEDURE contratos.eli_contrato(p_id VARCHAR)
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public, pg_temp AS $$
BEGIN
    DELETE FROM ContratosOcupacion WHERE idContrato = p_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'El contrato % no existe.', p_id;
    END IF;
EXCEPTION
    WHEN foreign_key_violation THEN
        RAISE EXCEPTION 'No se puede eliminar el contrato %: tiene invitados o reservas asociados.', p_id;
END;
$$;

-- Consultas
CREATE OR REPLACE FUNCTION contratos.co_contratos()
RETURNS SETOF ContratosOcupacion
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public, pg_temp AS $$
    SELECT * FROM ContratosOcupacion ORDER BY fechaInicio DESC;
$$;

CREATE OR REPLACE FUNCTION contratos.co_contratos_residente(p_residente VARCHAR)
RETURNS SETOF ContratosOcupacion
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public, pg_temp AS $$
    SELECT * FROM ContratosOcupacion
    WHERE idResidente = p_residente
    ORDER BY fechaInicio DESC;
$$;

CREATE OR REPLACE FUNCTION contratos.co_contratos_estado(p_estado VARCHAR)
RETURNS SETOF ContratosOcupacion
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public, pg_temp AS $$
    SELECT * FROM ContratosOcupacion
    WHERE estadoContrato = p_estado
    ORDER BY fechaInicio DESC;
$$;

CREATE OR REPLACE FUNCTION contratos.co_contratos_habitacion(p_habitacion VARCHAR)
RETURNS SETOF ContratosOcupacion
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public, pg_temp AS $$
    SELECT * FROM ContratosOcupacion
    WHERE idHabitacion = p_habitacion
    ORDER BY fechaInicio DESC;
$$;

-- Politicas de cancelacion (solo corto plazo) y clausulas (solo largo plazo).
-- La restriccion la garantizan las FK hacia cada subtipo; aqui se traduce el error.
CREATE OR REPLACE PROCEDURE contratos.ad_politica(p_contrato VARCHAR, p_politica VARCHAR)
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public, pg_temp AS $$
BEGIN
    INSERT INTO TienePoliticas (idContrato, politicaCancelacion)
    VALUES (p_contrato, p_politica);
EXCEPTION
    WHEN foreign_key_violation THEN
        RAISE EXCEPTION 'El contrato % no existe o no es de corto plazo: no admite políticas de cancelación.', p_contrato;
    WHEN unique_violation THEN
        RAISE EXCEPTION 'La política indicada ya existe para el contrato %.', p_contrato;
END;
$$;

CREATE OR REPLACE PROCEDURE contratos.eli_politica(p_contrato VARCHAR, p_politica VARCHAR)
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public, pg_temp AS $$
BEGIN
    DELETE FROM TienePoliticas
     WHERE idContrato = p_contrato AND politicaCancelacion = p_politica;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'La política indicada no existe para el contrato %.', p_contrato;
    END IF;
END;
$$;

CREATE OR REPLACE PROCEDURE contratos.ad_clausula(p_contrato VARCHAR, p_clausula VARCHAR)
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public, pg_temp AS $$
BEGIN
    INSERT INTO TieneClausulas (idContrato, clausula)
    VALUES (p_contrato, p_clausula);
EXCEPTION
    WHEN foreign_key_violation THEN
        RAISE EXCEPTION 'El contrato % no existe o no es de largo plazo: no admite cláusulas.', p_contrato;
    WHEN unique_violation THEN
        RAISE EXCEPTION 'La cláusula indicada ya existe para el contrato %.', p_contrato;
END;
$$;

CREATE OR REPLACE PROCEDURE contratos.eli_clausula(p_contrato VARCHAR, p_clausula VARCHAR)
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public, pg_temp AS $$
BEGIN
    DELETE FROM TieneClausulas
     WHERE idContrato = p_contrato AND clausula = p_clausula;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'La cláusula indicada no existe para el contrato %.', p_contrato;
    END IF;
END;
$$;


-- ============================================================================
-- PAQUETE RESERVAS
-- ============================================================================
CREATE SCHEMA IF NOT EXISTS reservas;

-- AD_RESERVA
-- Reglas (en triggers/CHECK): espacio disponible, asistentes <= aforo, horaFin > horaInicio,
-- sin traslape, contrato vigente.
-- Supuesto: toda reserva nace 'Confirmada'.
CREATE OR REPLACE PROCEDURE reservas.ad_reserva(
    p_id           VARCHAR,
    p_fecha        DATE,
    p_hora_inicio  TIME,
    p_hora_fin     TIME,
    p_espacio      VARCHAR,
    p_cantidad     INTEGER,
    p_contrato     VARCHAR)
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public, pg_temp AS $$
BEGIN
    INSERT INTO ReservasEspacios
        (idReserva, fechaReserva, horaInicio, horaFin, idEspacio,
         cantidadPersonas, estadoReserva, idContrato)
    VALUES
        (p_id, p_fecha, p_hora_inicio, p_hora_fin, p_espacio,
         p_cantidad, 'Confirmada', p_contrato);
END;
$$;

-- MOD_RESERVA
-- Solo cambia el estado (no el horario), asi que no hay que revalidar traslapes.
-- Una reserva Cancelada no puede reactivarse.
CREATE OR REPLACE PROCEDURE reservas.mod_reserva(p_id VARCHAR, p_estado VARCHAR)
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public, pg_temp AS $$
DECLARE
    v_actual VARCHAR(20);
BEGIN
    SELECT estadoReserva INTO v_actual
    FROM ReservasEspacios
    WHERE idReserva = p_id
    FOR UPDATE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'La reserva % no existe.', p_id;
    END IF;

    IF v_actual = 'Cancelada' AND p_estado <> 'Cancelada' THEN
        RAISE EXCEPTION 'La reserva % está cancelada y no puede reactivarse; registre una nueva.', p_id;
    END IF;

    UPDATE ReservasEspacios SET estadoReserva = p_estado WHERE idReserva = p_id;
END;
$$;

-- ELI_RESERVA  (tg_eliminar_reserva exige estado 'Cancelada')
CREATE OR REPLACE PROCEDURE reservas.eli_reserva(p_id VARCHAR)
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public, pg_temp AS $$
BEGIN
    DELETE FROM ReservasEspacios WHERE idReserva = p_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'La reserva % no existe.', p_id;
    END IF;
END;
$$;

-- Consultas
CREATE OR REPLACE FUNCTION reservas.co_reservas()
RETURNS SETOF ReservasEspacios
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public, pg_temp AS $$
    SELECT * FROM ReservasEspacios ORDER BY fechaReserva DESC, horaInicio;
$$;

-- CORREGIDO: se compara por DIA (fechaReserva es TIMESTAMP).
CREATE OR REPLACE FUNCTION reservas.co_reservas_espacio(p_espacio VARCHAR, p_fecha DATE)
RETURNS SETOF ReservasEspacios
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public, pg_temp AS $$
    SELECT * FROM ReservasEspacios
    WHERE idEspacio = p_espacio AND fechaReserva::date = p_fecha
    ORDER BY horaInicio;
$$;

CREATE OR REPLACE FUNCTION reservas.co_reservas_contrato(p_contrato VARCHAR)
RETURNS SETOF ReservasEspacios
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public, pg_temp AS $$
    SELECT * FROM ReservasEspacios
    WHERE idContrato = p_contrato
    ORDER BY fechaReserva DESC, horaInicio;
$$;


-- ============================================================================
-- PAQUETE INVITADOS
-- ============================================================================
CREATE SCHEMA IF NOT EXISTS invitados;

-- AD_INVITADO
-- fechaHoraIngreso y EstadoInvitado los asigna tg_invitado_ingresado.
-- Reglas: contrato vigente y maximo 2 invitados activos (tg_ins_invitado).
CREATE OR REPLACE PROCEDURE invitados.ad_invitado(
    p_id         VARCHAR,
    p_nombre     VARCHAR,
    p_tipo_id    VARCHAR,
    p_documento  VARCHAR,
    p_contrato   VARCHAR,
    p_personal   VARCHAR)
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public, pg_temp AS $$
BEGIN
    INSERT INTO Invitados
        (idInvitado, nombreInvitado, TipoIdentificacion, documentoInvitado,
         idContrato, idPersonal_Registro)
    VALUES
        (p_id, p_nombre, p_tipo_id, p_documento,
         p_contrato, p_personal);
END;
$$;

-- MOD_INVITADO: registra la salida (por defecto, ahora).
-- CHK_Invitado_Fechas valida salida > ingreso y tg_invitado_fuera cambia el estado a 'Retirado'.
CREATE OR REPLACE PROCEDURE invitados.mod_invitado(
    p_id      VARCHAR,
    p_salida  TIMESTAMP DEFAULT LOCALTIMESTAMP)
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public, pg_temp AS $$
BEGIN
    UPDATE Invitados SET fechaHoraSalida = p_salida WHERE idInvitado = p_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'El invitado % no existe.', p_id;
    END IF;
END;
$$;

-- CAN_INVITADO (servicio adicional, agreguelo al UML)
-- Sin el, ELI_INVITADO nunca podria ejecutarse: ningun otro servicio deja a
-- un invitado en estado 'Cancelado', que es lo que exige tg_ele_invitado.
CREATE OR REPLACE PROCEDURE invitados.can_invitado(p_id VARCHAR)
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public, pg_temp AS $$
BEGIN
    UPDATE Invitados
       SET EstadoInvitado = 'Cancelado'
     WHERE idInvitado = p_id
       AND EstadoInvitado = 'En las instalaciones'
       AND fechaHoraSalida IS NULL;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'El invitado % no existe o ya no está en las instalaciones.', p_id;
    END IF;
END;
$$;

-- ELI_INVITADO  (tg_ele_invitado exige estado 'Cancelado')
CREATE OR REPLACE PROCEDURE invitados.eli_invitado(p_id VARCHAR)
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public, pg_temp AS $$
BEGIN
    DELETE FROM Invitados WHERE idInvitado = p_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'El invitado % no existe.', p_id;
    END IF;
END;
$$;

-- Consultas
CREATE OR REPLACE FUNCTION invitados.co_invitados()
RETURNS SETOF Invitados
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public, pg_temp AS $$
    SELECT * FROM Invitados ORDER BY fechaHoraIngreso DESC;
$$;

CREATE OR REPLACE FUNCTION invitados.co_invitados_activos()
RETURNS SETOF Invitados
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public, pg_temp AS $$
    SELECT * FROM Invitados
    WHERE EstadoInvitado = 'En las instalaciones'
    ORDER BY fechaHoraIngreso;
$$;

CREATE OR REPLACE FUNCTION invitados.co_invitados_contrato(p_contrato VARCHAR)
RETURNS SETOF Invitados
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public, pg_temp AS $$
    SELECT * FROM Invitados
    WHERE idContrato = p_contrato
    ORDER BY fechaHoraIngreso DESC;
$$;
