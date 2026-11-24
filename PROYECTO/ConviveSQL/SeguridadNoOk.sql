------------------------------------------------------------------
------------------ SeguridadNoOK ---------------------------------
------------------------------------------------------------------

-- RECEPCIONISTA: no accede a tablas, vistas, paquetes base ni servicios de otros actores --------
SET ROLE usr_recepcion;

-- SN-01 Leer la tabla Personal (tiene los salarios)
-- Debe fallar: permission denied for table personal
SELECT * FROM Personal;

-- SN-02 Leer una vista directamente (debe usar su servicio)
-- Debe fallar: permission denied for view v_invitados_activos
SELECT * FROM v_invitados_activos;

-- SN-03 Ejecutar un servicio del Gerente
-- Debe fallar: permission denied for schema gerente
SELECT * FROM gerente.co_ingresos_por_tipo();

-- SN-04 Ejecutar una accion estrategica del Gerente (crear propiedad)
-- Debe fallar: permission denied for schema gerente
CALL gerente.ad_propiedad('AAA0999FAIL', 'Propiedad No Autorizada', 'Calle 1 # 2-3', 'Bogota');

-- SN-05 Ejecutar un servicio del Administrador (consultar inventario o eliminar habitacion)
-- Debe fallar: permission denied for schema administrador
SELECT * FROM administrador.co_inventario_habitacion();

-- SN-06 Intentar eliminar un contrato desde recepcionista (solo el admin elimina contratos)
-- Debe fallar: procedure recepcionista.eli_contrato(unknown) does not exist / permission denied
CALL administrador.eli_contrato('COP-2026-0006');

-- SN-07 Llamar directamente al paquete base Personas sin pasar por su esquema de actor
-- Debe fallar: permission denied for schema personas
CALL personas.ad_personal('1010000006', 'Mantenimiento', 1500000);

-- SN-08 Modificar una tabla directamente
-- Debe fallar: permission denied for table contratosocupacion
UPDATE ContratosOcupacion SET valorContrato = 1 WHERE idContrato = 'COP-2026-0001';

RESET ROLE;


-- ADMINISTRADOR: no accede a tablas, paquetes base ni servicios de otros actores --------
SET ROLE usr_admin;

-- SN-09 Leer la tabla Personal directamente
-- Debe fallar: permission denied for table personal
SELECT * FROM Personal;

-- SN-10 Ejecutar una consulta del Gerente
-- Debe fallar: permission denied for schema gerente
SELECT * FROM gerente.co_ingresos_por_tipo();

-- SN-11 Ejecutar una accion estrategica del Gerente (crear o eliminar propiedad)
-- Debe fallar: permission denied for schema gerente
CALL gerente.ad_propiedad('AAA0999FAIL', 'Propiedad Admin Fail', 'Calle 1 # 2-3', 'Bogota');

-- SN-12 Ejecutar una accion exclusiva del Gerente (crear tipo de habitacion)
-- Debe fallar: permission denied for schema gerente
CALL gerente.ad_tipo_habitacion('TH-FAIL', 'Suite', 'No autorizado', 2, 2000000, 'Largo Plazo');

-- SN-13 Ejecutar un servicio del Recepcionista
-- Debe fallar: permission denied for schema recepcionista
SELECT * FROM recepcionista.co_invitados_activos();

-- SN-14 Llamar directamente al paquete base Propiedades sin pasar por su esquema
-- Debe fallar: permission denied for schema propiedades
CALL propiedades.ad_propiedad('AAA0999FAIL', 'Propiedad Directa', 'Calle 1 # 2-3', 'Bogota');

RESET ROLE;


-- GERENTE: no accede a tablas, paquetes base ni operaciones diarias de recepcion/admin --------
SET ROLE usr_gerente;

-- SN-15 Registrar un invitado usando el esquema de Recepcionista
-- Debe fallar: permission denied for schema recepcionista
CALL recepcionista.ad_invitado('INV-0070', 'Invitado Prueba', 'CC', '1098765070', 'COP-2026-0003', '1000000002');

-- SN-16 Llamar directamente al paquete base Invitados
-- Debe fallar: permission denied for schema invitados
CALL invitados.ad_invitado('INV-0070', 'Invitado Prueba', 'CC', '1098765070', 'COP-2026-0003', '1000000002');

-- SN-17 Leer una vista con datos de personal directamente
-- Debe fallar: permission denied for view v_personal_publico
SELECT * FROM v_personal_publico;

-- SN-18 Eliminar filas de una tabla directamente
-- Debe fallar: permission denied for table contratosocupacion
DELETE FROM ContratosOcupacion;

-- SN-19 Ejecutar un servicio operativo del Administrador (modificar inventario o eliminar contrato)
-- Debe fallar: permission denied for schema administrador
CALL administrador.mod_inventario('MOB-001', 'Dañado');

-- SN-20 Consultar propiedades directamente en el paquete base Propiedades
-- Debe fallar: permission denied for schema propiedades
SELECT * FROM propiedades.co_propiedades();

RESET ROLE;
