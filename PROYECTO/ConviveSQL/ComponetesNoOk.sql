-- ==========================================
-- ----------- ComponentesNoOk --------------
-- ==========================================


-- PROPIEDADES ------------------------------
-- CN-01 ad_propiedad: CHIP en minusculas (dominio TCHIP)
-- Debe fallar: value for domain tchip violates check constraint "tchip_check"
CALL propiedades.ad_propiedad('aaa0999xxxx','Sede Error','Calle Falsa 123','Bogotá');

-- CN-02 ad_propiedad: id repetido
-- Debe fallar: duplicate key value violates unique constraint "pk_propiedad"
CALL propiedades.ad_propiedad('AAA0123NORT','Otra Sede','Calle 1 # 1-1','Cali');

-- CN-03 mod_propiedad: propiedad inexistente
-- Debe fallar: La propiedad AAA9999ZZZZ no existe.
CALL propiedades.mod_propiedad('AAA9999ZZZZ','Nuevo nombre');

-- CN-04 eli_propiedad: tiene habitaciones y espacios
-- Debe fallar: No se puede eliminar la propiedad AAA0123NORT: tiene habitaciones o espacios comunes asociados.
CALL propiedades.eli_propiedad('AAA0123NORT');

-- CN-05 eli_propiedad: inexistente
-- Debe fallar: La propiedad AAA9999ZZZZ no existe.
CALL propiedades.eli_propiedad('AAA9999ZZZZ');

-- CN-06 ad_espacio: aforo en cero (dominio TCantidad)
-- Debe fallar: value for domain tcantidad violates check constraint "tcantidad_check"
CALL propiedades.ad_espacio('ESP-009','Sala sin aforo',0,'AAA0123NORT');

-- CN-07 mod_espacio: espacio inexistente
-- Debe fallar: El espacio común ESP-999 no existe.
CALL propiedades.mod_espacio('ESP-999','Otro nombre');

-- CN-08 eli_espacio: tiene reservas
-- Debe fallar: No se puede eliminar el espacio ESP-001: tiene reservas asociadas.
CALL propiedades.eli_espacio('ESP-001');


-- HABITACIONES, TIPOS E INVENTARIO ------------------------------
-- CN-09 ad_habitacion: propiedad inexistente
-- Debe fallar: insert or update on table "habitaciones" violates foreign key constraint "fk_habitaciones_propiedad"
CALL habitaciones.ad_habitacion('HAB-998','AAA9999ZZZZ','Individual');

-- CN-10 mod_habitacion: marcar Ocupada a mano (solo lo gestionan los contratos)
-- Debe fallar: El estado Ocupada solo lo gestionan los contratos.
CALL habitaciones.mod_habitacion('HAB-104', NULL, 'Ocupada');

-- CN-11 mod_habitacion: habitacion inexistente
-- Debe fallar: La habitación HAB-999 no existe.
CALL habitaciones.mod_habitacion('HAB-999', NULL, 'Mantenimiento');

-- CN-12 eli_habitacion: tiene contratos e inventario
-- Debe fallar: No se puede eliminar la habitación HAB-101: tiene contratos o inventario asociados.
CALL habitaciones.eli_habitacion('HAB-101');

-- CN-13 ad_tipo_habitacion: el tipo ya existe
-- Debe fallar: duplicate key value violates unique constraint "pk_tipohabitacion"
CALL habitaciones.ad_tipo_habitacion('Suite','Otra Suite','x',3,1000,'Corto Plazo');

-- CN-14 mod_tipo_habitacion: tipo inexistente
-- Debe fallar: El tipo de habitación Penthouse no existe.
CALL habitaciones.mod_tipo_habitacion('Penthouse', NULL, NULL, 500000);

-- CN-15 eli_tipo_habitacion: tiene habitaciones
-- Debe fallar: No se puede eliminar el tipo de habitación Suite: existen habitaciones de ese tipo.
CALL habitaciones.eli_tipo_habitacion('Suite');

-- CN-16 ad_inventario: el prefijo del id no coincide con la categoria
-- Debe fallar: new row for relation "inventarioshabitaciones" violates check constraint "chk_inventario_prefijo"
CALL habitaciones.ad_inventario('MOB-SILLA-0199','Silla','ELE','Silla de prueba','Nuevo','HAB-101');

-- CN-17 mod_inventario: activo inexistente
-- Debe fallar: El activo MOB-SILLA-0999 no existe en el inventario.
CALL habitaciones.mod_inventario('MOB-SILLA-0999','Bueno');

-- CN-18 eli_inventario: activo inexistente
-- Debe fallar: El activo MOB-SILLA-0999 no existe en el inventario.
CALL habitaciones.eli_inventario('MOB-SILLA-0999');


-- PERSONAS ------------------------------
-- CN-19 ad_persona: correo ya registrado
-- Debe fallar: duplicate key value violates unique constraint "uq_persona_correo"
CALL personas.ad_persona('1030000009','Otro Usuario','CC','3105550009','sofia.ruiz@correo.com');

-- CN-20 mod_persona: persona inexistente
-- Debe fallar: La persona 1099999999 no existe.
CALL personas.mod_persona('1099999999','Nuevo nombre');

-- CN-21 ad_residente: la persona no existe
-- Debe fallar: insert or update on table "residentes" violates foreign key constraint "fk_residentes_persona"
CALL personas.ad_residente('1099999999');

-- CN-22 eli_residente: tiene contratos
-- Debe fallar: No se puede eliminar el residente 1010000001: tiene contratos asociados.
CALL personas.eli_residente('1010000001');

-- CN-23 ad_personal: segundo Administrador
-- Debe fallar: No se puede asignar el cargo de Administrador: ya existe uno.
CALL personas.ad_personal('1010000006','Administrador',4000000);

-- CN-24 ad_personal: cargo que no existe (dominio TCargo)
-- Debe fallar: value for domain tcargo violates check constraint "tcargo_check"
CALL personas.ad_personal('1010000006','Gerente',4000000);

-- CN-25 mod_personal: empleado inexistente
-- Debe fallar: El empleado 1099999999 no existe.
CALL personas.mod_personal('1099999999','Mantenimiento',1500000);

-- CN-26 ad_contacto: tercer contacto de un residente
-- Debe fallar: El residente 1010000001 ya tiene 2 contactos de emergencia.
CALL personas.ad_contacto('1020000003','1010000001','Amiga');

-- CN-27 mod_contacto: el contacto no existe para ese residente
-- Debe fallar: El contacto 1020000004 no existe para el residente 1010000001.
CALL personas.mod_contacto('1020000004','1010000001','Tío');

-- CN-28 eli_contacto: el contacto no existe para ese residente
-- Debe fallar: El contacto 1020000004 no existe para el residente 1010000001.
CALL personas.eli_contacto('1020000004','1010000001');


-- CONTRATOS ------------------------------
-- CN-29 ad_contrato: habitacion ocupada (HAB-101)
-- Debe fallar: La habitación HAB-101 no se encuentra disponible.
CALL contratos.ad_contrato('COP-2026-0030','0030','2026-12-01','2027-03-01',1000000,'Borrador','HAB-101','1010000005','1000000002');

-- CN-30 ad_contrato: registrado por personal de Mantenimiento
-- Debe fallar: El personal registrador debe tener el cargo de Recepcionista o Administrador.
CALL contratos.ad_contrato('COP-2026-0030','0030','2026-12-01','2027-03-01',1000000,'Borrador','HAB-203','1010000005','1000000004');

-- CN-31 ad_contrato: duracion de mas de 1 anio
-- Debe fallar: new row for relation "contratosocupacion" violates check constraint "chk_contrato_duracion"
CALL contratos.ad_contrato('COP-2026-0030','0030','2026-01-01','2028-01-01',1000000,'Borrador','HAB-203','1010000005','1000000002');

-- CN-32 mod_contrato: contrato inexistente
-- Debe fallar: El contrato COP-2026-9999 no existe.
CALL contratos.mod_contrato('COP-2026-9999', NULL, 'Cancelado');

-- CN-33 mod_contrato: reabrir un contrato finalizado
-- Debe fallar: El contrato COP-2026-0006 está Finalizado y no puede cambiar de estado.
CALL contratos.mod_contrato('COP-2026-0006', NULL, 'Vigente');

-- CN-34 ad_politica: contrato de LARGO plazo
-- Debe fallar: El contrato COP-2026-0001 no existe o no es de corto plazo: no admite políticas de cancelación.
CALL contratos.ad_politica('COP-2026-0001','Politica en contrato largo');

-- CN-35 ad_clausula: contrato de CORTO plazo
-- Debe fallar: El contrato COP-2026-0004 no existe o no es de largo plazo: no admite cláusulas.
CALL contratos.ad_clausula('COP-2026-0004','Clausula en contrato corto');

-- CN-36 eli_politica: la politica no existe
-- Debe fallar: La política indicada no existe para el contrato COP-2026-0004.
CALL contratos.eli_politica('COP-2026-0004','Politica inexistente');

-- CN-37 eli_clausula: la clausula no existe
-- Debe fallar: La cláusula indicada no existe para el contrato COP-2026-0001.
CALL contratos.eli_clausula('COP-2026-0001','Clausula inexistente');

-- CN-38 eli_contrato: tiene invitados
-- Debe fallar: No se puede eliminar el contrato COP-2026-0004: tiene invitados o reservas asociados.
CALL contratos.eli_contrato('COP-2026-0004');

-- CN-39 eli_contrato: inexistente
-- Debe fallar: El contrato COP-2026-9999 no existe.
CALL contratos.eli_contrato('COP-2026-9999');


-- RESERVAS ------------------------------
-- CN-40 ad_reserva: se traslapa con otra (ESP-001 hoy 18:00-20:00)
-- Debe fallar: El espacio común ESP-001 ya tiene una reserva en el rango horario solicitado para la fecha <fecha>.
CALL reservas.ad_reserva('ESP-26-0050', CURRENT_DATE, '19:00', '21:00', 'ESP-001', 3, 'COP-2026-0002');

-- CN-41 ad_reserva: supera el aforo (aforo 12, 13 personas)
-- Debe fallar: El aforo solicitado (13) supera el aforo máximo permitido para el espacio común ESP-002.
CALL reservas.ad_reserva('ESP-26-0050', CURRENT_DATE + 7, '10:00', '12:00', 'ESP-002', 13, 'COP-2026-0003');

-- CN-42 ad_reserva: contrato que no esta vigente (Borrador)
-- Debe fallar: El contrato COP-2026-0005 no está vigente: no puede reservar espacios.
CALL reservas.ad_reserva('ESP-26-0050', CURRENT_DATE + 7, '10:00', '12:00', 'ESP-002', 3, 'COP-2026-0005');

-- CN-43 mod_reserva: reserva inexistente
-- Debe fallar: La reserva ESP-26-9999 no existe.
CALL reservas.mod_reserva('ESP-26-9999','Completada');

-- CN-44 mod_reserva: reactivar una reserva cancelada
-- Debe fallar: La reserva ESP-26-0005 está cancelada y no puede reactivarse; registre una nueva.
CALL reservas.mod_reserva('ESP-26-0005','Confirmada');

-- CN-45 eli_reserva: la reserva no esta cancelada
-- Debe fallar: Solo se pueden eliminar reservas que estén en estado Cancelada.
CALL reservas.eli_reserva('ESP-26-0001');

-- CN-46 eli_reserva: inexistente
-- Debe fallar: La reserva ESP-26-9999 no existe.
CALL reservas.eli_reserva('ESP-26-9999');


-- INVITADOS ------------------------------
-- CN-47 ad_invitado: tercer invitado activo en el contrato
-- Debe fallar: Se ha alcanzado el límite máximo de 2 invitados activos simultáneamente para este contrato.
CALL invitados.ad_invitado('INV-0050','Invitado Prueba','CC','1098765050','COP-2026-0001','1000000002');

-- CN-48 ad_invitado: contrato que no esta vigente (Finalizado)
-- Debe fallar: El contrato asociado no se encuentra vigente.
CALL invitados.ad_invitado('INV-0050','Invitado Prueba','CC','1098765050','COP-2026-0006','1000000002');

-- CN-49 mod_invitado: invitado inexistente
-- Debe fallar: El invitado INV-9999 no existe.
CALL invitados.mod_invitado('INV-9999');

-- CN-50 can_invitado: el invitado ya se retiro
-- Debe fallar: El invitado INV-0003 no existe o ya no está en las instalaciones.
CALL invitados.can_invitado('INV-0003');

-- CN-51 eli_invitado: el invitado no esta cancelado
-- Debe fallar: Solo se pueden eliminar invitados que estén en estado Cancelado.
CALL invitados.eli_invitado('INV-0001');

-- CN-52 eli_invitado: inexistente
-- Debe fallar: El invitado INV-9999 no existe.
CALL invitados.eli_invitado('INV-9999');

