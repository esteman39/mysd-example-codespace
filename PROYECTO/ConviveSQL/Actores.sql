-- ============================================================================
-- ACTORES DEL SISTEMA (ESQUEMAS DE SEGURIDAD Y OPERACION)
-- ============================================================================

CREATE SCHEMA IF NOT EXISTS recepcionista;
CREATE SCHEMA IF NOT EXISTS administrador;
CREATE SCHEMA IF NOT EXISTS gerente;


-- ============================================================================
-- 1. RECEPCIONISTA
--    Operaciones diarias: consultas operativas, gestion de invitados, reservas
--    de espacios comunes, registro de personas/residentes y contratos.
-- ============================================================================

-- -------------------------
-- Consultas (Funciones)
-- -------------------------

-- p_propiedad NULL = todas las propiedades
CREATE OR REPLACE FUNCTION recepcionista.co_disponibilidad_habitaciones(p_propiedad VARCHAR DEFAULT NULL)
RETURNS SETOF v_disponibilidad_por_tipo
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public, pg_temp AS $$
    SELECT * FROM v_disponibilidad_por_tipo
    WHERE p_propiedad IS NULL OR idPropiedad = p_propiedad
    ORDER BY nombrePropiedad, nombreTipoHabitacion;
$$;

-- Reservas (no canceladas) de un dia, con el porcentaje de aforo; por defecto, hoy
CREATE OR REPLACE FUNCTION recepcionista.co_control_aforo(p_fecha DATE DEFAULT CURRENT_DATE)
RETURNS SETOF v_control_aforo_espacios
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public, pg_temp AS $$
    SELECT * FROM v_control_aforo_espacios
    WHERE fechaReserva::date = p_fecha
    ORDER BY nombreEspacio, horaInicio;
$$;

CREATE OR REPLACE FUNCTION recepcionista.co_invitados_activos()
RETURNS SETOF v_invitados_activos
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public, pg_temp AS $$
    SELECT * FROM v_invitados_activos ORDER BY fechaHoraIngreso;
$$;

-- -------------------------
-- Acciones Operativas (Procedimientos delegados a paquetes de dominio)
-- -------------------------

-- Gestion de Invitados
CREATE OR REPLACE PROCEDURE recepcionista.ad_invitado(
    p_id         VARCHAR,
    p_nombre     VARCHAR,
    p_tipo_id    VARCHAR,
    p_documento  VARCHAR,
    p_contrato   VARCHAR,
    p_personal   VARCHAR)
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public, invitados, pg_temp AS $$
BEGIN
    CALL invitados.ad_invitado(p_id, p_nombre, p_tipo_id, p_documento, p_contrato, p_personal);
END;
$$;

CREATE OR REPLACE PROCEDURE recepcionista.mod_invitado(
    p_id      VARCHAR,
    p_salida  TIMESTAMP DEFAULT LOCALTIMESTAMP)
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public, invitados, pg_temp AS $$
BEGIN
    CALL invitados.mod_invitado(p_id, p_salida);
END;
$$;

CREATE OR REPLACE PROCEDURE recepcionista.can_invitado(p_id VARCHAR)
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public, invitados, pg_temp AS $$
BEGIN
    CALL invitados.can_invitado(p_id);
END;
$$;

-- Gestion de Reservas de Espacios Comunes
CREATE OR REPLACE PROCEDURE recepcionista.ad_reserva(
    p_id           VARCHAR,
    p_fecha        DATE,
    p_hora_inicio  TIME,
    p_hora_fin     TIME,
    p_espacio      VARCHAR,
    p_cantidad     INTEGER,
    p_contrato     VARCHAR)
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public, reservas, pg_temp AS $$
BEGIN
    CALL reservas.ad_reserva(p_id, p_fecha, p_hora_inicio, p_hora_fin, p_espacio, p_cantidad, p_contrato);
END;
$$;

CREATE OR REPLACE PROCEDURE recepcionista.mod_reserva(p_id VARCHAR, p_estado VARCHAR)
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public, reservas, pg_temp AS $$
BEGIN
    CALL reservas.mod_reserva(p_id, p_estado);
END;
$$;

-- Gestion de Personas, Residentes y Contactos de Emergencia
CREATE OR REPLACE PROCEDURE recepcionista.ad_persona(
    p_id        VARCHAR,
    p_nombre    VARCHAR,
    p_tipo_id   VARCHAR,
    p_telefono  VARCHAR,
    p_correo    VARCHAR)
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public, personas, pg_temp AS $$
BEGIN
    CALL personas.ad_persona(p_id, p_nombre, p_tipo_id, p_telefono, p_correo);
END;
$$;

CREATE OR REPLACE PROCEDURE recepcionista.mod_persona(
    p_id        VARCHAR,
    p_nombre    VARCHAR DEFAULT NULL,
    p_telefono  VARCHAR DEFAULT NULL,
    p_correo    VARCHAR DEFAULT NULL)
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public, personas, pg_temp AS $$
BEGIN
    CALL personas.mod_persona(p_id, p_nombre, p_telefono, p_correo);
END;
$$;

CREATE OR REPLACE PROCEDURE recepcionista.ad_residente(p_persona VARCHAR)
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public, personas, pg_temp AS $$
BEGIN
    CALL personas.ad_residente(p_persona);
END;
$$;

CREATE OR REPLACE PROCEDURE recepcionista.ad_contacto(
    p_contacto    VARCHAR,
    p_residente   VARCHAR,
    p_parentesco  VARCHAR,
    p_principal   BOOLEAN DEFAULT FALSE)
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public, personas, pg_temp AS $$
BEGIN
    CALL personas.ad_contacto(p_contacto, p_residente, p_parentesco, p_principal);
END;
$$;

CREATE OR REPLACE PROCEDURE recepcionista.mod_contacto(
    p_contacto    VARCHAR,
    p_residente   VARCHAR,
    p_parentesco  VARCHAR DEFAULT NULL,
    p_principal   BOOLEAN DEFAULT NULL)
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public, personas, pg_temp AS $$
BEGIN
    CALL personas.mod_contacto(p_contacto, p_residente, p_parentesco, p_principal);
END;
$$;

-- Gestion de Contratos de Ocupacion
CREATE OR REPLACE PROCEDURE recepcionista.ad_contrato(
    p_id          VARCHAR,
    p_numero      VARCHAR,
    p_inicio      DATE,
    p_fin         DATE,
    p_valor       NUMERIC,
    p_estado      VARCHAR,
    p_habitacion  VARCHAR,
    p_residente   VARCHAR,
    p_personal    VARCHAR)
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public, contratos, pg_temp AS $$
BEGIN
    CALL contratos.ad_contrato(p_id, p_numero, p_inicio, p_fin, p_valor, p_estado, p_habitacion, p_residente, p_personal);
END;
$$;

CREATE OR REPLACE PROCEDURE recepcionista.mod_contrato(
    p_id      VARCHAR,
    p_fin     DATE    DEFAULT NULL,
    p_estado  VARCHAR DEFAULT NULL)
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public, contratos, pg_temp AS $$
BEGIN
    CALL contratos.mod_contrato(p_id, p_fin, p_estado);
END;
$$;


-- ============================================================================
-- 2. ADMINISTRADOR
--    Administracion operativa e infraestructura: habitaciones, inventarios,
--    espacios comunes, contratos (incl. politicas/clausulas), residentes y personal.
-- ============================================================================

-- -------------------------
-- Consultas (Funciones)
-- -------------------------

CREATE OR REPLACE FUNCTION administrador.co_disponibilidad_habitaciones(p_propiedad VARCHAR DEFAULT NULL)
RETURNS SETOF v_disponibilidad_por_tipo
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public, pg_temp AS $$
    SELECT * FROM v_disponibilidad_por_tipo
    WHERE p_propiedad IS NULL OR idPropiedad = p_propiedad
    ORDER BY nombrePropiedad, nombreTipoHabitacion;
$$;

-- p_habitacion NULL = todas las habitaciones
CREATE OR REPLACE FUNCTION administrador.co_inventario_habitacion(p_habitacion VARCHAR DEFAULT NULL)
RETURNS SETOF v_inventario_habitacion
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public, pg_temp AS $$
    SELECT * FROM v_inventario_habitacion
    WHERE p_habitacion IS NULL OR idHabitacion = p_habitacion
    ORDER BY idHabitacion, idInventario;
$$;

-- p_modalidad: 'Largo Plazo', 'Corto Plazo' o NULL (todas)
CREATE OR REPLACE FUNCTION administrador.co_contratos_vigentes(p_modalidad VARCHAR DEFAULT NULL)
RETURNS SETOF v_contratos_vigentes
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public, pg_temp AS $$
    SELECT * FROM v_contratos_vigentes
    WHERE p_modalidad IS NULL OR modalidad = p_modalidad
    ORDER BY modalidad, fechaInicio;
$$;

-- -------------------------
-- Acciones Administrativas (Procedimientos delegados)
-- -------------------------

-- Gestion de Habitaciones e Inventario
CREATE OR REPLACE PROCEDURE administrador.ad_habitacion(
    p_id         VARCHAR,
    p_propiedad  VARCHAR,
    p_tipo       VARCHAR)
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public, habitaciones, pg_temp AS $$
BEGIN
    CALL habitaciones.ad_habitacion(p_id, p_propiedad, p_tipo);
END;
$$;

CREATE OR REPLACE PROCEDURE administrador.mod_habitacion(
    p_id      VARCHAR,
    p_tipo    VARCHAR DEFAULT NULL,
    p_estado  VARCHAR DEFAULT NULL)
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public, habitaciones, pg_temp AS $$
BEGIN
    CALL habitaciones.mod_habitacion(p_id, p_tipo, p_estado);
END;
$$;

CREATE OR REPLACE PROCEDURE administrador.eli_habitacion(p_id VARCHAR)
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public, habitaciones, pg_temp AS $$
BEGIN
    CALL habitaciones.eli_habitacion(p_id);
END;
$$;

CREATE OR REPLACE PROCEDURE administrador.ad_inventario(
    p_id              VARCHAR,
    p_nombre          VARCHAR,
    p_categoria       VARCHAR,
    p_descripcion     VARCHAR,
    p_estado_inicial  VARCHAR,
    p_habitacion      VARCHAR)
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public, habitaciones, pg_temp AS $$
BEGIN
    CALL habitaciones.ad_inventario(p_id, p_nombre, p_categoria, p_descripcion, p_estado_inicial, p_habitacion);
END;
$$;

CREATE OR REPLACE PROCEDURE administrador.mod_inventario(p_id VARCHAR, p_estado_final VARCHAR)
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public, habitaciones, pg_temp AS $$
BEGIN
    CALL habitaciones.mod_inventario(p_id, p_estado_final);
END;
$$;

CREATE OR REPLACE PROCEDURE administrador.eli_inventario(p_id VARCHAR)
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public, habitaciones, pg_temp AS $$
BEGIN
    CALL habitaciones.eli_inventario(p_id);
END;
$$;

-- Gestion de Espacios Comunes
CREATE OR REPLACE PROCEDURE administrador.ad_espacio(
    p_id         VARCHAR,
    p_nombre     VARCHAR,
    p_aforo      INTEGER,
    p_propiedad  VARCHAR)
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public, propiedades, pg_temp AS $$
BEGIN
    CALL propiedades.ad_espacio(p_id, p_nombre, p_aforo, p_propiedad);
END;
$$;

CREATE OR REPLACE PROCEDURE administrador.mod_espacio(
    p_id      VARCHAR,
    p_nombre  VARCHAR DEFAULT NULL,
    p_aforo   INTEGER DEFAULT NULL,
    p_estado  VARCHAR DEFAULT NULL)
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public, propiedades, pg_temp AS $$
BEGIN
    CALL propiedades.mod_espacio(p_id, p_nombre, p_aforo, p_estado);
END;
$$;

CREATE OR REPLACE PROCEDURE administrador.eli_espacio(p_id VARCHAR)
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public, propiedades, pg_temp AS $$
BEGIN
    CALL propiedades.eli_espacio(p_id);
END;
$$;

-- Gestion de Contratos, Politicas y Clausulas
CREATE OR REPLACE PROCEDURE administrador.ad_contrato(
    p_id          VARCHAR,
    p_numero      VARCHAR,
    p_inicio      DATE,
    p_fin         DATE,
    p_valor       NUMERIC,
    p_estado      VARCHAR,
    p_habitacion  VARCHAR,
    p_residente   VARCHAR,
    p_personal    VARCHAR)
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public, contratos, pg_temp AS $$
BEGIN
    CALL contratos.ad_contrato(p_id, p_numero, p_inicio, p_fin, p_valor, p_estado, p_habitacion, p_residente, p_personal);
END;
$$;

CREATE OR REPLACE PROCEDURE administrador.mod_contrato(
    p_id      VARCHAR,
    p_fin     DATE    DEFAULT NULL,
    p_estado  VARCHAR DEFAULT NULL)
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public, contratos, pg_temp AS $$
BEGIN
    CALL contratos.mod_contrato(p_id, p_fin, p_estado);
END;
$$;

CREATE OR REPLACE PROCEDURE administrador.eli_contrato(p_id VARCHAR)
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public, contratos, pg_temp AS $$
BEGIN
    CALL contratos.eli_contrato(p_id);
END;
$$;

CREATE OR REPLACE PROCEDURE administrador.ad_politica(p_contrato VARCHAR, p_politica VARCHAR)
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public, contratos, pg_temp AS $$
BEGIN
    CALL contratos.ad_politica(p_contrato, p_politica);
END;
$$;

CREATE OR REPLACE PROCEDURE administrador.eli_politica(p_contrato VARCHAR, p_politica VARCHAR)
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public, contratos, pg_temp AS $$
BEGIN
    CALL contratos.eli_politica(p_contrato, p_politica);
END;
$$;

CREATE OR REPLACE PROCEDURE administrador.ad_clausula(p_contrato VARCHAR, p_clausula VARCHAR)
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public, contratos, pg_temp AS $$
BEGIN
    CALL contratos.ad_clausula(p_contrato, p_clausula);
END;
$$;

CREATE OR REPLACE PROCEDURE administrador.eli_clausula(p_contrato VARCHAR, p_clausula VARCHAR)
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public, contratos, pg_temp AS $$
BEGIN
    CALL contratos.eli_clausula(p_contrato, p_clausula);
END;
$$;

-- Gestion de Residentes, Contactos y Personal Operativo
CREATE OR REPLACE PROCEDURE administrador.eli_residente(p_id VARCHAR)
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public, personas, pg_temp AS $$
BEGIN
    CALL personas.eli_residente(p_id);
END;
$$;

CREATE OR REPLACE PROCEDURE administrador.eli_contacto(p_contacto VARCHAR, p_residente VARCHAR)
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public, personas, pg_temp AS $$
BEGIN
    CALL personas.eli_contacto(p_contacto, p_residente);
END;
$$;

CREATE OR REPLACE PROCEDURE administrador.eli_reserva(p_id VARCHAR)
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public, reservas, pg_temp AS $$
BEGIN
    CALL reservas.eli_reserva(p_id);
END;
$$;

CREATE OR REPLACE PROCEDURE administrador.eli_invitado(p_id VARCHAR)
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public, invitados, pg_temp AS $$
BEGIN
    CALL invitados.eli_invitado(p_id);
END;
$$;

CREATE OR REPLACE PROCEDURE administrador.ad_personal(
    p_persona  VARCHAR,
    p_cargo    VARCHAR,
    p_salario  NUMERIC)
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public, personas, pg_temp AS $$
BEGIN
    CALL personas.ad_personal(p_persona, p_cargo, p_salario);
END;
$$;

CREATE OR REPLACE PROCEDURE administrador.mod_personal(
    p_id       VARCHAR,
    p_cargo    VARCHAR DEFAULT NULL,
    p_salario  NUMERIC DEFAULT NULL)
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public, personas, pg_temp AS $$
BEGIN
    CALL personas.mod_personal(p_id, p_cargo, p_salario);
END;
$$;


-- ============================================================================
-- 3. GERENTE / DUENO
--    Gobierno estrategico: propiedades, catalogo y tarifas de tipos de habitacion,
--    personal y analitica gerencial.
-- ============================================================================

-- -------------------------
-- Consultas Gerenciales (Funciones)
-- -------------------------

-- Contratos que estuvieron activos en algun momento del periodo [p_inicio, p_fin]
CREATE OR REPLACE FUNCTION gerente.co_contratos_periodo(p_inicio DATE, p_fin DATE)
RETURNS TABLE (idContrato VARCHAR, numeroContrato VARCHAR, estadoContrato VARCHAR,
               residente VARCHAR, fechaInicio DATE, fechaFin DATE, valorContrato NUMERIC)
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public, pg_temp AS $$
    SELECT c.idContrato, c.numeroContrato, c.estadoContrato, per.nombrePersona,
           c.fechaInicio, c.fechaFin, c.valorContrato
    FROM ContratosOcupacion c
    JOIN Personas per ON per.idPersona = c.idResidente
    WHERE c.fechaInicio <= p_fin AND c.fechaFin >= p_inicio
    ORDER BY c.fechaInicio;
$$;

CREATE OR REPLACE FUNCTION gerente.co_demanda_espacios(p_propiedad VARCHAR DEFAULT NULL)
RETURNS SETOF v_demanda_espacios_franja
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public, pg_temp AS $$
    SELECT * FROM v_demanda_espacios_franja
    WHERE p_propiedad IS NULL OR idPropiedad = p_propiedad
    ORDER BY nombreEspacio, franja;
$$;

-- El modelo no registra gastos: es ingreso contratado, no rentabilidad
CREATE OR REPLACE FUNCTION gerente.co_ingresos_por_tipo()
RETURNS SETOF v_ingresos_por_tipo
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public, pg_temp AS $$
    SELECT * FROM v_ingresos_por_tipo ORDER BY ingresos_contratados DESC;
$$;

-- -------------------------
-- Acciones Estrategicas (Procedimientos delegados)
-- -------------------------

-- Gobierno de Propiedades
CREATE OR REPLACE PROCEDURE gerente.ad_propiedad(
    p_id         VARCHAR,
    p_nombre     VARCHAR,
    p_direccion  VARCHAR,
    p_ciudad     VARCHAR)
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public, propiedades, pg_temp AS $$
BEGIN
    CALL propiedades.ad_propiedad(p_id, p_nombre, p_direccion, p_ciudad);
END;
$$;

CREATE OR REPLACE PROCEDURE gerente.mod_propiedad(p_id VARCHAR, p_nombre VARCHAR)
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public, propiedades, pg_temp AS $$
BEGIN
    CALL propiedades.mod_propiedad(p_id, p_nombre);
END;
$$;

CREATE OR REPLACE PROCEDURE gerente.eli_propiedad(p_id VARCHAR)
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public, propiedades, pg_temp AS $$
BEGIN
    CALL propiedades.eli_propiedad(p_id);
END;
$$;

-- Catalogo y Tarifas de Tipos de Habitacion
CREATE OR REPLACE PROCEDURE gerente.ad_tipo_habitacion(
    p_id           VARCHAR,
    p_nombre       VARCHAR,
    p_descripcion  VARCHAR,
    p_capacidad    INTEGER,
    p_tarifa       NUMERIC,
    p_modalidad    VARCHAR)
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public, habitaciones, pg_temp AS $$
BEGIN
    CALL habitaciones.ad_tipo_habitacion(p_id, p_nombre, p_descripcion, p_capacidad, p_tarifa, p_modalidad);
END;
$$;

CREATE OR REPLACE PROCEDURE gerente.mod_tipo_habitacion(
    p_id           VARCHAR,
    p_descripcion  VARCHAR DEFAULT NULL,
    p_capacidad    INTEGER DEFAULT NULL,
    p_tarifa       NUMERIC DEFAULT NULL,
    p_modalidad    VARCHAR DEFAULT NULL)
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public, habitaciones, pg_temp AS $$
BEGIN
    CALL habitaciones.mod_tipo_habitacion(p_id, p_descripcion, p_capacidad, p_tarifa, p_modalidad);
END;
$$;

CREATE OR REPLACE PROCEDURE gerente.eli_tipo_habitacion(p_id VARCHAR)
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public, habitaciones, pg_temp AS $$
BEGIN
    CALL habitaciones.eli_tipo_habitacion(p_id);
END;
$$;

-- Contratacion y Ajustes Salariales de Personal
CREATE OR REPLACE PROCEDURE gerente.ad_personal(
    p_persona  VARCHAR,
    p_cargo    VARCHAR,
    p_salario  NUMERIC)
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public, personas, pg_temp AS $$
BEGIN
    CALL personas.ad_personal(p_persona, p_cargo, p_salario);
END;
$$;

CREATE OR REPLACE PROCEDURE gerente.mod_personal(
    p_id       VARCHAR,
    p_cargo    VARCHAR DEFAULT NULL,
    p_salario  NUMERIC DEFAULT NULL)
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public, personas, pg_temp AS $$
BEGIN
    CALL personas.mod_personal(p_id, p_cargo, p_salario);
END;
$$;
