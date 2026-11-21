-- =================================
-- ---------- Atributos ------------
-- =================================


ALTER TABLE ContratosOcupacion ALTER COLUMN estadoContrato      SET DEFAULT 'Borrador';
ALTER TABLE Habitaciones       ALTER COLUMN estadoHabitacion    SET DEFAULT 'Disponible';
ALTER TABLE EspaciosComunes    ALTER COLUMN estadoActualEspacio SET DEFAULT 'Disponible';
ALTER TABLE ReservasEspacios   ALTER COLUMN estadoReserva       SET DEFAULT 'Confirmada';
ALTER TABLE ContactosEmergencia ALTER COLUMN esPrincipal        SET DEFAULT FALSE;
ALTER TABLE Invitados          ALTER COLUMN EstadoInvitado      SET DEFAULT 'En las instalaciones';