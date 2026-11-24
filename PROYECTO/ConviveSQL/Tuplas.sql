-- =========================================
-- ----------- Tuplas (Checks) -----------
-- =========================================
-- Restriccion 1: la fecha de fin es posterior a la de inicio
ALTER TABLE ContratosOcupacion
ADD CONSTRAINT CHK_Contrato_Fechas
CHECK (fechaFin > fechaInicio);

-- Restriccion 2: duracion maxima de un contrato: 1 año
ALTER TABLE ContratosOcupacion
ADD CONSTRAINT CHK_Contrato_Duracion
CHECK (fechaFin <= fechaInicio + INTERVAL '1 year');

-- Restriccion 3: la hora de fin de una reserva es posterior a la de inicio
ALTER TABLE ReservasEspacios
ADD CONSTRAINT CHK_Reserva_Horas
CHECK (horaFin > horaInicio);

-- Restriccion 4: la salida de un invitado es posterior a su ingreso (si ya salio)
ALTER TABLE Invitados
ADD CONSTRAINT CHK_Invitado_Fechas
CHECK (fechaHoraSalida IS NULL OR fechaHoraSalida > fechaHoraIngreso);

-- Restriccion 5: el prefijo del id del activo coincide con su categoria
-- (MOB-SILLA-0101 debe tener categoriaActivo = 'MOB')
ALTER TABLE InventariosHabitaciones
ADD CONSTRAINT CHK_Inventario_Prefijo
CHECK (LEFT(idInventario, 3) = categoriaActivo);
