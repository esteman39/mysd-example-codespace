------------------------------------------------------------------
------------------ SeguridadOK -----------------------------------
------------------------------------------------------------------

-- ===================== RECEPCIONISTA =====================
SET ROLE usr_recepcion;
-- Esperado: usr_recepcion
SELECT current_user;

-- SO-01 Bitacora de invitados activos
-- Esperado: 3
SELECT COUNT(*) FROM recepcionista.co_invitados_activos();

-- SO-02 Control de asistencia y aforo de hoy (ESP-26-0001 y ESP-26-0002)
-- Esperado: 2
SELECT COUNT(*) FROM recepcionista.co_control_aforo();

-- SO-03 Disponibilidad por tipo: una propiedad (4 tipos) y todas (6 combinaciones)
-- Esperado: 4
SELECT COUNT(*) FROM recepcionista.co_disponibilidad_habitaciones('AAA0123NORT');
-- Esperado: 6
SELECT COUNT(*) FROM recepcionista.co_disponibilidad_habitaciones();

-- SO-04 Servicios de su operacion diaria a traves de su esquema (recepcionista.*):
--       registrar invitado, registrar salida, cancelar invitado y gestionar reserva
CALL recepcionista.ad_invitado('INV-0060', 'Visitante Recepción', 'CC', '1098765060', 'COP-2026-0003', '1000000002');
-- Esperado: En las instalaciones
SELECT EstadoInvitado FROM recepcionista.co_invitados_activos() WHERE idInvitado = 'INV-0060';

CALL recepcionista.mod_invitado('INV-0060');
-- Esperado: 0 (ya fue retirado)
SELECT COUNT(*) FROM recepcionista.co_invitados_activos() WHERE idInvitado = 'INV-0060';

CALL recepcionista.ad_invitado('INV-0061', 'Visitante Cancelado', 'CC', '1098765061', 'COP-2026-0003', '1000000002');
CALL recepcionista.can_invitado('INV-0061');
-- Esperado: 0 (cancelado)
SELECT COUNT(*) FROM recepcionista.co_invitados_activos() WHERE idInvitado = 'INV-0061';

CALL recepcionista.ad_reserva('ESP-26-0060', CURRENT_DATE + 3, '09:00', '10:00', 'ESP-002', 4, 'COP-2026-0003');
-- Esperado: 3 (las 2 de hoy + la nueva de dentro de 3 dias)
SELECT COUNT(*) FROM recepcionista.co_control_aforo(CURRENT_DATE + 3);
CALL recepcionista.mod_reserva('ESP-26-0060', 'Cancelada');
-- Esperado: 0 (cancelada no cuenta en control de aforo)
SELECT COUNT(*) FROM recepcionista.co_control_aforo(CURRENT_DATE + 3);

-- SO-05 Gestion de personas, residentes, contactos y contratos desde recepcionista
CALL recepcionista.ad_persona('1099000060', 'Nuevo Residente Rec', 'CC', '3001112233', 'nuevo.rec@correo.com');
CALL recepcionista.mod_persona('1099000060', 'Nuevo Residente Rec Mod', '3001112244', NULL);
CALL recepcionista.ad_residente('1099000060');

CALL recepcionista.ad_persona('1099000061', 'Contacto Emergencia Rec', 'CC', '3005556677', 'contacto.rec@correo.com');
CALL recepcionista.ad_contacto('1099000061', '1099000060', 'Madre', TRUE);
CALL recepcionista.mod_contacto('1099000061', '1099000060', 'Acudiente', TRUE);

CALL recepcionista.ad_contrato('COP-2026-0060', 'CTR-0060', CURRENT_DATE, CURRENT_DATE + 15, 900000, 'Vigente', 'HAB-102', '1099000060', '1000000002');
CALL recepcionista.mod_contrato('COP-2026-0060', CURRENT_DATE + 20, NULL);

RESET ROLE;


-- ===================== ADMINISTRADOR =====================
SET ROLE usr_admin;
-- Esperado: usr_admin
SELECT current_user;

-- SO-06 Contratos vigentes por modalidad
-- Esperado: 6 (5 iniciales + COP-2026-0060 creado en SO-05)
SELECT COUNT(*) FROM administrador.co_contratos_vigentes();
-- Esperado: 4
SELECT COUNT(*) FROM administrador.co_contratos_vigentes('Largo Plazo');
-- Esperado: 2
SELECT COUNT(*) FROM administrador.co_contratos_vigentes('Corto Plazo');

-- SO-07 Inventario inicial y final: una habitacion (HAB-201) y todas
-- Esperado: 2
SELECT COUNT(*) FROM administrador.co_inventario_habitacion('HAB-201');
-- Esperado: 8
SELECT COUNT(*) FROM administrador.co_inventario_habitacion();

-- SO-08 Disponibilidad por tipo y propiedad
-- Esperado: 6
SELECT COUNT(*) FROM administrador.co_disponibilidad_habitaciones();

-- SO-09 Gestion operativa e infraestructura desde administrador.*:
--       habitaciones, inventario, espacios comunes y depuracion de registros
CALL administrador.ad_habitacion('HAB-999', 'AAA0123NORT', 'Individual');
CALL administrador.mod_habitacion('HAB-999', NULL, 'Mantenimiento');

CALL administrador.ad_inventario('MOB-999', 'Escritorio Prueba', 'Mobiliario', 'Escritorio de madera', 'Bueno', 'HAB-999');
CALL administrador.mod_inventario('MOB-999', 'Excelente');
-- Esperado: 1
SELECT COUNT(*) FROM administrador.co_inventario_habitacion('HAB-999');
CALL administrador.eli_inventario('MOB-999');
CALL administrador.eli_habitacion('HAB-999');

CALL administrador.ad_espacio('ESP-999', 'Sala Coworking Test', 12, 'AAA0123NORT');
CALL administrador.mod_espacio('ESP-999', 'Sala Coworking Renovada', 15, 'Disponible');
CALL administrador.eli_espacio('ESP-999');

-- SO-10 Gestion de politicas, clausulas, depuracion y personal desde administrador.*
CALL administrador.ad_politica('COP-2026-0060', 'Cancelacion gratuita con 48h de anticipacion.');
CALL administrador.eli_politica('COP-2026-0060', 'Cancelacion gratuita con 48h de anticipacion.');
CALL administrador.eli_contrato('COP-2026-0060');

CALL administrador.eli_contacto('1099000061', '1099000060');
CALL administrador.eli_residente('1099000060');
CALL administrador.eli_reserva('ESP-26-0060');
CALL administrador.eli_invitado('INV-0061');

CALL administrador.mod_personal('1000000004', NULL, 1650000);
RESET ROLE;
-- (con el usuario dueño de las tablas, se confirma el cambio)
-- Esperado: 1650000.00
SELECT salarioBase FROM Personal WHERE idPersonal = '1000000004';


-- ===================== GERENTE =====================
SET ROLE usr_gerente;
-- Esperado: usr_gerente
SELECT current_user;

-- SO-11 Ingresos contratados por tipo de habitacion (3 tipos con contratos vigentes o finalizados)
-- Esperado: 3
SELECT COUNT(*) FROM gerente.co_ingresos_por_tipo();

-- SO-12 Demanda de espacios comunes por franja: todas las propiedades (4) y solo El Poblado (1)
-- Esperado: 4
SELECT COUNT(*) FROM gerente.co_demanda_espacios();
-- Esperado: 1
SELECT COUNT(*) FROM gerente.co_demanda_espacios('AAA0456POBL');

-- SO-13 Contratos activos en el ultimo trimestre de 2026
-- Esperado: 6
SELECT COUNT(*) FROM gerente.co_contratos_periodo('2026-10-01', '2026-12-31');

-- SO-14 Gobierno estrategico desde gerente.*: propiedades, tipos de habitacion y personal
CALL gerente.ad_propiedad('AAA0789TEST', 'Convive Test', 'Calle 10 # 5-5', 'Cali');
CALL gerente.mod_propiedad('AAA0789TEST', 'Convive Test Cali');
CALL gerente.eli_propiedad('AAA0789TEST');

CALL gerente.ad_tipo_habitacion('TH-TEST', 'Suite', 'Suite ejecutiva de prueba', 2, 2500000, 'Largo Plazo');
CALL gerente.mod_tipo_habitacion('TH-TEST', 'Suite ejecutiva actualizada', 2, 2650000, 'Largo Plazo');
CALL gerente.eli_tipo_habitacion('TH-TEST');

CALL gerente.mod_personal('1000000004', NULL, 1700000);
RESET ROLE;
-- (con el usuario dueño de las tablas, se confirma el cambio)
-- Esperado: 1700000.00
SELECT salarioBase FROM Personal WHERE idPersonal = '1000000004';
