----------------------------------------------------
--------- DisparadoresOK (TriggersOk) ----------------
----------------------------------------------------

-- D-OK-01 tg_actualizar_propiedad: el nombre de la propiedad si se puede modificar
UPDATE Propiedades SET nombrePropiedad = 'Convive Chapinero Renovado' WHERE idPropiedad = 'AAA0123NORT';

-- D-OK-02 [CORRECCION] tg_restricciones_actualizacion: el telefono de una persona si se puede modificar
-- (antes TODO UPDATE sobre Personas fallaba)
UPDATE Personas SET telefonoPersona = '3109999999' WHERE idPersona = '1010000001';

-- D-OK-03 tg_asignacion_tcontrato: un contrato corto (5 dias) crea solo su subtipo de corto plazo
INSERT INTO ContratosOcupacion VALUES ('COP-2026-0013','0013','2027-01-10','2027-01-15',450000,'Borrador','HAB-104','1010000005','1000000002');
-- Esperado: 5
SELECT totalNoches FROM ContratosCortoPlazo WHERE idContrato = 'COP-2026-0013';

-- D-OK-04 [CORRECCION] Un UPDATE de contrato ya no intenta crear el subtipo otra vez
-- (antes cualquier UPDATE fallaba por llave duplicada)
UPDATE ContratosOcupacion SET valorContrato = 500000 WHERE idContrato = 'COP-2026-0013';

-- D-OK-05 tg_contrato_confirmado: Borrador -> Vigente, la habitacion pasa de Disponible a Ocupada
-- Esperado: Disponible
SELECT estadoHabitacion FROM Habitaciones WHERE idHabitacion = 'HAB-104';
UPDATE ContratosOcupacion SET estadoContrato = 'Vigente' WHERE idContrato = 'COP-2026-0005';
-- Esperado: Ocupada
SELECT estadoHabitacion FROM Habitaciones WHERE idHabitacion = 'HAB-104';

-- D-OK-06 [CORRECCION] Contrato nuevo que inicia el dia 30: el dia de corte queda en 28
-- (antes violaba el dominio TDiaCorte). Largo plazo: dura mas de 31 dias.
INSERT INTO ContratosOcupacion VALUES ('COP-2026-0020','0020','2026-12-30','2027-04-30',7200000,'Vigente','HAB-203','1010000005','1000000002');
-- Esperado: 28
SELECT diaCorteMensual FROM ContratosLargoPlazo WHERE idContrato = 'COP-2026-0020';
-- Esperado: Ocupada
SELECT estadoHabitacion FROM Habitaciones WHERE idHabitacion = 'HAB-203';

-- D-OK-07 tg_contrato_confirmado: Vigente -> Finalizado, la habitacion pasa a 'En Limpieza'
-- Esperado: Ocupada
SELECT estadoHabitacion FROM Habitaciones WHERE idHabitacion = 'HAB-105';
UPDATE ContratosOcupacion SET estadoContrato = 'Finalizado' WHERE idContrato = 'COP-2026-0004';
-- Esperado: En Limpieza
SELECT estadoHabitacion FROM Habitaciones WHERE idHabitacion = 'HAB-105';

-- D-OK-08 [CORRECCION] tg_habitacion_libre: eliminar un contrato HISTORICO no cambia la habitacion
-- (antes la dejaba 'Disponible'; HAB-201 sigue 'En Limpieza')
DELETE FROM ContratosOcupacion WHERE idContrato = 'COP-2026-0006';
-- Esperado: En Limpieza
SELECT estadoHabitacion FROM Habitaciones WHERE idHabitacion = 'HAB-201';

-- D-OK-09 tg_habitacion_libre: eliminar un contrato VIGENTE si libera la habitacion
DELETE FROM ContratosOcupacion WHERE idContrato = 'COP-2026-0020';
-- Esperado: Disponible
SELECT estadoHabitacion FROM Habitaciones WHERE idHabitacion = 'HAB-203';

-- D-OK-10 tg_ins_reservaespacio: reserva valida dentro del aforo
INSERT INTO ReservasEspacios VALUES ('ESP-26-0020', CURRENT_DATE + 5, '09:00', '11:00', 'ESP-002', 5, 'Confirmada', 'COP-2026-0003');

-- D-OK-11 tg_espacio_ocupado: una reserva pegada a otra (22:00-23:00 despues de 20:00-22:00) no se traslapa
INSERT INTO ReservasEspacios VALUES ('ESP-26-0021', CURRENT_DATE, '22:00', '23:00', 'ESP-001', 4, 'Confirmada', 'COP-2026-0001');

-- D-OK-12 tg_espacio_ocupado: una reserva CANCELADA no bloquea el horario (ESP-26-0005: ESP-001, +2 dias, 18:00-20:00)
INSERT INTO ReservasEspacios VALUES ('ESP-26-0022', CURRENT_DATE + 2, '18:00', '20:00', 'ESP-001', 6, 'Confirmada', 'COP-2026-0002');

-- D-OK-13 [CORRECCION] tg_eliminar_reserva: una reserva cancelada si se puede eliminar
-- (antes NINGUNA reserva se podia eliminar)
DELETE FROM ReservasEspacios WHERE idReserva = 'ESP-26-0005';

-- D-OK-14 [CORRECCION] tg_ins_invitado + tg_invitado_ingresado: registrar un invitado
-- (antes ningun invitado se podia registrar). Ingreso y estado se asignan solos.
INSERT INTO Invitados (idInvitado, nombreInvitado, documentoInvitado, TipoIdentificacion, idContrato, idPersonal_Registro)
VALUES ('INV-0020', 'Laura Díaz', '1098765020', 'CC', 'COP-2026-0003', '1000000002');
-- Esperado: En las instalaciones
SELECT EstadoInvitado FROM Invitados WHERE idInvitado = 'INV-0020';

-- D-OK-15 tg_ins_invitado: el segundo invitado activo del mismo contrato todavia cabe (el limite es 2)
INSERT INTO Invitados (idInvitado, nombreInvitado, documentoInvitado, TipoIdentificacion, idContrato, idPersonal_Registro)
VALUES ('INV-0021', 'Tomás Rey', '1098765021', 'CC', 'COP-2026-0003', '1000000002');
-- Esperado: 2
SELECT COUNT(*) FROM Invitados WHERE idContrato = 'COP-2026-0003' AND EstadoInvitado = 'En las instalaciones';

-- D-OK-16 tg_invitado_fuera: al registrar la salida el invitado pasa a 'Retirado'
UPDATE Invitados SET fechaHoraSalida = CURRENT_TIMESTAMP WHERE idInvitado = 'INV-0020';
-- Esperado: Retirado
SELECT EstadoInvitado FROM Invitados WHERE idInvitado = 'INV-0020';

-- D-OK-17 tg_ele_invitado: un invitado cancelado si se puede eliminar
DELETE FROM Invitados WHERE idInvitado = 'INV-0005';

-- D-OK-18 tg_roles_trabajadores: personal de Mantenimiento no tiene limite
INSERT INTO Personas VALUES ('1000000006', 'Raúl Peña', 'CC', '3001000006', 'raul.pena@convive.co');
INSERT INTO Personal VALUES ('1000000006', 'Mantenimiento', 1600000.00);

-- D-OK-19 tg_agregar_contacto: segundo contacto (no principal) de un residente que ya tiene principal
INSERT INTO ContactosEmergencia VALUES ('1020000002', 'Tío', FALSE, '1010000003');
-- Esperado: 2
SELECT COUNT(*) FROM ContactosEmergencia WHERE idResidente = '1010000003';

-- D-OK-20 tg_contacto_principal: el primer contacto de un residente queda principal aunque se registre FALSE
INSERT INTO ContactosEmergencia VALUES ('1020000004', 'Amiga', FALSE, '1010000005');
-- Esperado: t
SELECT esPrincipal FROM ContactosEmergencia WHERE idResidente = '1010000005';

-- D-OK-21 tg_adicionar_habitacion: una habitacion nueva nace 'Disponible' aunque se pida otro estado
INSERT INTO Habitaciones VALUES ('HAB-901', 'Individual', 'Mantenimiento', 'AAA0123NORT');
-- Esperado: Disponible
SELECT estadoHabitacion FROM Habitaciones WHERE idHabitacion = 'HAB-901';