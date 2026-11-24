-----------------------------------------------
------------------ PRIMARY (PK) -----------------
-------------------------------------------------

ALTER TABLE Propiedades ADD CONSTRAINT PK_Propiedad PRIMARY KEY (idPropiedad);

ALTER TABLE EspaciosComunes ADD CONSTRAINT PK_EspacioComun PRIMARY KEY (idEspacio);

ALTER TABLE ReservasEspacios ADD CONSTRAINT PK_ReservaEspacio PRIMARY KEY (idReserva);

ALTER TABLE ContratosOcupacion ADD CONSTRAINT PK_ContratoOcupacion PRIMARY KEY (idContrato);

ALTER TABLE ContratosLargoPlazo ADD CONSTRAINT PK_ContratoLargoPlazo PRIMARY KEY (idContrato);

ALTER TABLE ContratosCortoPlazo ADD CONSTRAINT PK_ContratoCortoPlazo PRIMARY KEY (idContrato);

ALTER TABLE Personas ADD CONSTRAINT PK_Persona PRIMARY KEY (idPersona);

ALTER TABLE Residentes ADD CONSTRAINT PK_Residente PRIMARY KEY (idResidente);

ALTER TABLE Personal ADD CONSTRAINT PK_Personal PRIMARY KEY (idPersonal);

ALTER TABLE Habitaciones    ADD CONSTRAINT PK_Habitacion PRIMARY KEY (idHabitacion);

ALTER TABLE TiposDeHabitaciones ADD CONSTRAINT PK_TipoHabitacion PRIMARY KEY (idTipoHabitacion);

ALTER TABLE InventariosHabitaciones ADD CONSTRAINT PK_Inventario PRIMARY KEY (idInventario);

ALTER TABLE Invitados ADD CONSTRAINT PK_Invitado PRIMARY KEY (idInvitado);

ALTER TABLE ContactosEmergencia ADD CONSTRAINT PK_ContactoEmergencia PRIMARY KEY (idResidente, idContactoEmergencia);

ALTER TABLE TienePoliticas ADD CONSTRAINT PK_TienePoliticas PRIMARY KEY (idContrato, politicaCancelacion);

ALTER TABLE TieneClausulas ADD CONSTRAINT PK_TieneClausulas PRIMARY KEY (idContrato, clausula);