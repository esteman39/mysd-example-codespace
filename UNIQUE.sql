-----------------------------------------
---------------- UNIQUE -----------------
-----------------------------------------
-- Alternativas de negocio que no pueden repetirse (la PK ya cubre el id).

-- Un correo identifica a una sola persona
ALTER TABLE Personas ADD CONSTRAINT UQ_Persona_Correo UNIQUE (correoPersona);

-- No pueden existir dos tipos de habitacion con el mismo nombre comercial
ALTER TABLE TiposDeHabitaciones ADD CONSTRAINT UQ_TipoHabitacion_Nombre UNIQUE (nombreTipoHabitacion);

-- El numero de contrato (4 digitos) es el numero visible para el residente
ALTER TABLE ContratosOcupacion ADD CONSTRAINT UQ_Contrato_Numero UNIQUE (numeroContrato);

-- Una direccion en una ciudad corresponde a una sola propiedad
ALTER TABLE Propiedades ADD CONSTRAINT UQ_Propiedad_Direccion UNIQUE (direccionPropiedad, ciudadPropiedad);

-- Dentro de una propiedad no se repite el nombre de un espacio comun
ALTER TABLE EspaciosComunes ADD CONSTRAINT UQ_Espacio_Propiedad_Nombre UNIQUE (idPropiedad, nombreEspacio);