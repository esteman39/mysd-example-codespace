---------------------------------------------
------------- TuplasOk ---------------------
---------------------------------------------


-- CHK_Contrato_Fechas y CHK_Contrato_Duracion --------------------
-- T-OK-01 Contrato con fecha fin posterior al inicio (6 meses)
INSERT INTO ContratosOcupacion VALUES ('COP-2026-0010','0010','2026-06-01','2026-12-01',1200000,'Borrador','HAB-203','1010000005','1000000002');

-- T-OK-02 Contrato de exactamente 1 anio (limite permitido)
INSERT INTO ContratosOcupacion VALUES ('COP-2026-0011','0011','2026-01-01','2027-01-01',1200000,'Borrador','HAB-203','1010000005','1000000002');

-- T-OK-03 UPDATE que extiende la fecha fin dentro del anio
UPDATE ContratosOcupacion SET fechaFin = '2026-12-15' WHERE idContrato = 'COP-2026-0010';

-- CHK_Reserva_Horas ----------------------------------------------
-- T-OK-04 Reserva con hora fin mayor que la hora inicio
INSERT INTO ReservasEspacios VALUES ('ESP-26-0010', CURRENT_DATE + 10, '09:00', '11:00', 'ESP-002', 2, 'Confirmada', 'COP-2026-0001');

-- CHK_Invitado_Fechas --------------------------------------------
-- T-OK-05 Invitado con salida posterior al ingreso
INSERT INTO Invitados VALUES ('INV-0010','Invitado Prueba','1234567890','CC','2026-10-20 14:00','2026-10-20 18:00','Retirado','COP-2026-0003','1000000002');

-- T-OK-06 Invitado que aun no sale (fechaHoraSalida NULL)
INSERT INTO Invitados VALUES ('INV-0011','Invitado Activo','1234567891','CC','2026-10-20 14:00',NULL,'En las instalaciones','COP-2026-0003','1000000002');

-- CHK_Inventario_Prefijo -----------------------------------------
-- T-OK-07 Id con prefijo MOB y categoria MOB
INSERT INTO InventariosHabitaciones VALUES ('MOB-SILLA-0301','Silla de escritorio','MOB','Silla','Nuevo',NULL,'HAB-103');
