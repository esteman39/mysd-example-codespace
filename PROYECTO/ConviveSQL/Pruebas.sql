-- ================================
-- Seguridad
-- ================================

-- HISTORIA DE PRUEBAS DE SEGURIDAD 1

-- El gerente de la propiedad Convive Chapinero (AAA0123NORT) quiere relevar a la recepcionista y vincular a una nueva persona. 
-- La nueva recepcionista debe registrar el ingreso de invitados asociados a un contrato vigente, y luego registrar la salida o cancelacion de los invitados.

----------------------------------------------------------------------
-- PASO 1. El gerente registra los datos de la persona que sera la nueva
-- recepcionista (servicio: gerente.ad_persona).
----------------------------------------------------------------------
SET ROLE usr_gerente;
-- Esperado: usr_gerente
SELECT current_user;
CALL gerente.ad_persona('1060000001', 'Natalia Beltrán', 'CC', '3135550001', 'natalia.beltran@convive.co');
RESET ROLE;

-- Verificacion (con el usuario dueño de las tablas): la persona quedo registrada.
-- Esperado: Natalia Beltrán
SELECT nombrePersona FROM Personas WHERE idPersona = '1060000001';

-- Regla: una vez registrada, el tipo y el numero de identificacion no se pueden
-- modificar (tg_restricciones_actualizacion).
-- Debe fallar: No se puede modificar el documento de identidad principal.
UPDATE Personas SET TipoIdentificacion = 'CE' WHERE idPersona = '1060000001';

----------------------------------------------------------------------
-- PASO 2. Relevo del personal en recepcion (servicios: gerente.ad_personal y
-- gerente.mod_personal). Regla: maximo 2 Recepcionistas y 1 Administrador
-- (tg_roles_trabajadores).
----------------------------------------------------------------------
SET ROLE usr_gerente;

-- Con dos recepcionistas, no se puede vincular a un tercero.
-- Debe fallar: No se puede asignar el cargo de Recepcionista: ya existen dos.
CALL gerente.ad_personal('1060000001', 'Recepcionista', 2100000);

-- Relevo: la recepcionista saliente (1000000003) pasa a Mantenimiento...
CALL gerente.mod_personal('1000000003', 'Mantenimiento');
-- ...y ahora si se vincula a la nueva recepcionista.
CALL gerente.ad_personal('1060000001', 'Recepcionista', 2100000);

-- Tampoco puede haber un segundo Administrador.
-- Debe fallar: No se puede asignar el cargo de Administrador: ya existe uno.
CALL gerente.mod_personal('1060000001', 'Administrador');
RESET ROLE;

-- Verificacion de los cargos (con el usuario dueño de las tablas).
-- Esperado: 2
SELECT COUNT(*) FROM Personal WHERE cargoPersonal = 'Recepcionista';
-- Esperado: 1
SELECT COUNT(*) FROM Personal WHERE cargoPersonal = 'Administrador';
-- Esperado: 3
SELECT COUNT(*) FROM Personal WHERE cargoPersonal = 'Mantenimiento';

----------------------------------------------------------------------
-- PASO 3. La nueva recepcionista registra el ingreso de dos invitados de la
-- misma habitacion (HAB-202), asociados a su contrato vigente COP-2026-0007
-- (servicio: recepcionista.ad_invitado).
----------------------------------------------------------------------
SET ROLE usr_recepcion;
-- Esperado: usr_recepcion
SELECT current_user;

CALL recepcionista.ad_invitado('INV-0201', 'Laura Gómez', 'CC', '1098766201', 'COP-2026-0007', '1060000001');
-- El sistema asigna solo el estado inicial y la fecha y hora de ingreso
-- (tg_invitado_ingresado).
-- Esperado: En las instalaciones
SELECT EstadoInvitado FROM invitados.co_invitados_contrato('COP-2026-0007') WHERE idInvitado = 'INV-0201';
-- Esperado: t
SELECT fechaHoraIngreso IS NOT NULL FROM invitados.co_invitados_contrato('COP-2026-0007') WHERE idInvitado = 'INV-0201';

CALL recepcionista.ad_invitado('INV-0202', 'Mauricio Díaz', 'CC', '1098766202', 'COP-2026-0007', '1060000001');
-- Esperado: 2
SELECT COUNT(*) FROM invitados.co_invitados_contrato('COP-2026-0007') WHERE EstadoInvitado = 'En las instalaciones';

-- Regla: maximo 2 invitados activos por contrato (tg_ins_invitado).
-- Debe fallar: Se ha alcanzado el límite máximo de 2 invitados activos simultáneamente para este contrato.
CALL recepcionista.ad_invitado('INV-0203', 'Tercer Invitado', 'CC', '1098766203', 'COP-2026-0007', '1060000001');

-- Regla: el contrato debe estar Vigente (el COP-2026-0006 esta Finalizado).
-- Debe fallar: El contrato asociado no se encuentra vigente.
CALL recepcionista.ad_invitado('INV-0204', 'Invitado Contrato Cerrado', 'CC', '1098766204', 'COP-2026-0006', '1060000001');

----------------------------------------------------------------------
-- PASO 4. Seguimiento y cierre: la recepcionista consulta la bitacora de invitados
-- activos y registra la salida o la cancelacion
-- (servicios: recepcionista.co_invitados_activos, mod_invitado, can_invitado).
----------------------------------------------------------------------
-- 3 invitados activos que ya habia en el edificio + los 2 nuevos.
-- Esperado: 5
SELECT COUNT(*) FROM recepcionista.co_invitados_activos();

-- Salida de Laura: al registrar la hora de salida, el estado cambia solo a 'Retirado'
-- (tg_invitado_fuera).
CALL recepcionista.mod_invitado('INV-0201');
-- Esperado: Retirado
SELECT EstadoInvitado FROM invitados.co_invitados_contrato('COP-2026-0007') WHERE idInvitado = 'INV-0201';

-- La visita de Mauricio se cancela.
CALL recepcionista.can_invitado('INV-0202');
-- Esperado: Cancelado
SELECT EstadoInvitado FROM invitados.co_invitados_contrato('COP-2026-0007') WHERE idInvitado = 'INV-0202';

-- Regla: solo se eliminan los registros en estado 'Cancelado' (tg_ele_invitado).
-- Debe fallar: Solo se pueden eliminar invitados que estén en estado Cancelado.
CALL recepcionista.eli_invitado('INV-0201');
CALL recepcionista.eli_invitado('INV-0202');

-- Con la salida y la cancelacion, el contrato recupera cupo: queda en la bitacora
-- lo que ya estaba (3) y puede ingresar un nuevo invitado.
-- Esperado: 3
SELECT COUNT(*) FROM recepcionista.co_invitados_activos();
CALL recepcionista.ad_invitado('INV-0205', 'Invitada Nueva', 'CC', '1098766205', 'COP-2026-0007', '1060000001');
-- Esperado: 4
SELECT COUNT(*) FROM recepcionista.co_invitados_activos();
RESET ROLE;



SET ROLE usr_admin;
-- Esperado: usr_admin
SELECT current_user;

----------------------------------------------------------------------
-- PASO 1. Verificacion de disponibilidad (administrador.co_disponibilidad_habitaciones).
-- El administrador busca una habitacion individual disponible en El Poblado.
----------------------------------------------------------------------
-- Esperado: 1
SELECT disponibles FROM administrador.co_disponibilidad_habitaciones('AAA0456POBL') WHERE nombreTipoHabitacion = 'Habitación Individual';
-- La habitacion disponible es HAB-203.
-- Esperado: HAB-203
SELECT idHabitacion FROM habitaciones.co_habitaciones_disponibles() WHERE idPropiedad = 'AAA0456POBL';

----------------------------------------------------------------------
-- PASO 2. Revision de inventario (administrador.co_inventario_habitacion).
----------------------------------------------------------------------
-- HAB-203 aun no tiene activos registrados.
-- Esperado: 0
SELECT COUNT(*) FROM administrador.co_inventario_habitacion('HAB-203');

-- Se registra el inventario inicial antes de asignar la habitacion.
CALL habitaciones.ad_inventario('MOB-CAMA-0203', 'Cama sencilla', 'MOB', 'Cama sencilla con colchón ortopédico', 'Nuevo', 'HAB-203');
CALL habitaciones.ad_inventario('ELE-NEVERA-0203', 'Nevera', 'ELE', 'Nevera pequeña de 90 litros', 'Bueno', 'HAB-203');
-- Esperado: 2
SELECT COUNT(*) FROM administrador.co_inventario_habitacion('HAB-203');
-- Mientras la habitacion esta en uso, ningun activo tiene estado final.
-- Esperado: t
SELECT bool_and(estadoFinal IS NULL) FROM administrador.co_inventario_habitacion('HAB-203');
-- Como referencia, HAB-201 (ya finalizada) muestra el estado inicial y el final de sus activos:
-- los 2 activos cambiaron de estado.
-- Esperado: 2
SELECT COUNT(*) FROM administrador.co_inventario_habitacion('HAB-201') WHERE cambio_estado;

----------------------------------------------------------------------
-- PASO 3. Registro del contrato anual en estado Borrador (administrador.ad_contrato).
-- Regla: la fecha fin debe ser mayor que la de inicio y la duracion no puede
-- exceder 1 anio.
----------------------------------------------------------------------
-- Fecha fin igual a la fecha de inicio.
-- Debe fallar: new row for relation "contratosocupacion" violates check constraint "chk_contrato_fechas"
CALL administrador.ad_contrato('COP-2026-0301', '0301', '2026-12-01', '2026-12-01', 14400000, 'Borrador', 'HAB-203', '1010000005', '1000000002');

-- Duracion de 1 anio y 1 dia.
-- Debe fallar: new row for relation "contratosocupacion" violates check constraint "chk_contrato_duracion"
CALL administrador.ad_contrato('COP-2026-0301', '0301', '2026-12-01', '2027-12-02', 14400000, 'Borrador', 'HAB-203', '1010000005', '1000000002');

-- Duracion de exactamente 1 anio (fechaFin = fechaInicio + 1 anio): valido.
CALL administrador.ad_contrato('COP-2026-0301', '0301', '2026-12-01', '2027-12-01', 14400000, 'Borrador', 'HAB-203', '1010000005', '1000000002');
-- Esperado: Borrador
SELECT estadoContrato FROM contratos.co_contratos_residente('1010000005') WHERE idContrato = 'COP-2026-0301';
-- Un Borrador no ocupa la habitacion.
-- Esperado: Disponible
SELECT estadoHabitacion FROM habitaciones.co_habitaciones() WHERE idHabitacion = 'HAB-203';

-- Regla: el subtipo (largo o corto plazo) lo asigna solo el sistema segun la duracion
-- (tg_asignacion_tcontrato). Se comprueba con el usuario dueño de las tablas.
RESET ROLE;
-- Esperado: 1
SELECT diaCorteMensual FROM ContratosLargoPlazo WHERE idContrato = 'COP-2026-0301';
-- Esperado: 0
SELECT COUNT(*) FROM ContratosCortoPlazo WHERE idContrato = 'COP-2026-0301';
SET ROLE usr_admin;

----------------------------------------------------------------------
-- PASO 4. Activacion del contrato (administrador.mod_contrato): Borrador -> Vigente.
----------------------------------------------------------------------
CALL administrador.mod_contrato('COP-2026-0301', NULL, 'Vigente');
-- Esperado: Vigente
SELECT estadoContrato FROM contratos.co_contratos_residente('1010000005') WHERE idContrato = 'COP-2026-0301';
-- La habitacion pasa sola a 'Ocupada' (tg_contrato_confirmado).
-- Esperado: Ocupada
SELECT estadoHabitacion FROM habitaciones.co_habitaciones() WHERE idHabitacion = 'HAB-203';

-- Nadie puede forzar el estado 'Ocupada' con mod_habitacion, ni liberar una habitacion ocupada.
-- Debe fallar: El estado Ocupada solo lo gestionan los contratos.
CALL habitaciones.mod_habitacion('HAB-104', NULL, 'Ocupada');
-- Debe fallar: El estado Ocupada solo lo gestionan los contratos.
CALL habitaciones.mod_habitacion('HAB-203', NULL, 'Disponible');

-- Proteccion de estados terminales: un contrato Finalizado no vuelve a Vigente.
-- Debe fallar: El contrato COP-2026-0006 está Finalizado y no puede cambiar de estado.
CALL administrador.mod_contrato('COP-2026-0006', NULL, 'Vigente');

----------------------------------------------------------------------
-- PASO 5. Monitoreo de vencimientos y corto plazo
-- (administrador.co_contratos_vigentes y contratos.co_contratos).
----------------------------------------------------------------------
-- Solo se ven los contratos vigentes: 5 que habia + el nuevo.
-- Esperado: 6
SELECT COUNT(*) FROM administrador.co_contratos_vigentes();
-- Filtro por modalidad.
-- Esperado: 5
SELECT COUNT(*) FROM administrador.co_contratos_vigentes('Largo Plazo');
-- Esperado: 1
SELECT COUNT(*) FROM administrador.co_contratos_vigentes('Corto Plazo');

-- Vigentes proximos a vencer: los que terminan antes del 2027-03-01 (el nuevo vence en 2027-12-01).
-- Esperado: 2
SELECT COUNT(*) FROM administrador.co_contratos_vigentes() WHERE fechaFin < DATE '2027-03-01';

-- Contratos de corto plazo (31 dias o menos) que iniciaron en el ultimo trimestre de 2026,
-- sin importar su estado.
-- Esperado: 2
SELECT COUNT(*) FROM contratos.co_contratos()
WHERE fechaFin - fechaInicio <= 31 AND fechaInicio BETWEEN DATE '2026-10-01' AND DATE '2026-12-31';
RESET ROLE;
