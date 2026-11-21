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

-- SO-04 Servicios de su operacion diaria: registrar un invitado y una reserva
CALL invitados.ad_invitado('INV-0060', 'Visitante Recepción', 'CC', '1098765060', 'COP-2026-0003', '1000000002');
-- Esperado: En las instalaciones
SELECT EstadoInvitado FROM invitados.co_invitados_activos() WHERE idInvitado = 'INV-0060';
CALL reservas.ad_reserva('ESP-26-0060', CURRENT_DATE + 3, '09:00', '10:00', 'ESP-002', 4, 'COP-2026-0003');
-- Esperado: 1
SELECT COUNT(*) FROM reservas.co_reservas_espacio('ESP-002', CURRENT_DATE + 3);
RESET ROLE;

-- ===================== ADMINISTRADOR =====================
SET ROLE usr_admin;
-- Esperado: usr_admin
SELECT current_user;

-- SO-05 Contratos vigentes por modalidad
-- Esperado: 5
SELECT COUNT(*) FROM administrador.co_contratos_vigentes();
-- Esperado: 4
SELECT COUNT(*) FROM administrador.co_contratos_vigentes('Largo Plazo');
-- Esperado: 1
SELECT COUNT(*) FROM administrador.co_contratos_vigentes('Corto Plazo');

-- SO-06 Inventario inicial y final: una habitacion (HAB-201) y todas
-- Esperado: 2
SELECT COUNT(*) FROM administrador.co_inventario_habitacion('HAB-201');
-- Esperado: 8
SELECT COUNT(*) FROM administrador.co_inventario_habitacion();

-- SO-07 Disponibilidad por tipo y propiedad
-- Esperado: 6
SELECT COUNT(*) FROM administrador.co_disponibilidad_habitaciones();

-- SO-08 Gestion de los componentes: crear una propiedad y cambiar el salario de un empleado
CALL propiedades.ad_propiedad('AAA0789TEST', 'Convive Test', 'Calle 10 # 5-5', 'Cali');
-- Esperado: 3
SELECT COUNT(*) FROM propiedades.co_propiedades();
CALL personas.mod_personal('1000000004', NULL, 1650000);
RESET ROLE;
-- (con el usuario dueño de las tablas, se confirma el cambio)
-- Esperado: 1650000.00
SELECT salarioBase FROM Personal WHERE idPersonal = '1000000004';

-- ===================== GERENTE =====================
SET ROLE usr_gerente;
-- Esperado: usr_gerente
SELECT current_user;

-- SO-09 Ingresos contratados por tipo de habitacion (3 tipos con contratos vigentes o finalizados)
-- Esperado: 3
SELECT COUNT(*) FROM gerente.co_ingresos_por_tipo();

-- SO-10 Demanda de espacios comunes por franja: todas las propiedades (4) y solo El Poblado (1)
-- Esperado: 4
SELECT COUNT(*) FROM gerente.co_demanda_espacios();
-- Esperado: 1
SELECT COUNT(*) FROM gerente.co_demanda_espacios('AAA0456POBL');

-- SO-11 Contratos activos en el ultimo trimestre de 2026
-- Esperado: 6
SELECT COUNT(*) FROM gerente.co_contratos_periodo('2026-10-01', '2026-12-31');
RESET ROLE;