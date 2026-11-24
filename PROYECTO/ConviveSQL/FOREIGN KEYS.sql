-------------------------------------------------------
------------- FOREIGN KEYS ----------------------------   
-------------------------------------------------------


-- Propiedades
ALTER TABLE EspaciosComunes ADD CONSTRAINT FK_EspaciosComunes_Propiedad
    FOREIGN KEY (idPropiedad) REFERENCES Propiedades(idPropiedad);
ALTER TABLE Habitaciones ADD CONSTRAINT FK_Habitaciones_Propiedad
    FOREIGN KEY (idPropiedad) REFERENCES Propiedades(idPropiedad);
ALTER TABLE Habitaciones ADD CONSTRAINT FK_Habitaciones_TipoHabitacion
    FOREIGN KEY (tipoHabitacion) REFERENCES TiposDeHabitaciones(idTipoHabitacion);
ALTER TABLE InventariosHabitaciones ADD CONSTRAINT FK_InventariosHabitaciones_Habitaciones
    FOREIGN KEY (idHabitacion) REFERENCES Habitaciones(idHabitacion);

-- Personas (generalizacion: Residentes y Personal son subtipos)
ALTER TABLE Residentes ADD CONSTRAINT FK_Residentes_Persona
    FOREIGN KEY (idResidente) REFERENCES Personas(idPersona);
ALTER TABLE Personal ADD CONSTRAINT FK_Personal_Persona
    FOREIGN KEY (idPersonal) REFERENCES Personas(idPersona);
ALTER TABLE ContactosEmergencia ADD CONSTRAINT FK_ContactosEmergencia_Residentes
    FOREIGN KEY (idResidente) REFERENCES Residentes(idResidente);
-- NUEVA: el contacto de emergencia es una Persona (antes no tenia FK)
ALTER TABLE ContactosEmergencia ADD CONSTRAINT FK_ContactosEmergencia_Personas
    FOREIGN KEY (idContactoEmergencia) REFERENCES Personas(idPersona);

-- Contratos
ALTER TABLE ContratosOcupacion ADD CONSTRAINT FK_ContratosOcupacion_Habitaciones
    FOREIGN KEY (idHabitacion) REFERENCES Habitaciones(idHabitacion);
ALTER TABLE ContratosOcupacion ADD CONSTRAINT FK_ContratosOcupacion_Residente
    FOREIGN KEY (idResidente) REFERENCES Residentes(idResidente);
ALTER TABLE ContratosOcupacion ADD CONSTRAINT FK_ContratosOcupacion_Personal
    FOREIGN KEY (idPersonal) REFERENCES Personal(idPersonal);
ALTER TABLE ContratosLargoPlazo ADD CONSTRAINT FK_ContratosLargoPlazo_ContratosOcupacion
    FOREIGN KEY (idContrato) REFERENCES ContratosOcupacion(idContrato);
ALTER TABLE ContratosCortoPlazo ADD CONSTRAINT FK_ContratosCortoPlazo_ContratosOcupacion
    FOREIGN KEY (idContrato) REFERENCES ContratosOcupacion(idContrato);
ALTER TABLE TienePoliticas ADD CONSTRAINT FK_TienePoliticas_ContratosCortoPlazo
    FOREIGN KEY (idContrato) REFERENCES ContratosCortoPlazo(idContrato);
ALTER TABLE TieneClausulas ADD CONSTRAINT FK_TieneClausulas_ContratosLargoPlazo
    FOREIGN KEY (idContrato) REFERENCES ContratosLargoPlazo(idContrato);

-- Reservas e invitados
ALTER TABLE ReservasEspacios ADD CONSTRAINT FK_ReservasEspacios_EspaciosComunes
    FOREIGN KEY (idEspacio) REFERENCES EspaciosComunes(idEspacio);
ALTER TABLE ReservasEspacios ADD CONSTRAINT FK_ReservasEspacios_ContratosOcupacion
    FOREIGN KEY (idContrato) REFERENCES ContratosOcupacion(idContrato);
ALTER TABLE Invitados ADD CONSTRAINT FK_Invitados_ContratosOcupacion
    FOREIGN KEY (idContrato) REFERENCES ContratosOcupacion(idContrato);
ALTER TABLE Invitados ADD CONSTRAINT FK_Invitados_Personal
    FOREIGN KEY (idPersonal_Registro) REFERENCES Personal(idPersonal);
