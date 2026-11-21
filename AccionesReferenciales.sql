-----------------------------------------------------
------------- AccionesReferenciales -----------------
-----------------------------------------------------


ALTER TABLE Habitaciones DROP CONSTRAINT IF EXISTS FK_Habitaciones_Propiedad;
ALTER TABLE Habitaciones ADD CONSTRAINT FK_Habitaciones_Propiedad
    FOREIGN KEY (idPropiedad) REFERENCES Propiedades(idPropiedad)
    ON UPDATE RESTRICT ON DELETE RESTRICT;

ALTER TABLE EspaciosComunes DROP CONSTRAINT IF EXISTS FK_EspaciosComunes_Propiedad;
ALTER TABLE EspaciosComunes ADD CONSTRAINT FK_EspaciosComunes_Propiedad
    FOREIGN KEY (idPropiedad) REFERENCES Propiedades(idPropiedad)
    ON UPDATE RESTRICT ON DELETE RESTRICT;

-- ===== Habitaciones, tipos e inventario =====
ALTER TABLE Habitaciones DROP CONSTRAINT IF EXISTS FK_Habitaciones_TipoHabitacion;
ALTER TABLE Habitaciones ADD CONSTRAINT FK_Habitaciones_TipoHabitacion
    FOREIGN KEY (tipoHabitacion) REFERENCES TiposDeHabitaciones(idTipoHabitacion)
    ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE InventariosHabitaciones DROP CONSTRAINT IF EXISTS FK_InventariosHabitaciones_Habitaciones;
ALTER TABLE InventariosHabitaciones ADD CONSTRAINT FK_InventariosHabitaciones_Habitaciones
    FOREIGN KEY (idHabitacion) REFERENCES Habitaciones(idHabitacion)
    ON UPDATE CASCADE ON DELETE RESTRICT;


ALTER TABLE Residentes DROP CONSTRAINT IF EXISTS FK_Residentes_Persona;
ALTER TABLE Residentes ADD CONSTRAINT FK_Residentes_Persona
    FOREIGN KEY (idResidente) REFERENCES Personas(idPersona)
    ON UPDATE RESTRICT ON DELETE RESTRICT;

ALTER TABLE Personal DROP CONSTRAINT IF EXISTS FK_Personal_Persona;
ALTER TABLE Personal ADD CONSTRAINT FK_Personal_Persona
    FOREIGN KEY (idPersonal) REFERENCES Personas(idPersona)
    ON UPDATE RESTRICT ON DELETE RESTRICT;

ALTER TABLE ContactosEmergencia DROP CONSTRAINT IF EXISTS FK_ContactosEmergencia_Residentes;
ALTER TABLE ContactosEmergencia ADD CONSTRAINT FK_ContactosEmergencia_Residentes
    FOREIGN KEY (idResidente) REFERENCES Residentes(idResidente)
    ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE ContactosEmergencia DROP CONSTRAINT IF EXISTS FK_ContactosEmergencia_Personas;
ALTER TABLE ContactosEmergencia ADD CONSTRAINT FK_ContactosEmergencia_Personas
    FOREIGN KEY (idContactoEmergencia) REFERENCES Personas(idPersona)
    ON UPDATE RESTRICT ON DELETE RESTRICT;

ALTER TABLE ContratosOcupacion DROP CONSTRAINT IF EXISTS FK_ContratosOcupacion_Habitaciones;
ALTER TABLE ContratosOcupacion ADD CONSTRAINT FK_ContratosOcupacion_Habitaciones
    FOREIGN KEY (idHabitacion) REFERENCES Habitaciones(idHabitacion)
    ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE ContratosOcupacion DROP CONSTRAINT IF EXISTS FK_ContratosOcupacion_Residente;
ALTER TABLE ContratosOcupacion ADD CONSTRAINT FK_ContratosOcupacion_Residente
    FOREIGN KEY (idResidente) REFERENCES Residentes(idResidente)
    ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE ContratosOcupacion DROP CONSTRAINT IF EXISTS FK_ContratosOcupacion_Personal;
ALTER TABLE ContratosOcupacion ADD CONSTRAINT FK_ContratosOcupacion_Personal
    FOREIGN KEY (idPersonal) REFERENCES Personal(idPersonal)
    ON UPDATE CASCADE ON DELETE RESTRICT;


ALTER TABLE ContratosLargoPlazo DROP CONSTRAINT IF EXISTS FK_ContratosLargoPlazo_ContratosOcupacion;
ALTER TABLE ContratosLargoPlazo ADD CONSTRAINT FK_ContratosLargoPlazo_ContratosOcupacion
    FOREIGN KEY (idContrato) REFERENCES ContratosOcupacion(idContrato)
    ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE ContratosCortoPlazo DROP CONSTRAINT IF EXISTS FK_ContratosCortoPlazo_ContratosOcupacion;
ALTER TABLE ContratosCortoPlazo ADD CONSTRAINT FK_ContratosCortoPlazo_ContratosOcupacion
    FOREIGN KEY (idContrato) REFERENCES ContratosOcupacion(idContrato)
    ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE TienePoliticas DROP CONSTRAINT IF EXISTS FK_TienePoliticas_ContratosCortoPlazo;
ALTER TABLE TienePoliticas ADD CONSTRAINT FK_TienePoliticas_ContratosCortoPlazo
    FOREIGN KEY (idContrato) REFERENCES ContratosCortoPlazo(idContrato)
    ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE TieneClausulas DROP CONSTRAINT IF EXISTS FK_TieneClausulas_ContratosLargoPlazo;
ALTER TABLE TieneClausulas ADD CONSTRAINT FK_TieneClausulas_ContratosLargoPlazo
    FOREIGN KEY (idContrato) REFERENCES ContratosLargoPlazo(idContrato)
    ON UPDATE CASCADE ON DELETE CASCADE;


ALTER TABLE ReservasEspacios DROP CONSTRAINT IF EXISTS FK_ReservasEspacios_EspaciosComunes;
ALTER TABLE ReservasEspacios ADD CONSTRAINT FK_ReservasEspacios_EspaciosComunes
    FOREIGN KEY (idEspacio) REFERENCES EspaciosComunes(idEspacio)
    ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE ReservasEspacios DROP CONSTRAINT IF EXISTS FK_ReservasEspacios_ContratosOcupacion;
ALTER TABLE ReservasEspacios ADD CONSTRAINT FK_ReservasEspacios_ContratosOcupacion
    FOREIGN KEY (idContrato) REFERENCES ContratosOcupacion(idContrato)
    ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE Invitados DROP CONSTRAINT IF EXISTS FK_Invitados_ContratosOcupacion;
ALTER TABLE Invitados ADD CONSTRAINT FK_Invitados_ContratosOcupacion
    FOREIGN KEY (idContrato) REFERENCES ContratosOcupacion(idContrato)
    ON UPDATE CASCADE ON DELETE RESTRICT;

ALTER TABLE Invitados DROP CONSTRAINT IF EXISTS FK_Invitados_Personal;
ALTER TABLE Invitados ADD CONSTRAINT FK_Invitados_Personal
    FOREIGN KEY (idPersonal_Registro) REFERENCES Personal(idPersonal)
    ON UPDATE CASCADE ON DELETE RESTRICT;
