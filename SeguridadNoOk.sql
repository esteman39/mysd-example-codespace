------------------------------------------------------------------
------------------ SeguridadNoOK ---------------------------------
------------------------------------------------------------------



-- RECEPCIONISTA: no accede a tablas, vistas ni a servicios de otros actores --------
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

-- SN-04 Ejecutar un servicio del Administrador
-- Debe fallar: permission denied for schema administrador
SELECT * FROM administrador.co_inventario_habitacion();

-- SN-05 Registrar personal (componente Personas)
-- Debe fallar: permission denied for schema personas
CALL personas.ad_personal('1010000006','Mantenimiento',1500000);

-- SN-06 Eliminar un contrato (componente Contratos)
-- Debe fallar: permission denied for schema contratos
CALL contratos.eli_contrato('COP-2026-0006');

-- SN-07 Modificar una tabla directamente
-- Debe fallar: permission denied for table contratosocupacion
UPDATE ContratosOcupacion SET valorContrato = 1 WHERE idContrato = 'COP-2026-0001';

RESET ROLE;

-- ADMINISTRADOR: tampoco accede a tablas ni a servicios de otros actores --------
SET ROLE usr_admin;

-- SN-08 Leer la tabla Personal directamente
-- Debe fallar: permission denied for table personal
SELECT * FROM Personal;

-- SN-09 Ejecutar un servicio del Gerente
-- Debe fallar: permission denied for schema gerente
SELECT * FROM gerente.co_ingresos_por_tipo();

-- SN-10 Ejecutar un servicio del Recepcionista
-- Debe fallar: permission denied for schema recepcionista
SELECT * FROM recepcionista.co_invitados_activos();

RESET ROLE;

-- GERENTE: solo consulta con sus servicios --------
SET ROLE usr_gerente;

-- SN-11 Registrar un invitado (componente Invitados)
-- Debe fallar: permission denied for schema invitados
CALL invitados.ad_invitado('INV-0070','Invitado Prueba','CC','1098765070','COP-2026-0003','1000000002');

-- SN-12 Leer una vista con datos de personal
-- Debe fallar: permission denied for view v_personal_publico
SELECT * FROM v_personal_publico;

-- SN-13 Eliminar filas de una tabla
-- Debe fallar: permission denied for table contratosocupacion
DELETE FROM ContratosOcupacion;

-- SN-14 Ejecutar un servicio del Administrador
-- Debe fallar: permission denied for schema administrador
SELECT * FROM administrador.co_contratos_vigentes();

-- SN-15 Consultar propiedades (componente Propiedades)
-- Debe fallar: permission denied for schema propiedades
SELECT * FROM propiedades.co_propiedades();

RESET ROLE;