-----------------------------------------------------
------------------ AccionesReferencialesOk ----------
-----------------------------------------------------


-- A-OK-01 ON DELETE CASCADE: al eliminar un contrato de largo plazo se eliminan su subtipo y sus clausulas
-- Esperado: 1
SELECT COUNT(*) FROM ContratosLargoPlazo WHERE idContrato = 'COP-2026-0006';
-- Esperado: 1
SELECT COUNT(*) FROM TieneClausulas WHERE idContrato = 'COP-2026-0006';
DELETE FROM ContratosOcupacion WHERE idContrato = 'COP-2026-0006';
-- Esperado: 0
SELECT COUNT(*) FROM ContratosLargoPlazo WHERE idContrato = 'COP-2026-0006';
-- Esperado: 0
SELECT COUNT(*) FROM TieneClausulas WHERE idContrato = 'COP-2026-0006';

-- A-OK-02 ON DELETE CASCADE en dos niveles: contrato corto plazo -> subtipo -> politicas
-- Esperado: 1
SELECT COUNT(*) FROM ContratosCortoPlazo WHERE idContrato = 'COP-2026-0005';
-- Esperado: 1
SELECT COUNT(*) FROM TienePoliticas WHERE idContrato = 'COP-2026-0005';
DELETE FROM ContratosOcupacion WHERE idContrato = 'COP-2026-0005';
-- Esperado: 0
SELECT COUNT(*) FROM ContratosCortoPlazo WHERE idContrato = 'COP-2026-0005';
-- Esperado: 0
SELECT COUNT(*) FROM TienePoliticas WHERE idContrato = 'COP-2026-0005';

-- A-OK-03 ON UPDATE CASCADE: corregir el id de un contrato lo propaga a subtipo, clausulas y reservas
-- Esperado: 1
SELECT COUNT(*) FROM ReservasEspacios WHERE idContrato = 'COP-2026-0007';
UPDATE ContratosOcupacion SET idContrato = 'COP-2026-0017' WHERE idContrato = 'COP-2026-0007';
-- Esperado: 1
SELECT COUNT(*) FROM ReservasEspacios WHERE idContrato = 'COP-2026-0017';
-- Esperado: 1
SELECT COUNT(*) FROM ContratosLargoPlazo WHERE idContrato = 'COP-2026-0017';
-- Esperado: 1
SELECT COUNT(*) FROM TieneClausulas WHERE idContrato = 'COP-2026-0017';
-- Esperado: 0
SELECT COUNT(*) FROM ReservasEspacios WHERE idContrato = 'COP-2026-0007';

-- A-OK-04 ON DELETE CASCADE: al eliminar un residente se eliminan sus contactos, pero no las personas contacto
-- (preparacion: un residente nuevo, sin contratos, con un contacto que ya lo es de otros dos residentes)
INSERT INTO Personas VALUES ('1010000007', 'Pablo Ramírez', 'CC', '3101000007', 'pablo.ramirez@correo.com');
INSERT INTO Residentes VALUES ('1010000007');
INSERT INTO ContactosEmergencia VALUES ('1020000001', 'Tía', TRUE, '1010000007');
-- Esperado: 1
SELECT COUNT(*) FROM ContactosEmergencia WHERE idResidente = '1010000007';
DELETE FROM Residentes WHERE idResidente = '1010000007';
-- Esperado: 0
SELECT COUNT(*) FROM ContactosEmergencia WHERE idResidente = '1010000007';
-- La persona contacto sigue existiendo...
-- Esperado: 1
SELECT COUNT(*) FROM Personas WHERE idPersona = '1020000001';
-- ...y sigue siendo contacto de los otros residentes
-- Esperado: 2
SELECT COUNT(*) FROM ContactosEmergencia WHERE idContactoEmergencia = '1020000001';

-- A-OK-05 RESTRICT solo bloquea cuando hay filas hijas: una habitacion sin contratos ni inventario si se elimina
-- Esperado: 1
SELECT COUNT(*) FROM Habitaciones WHERE idHabitacion = 'HAB-106';
DELETE FROM Habitaciones WHERE idHabitacion = 'HAB-106';
-- Esperado: 0
SELECT COUNT(*) FROM Habitaciones WHERE idHabitacion = 'HAB-106';
