
-- ========================================
--  -- INDICES ---------------------------
-- ========================================

-- ---- Columnas de FK ----
CREATE INDEX IF NOT EXISTS idx_hab_propiedad     ON Habitaciones (idPropiedad);
CREATE INDEX IF NOT EXISTS idx_hab_tipo          ON Habitaciones (tipoHabitacion);
CREATE INDEX IF NOT EXISTS idx_contr_residente   ON ContratosOcupacion (idResidente);
CREATE INDEX IF NOT EXISTS idx_contr_personal    ON ContratosOcupacion (idPersonal);
CREATE INDEX IF NOT EXISTS idx_reserva_contrato  ON ReservasEspacios (idContrato);
CREATE INDEX IF NOT EXISTS idx_invit_personal    ON Invitados (idPersonal_Registro);
CREATE INDEX IF NOT EXISTS idx_inventario_hab    ON InventariosHabitaciones (idHabitacion);

-- ---- Consultas y triggers ----

CREATE INDEX IF NOT EXISTS idx_contratos_hab_estado ON ContratosOcupacion (idHabitacion, estadoContrato);

CREATE INDEX IF NOT EXISTS idx_hab_disponibles ON Habitaciones (idPropiedad, tipoHabitacion)
    WHERE estadoHabitacion = 'Disponible';


CREATE INDEX IF NOT EXISTS idx_contr_periodo ON ContratosOcupacion (fechaInicio, fechaFin);


CREATE INDEX IF NOT EXISTS idx_reserva_espacio_dia ON ReservasEspacios (idEspacio, (fechaReserva::date))
    WHERE estadoReserva <> 'Cancelada';

CREATE INDEX IF NOT EXISTS idx_invitados_activos ON Invitados (idContrato)
    WHERE EstadoInvitado = 'En las instalaciones';

-- ---- Indices UNICOS parciales: garantizan una regla declarativamente ----

CREATE UNIQUE INDEX IF NOT EXISTS ux_hab_un_contrato_vigente ON ContratosOcupacion (idHabitacion)
    WHERE estadoContrato = 'Vigente';

CREATE UNIQUE INDEX IF NOT EXISTS ux_un_administrador ON Personal (cargoPersonal)
    WHERE cargoPersonal = 'Administrador';

CREATE UNIQUE INDEX IF NOT EXISTS ux_un_contacto_principal ON ContactosEmergencia (idResidente)
    WHERE esPrincipal;
