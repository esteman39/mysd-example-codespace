-- =============================
-- --------- Actores -----------
-- =============================


CREATE SCHEMA IF NOT EXISTS recepcionista;
CREATE SCHEMA IF NOT EXISTS administrador;
-- CREATE SCHEMA IF NOT EXISTS gerente;

-- ============================================================================
-- RECEPCIONISTA
--   Caso de uso: Consulta de disponibilidad de habitaciones por tipo y propiedad
--   Caso de uso: Consulta de control de asistencia y aforo en espacios comunes
--   Caso de uso: Consulta de bitacora de invitados activos en el edificio
-- ============================================================================

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

-- ============================================================================
-- ADMINISTRADOR
--   Caso de uso: Consulta de disponibilidad de habitaciones por tipo y propiedad
--   Caso de uso: Consulta de inventario inicial y final por habitacion
--   Caso de uso: Consulta de contratos vigentes por modalidad
-- ============================================================================

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

-- ============================================================================
-- GERENTE
--   Caso de uso: Consultar los registros de contratos de un periodo dado
--   Caso de uso: Consultar la demanda de espacios comunes, con franjas horarias
--   Caso de uso: Consultar la rentabilidad por tipo de habitacion  (aqui: ingresos)
--
--   FUERA DE ALCANCE (el modelo no tiene tablas de pagos ni de gastos):
--     - egresos e ingresos en los meses de alto flujo
--     - estado de cartera vencida
--     - comparacion mensual entre ingresos por contratos y gastos operativos fijos
-- ============================================================================

-- Contratos que estuvieron activos en algun momento del periodo [p_inicio, p_fin]
--CREATE OR REPLACE FUNCTION gerente.co_contratos_periodo(p_inicio DATE, p_fin DATE)
--RETURNS TABLE (idContrato VARCHAR, numeroContrato VARCHAR, estadoContrato VARCHAR,
--               residente VARCHAR, fechaInicio DATE, fechaFin DATE, valorContrato NUMERIC)
--LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public, pg_temp AS $$
--    SELECT c.idContrato, c.numeroContrato, c.estadoContrato, per.nombrePersona,
--           c.fechaInicio, c.fechaFin, c.valorContrato
--    FROM ContratosOcupacion c
--    JOIN Personas per ON per.idPersona = c.idResidente
--    WHERE c.fechaInicio <= p_fin AND c.fechaFin >= p_inicio
--    ORDER BY c.fechaInicio;
--$$;

--CREATE OR REPLACE FUNCTION gerente.co_demanda_espacios(p_propiedad VARCHAR DEFAULT NULL)
--RETURNS SETOF v_demanda_espacios_franja
--LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public, pg_temp AS $$
--    SELECT * FROM v_demanda_espacios_franja
--    WHERE p_propiedad IS NULL OR idPropiedad = p_propiedad
--    ORDER BY nombreEspacio, franja;
--$$;

-- El modelo no registra gastos: es ingreso contratado, no rentabilidad
--CREATE OR REPLACE FUNCTION gerente.co_ingresos_por_tipo()
--RETURNS SETOF v_ingresos_por_tipo
--LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public, pg_temp AS $$
--    SELECT * FROM v_ingresos_por_tipo ORDER BY ingresos_contratados DESC;
--$$;
