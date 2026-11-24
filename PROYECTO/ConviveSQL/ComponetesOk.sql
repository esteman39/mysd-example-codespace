-- ================================
-- -------- ComponentesOk ---------
-- ================================


-- ===================== PROPIEDADES =====================

-- CO-01 ad_propiedad + co_propiedades: ahora hay 3 propiedades
CALL propiedades.ad_propiedad('AAA0789TEST', 'Convive Test', 'Calle 10 # 5-5', 'Cali');
-- Esperado: 3
SELECT COUNT(*) FROM propiedades.co_propiedades();

-- CO-02 mod_propiedad + co_propiedades_ciudad (la busqueda no distingue mayusculas)
CALL propiedades.mod_propiedad('AAA0789TEST', 'Convive Test Renombrada');
-- Esperado: Convive Test Renombrada
SELECT nombrePropiedad FROM propiedades.co_propiedades_ciudad('cali');

-- CO-03 ad_espacio: el espacio nace 'Disponible' (DEFAULT)
CALL propiedades.ad_espacio('ESP-005', 'Sala de Estudio', 8, 'AAA0789TEST');
-- Esperado: Disponible
SELECT estadoActualEspacio FROM propiedades.co_espacios_propiedad('AAA0789TEST');

-- CO-04 mod_espacio: cambia aforo y estado (los parametros en NULL no se modifican)
CALL propiedades.mod_espacio('ESP-005', NULL, 10, 'En Mantenimiento');
-- Esperado: En Mantenimiento
SELECT estadoActualEspacio FROM propiedades.co_espacios_propiedad('AAA0789TEST');
-- Esperado: Sala de Estudio
SELECT nombreEspacio FROM propiedades.co_espacios_propiedad('AAA0789TEST');

-- CO-05 eli_espacio: sin reservas, se elimina
CALL propiedades.eli_espacio('ESP-005');
-- Esperado: 0
SELECT COUNT(*) FROM propiedades.co_espacios_propiedad('AAA0789TEST');

-- CO-06 eli_propiedad: sin habitaciones ni espacios, se elimina
CALL propiedades.eli_propiedad('AAA0789TEST');
-- Esperado: 2
SELECT COUNT(*) FROM propiedades.co_propiedades();

-- ===================== PERSONAS =====================

-- CO-07 ad_persona + ad_residente
CALL personas.ad_persona('1030000001', 'Nuevo Residente', 'CC', '3105550001', 'nuevo.residente@correo.com');
CALL personas.ad_persona('1030000002', 'Contacto Nuevo', 'CC', '3105550002', 'contacto.nuevo@correo.com');
CALL personas.ad_residente('1030000001');
-- Esperado: 7
SELECT COUNT(*) FROM personas.co_residentes();

-- CO-08 mod_persona: solo cambia el nombre (telefono y correo quedan igual)
CALL personas.mod_persona('1030000001', 'Nuevo Residente Editado');
-- Esperado: Nuevo Residente Editado
SELECT nombrePersona FROM personas.co_residentes() WHERE idResidente = '1030000001';
-- Esperado: 3105550001
SELECT telefonoPersona FROM personas.co_residentes() WHERE idResidente = '1030000001';

-- CO-09 ad_contacto: el primer contacto de un residente queda principal (tg_contacto_principal)
CALL personas.ad_contacto('1030000002', '1030000001', 'Padre');
-- Esperado: t
SELECT esPrincipal FROM personas.co_contactos_residente('1030000001');

-- CO-10 mod_contacto: cambia el parentesco
CALL personas.mod_contacto('1030000002', '1030000001', 'Tío', TRUE);
-- Esperado: Tío
SELECT parentescoContacto FROM personas.co_contactos_residente('1030000001');

-- CO-11 ad_personal + co_personal_cargo (v_personal_publico: sin salario)
CALL personas.ad_persona('1030000003', 'Nuevo Técnico', 'CC', '3105550003', 'nuevo.tecnico@convive.co');
CALL personas.ad_personal('1030000003', 'Mantenimiento', 1600000);
-- Esperado: 3
SELECT COUNT(*) FROM personas.co_personal_cargo('Mantenimiento');

-- CO-12 mod_personal: cambia el salario (se lee de la tabla; la vista no lo muestra)
CALL personas.mod_personal('1030000003', NULL, 1700000);
-- Esperado: 1700000.00
SELECT salarioBase FROM Personal WHERE idPersonal = '1030000003';

-- CO-13 eli_contacto
CALL personas.eli_contacto('1030000002', '1030000001');
-- Esperado: 0
SELECT COUNT(*) FROM personas.co_contactos_residente('1030000001');

-- CO-14 eli_residente: sin contratos, se elimina
CALL personas.eli_residente('1030000001');
-- Esperado: 6
SELECT COUNT(*) FROM personas.co_residentes();

-- ===================== CONTRATOS =====================

-- CO-15 ad_contrato: el subtipo (largo plazo, dia de corte 1) lo crea el trigger tg_asignacion_tcontrato
CALL contratos.ad_contrato('COP-2026-0014', '0014', '2026-12-01', '2027-03-01', 5700000, 'Borrador', 'HAB-203', '1010000005', '1000000002');
-- Esperado: 1
SELECT diaCorteMensual FROM ContratosLargoPlazo WHERE idContrato = 'COP-2026-0014';

-- CO-16 mod_contrato: al cambiar la fecha fin de un contrato corto se recalcula totalNoches (4 -> 7)
-- Esperado: 4
SELECT totalNoches FROM ContratosCortoPlazo WHERE idContrato = 'COP-2026-0005';
CALL contratos.mod_contrato('COP-2026-0005', DATE '2026-12-08', NULL);
-- Esperado: 7
SELECT totalNoches FROM ContratosCortoPlazo WHERE idContrato = 'COP-2026-0005';

-- CO-17 mod_contrato: Borrador -> Vigente, la habitacion pasa a Ocupada
CALL contratos.mod_contrato('COP-2026-0014', NULL, 'Vigente');
-- Esperado: Ocupada
SELECT estadoHabitacion FROM habitaciones.co_habitaciones() WHERE idHabitacion = 'HAB-203';

-- CO-18 ad_clausula (contrato largo) y ad_politica (contrato corto)
CALL contratos.ad_clausula('COP-2026-0014', 'Clausula de prueba.');
CALL contratos.ad_politica('COP-2026-0005', 'Politica adicional de prueba.');
-- Esperado: 1
SELECT COUNT(*) FROM TieneClausulas WHERE idContrato = 'COP-2026-0014';
-- Esperado: 2
SELECT COUNT(*) FROM TienePoliticas WHERE idContrato = 'COP-2026-0005';

-- CO-19 eli_clausula y eli_politica
CALL contratos.eli_clausula('COP-2026-0014', 'Clausula de prueba.');
CALL contratos.eli_politica('COP-2026-0005', 'Politica adicional de prueba.');
-- Esperado: 0
SELECT COUNT(*) FROM TieneClausulas WHERE idContrato = 'COP-2026-0014';
-- Esperado: 1
SELECT COUNT(*) FROM TienePoliticas WHERE idContrato = 'COP-2026-0005';

-- CO-20 Consultas de contratos
-- Esperado: 8
SELECT COUNT(*) FROM contratos.co_contratos();
-- Esperado: 6
SELECT COUNT(*) FROM contratos.co_contratos_estado('Vigente');
-- Esperado: 2
SELECT COUNT(*) FROM contratos.co_contratos_residente('1010000006');
-- Esperado: 1
SELECT COUNT(*) FROM contratos.co_contratos_habitacion('HAB-203');

-- CO-21 mod_contrato: Vigente -> Finalizado, la habitacion pasa a 'En Limpieza'
CALL contratos.mod_contrato('COP-2026-0014', NULL, 'Finalizado');
-- Esperado: En Limpieza
SELECT estadoHabitacion FROM habitaciones.co_habitaciones() WHERE idHabitacion = 'HAB-203';

-- CO-22 eli_contrato: un solo DELETE; el subtipo se elimina por CASCADE y la habitacion no cambia
CALL contratos.eli_contrato('COP-2026-0014');
-- Esperado: 0
SELECT COUNT(*) FROM ContratosLargoPlazo WHERE idContrato = 'COP-2026-0014';
-- Esperado: En Limpieza
SELECT estadoHabitacion FROM habitaciones.co_habitaciones() WHERE idHabitacion = 'HAB-203';

-- CO-23 eli_contrato de un Borrador corto: se van el subtipo y sus politicas
CALL contratos.eli_contrato('COP-2026-0005');
-- Esperado: 0
SELECT COUNT(*) FROM ContratosCortoPlazo WHERE idContrato = 'COP-2026-0005';
-- Esperado: 0
SELECT COUNT(*) FROM TienePoliticas WHERE idContrato = 'COP-2026-0005';

-- ===================== HABITACIONES, TIPOS E INVENTARIO =====================

-- CO-24 mod_habitacion: limpieza terminada, 'En Limpieza' -> 'Disponible'
CALL habitaciones.mod_habitacion('HAB-203', NULL, 'Disponible');
-- Esperado: Disponible
SELECT estadoHabitacion FROM habitaciones.co_habitaciones() WHERE idHabitacion = 'HAB-203';

-- CO-25 ad_habitacion: nace 'Disponible'
CALL habitaciones.ad_habitacion('HAB-107', 'AAA0123NORT', 'Individual');
-- Esperado: Disponible
SELECT estadoHabitacion FROM habitaciones.co_habitaciones() WHERE idHabitacion = 'HAB-107';

-- CO-26 mod_habitacion: a mantenimiento; deja de aparecer entre las disponibles
CALL habitaciones.mod_habitacion('HAB-107', NULL, 'Mantenimiento');
-- Esperado: Mantenimiento
SELECT estadoHabitacion FROM habitaciones.co_habitaciones() WHERE idHabitacion = 'HAB-107';
-- Esperado: 2
SELECT COUNT(*) FROM habitaciones.co_habitaciones_disponibles();

-- CO-27 eli_habitacion: sin contratos ni inventario, se elimina
CALL habitaciones.eli_habitacion('HAB-107');
-- Esperado: 9
SELECT COUNT(*) FROM habitaciones.co_habitaciones();

-- CO-28 Ciclo de un tipo de habitacion. HAB-104 (Compartida) ya no tiene contratos:
-- se elimina la habitacion, luego el tipo (sin habitaciones), y se vuelven a crear.
CALL habitaciones.eli_habitacion('HAB-104');
-- Esperado: 8
SELECT COUNT(*) FROM habitaciones.co_habitaciones();
CALL habitaciones.eli_tipo_habitacion('Compartida');
-- Esperado: 3
SELECT COUNT(*) FROM habitaciones.co_tipos_habitacion();
CALL habitaciones.ad_tipo_habitacion('Compartida', 'Habitación Compartida', 'Habitación con dos camas sencillas y baño compartido', 2, 90000, 'Corto Plazo');
-- Esperado: 4
SELECT COUNT(*) FROM habitaciones.co_tipos_habitacion();
CALL habitaciones.ad_habitacion('HAB-104', 'AAA0123NORT', 'Compartida');
-- Esperado: 9
SELECT COUNT(*) FROM habitaciones.co_habitaciones();

-- CO-29 mod_tipo_habitacion: cambia solo la tarifa
CALL habitaciones.mod_tipo_habitacion('Suite', NULL, NULL, 260000);
-- Esperado: 260000.00
SELECT tarifaBase FROM habitaciones.co_tipos_habitacion() WHERE idTipoHabitacion = 'Suite';

-- CO-30 Inventario: ad_inventario, mod_inventario (estado final) y eli_inventario
CALL habitaciones.ad_inventario('MOB-MESA-0104', 'Mesa auxiliar', 'MOB', 'Mesa auxiliar pequeña', 'Nuevo', 'HAB-104');
-- Esperado: 1
SELECT COUNT(*) FROM habitaciones.co_inventario_habitacion('HAB-104');
CALL habitaciones.mod_inventario('MOB-MESA-0104', 'Bueno');
-- Esperado: Bueno
SELECT estadoFinal FROM habitaciones.co_inventario_habitacion('HAB-104');
CALL habitaciones.eli_inventario('MOB-MESA-0104');
-- Esperado: 0
SELECT COUNT(*) FROM habitaciones.co_inventario_habitacion('HAB-104');

-- ===================== RESERVAS =====================

-- CO-31 ad_reserva: toda reserva nace 'Confirmada'
CALL reservas.ad_reserva('ESP-26-0040', CURRENT_DATE + 9, '09:00', '11:00', 'ESP-002', 5, 'COP-2026-0003');
-- Esperado: Confirmada
SELECT estadoReserva FROM ReservasEspacios WHERE idReserva = 'ESP-26-0040';

-- CO-32 mod_reserva: Confirmada -> Completada y Confirmada -> Cancelada
CALL reservas.mod_reserva('ESP-26-0040', 'Completada');
-- Esperado: Completada
SELECT estadoReserva FROM ReservasEspacios WHERE idReserva = 'ESP-26-0040';
CALL reservas.mod_reserva('ESP-26-0003', 'Cancelada');
-- Esperado: Cancelada
SELECT estadoReserva FROM ReservasEspacios WHERE idReserva = 'ESP-26-0003';

-- CO-33 eli_reserva: una reserva cancelada si se elimina
CALL reservas.eli_reserva('ESP-26-0003');
-- Esperado: 6
SELECT COUNT(*) FROM reservas.co_reservas();

-- CO-34 Consultas de reservas
-- Esperado: 2
SELECT COUNT(*) FROM reservas.co_reservas_espacio('ESP-001', CURRENT_DATE);
-- Esperado: 3
SELECT COUNT(*) FROM reservas.co_reservas_contrato('COP-2026-0001');

-- ===================== INVITADOS =====================

-- CO-35 ad_invitado: ingreso y estado se asignan solos
CALL invitados.ad_invitado('INV-0040', 'Carla Núñez', 'CC', '1098765040', 'COP-2026-0003', '1000000002');
-- Esperado: En las instalaciones
SELECT EstadoInvitado FROM Invitados WHERE idInvitado = 'INV-0040';

-- CO-36 mod_invitado: registra la salida (por defecto, ahora) y pasa a 'Retirado'
CALL invitados.mod_invitado('INV-0040');
-- Esperado: Retirado
SELECT EstadoInvitado FROM Invitados WHERE idInvitado = 'INV-0040';

-- CO-37 can_invitado y eli_invitado: se cancela un invitado activo y luego se elimina
CALL invitados.ad_invitado('INV-0041', 'Pablo Soto', 'CC', '1098765041', 'COP-2026-0003', '1000000002');
CALL invitados.can_invitado('INV-0041');
-- Esperado: Cancelado
SELECT EstadoInvitado FROM Invitados WHERE idInvitado = 'INV-0041';
CALL invitados.eli_invitado('INV-0041');
-- Esperado: 0
SELECT COUNT(*) FROM Invitados WHERE idInvitado = 'INV-0041';

-- CO-38 Consultas de invitados
-- Esperado: 7
SELECT COUNT(*) FROM invitados.co_invitados();
-- Esperado: 3
SELECT COUNT(*) FROM invitados.co_invitados_activos();
-- Esperado: 2
SELECT COUNT(*) FROM invitados.co_invitados_contrato('COP-2026-0003');

