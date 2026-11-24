-- ===================== INDICES UNICOS PARCIALES =====================
-- Estas tres reglas las protege un indice unico; DEBEN fallar.

-- Ino-1 Dos contratos vigentes en la misma habitacion (HAB-101 ya tiene COP-2026-0001 vigente)
-- Debe fallar: duplicate key value violates unique constraint "ux_hab_un_contrato_vigente"
INSERT INTO ContratosOcupacion VALUES ('COP-2026-0040','0040','2026-12-01','2027-03-01',7200000,'Vigente','HAB-101','1010000005','1000000002');

-- Ino-2 Un segundo administrador
-- Debe fallar: duplicate key value violates unique constraint "ux_un_administrador"
UPDATE Personal SET cargoPersonal = 'Administrador' WHERE idPersonal = '1000000004';

-- Ino-3 Un segundo contacto principal para el mismo residente
-- Debe fallar: duplicate key value violates unique constraint "ux_un_contacto_principal"
INSERT INTO ContactosEmergencia VALUES ('1020000002', 'Tío', TRUE, '1010000003');