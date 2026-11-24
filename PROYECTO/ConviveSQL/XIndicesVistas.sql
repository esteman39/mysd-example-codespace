-- ========================================
--  XIndicesVistas
-- ========================================


DROP VIEW IF EXISTS v_habitaciones_disponibles;
DROP VIEW IF EXISTS v_disponibilidad_por_tipo;
DROP VIEW IF EXISTS v_invitados_activos;
DROP VIEW IF EXISTS v_control_aforo_espacios;
DROP VIEW IF EXISTS v_contratos_vigentes;
DROP VIEW IF EXISTS v_inventario_habitacion;
DROP VIEW IF EXISTS v_personal_publico;
DROP VIEW IF EXISTS v_demanda_espacios_franja;
DROP VIEW IF EXISTS v_ingresos_por_tipo;

DROP INDEX IF EXISTS idx_hab_propiedad;
DROP INDEX IF EXISTS idx_hab_tipo;
DROP INDEX IF EXISTS idx_contr_residente;
DROP INDEX IF EXISTS idx_contr_personal;
DROP INDEX IF EXISTS idx_reserva_contrato;
DROP INDEX IF EXISTS idx_invit_personal;
DROP INDEX IF EXISTS idx_inventario_hab;
DROP INDEX IF EXISTS idx_contratos_hab_estado;
DROP INDEX IF EXISTS idx_hab_disponibles;
DROP INDEX IF EXISTS idx_contr_periodo;
DROP INDEX IF EXISTS idx_reserva_espacio_dia;
DROP INDEX IF EXISTS idx_invitados_activos;
DROP INDEX IF EXISTS ux_hab_un_contrato_vigente;
DROP INDEX IF EXISTS ux_un_administrador;
DROP INDEX IF EXISTS ux_un_contacto_principal;