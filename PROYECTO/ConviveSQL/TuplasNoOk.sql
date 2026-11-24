------------------------------------------------------------
------------------- TuplasNoOk ----------------------------
------------------------------------------------------------

-- CHK_Contrato_Fechas  (fechaFin > fechaInicio) --------------------
-- T-N-01 Fin anterior al inicio
-- Debe fallar: new row for relation "contratosocupacion" violates check constraint "chk_contrato_fechas"
INSERT INTO ContratosOcupacion VALUES ('COP-2026-0090','0090','2026-06-01','2026-05-31',1200000,'Borrador','HAB-203','1010000005','1000000002');

-- T-N-02 Fin igual al inicio
-- Debe fallar: new row for relation "contratosocupacion" violates check constraint "chk_contrato_fechas"
INSERT INTO ContratosOcupacion VALUES ('COP-2026-0090','0090','2026-06-01','2026-06-01',1200000,'Borrador','HAB-203','1010000005','1000000002');

-- T-N-03 UPDATE que deja la fecha fin antes del inicio
-- Debe fallar: new row for relation "contratosocupacion" violates check constraint "chk_contrato_fechas"
UPDATE ContratosOcupacion SET fechaFin = '2026-11-30' WHERE idContrato = 'COP-2026-0005';


-- CHK_Contrato_Duracion  (maximo 1 anio) --------------------
-- T-N-04 Contrato de 1 anio y 1 dia
-- Debe fallar: new row for relation "contratosocupacion" violates check constraint "chk_contrato_duracion"
INSERT INTO ContratosOcupacion VALUES ('COP-2026-0090','0090','2026-01-01','2027-01-02',1200000,'Borrador','HAB-203','1010000005','1000000002');

-- T-N-05 Contrato de 2 anios
-- Debe fallar: new row for relation "contratosocupacion" violates check constraint "chk_contrato_duracion"
INSERT INTO ContratosOcupacion VALUES ('COP-2026-0090','0090','2026-01-01','2028-01-01',1200000,'Borrador','HAB-203','1010000005','1000000002');

-- T-N-06 UPDATE que extiende la fecha fin mas de 1 anio
-- Debe fallar: new row for relation "contratosocupacion" violates check constraint "chk_contrato_duracion"
UPDATE ContratosOcupacion SET fechaFin = '2028-01-01' WHERE idContrato = 'COP-2026-0005';


-- CHK_Reserva_Horas  (horaFin > horaInicio) --------------------
-- T-N-07 Hora fin igual a la hora inicio
-- Debe fallar: new row for relation "reservasespacios" violates check constraint "chk_reserva_horas"
INSERT INTO ReservasEspacios VALUES ('ESP-26-0090', CURRENT_DATE + 20, '10:00', '10:00', 'ESP-002', 2, 'Confirmada', 'COP-2026-0001');

-- T-N-08 Hora fin anterior a la hora inicio
-- Debe fallar: new row for relation "reservasespacios" violates check constraint "chk_reserva_horas"
INSERT INTO ReservasEspacios VALUES ('ESP-26-0090', CURRENT_DATE + 20, '12:00', '10:00', 'ESP-002', 2, 'Confirmada', 'COP-2026-0001');


-- CHK_Invitado_Fechas  (salida > ingreso) --------------------
-- T-N-09 Salida anterior al ingreso
-- Debe fallar: new row for relation "invitados" violates check constraint "chk_invitado_fechas"
INSERT INTO Invitados VALUES ('INV-0090','Invitado Prueba','1234567890','CC','2026-10-20 15:00','2026-10-20 14:00','Retirado','COP-2026-0003','1000000002');

-- T-N-10 Salida igual al ingreso
-- Debe fallar: new row for relation "invitados" violates check constraint "chk_invitado_fechas"
INSERT INTO Invitados VALUES ('INV-0090','Invitado Prueba','1234567890','CC','2026-10-20 15:00','2026-10-20 15:00','Retirado','COP-2026-0003','1000000002');


-- CHK_Inventario_Prefijo  (el prefijo del id coincide con la categoria) --------------------
-- T-N-11 Id con prefijo MOB y categoria ELE
-- Debe fallar: new row for relation "inventarioshabitaciones" violates check constraint "chk_inventario_prefijo"
INSERT INTO InventariosHabitaciones VALUES ('MOB-SILLA-0390','Silla','ELE','Silla','Nuevo',NULL,'HAB-103');

