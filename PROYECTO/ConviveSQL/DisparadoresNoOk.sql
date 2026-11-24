------------------------------------------------------------------
---------------- DisparadoresNoOK (TriggersNoOk) ----------------
------------------------------------------------------------------

-- PROPIEDADES Y PERSONAS -------------------------
-- D-N-01 tg_actualizar_propiedad: cambiar la ciudad de una propiedad
-- Debe fallar: Modificación denegada: Solo es mutable el nombre de la propiedad.
UPDATE Propiedades SET ciudadPropiedad = 'Cali' WHERE idPropiedad = 'AAA0123NORT';

-- D-N-02 tg_restricciones_actualizacion: cambiar el tipo de documento de una persona
-- Debe fallar: No se puede modificar el documento de identidad principal.
UPDATE Personas SET TipoIdentificacion = 'CE' WHERE idPersona = '1010000001';


-- PERSONAL -------------------------
-- D-N-03 tg_roles_trabajadores: segundo Administrador
-- Debe fallar: No se puede asignar el cargo de Administrador: ya existe uno.
UPDATE Personal SET cargoPersonal = 'Administrador' WHERE idPersonal = '1000000004';

-- D-N-04 tg_roles_trabajadores: tercer Recepcionista
-- Debe fallar: No se puede asignar el cargo de Recepcionista: ya existen dos.
UPDATE Personal SET cargoPersonal = 'Recepcionista' WHERE idPersonal = '1000000004';


-- CONTACTOS DE EMERGENCIA -------------------------
-- D-N-05 tg_agregar_contacto: segundo contacto principal
-- Debe fallar: El residente 1010000003 ya tiene un contacto de emergencia principal.
INSERT INTO ContactosEmergencia VALUES ('1020000002','Tío',TRUE,'1010000003');

-- D-N-06 tg_max_contactos: tercer contacto para un residente que ya tiene 2
-- Debe fallar: El residente 1010000001 ya tiene 2 contactos de emergencia.
INSERT INTO ContactosEmergencia VALUES ('1020000003','Amiga',FALSE,'1010000001');


-- CONTRATOS -------------------------
-- D-N-07 tg_ins_contrato: contrato en una habitacion ocupada (HAB-101)
-- Debe fallar: La habitación HAB-101 no se encuentra disponible.
INSERT INTO ContratosOcupacion VALUES ('COP-2026-0030','0030','2026-12-01','2027-03-01',1000000,'Vigente','HAB-101','1010000005','1000000002');

-- D-N-08 tg_ins_contrato: contrato registrado por personal de Mantenimiento
-- Debe fallar: El personal registrador debe tener el cargo de Recepcionista o Administrador.
INSERT INTO ContratosOcupacion VALUES ('COP-2026-0030','0030','2026-12-01','2027-03-01',1000000,'Borrador','HAB-203','1010000005','1000000004');

-- D-N-09 tg_ins_contrato: residente que no esta registrado
-- Debe fallar: El residente con ID 1099999999 no está registrado en el sistema.
INSERT INTO ContratosOcupacion VALUES ('COP-2026-0030','0030','2026-12-01','2027-03-01',1000000,'Borrador','HAB-203','1099999999','1000000002');

-- D-N-10 tg_ins_contrato: UPDATE que mueve un contrato a una habitacion ocupada
-- Debe fallar: La habitación HAB-101 no se encuentra disponible.
UPDATE ContratosOcupacion SET idHabitacion = 'HAB-101' WHERE idContrato = 'COP-2026-0005';


-- RESERVAS DE ESPACIOS -------------------------
-- D-N-11 tg_ins_reservaespacio: espacio en mantenimiento
-- Debe fallar: El espacio común ESP-003 no se encuentra disponible para reservas.
INSERT INTO ReservasEspacios VALUES ('ESP-26-0030', CURRENT_DATE + 7, '10:00', '12:00', 'ESP-003', 3, 'Confirmada', 'COP-2026-0001');

-- D-N-12 tg_ins_reservaespacio: supera el aforo (aforo 12, 13 personas)
-- Debe fallar: El aforo solicitado (13) supera el aforo máximo permitido para el espacio común ESP-002.
INSERT INTO ReservasEspacios VALUES ('ESP-26-0030', CURRENT_DATE + 7, '10:00', '12:00', 'ESP-002', 13, 'Confirmada', 'COP-2026-0003');

-- D-N-13 tg_espacio_ocupado: traslape con otra reserva (18:00-20:00 ya reservado)
-- Debe fallar: El espacio común ESP-001 ya tiene una reserva en el rango horario solicitado para la fecha <fecha>.
INSERT INTO ReservasEspacios VALUES ('ESP-26-0030', CURRENT_DATE, '19:00', '21:00', 'ESP-001', 3, 'Confirmada', 'COP-2026-0002');

-- D-N-14 tg_reserva_contrato_vigente: contrato que no esta vigente (Borrador)
-- Debe fallar: El contrato COP-2026-0005 no está vigente: no puede reservar espacios.
INSERT INTO ReservasEspacios VALUES ('ESP-26-0030', CURRENT_DATE + 7, '10:00', '12:00', 'ESP-002', 3, 'Confirmada', 'COP-2026-0005');

-- D-N-15 tg_eliminar_reserva: eliminar una reserva que no esta cancelada
-- Debe fallar: Solo se pueden eliminar reservas que estén en estado Cancelada.
DELETE FROM ReservasEspacios WHERE idReserva = 'ESP-26-0001';


-- INVITADOS -------------------------
-- D-N-16 tg_ins_invitado: invitado en un contrato que no esta vigente (Finalizado)
-- Debe fallar: El contrato asociado no se encuentra vigente.
INSERT INTO Invitados (idInvitado, nombreInvitado, documentoInvitado, TipoIdentificacion, idContrato, idPersonal_Registro) VALUES ('INV-0030','Invitado Prueba','1098765030','CC','COP-2026-0006','1000000002');

-- D-N-17 tg_ins_invitado: tercer invitado activo en un contrato que ya tiene 2
-- Debe fallar: Se ha alcanzado el límite máximo de 2 invitados activos simultáneamente para este contrato.
INSERT INTO Invitados (idInvitado, nombreInvitado, documentoInvitado, TipoIdentificacion, idContrato, idPersonal_Registro) VALUES ('INV-0031','Invitado Prueba','1098765031','CC','COP-2026-0001','1000000002');

-- D-N-18 tg_invitado_fuera: salida anterior al ingreso
-- Debe fallar: La hora de salida debe ser estrictamente mayor a la hora de ingreso.
UPDATE Invitados SET fechaHoraSalida = fechaHoraIngreso - INTERVAL '1 hour' WHERE idInvitado = 'INV-0001';

-- D-N-19 tg_ele_invitado: eliminar un invitado que no esta cancelado
-- Debe fallar: Solo se pueden eliminar invitados que estén en estado Cancelado.
DELETE FROM Invitados WHERE idInvitado = 'INV-0001';