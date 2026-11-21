--------------------------------------------------------
------------------ IndicesVistasOK ---------------------
--------------------------------------------------------
-- Ejercita y valida las vistas y los indices.
-- Requiere PoblarOK, Indices y Vistas. Debe ejecutarse SIN los triggers
-- creados (con triggers, las ultimas 3 pruebas fallarian con el mensaje del trigger).
-- Cada SELECT lleva encima el resultado esperado; cada EXPLAIN indica el
-- indice que debe aparecer en el plan.

-- ===================== VISTAS =====================

-- V-01 v_habitaciones_disponibles: HAB-104 y HAB-203 (HAB-106 esta en mantenimiento)
-- Esperado: 2
SELECT COUNT(*) FROM v_habitaciones_disponibles;

-- V-02 v_disponibilidad_por_tipo: 6 combinaciones propiedad-tipo
-- Esperado: 6
SELECT COUNT(*) FROM v_disponibilidad_por_tipo;
-- Compartida en Chapinero: 1 habitacion y esta disponible
-- Esperado: 1
SELECT disponibles FROM v_disponibilidad_por_tipo WHERE nombrePropiedad = 'Convive Chapinero' AND nombreTipoHabitacion = 'Habitación Compartida';

-- V-03 v_contratos_vigentes: 5 vigentes, 4 de largo plazo y 1 de corto
-- Esperado: 5
SELECT COUNT(*) FROM v_contratos_vigentes;
-- Esperado: 4
SELECT COUNT(*) FROM v_contratos_vigentes WHERE modalidad = 'Largo Plazo';

-- V-04 v_invitados_activos: INV-0001, INV-0002 e INV-0004
-- Esperado: 3
SELECT COUNT(*) FROM v_invitados_activos;

-- V-05 v_control_aforo_espacios: 5 reservas no canceladas; la de 8 personas en el salon (aforo 25) es 32.0 %
-- Esperado: 5
SELECT COUNT(*) FROM v_control_aforo_espacios;
-- Esperado: 32.0
SELECT pct_aforo FROM v_control_aforo_espacios WHERE idReserva = 'ESP-26-0001';

-- V-06 v_inventario_habitacion: 8 activos, 2 con cambio de estado
-- Esperado: 8
SELECT COUNT(*) FROM v_inventario_habitacion;
-- Esperado: 2
SELECT COUNT(*) FROM v_inventario_habitacion WHERE cambio_estado;

-- V-07 v_personal_publico: 5 empleados y NINGUNA columna de salario
-- Esperado: 5
SELECT COUNT(*) FROM v_personal_publico;
-- Esperado: 0
SELECT COUNT(*) FROM information_schema.columns WHERE table_name = 'v_personal_publico' AND column_name ILIKE '%salario%';

-- V-08 v_demanda_espacios_franja: 4 combinaciones espacio-franja; el salon de noche tiene 2 reservas y 13 asistentes
-- Esperado: 4
SELECT COUNT(*) FROM v_demanda_espacios_franja;
-- Esperado: 2
SELECT reservas FROM v_demanda_espacios_franja WHERE idEspacio = 'ESP-001' AND franja = 'Noche';
-- Esperado: 13
SELECT asistentes FROM v_demanda_espacios_franja WHERE idEspacio = 'ESP-001' AND franja = 'Noche';

-- V-09 v_ingresos_por_tipo: 3 tipos con contratos vigentes o finalizados; Doble = 22.8 M x 2
-- Esperado: 3
SELECT COUNT(*) FROM v_ingresos_por_tipo;
-- Esperado: 45600000.00
SELECT ingresos_contratados FROM v_ingresos_por_tipo WHERE idTipoHabitacion = 'Doble';

-- ===================== INDICES =====================

-- I-01 Existen los 15 indices del proyecto
-- Esperado: 15
SELECT COUNT(*) FROM pg_indexes WHERE schemaname = 'public' AND (indexname LIKE 'idx\_%' OR indexname LIKE 'ux\_%');

-- Con tan pocos datos el optimizador prefiere leer la tabla completa. Para comprobar que
-- cada indice SI puede usarse, se desactiva el recorrido secuencial solo en esta sesion.
SET enable_seqscan = off;

-- I-02 Debe usar: idx_hab_propiedad
EXPLAIN SELECT * FROM Habitaciones WHERE idPropiedad = 'AAA0456POBL';
-- I-03 Debe usar: idx_hab_tipo
EXPLAIN SELECT * FROM Habitaciones WHERE tipoHabitacion = 'Suite';
-- I-04 Debe usar: idx_hab_disponibles
EXPLAIN SELECT idHabitacion FROM Habitaciones WHERE idPropiedad = 'AAA0123NORT' AND tipoHabitacion = 'Compartida' AND estadoHabitacion = 'Disponible';
-- I-05 Debe usar: idx_contratos_hab_estado
EXPLAIN SELECT * FROM ContratosOcupacion WHERE idHabitacion = 'HAB-201' AND estadoContrato = 'Finalizado';
-- I-06 Debe usar: idx_contr_residente
EXPLAIN SELECT * FROM ContratosOcupacion WHERE idResidente = '1010000001';
-- I-07 Debe usar: idx_contr_personal
EXPLAIN SELECT * FROM ContratosOcupacion WHERE idPersonal = '1000000003';
-- I-08 Debe usar: idx_contr_periodo
EXPLAIN SELECT * FROM ContratosOcupacion WHERE fechaInicio <= DATE '2026-12-31' AND fechaFin >= DATE '2026-10-01';
-- I-09 Debe usar: idx_reserva_contrato
EXPLAIN SELECT * FROM ReservasEspacios WHERE idContrato = 'COP-2026-0001';
-- I-10 Debe usar: idx_reserva_espacio_dia
EXPLAIN SELECT * FROM ReservasEspacios WHERE idEspacio = 'ESP-001' AND fechaReserva::date = CURRENT_DATE AND estadoReserva <> 'Cancelada';
-- I-11 Debe usar: idx_invit_personal
EXPLAIN SELECT * FROM Invitados WHERE idPersonal_Registro = '1000000002';
-- I-12 Debe usar: idx_invitados_activos
EXPLAIN SELECT * FROM Invitados WHERE idContrato = 'COP-2026-0001' AND EstadoInvitado = 'En las instalaciones';
-- I-13 Debe usar: idx_inventario_hab
EXPLAIN SELECT * FROM InventariosHabitaciones WHERE idHabitacion = 'HAB-101';

RESET enable_seqscan;

