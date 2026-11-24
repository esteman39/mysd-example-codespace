--------------------------------------------------
---------- Tablas --------------------------------
--------------------------------------------------

CREATE TABLE Propiedades (
    idPropiedad TCHIP,
    nombrePropiedad VARCHAR(100) NOT NULL,
    direccionPropiedad TDireccion NOT NULL,
    ciudadPropiedad VARCHAR(100) NOT NULL
);

CREATE TABLE EspaciosComunes (
    idEspacio TEspacioComun,
    nombreEspacio VARCHAR(100) NOT NULL,
    aforoEspacio TCantidad NOT NULL,
    estadoActualEspacio TEstadoEspacio NOT NULL,
    idPropiedad TCHIP
);

CREATE TABLE ReservasEspacios (
    idReserva TReservaEspacio,
    fechaReserva TIMESTAMP NOT NULL,
    horaInicio TIME NOT NULL,
    horaFin TIME NOT NULL,
    idEspacio TEspacioComun,
    cantidadPersonas TCantidad NOT NULL,
    estadoReserva TEstadoReserva NOT NULL,
    idContrato TIdContrato
);

CREATE TABLE ContratosOcupacion (
    idContrato TIdContrato,
    numeroContrato TNumeroContrato NOT NULL,
    fechaInicio DATE NOT NULL,
    fechaFin DATE NOT NULL,
    valorContrato TMoneda NOT NULL,
    estadoContrato TEstadoContrato NOT NULL,
    idHabitacion TIdHabitacion,
    idResidente TIdentificacion, 
    idPersonal TIdentificacion
);

CREATE TABLE ContratosLargoPlazo(
    idContrato TIdContrato,
    diaCorteMensual TDiaCorte NOT NULL
);

CREATE TABLE ContratosCortoPlazo(
    idContrato TIdContrato,
    totalNoches TCantidad NOT NULL
);

CREATE TABLE TienePoliticas (
    idContrato TIdContrato,
    politicaCancelacion VARCHAR(200) NOT NULL
);

CREATE TABLE TieneClausulas (
    idContrato TIdContrato,
    clausula VARCHAR(200) NOT NULL
);


CREATE TABLE Personas (
    idPersona TIdentificacion,
    nombrePersona VARCHAR(100) NOT NULL,
    TipoIdentificacion TTipoDocumento NOT NULL,
    telefonoPersona TTelefono NOT NULL,
    correoPersona TCorreo NOT NULL
);

CREATE TABLE Residentes (
    idResidente TIdentificacion
);

CREATE TABLE ContactosEmergencia (
    idContactoEmergencia TIdentificacion,
    parentescoContacto VARCHAR(50) NOT NULL,
    esPrincipal BOOLEAN NOT NULL,
    idResidente TIdentificacion
);


CREATE TABLE Personal (
    idPersonal TIdentificacion,
    cargoPersonal TCargo NOT NULL,
    salarioBase TMoneda NOT NULL
);

CREATE TABLE Habitaciones (
    idHabitacion TIdHabitacion,
    tipoHabitacion TTipoHabitacion NOT NULL,
    estadoHabitacion TEstadoHabitacion NOT NULL,
    idPropiedad TCHIP
);  

CREATE TABLE TiposDeHabitaciones (
    idTipoHabitacion TTipoHabitacion,
    nombreTipoHabitacion VARCHAR(100) NOT NULL,
    descripcionTipoHabitacion VARCHAR(200) NOT NULL,
    capacidadMaxima TCantidad NOT NULL,
    tarifaBase TMoneda NOT NULL,
    modalidad TModalidadContrato NOT NULL
);

CREATE TABLE inventarioshabitaciones (
    idInventario TActivo,
    descripcionActivo VARCHAR(200) NOT NULL,
    categoriaActivo TCategoriaActivo NOT NULL,
    nombreActivo VARCHAR(100) NOT NULL,
    estadoInicial TEstadoActivo NOT NULL,
    estadoFinal TEstadoActivo,
    idHabitacion TIdHabitacion
);

CREATE TABLE Invitados (
    idInvitado TIdInvitado,
    nombreInvitado VARCHAR(100) NOT NULL,
    documentoInvitado TDocumentoInvitado NOT NULL,
    TipoIdentificacion TTipoDocumento NOT NULL,
    fechaHoraIngreso TIMESTAMP NOT NULL,
    fechaHoraSalida TIMESTAMP,
    EstadoInvitado TEstadoAcceso NOT NULL,
    idContrato TIdContrato,
    idPersonal_Registro TIdentificacion
);