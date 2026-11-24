-- ===============================
-- AccionesNoOk
-- ===============================


-- RESTRICT en Propiedades: tiene habitaciones y espacios comunes --------------------
-- A-N-01 Eliminar una propiedad con habitaciones
-- Debe fallar: update or delete on table "propiedades" violates foreign key constraint "fk_habitaciones_propiedad" on table "habitaciones"
DELETE FROM Propiedades WHERE idPropiedad = 'AAA0123NORT';

-- A-N-02 Cambiar el id de una propiedad (ON UPDATE RESTRICT: el id es inmutable)
-- Debe fallar: update or delete on table "propiedades" violates foreign key constraint "fk_habitaciones_propiedad" on table "habitaciones"
UPDATE Propiedades SET idPropiedad = 'AAA0999NEWX' WHERE idPropiedad = 'AAA0123NORT';


-- RESTRICT en catalogos, habitaciones y espacios --------------------
-- A-N-03 Eliminar un tipo de habitacion que tiene habitaciones
-- Debe fallar: update or delete on table "tiposdehabitaciones" violates foreign key constraint "fk_habitaciones_tipohabitacion" on table "habitaciones"
DELETE FROM TiposDeHabitaciones WHERE idTipoHabitacion = 'Individual';

-- A-N-04 Eliminar una habitacion que tiene contratos e inventario
-- Debe fallar: update or delete on table "habitaciones" violates foreign key constraint "fk_inventarioshabitaciones_habitaciones" on table "inventarioshabitaciones"
DELETE FROM Habitaciones WHERE idHabitacion = 'HAB-105';

-- A-N-05 Eliminar un espacio comun que tiene reservas
-- Debe fallar: update or delete on table "espacioscomunes" violates foreign key constraint "fk_reservasespacios_espacioscomunes" on table "reservasespacios"
DELETE FROM EspaciosComunes WHERE idEspacio = 'ESP-001';


-- RESTRICT en personas: residentes, personal y contactos --------------------
-- A-N-06 Eliminar un residente que tiene contratos
-- Debe fallar: update or delete on table "residentes" violates foreign key constraint "fk_contratosocupacion_residente" on table "contratosocupacion"
DELETE FROM Residentes WHERE idResidente = '1010000001';

-- A-N-07 Eliminar personal que registro contratos
-- Debe fallar: update or delete on table "personal" violates foreign key constraint "fk_contratosocupacion_personal" on table "contratosocupacion"
DELETE FROM Personal WHERE idPersonal = '1000000002';

-- A-N-08 Eliminar la persona que figura como contacto de emergencia
-- Debe fallar: update or delete on table "personas" violates foreign key constraint "fk_contactosemergencia_personas" on table "contactosemergencia"
DELETE FROM Personas WHERE idPersona = '1020000001';

-- A-N-09 Eliminar la persona que es residente
-- Debe fallar: update or delete on table "personas" violates foreign key constraint "fk_residentes_persona" on table "residentes"
DELETE FROM Personas WHERE idPersona = '1010000001';

-- A-N-10 Cambiar el documento de una persona (ON UPDATE RESTRICT: es inmutable)
-- Debe fallar: update or delete on table "personas" violates foreign key constraint "fk_residentes_persona" on table "residentes"
UPDATE Personas SET idPersona = '1010009999' WHERE idPersona = '1010000001';


-- RESTRICT en el historial del contrato (invitados y reservas) --------------------
-- A-N-11 Eliminar un contrato que tiene invitados
-- Debe fallar: update or delete on table "contratosocupacion" violates foreign key constraint "fk_invitados_contratosocupacion" on table "invitados"
DELETE FROM ContratosOcupacion WHERE idContrato = 'COP-2026-0004';

-- Como el DELETE fallo, el CASCADE hacia el subtipo tampoco ocurrio: la fila sigue
-- Esperado: 1
SELECT COUNT(*) FROM ContratosCortoPlazo WHERE idContrato = 'COP-2026-0004';

-- A-N-12 Eliminar un contrato que tiene reservas
-- Debe fallar: update or delete on table "contratosocupacion" violates foreign key constraint "fk_reservasespacios_contratosocupacion" on table "reservasespacios"
DELETE FROM ContratosOcupacion WHERE idContrato = 'COP-2026-0007';

-- Las clausulas tampoco se borraron (la operacion es atomica)
-- Esperado: 1
SELECT COUNT(*) FROM TieneClausulas WHERE idContrato = 'COP-2026-0007';

