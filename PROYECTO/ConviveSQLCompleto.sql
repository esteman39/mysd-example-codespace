--------------------------------------------------
---------- Tablas --------------------------------
--------------------------------------------------

CREATE TABLE Propiedades(
    idPropiedad TCHIP,
    nombrePropiedad VARCHAR(100) NOT NULL,
    direccionPropiedad TDireccion NOT NULL,
    ciudadPropiedad VARCHAR(100) NOT NULL
);

CREATE TABLE EspaciosComunes (
    idEspacio TEspacioComun,
    nombreEspacio VARCHAR(100) NOT NULL,
    aforoEspacio NUMERIC NOT NULL,
    estadoActualEspacio TEstadoEspacio NOT NULL,
    idPropiedad TCHIP
);

CREATE TABLE ReservasEspacios (
    idReserva TReservaEspacio,
    fechaReserva TIMESTAMP NOT NULL,
    horaInicio TIME NOT NULL,
    horaFin TIME NOT NULL,
    idEspacio TEspacioComun,
    cantidadPersonas NUMERIC NOT NULL,
    estadoReserva TEstadoReserva NOT NULL,
    idContrato TIdContrato
);

CREATE TABLE ContratosOcupacion (
    idContrato TIdContrato,
    numeroContrato TNumeroContrato NOT NULL,
    fechaInicio DATE NOT NULL,
    fechaFin DATE NULL,
    valorContrato TMoneda NOT NULL,
    estadoContrato TEstadoContrato NOT NULL,
    idHabitacion TIdHabitacion,
    idResidente TIdentificacion, 
    idPersonal TIdentificacion
);

CREATE TABLE ContratosLargoPlazo(
    idContrato TIdContrato,
    diaCorteMensual NUMERIC NOT NULL
);

CREATE TABLE ContratosCortoPlazo(
    idContrato TIdContrato,
    fechaInicio DATE NOT NULL
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
    telefonoPersona VARCHAR(15) NOT NULL,
    correoPersona VARCHAR(50) NOT NULL
);

CREATE TABLE Residentes (
    idResidente TIdentificacion
);

CREATE TABLE ContactosEmergencia (
    idContactoEmergencia TIdentificacion,
    parentesco VARCHAR(50) NOT NULL,
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
    capacidadMaxima NUMERIC NOT NULL,
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
    idInvitado TIdentificacion,
    nombreInvitado VARCHAR(100) NOT NULL,
    TipoIdentificacion TTipoDocumento NOT NULL,
    fechaHoraIngreso TIMESTAMP NOT NULL,
    fechaHoraSalida TIMESTAMP,
    EstadoInvitado TEstadoAcceso NOT NULL,
    idContrato TIdContrato,
    idPersonal_Registro TIdentificacion
);

-------------------------------------------------
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

ALTER TABLE ContactosEmergencia ADD CONSTRAINT PK_ContactoEmergencia PRIMARY KEY (idContactoEmergencia);

ALTER TABLE TienePoliticas ADD CONSTRAINT PK_TienePoliticas PRIMARY KEY (idContrato);

ALTER TABLE TieneClausulas ADD CONSTRAINT PK_TieneClausulas PRIMARY KEY (idContrato);

-------------------------------------------------
------------------ FOREIGN (FK) -----------------  
-------------------------------------------------

ALTER TABLE EspaciosComunes ADD CONSTRAINT FK_EspaciosComunes_Propiedad FOREIGN KEY (idPropiedad) REFERENCES Propiedades(idPropiedad);

ALTER TABLE ReservasEspacios ADD CONSTRAINT FK_ReservasEspacios_EspaciosComunes FOREIGN KEY (idEspacio) REFERENCES EspaciosComunes(idEspacio);

ALTER TABLE InventariosHabitaciones ADD CONSTRAINT FK_InventariosHabitaciones_Habitaciones FOREIGN KEY (idHabitacion) REFERENCES Habitaciones(idHabitacion);

ALTER TABLE ContratosOcupacion ADD CONSTRAINT FK_ContratosOcupacion_Habitaciones FOREIGN KEY (idHabitacion) REFERENCES Habitaciones(idHabitacion);

ALTER TABLE ContratosOcupacion ADD CONSTRAINT FK_ContratosOcupacion_Residente FOREIGN KEY (idResidente) REFERENCES Residentes(idResidente);

ALTER TABLE ContratosOcupacion ADD CONSTRAINT FK_ContratosOcupacion_Personal FOREIGN KEY (idPersonal) REFERENCES Personal(idPersonal);

ALTER TABLE ContratosLargoPlazo ADD CONSTRAINT FK_ContratosLargoPlazo_ContratosOcupacion FOREIGN KEY (idContrato) REFERENCES ContratosOcupacion(idContrato);

ALTER TABLE ContratosCortoPlazo ADD CONSTRAINT FK_ContratosCortoPlazo_ContratosOcupacion FOREIGN KEY (idContrato) REFERENCES ContratosOcupacion(idContrato);

ALTER TABLE ContactosEmergencia ADD CONSTRAINT FK_ContactosEmergencia_Residentes FOREIGN KEY (idResidente) REFERENCES Residentes(idResidente);

ALTER TABLE Invitados ADD CONSTRAINT FK_Invitados_ContratosOcupacion FOREIGN KEY (idContrato) REFERENCES ContratosOcupacion(idContrato);

ALTER TABLE Invitados ADD CONSTRAINT FK_Invitados_Personal FOREIGN KEY (idPersonal_Registro) REFERENCES Personal(idPersonal);

ALTER TABLE Habitaciones ADD CONSTRAINT FK_Habitaciones_Propiedad FOREIGN KEY (idPropiedad) REFERENCES Propiedades(idPropiedad);

ALTER TABLE Habitaciones ADD CONSTRAINT FK_Habitaciones_TipoHabitacion FOREIGN KEY (tipoHabitacion) REFERENCES TiposDeHabitaciones(idTipoHabitacion);

ALTER TABLE TiposDeHabitaciones ADD CONSTRAINT FK_TiposDeHabitaciones_Habitaciones FOREIGN KEY (idTipoHabitacion) REFERENCES Habitaciones(idHabitacion);

ALTER TABLE TienePoliticas ADD CONSTRAINT FK_TienePoliticas_ContratosCortoPlazo FOREIGN KEY (idContrato) REFERENCES ContratosCortoPlazo(idContrato);

ALTER TABLE TieneClausulas ADD CONSTRAINT FK_TieneClausulas_ContratosLargoPlazo FOREIGN KEY (idContrato) REFERENCES ContratosLargoPlazo(idContrato);

ALTER TABLE ReservasEspacios ADD CONSTRAINT FK_ReservasEspacios_ContratosOcupacion FOREIGN KEY (idContrato) REFERENCES ContratosOcupacion(idContrato);

ALTER TABLE Residentes ADD CONSTRAINT FK_Residentes_Persona FOREIGN KEY (idResidente) REFERENCES Personas(idPersona);

ALTER TABLE Personal ADD CONSTRAINT FK_Personal_Persona FOREIGN KEY (idPersonal) REFERENCES Personas (idPersona);

ALTER TABLE InventariosHabitaciones ADD CONSTRAINT FK_InventariosHabitaciones_Habitaciones FOREIGN KEY (idHabitacion) REFERENCES Habitaciones(idHabitacion);


-----------------------------------------
---------------- UNIQUE -----------------
-----------------------------------------

ALTER TABLE Personas ADD CONSTRAINT UQ_Persona_Correo UNIQUE (correoPersona);


----------------------------------------
--------------- DOMINIOS ---------------
----------------------------------------
-- 1. Dominio para el identificador catastral del inmueble
CREATE DOMAIN TCHIP AS VARCHAR(30)
CHECK (VALUE ~ '^[A-Z0-9\-]+$' AND VALUE ~ '^[A-Z]{2,}');

-- 2. Dominio para el identificador único de la habitación
CREATE DOMAIN TIdHabitacion AS VARCHAR(15)
CHECK ( VALUE ~ '^HAB-[A-Z0-9]{1,10}$');

-- 3. Dominio de texto con restricción de valores permitidos para el tipo de habitación
CREATE DOMAIN TTipoHabitacion AS VARCHAR(30)
CHECK (VALUE IN ('Individual', 'Compartida', 'Doble', 'Suite'));

-- 4. Dominio para el identificador de activos del inventario
CREATE DOMAIN TActivo AS VARCHAR(20)
CHECK (VALUE ~ '^[A-Z]{3}-[A-Z]+-[0-9]{4}$');

-- 5. Dominio con restricción de valores permitidos para el estado de los bienes muebles
CREATE DOMAIN TEstadoActivo AS VARCHAR(20)
CHECK (VALUE IN ('Nuevo', 'Bueno', 'Deteriorado', 'Dado de Baja'));

-- 6. Dominio para el identificador de las zonas compartidas
CREATE DOMAIN TEspacioComun AS VARCHAR(10)  
CHECK ( VALUE ~ '^ESP-[0-9]{1,5}$');

-- 7. Dominio para la disponibilidad de la zona
CREATE DOMAIN TEstadoEspacio AS VARCHAR(30)
CHECK (VALUE IN ('Disponible', 'En Mantenimiento', 'Clausurado'));

-- 8. Dominio para el identificador único de la transacción de préstamo de zona común
CREATE DOMAIN TReservaEspacio AS VARCHAR(20)
CHECK (VALUE ~ '^ESP-[0-9]{2}-[0-9]{4}$');

-- 9. Dominio para el ciclo de vida de la reserva
CREATE DOMAIN TEstadoReserva AS VARCHAR(20)
CHECK (VALUE IN ('Confirmada', 'Cancelada', 'Completada'));

-- 10. Dominio para el número de documento de identidad oficial
CREATE DOMAIN TIdentificacion AS VARCHAR(20)
CHECK (VALUE ~ '^[A-Z0-9]{2,20}$');

-- 11. Dominio para los tipos de documentos permitidos
CREATE DOMAIN TTipoDocumento AS VARCHAR(5)
CHECK (VALUE IN ('CC', 'CE', 'PP'));

-- 12. Dominio para los roles del personal administrativo
CREATE DOMAIN TCargo AS VARCHAR(30)
CHECK (VALUE IN ('Recepcionista', 'Administrador', 'Mantenimiento'));

-- 13. Dominio para el identificador único del acuerdo de ocupación
CREATE DOMAIN TIdContrato AS VARCHAR(20)
CHECK (VALUE ~ '^COP-[0-9]+-[0-9]{4}$');

-- 14. Dominio para el tipo de dato numérico con precisión decimal para valores monetarios
CREATE DOMAIN TMoneda AS DECIMAL(12,2)
CHECK (VALUE >= 0);

-- 15. Dominio para la vigencia del contrato
CREATE DOMAIN TEstadoContrato AS VARCHAR(20)
CHECK (VALUE IN ('Borrador', 'Vigente', 'Finalizado', 'Cancelado'));

-- 16. Dominio para el identificador único del registro de visita
CREATE DOMAIN TIdInvitado AS VARCHAR(20)
CHECK (VALUE ~ '^INV-[0-9]{4}$');

-- 17. Dominio para el documento de identidad del visitante externo
CREATE DOMAIN TDocumentoInvitado AS VARCHAR(20)
CHECK (VALUE ~ '^[A-Z0-9]{6,20}$');

-- 18. Dominio para el estado de acceso en tiempo real
CREATE DOMAIN TEstadoAcceso AS VARCHAR(25)
CHECK (VALUE IN ('En las instalaciones', 'Retirado', 'Cancelado'));

-- 19. Dominnio para la direccion de el lugar de residencia
CREATE DOMAIN TDireccion AS VARCHAR(200)
CHECK (VALUE ~ '^[A-Za-z0-9\s\.,#-]+$');


-- 20. Dominio para el numero de contrato
CREATE DOMAIN TNumeroContrato AS VARCHAR(20)
CHECK (VALUE ~'^[0-9]{4}$');
    
-- 21. Dominio para la categoria de los activos
CREATE DOMAIN TCategoriaActivo AS VARCHAR(50)
CHECK (VALUE IN ('MOB', 'ELE', 'COM', 'COC', 'TEX', 'SEG'));
--------------------------------------------------
----------------- XTablas ------------------------
--------------------------------------------------
DROP TABLE IF EXISTS ContactosEmergencia;
DROP TABLE IF EXISTS TienePoliticas;   
DROP TABLE IF EXISTS TieneClausulas;
DROP TABLE IF EXISTS ReservasEspacios;
DROP TABLE IF EXISTS ContratosLargoPlazo;
DROP TABLE IF EXISTS ContratosCortoPLazo;
DROP TABLE IF EXISTS ContratosOcupacion;
DROP TABLE IF EXISTS Propiedades;
DROP TABLE IF EXISTS InventariosHabitaciones;
DROP TABLE IF EXISTS Invitados;
DROP TABLE IF EXISTS Personas;
DROP TABLE IF EXISTS Personal;
DROP TABLE IF EXISTS Residentes;
DROP TABLE IF EXISTS TiposDeHabitaciones;
DROP TABLE IF EXISTS Habitaciones;
DROP TABLE IF EXISTS EspaciosComunes;

---------------------------------------------------
--------------- Consultas -------------------------
---------------------------------------------------

SELECT 
    p.nombrepropiedad,
    h.idhabitacion AS numero_habitacion,
    th.nombreTipoHabitacion AS tipo_habitacion,
    h.estadoHabitacion AS estado_habitacion,
    th.tarifaBase
FROM Habitaciones h
JOIN Propiedades p ON h.idpropiedad = p.idpropiedad
JOIN TiposDeHabitaciones th ON h.tipohabitacion = th.idtipohabitacion
ORDER BY p.nombrepropiedad, h.idhabitacion;

SELECT 
    c.idcontrato,
    per.nombrepersona AS nombre_residente,
    per.telefonopersona AS telefono_residente,
    h.idhabitacion AS numero_habitacion,
    c.fechainicio,
    c.fechafin,
    c.valorContrato,
    CASE 
        WHEN cl.idcontrato IS NOT NULL THEN 'Largo Plazo'
        WHEN cc.idcontrato IS NOT NULL THEN 'Corto Plazo'
        ELSE 'General'
    END AS tipo_contrato
FROM Contratosocupacion c
JOIN Residentes r ON c.idresidente = r.idResidente
JOIN Personas per ON r.idResidente = per.idPersona
JOIN Habitaciones h ON c.idhabitacion = h.idhabitacion
LEFT JOIN ContratosLargoPlazo cl ON c.idcontrato = cl.idcontrato
LEFT JOIN ContratosCortoPlazo cc ON c.idcontrato = cc.idcontrato
WHERE c.estadoContrato = 'Vigente';


SELECT 
    re.idreserva,
    ec.nombreespacio,
    re.fechaReserva,
    re.horaInicio,
    re.horaFin,
    re.cantidadpersonas,
    per.nombrepersona AS residente_responsable,
    h.idhabitacion AS numero_habitacion
FROM ReservasEspacios re
JOIN EspaciosComunes ec ON re.idespacio = ec.idespacio
JOIN Contratosocupacion c ON re.idcontrato = c.idcontrato
JOIN Residentes r ON c.idresidente = r.idResidente
JOIN Personas   per ON r.idResidente = per.idPersona
JOIN Habitaciones h ON c.idhabitacion = h.idhabitacion
WHERE DATE(re.fechaReserva) = CURRENT_DATE 
  AND re.estadoReserva = 'Confirmada'
ORDER BY re.horaInicio;

SELECT 
    h.idhabitacion AS numero_habitacion,
    inv.idinventario,
    inv.nombreactivo,
    inv.estadoinicial,
    inv.estadofinal
FROM inventarioshabitaciones inv
JOIN Habitaciones h ON inv.idhabitacion = h.idhabitacion
WHERE inv.estadofinal IN ('Deteriorado', 'Dado de Baja')
   OR inv.estadoinicial != inv.estadofinal;


-------------------------------------------------
------------------ PoblarOk ---------------------
-------------------------------------------------
-- 1. Propiedades
INSERT INTO Propiedades VALUES ('COL1234ABCD', 'Sede Norte Bogotá', 'Calle 100 # 15-20', 'Bogotá');

-- 2. Espacios Comunes
INSERT INTO EspaciosComunes VALUES ('ESP-01', 'Coworking Central', 25, 'Disponible', 'COL1234ABCD');

-- 3. Tipos de Habitaciones
INSERT INTO TiposDeHabitaciones VALUES ('Individual', 'Habitación Estandar', 'Cama sencilla y escritorio', 1, 1200000.00, 'Mensual');

-- 4. Habitaciones
INSERT INTO Habitaciones VALUES ('HAB-101', 'Individual', 'Disponible', 'COL1234ABCD');

-- 5. Personas (Residente y Personal)
INSERT INTO Personas VALUES ('RES12345', 'Carlos Perez', 'CC', '3101234567', 'carlos.perez@email.com');
INSERT INTO Personas VALUES ('PER98765', 'Ana Gomez', 'CC', '3209876543', 'ana.gomez@email.com');

-- 6. Herencia Personas
INSERT INTO Residentes VALUES ('RES12345');
INSERT INTO Personal VALUES ('PER98765', 'Recepcionista', 1800000.00);

-- 7. Contratos de Ocupación
INSERT INTO ContratosOcupacion VALUES ('COP-2026-0001', '0001', '2026-01-01', NULL, 1200000.00, 'Vigente', 'HAB-101', 'RES12345', 'PER98765');
INSERT INTO ContratosLargoPlazo VALUES ('COP-2026-0001', 5);
INSERT INTO TieneClausulas VALUES ('COP-2026-0001', 'Cláusula de convivencia estándar.');

-- 8. Inventario
INSERT INTO InventariosHabitaciones VALUES ('MOB-SILLA-101', 'Silla de escritorio ergonómica', 'MOB', 'Silla Oficina', 'Nuevo', NULL, 'HAB-101');

-- 9. Invitados
INSERT INTO Invitados VALUES ('INV-001', 'Maria Rodriguez', 'CC', '2026-10-17 10:00:00', NULL, 'En las instalaciones', 'COP-2026-0001', 'PER98765');

-- 10. Reservas
INSERT INTO ReservasEspacios VALUES ('ESP-001-001', '2026-10-18', '14:00:00', '16:00:00', 'ESP-001', 2, 'Confirmada', 'COP-2026-0001');

--------------------------------------------------
------------------ PoblarNoOk --------------------
--------------------------------------------------

-- PRUEBA 1: Falla por expresión regular del dominio TCHIP (letras minúsculas o formato incorrecto)
INSERT INTO Propiedades VALUES ('col1234abcd', 'Sede Error', 'Calle Falsa 123', 'Bogotá');

-- PRUEBA 2: Falla por restricción NOT NULL en nombrePropiedad
INSERT INTO Propiedades VALUES ('COL5678WXYZ', NULL, 'Carrera 7', 'Bogotá');

-- PRUEBA 3: Falla por Clave Foránea (Intentar asignar habitación a una propiedad inexistente)
INSERT INTO Habitaciones VALUES ('HAB-999', 'Individual', 'Disponible', 'COL9999WXYZ');

-- PRUEBA 4: Falla por Dominio TEstadoActivo (Estado no permitido dentro de la lista)
INSERT INTO InventariosHabitaciones VALUES ('MOB-MESA-002', 'Mesa de centro', 'MOB', 'Mesa', 'ExcelenteEstado', NULL, 'HAB-101');

-- PRUEBA 5: Falla por valor monetario negativo en TMoneda
INSERT INTO TiposDeHabitaciones VALUES ('Suite', 'Penthouse', 'Lujosa', 2, -500.00, 'Mensual');

-- PRUEBA 6: Falla por restricción UNIQUE en correoPersona
INSERT INTO Personas VALUES ('RES99999', 'Otro Usuario', 'CC', '3000000000', 'carlos.perez@email.com');

-------------------------------------------------------
------------------ xPoblar ----------------------------
-------------------------------------------------------
DELETE FROM ReservasEspacios;
DELETE FROM Invitados;
DELETE FROM InventariosHabitaciones;
DELETE FROM ContactosEmergencia;
DELETE FROM TieneClausulas;
DELETE FROM TienePoliticas;
DELETE FROM ContratosLargoPlazo;
DELETE FROM ContratosCortoPlazo;
DELETE FROM ContratosOcupacion;
DELETE FROM Habitaciones;
DELETE FROM TiposDeHabitaciones;
DELETE FROM EspaciosComunes;
DELETE FROM Personal;
DELETE FROM Residentes;
DELETE FROM Personas;
DELETE FROM Propiedades;

---------------------------------------------------------
--------------------- Tuplas ----------------------------
---------------------------------------------------------
-- Restricción 1: En los contratos, la fecha de fin debe ser mayor o igual a la fecha de inicio (si está definida)
ALTER TABLE ContratosOcupacion 
ADD CONSTRAINT CHK_Contrato_Fechas 
CHECK ( fechaFin > fechaInicio);

-- Restricción 2: En las reservas de espacios, la hora de fin debe ser estrictamente mayor a la hora de inicio
ALTER TABLE ReservasEspacios 
ADD CONSTRAINT CHK_Reserva_Horas 
CHECK (horaFin > horaInicio);

-- Restricción 3: En los contratos de largo plazo, el día de corte mensual debe estar entre 1 y 28
ALTER TABLE ContratosLargoPlazo
ADD CONSTRAINT CHK_ContratoLargo_DiaCorte
CHECK (diaCorteMensual BETWEEN 1 AND 28);

-- Restricción 4: En los contratos de corto plazo, el total de noches debe ser mayor a 0
ALTER TABLE ContratosCortoPlazo
ADD CONSTRAINT CHK_ContratoCorto_TotalNoches    
CHECK (totalNoches > 0);

-- Restricción 5: En los contactos de emergencia, solo puede haber un contacto principal por residente
ALTER TABLE ContactosEmergencia
ADD CONSTRAINT UQ_ContactoEmergencia_Principal
UNIQUE (idResidente, esPrincipal)
WHERE esPrincipal = TRUE;

-- Restricción 6: En los invitados, la fecha y hora de salida debe ser mayor a la fecha y hora de ingreso (si está definida)
ALTER TABLE Invitados
ADD CONSTRAINT CHK_Invitado_Fechas
CHECK (fechaHoraSalida IS NULL OR fechaHoraSalida > fechaHoraIngreso);

---------------------------------------------
------------- TuplasOk ---------------------
---------------------------------------------


-- 1. Contrato con fechas válidas (fin posterior a inicio y menor a 1 año)
INSERT INTO ContratosOcupacion VALUES ('COP-2026-001', '1001', '2026-06-01', '2026-12-01', 1200000.00, 'Vigente', 'HAB-101', 'RES12345', 'PER98765');

-- 2. Reserva de espacio con hora de fin estrictamente mayor a la de inicio
INSERT INTO ReservasEspacios VALUES ('ESP-01', '2026-10-25', '09:00:00', '11:00:00', 'ESP-001', 2, 'Confirmada', 'COP-2026-0001');

-- 3. Contrato de largo plazo con día de corte mensual válido (entre 1 y 28)
INSERT INTO ContratosLargoPlazo VALUES ('COP-2026-0002', 15);

-- 4. Contrato de corto plazo con total de noches mayor a 0
-- (Primero creamos un contrato de corto plazo válido)
INSERT INTO ContratosOcupacion VALUES ('COP-2026-002', '002', '2026-06-01', '2026-06-05', 500000.00, 'Vigente', 'HAB-102', 'RES12345', 'PER98765');
INSERT INTO ContratosCortoPlazo VALUES ('COP-2026-002', 4);

-- 5. Contacto de emergencia principal único por residente
INSERT INTO Personas VALUES ('EMER80990', 'Maria Lopez', 'CC', '3001234567', 'maria.lopez@email.com');
INSERT INTO ContactosEmergencia VALUES ('EMER80990', 'Madre', TRUE, 'RES12345');

-- 6. Invitado con fecha de salida mayor a la de ingreso
INSERT INTO Invitados VALUES ('INV-001', 'Lucía Gomez', 'CC', '2026-10-20 14:00:00', '2026-10-20 18:00:00', 'Retirado', 'COP-2026-0001', 'PER98765');

------------------------------------------------------------
------------------- TuplasNoOk ----------------------------
------------------------------------------------------------

-- 1. Contrato con fecha de fin anterior a la de inicio
INSERT INTO ContratosOcupacion VALUES ('COP-2026-003', '003', '2026-06-01', '2026-05-31', 1200000.00, 'Vigente', 'HAB-101', 'RES12345', 'PER98765');
-- 2. Reserva de espacio con hora de fin igual a la de inicio
INSERT INTO ReservasEspacios VALUES ('ESP-02', '2026-10-25', '10:00:00', '10:00:00', 'ESP-001', 2, 'Confirmada', 'COP-2026-0001');
-- 3. Contrato de largo plazo con día de corte mensual fuera del rango permitido
INSERT INTO ContratosLargoPlazo VALUES ('COP-2026-004', 30);
-- 4. Contrato de corto plazo con total de noches igual a 0 
INSERT INTO ContratosCortoPlazo VALUES ('COP-2026-005', 0);
-- 5. Contacto de emergencia principal duplicado para un mismo residente
INSERT INTO Personas VALUES ('EMER80991', 'Juan Lopez', 'CC', '3007654321', 'juan.lopez@email.com');
INSERT INTO ContactosEmergencia VALUES ('EMER80991', 'Padre', TRUE, 'RES12345');
-- 6. Invitado con fecha de salida anterior a la de ingreso
INSERT INTO Invitados VALUES ('INV-002', 'Juan Martinez', 'CC', '2026-10-20 15:00:00', '2026-10-20 14:00:00', 'Retirado', 'COP-2026-0001', 'PER98765'); 


------------- AccionesReferenciales -----------------
-----------------------------------------------------
-- Si se intenta eliminar una propiedad con elementos asociados, se restringe
ALTER TABLE Habitaciones DROP CONSTRAINT IF EXISTS FK_Habitaciones_Propiedad;
ALTER TABLE Habitaciones ADD CONSTRAINT FK_Habitaciones_Propiedad 
FOREIGN KEY (idPropiedad) REFERENCES Propiedades(idPropiedad) 
ON UPDATE CASCADE ON DELETE RESTRICT;

-- Si se elimina un contrato, se eliminan en cascada sus especializaciones (largo/corto plazo)
ALTER TABLE ContratosLargoPlazo DROP CONSTRAINT IF EXISTS FK_ContratosLargoPlazo_ContratosOcupacion;
ALTER TABLE ContratosLargoPlazo ADD CONSTRAINT FK_ContratosLargoPlazo_ContratosOcupacion 
FOREIGN KEY (idContrato) REFERENCES ContratosOcupacion(idContrato) 
ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE ContratosCortoPlazo DROP CONSTRAINT IF EXISTS FK_ContratosCortoPlazo_ContratosOcupacion;
ALTER TABLE ContratosCortoPlazo ADD CONSTRAINT FK_ContratosCortoPlazo_ContratosOcupacion 
FOREIGN KEY (idContrato) REFERENCES ContratosOcupacion(idContrato) 
ON UPDATE CASCADE ON DELETE CASCADE;

-- Si se elimina un contrato, se eliminan en cascada los invitados asociados 

ALTER TABLE invitados DROP CONSTRAINT IF EXISTS FK_Invitados_ContratosOcupacion;
ALTER TABLE invitados ADD CONSTRAINT FK_Invitados_ContratosOcupacion
FOREIGN KEY (idContrato) REFERENCES ContratosOcupacion(idContrato)
ON UPDATE CASCADE ON DELETE CASCADE;

-- Si se elimina un contrato, se eliminan en cascada las reservas asociadas
ALTER TABLE ReservasEspacios DROP CONSTRAINT IF EXISTS FK_ReservasEspacios_ContratosOcupacion;
ALTER TABLE ReservasEspacios ADD CONSTRAINT FK_ReservasEspacios_ContratosOcupacion
FOREIGN KEY (idContrato) REFERENCES ContratosOcupacion(idContrato) 
ON UPDATE CASCADE ON DELETE CASCADE;

-- si se elimina una propiedad, se eliminan en cascada sus habitaciones asociadas
ALTER TABLE Habitaciones DROP CONSTRAINT IF EXISTS FK_Habitaciones_Propiedad;
ALTER TABLE Habitaciones ADD CONSTRAINT FK_Habitaciones_Propiedad
FOREIGN KEY (idPropiedad) REFERENCES Propiedades(idPropiedad)
ON UPDATE CASCADE ON DELETE CASCADE;

-- si se elimina una propiedad, se eliminan en cascada los espacios comunes asociados
ALTER TABLE EspaciosComunes DROP CONSTRAINT IF EXISTS FK_EspaciosComunes_Propiedad;
ALTER TABLE EspaciosComunes ADD CONSTRAINT FK_EspaciosComunes_Propiedades
FOREIGN KEY (idPropiedad) REFERENCES Propiedades(idPropiedad)
ON UPDATE CASCADE ON DELETE CASCADE;

GRANT ALL ON SCHEMA ProyectoConvive TO public;
-----------------------------------------------------
------------------ AccionesReferencialesOk ----------
-----------------------------------------------------
INSERT INTO Personas VALUES ('RES12346', 'Laura Martinez', 'CC', '3107654321', 'lauratumami@mail.com');

-- 1. Prueba de ON DELETE CASCADE: Si eliminamos el contrato principal de largo plazo, 
-- se debe eliminar automáticamente de la tabla hija 'ContratosLargoPlazo'
INSERT INTO ContratosOcupacion VALUES ('COP-2026-0010', '0010', '2026-01-01', NULL, 1200000.00, 'Vigente', 'HAB-101', 'RES12346', 'PER98765');
INSERT INTO ContratosLargoPlazo VALUES ('COP-2026-0010', 5);
-- Verificamos que existe en la tabla hija:
SELECT * FROM ContratosLargoPlazo WHERE idContrato = 'COP-2026-0010';
-- Eliminamos el contrato principal:
DELETE FROM ContratosOcupacion WHERE idContrato = 'COP-2026-0010';
-- Verificamos que ya no existe en la tabla hija:
SELECT * FROM ContratosLargoPlazo WHERE idContrato = 'COP-2026-0010';

-- 2. Prueba de ON DELETE RESTRICT: Intentar eliminar una Propiedad que tiene Habitaciones asociadas (Debe fallar)
DELETE FROM Propiedades WHERE idPropiedad = 'COL1234ABCD';

------------------------------------------------------------------
------------------ Disparadores (Triggers) ------------------------
------------------------------------------------------------------

--MANTENER PROPIEDAD: Evitar cambios en ciudad, dirección y CHIP, y evitar eliminación si hay habitaciones asociadas

CREATE OR REPLACE FUNCTION fn_trigger_mantener_propiedad()
RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'UPDATE') THEN
        -- Validar que no cambie ni la ciudad, ni la dirección, ni el CHIP (idPropiedad)
        IF NEW.idPropiedad <> OLD.idPropiedad OR 
           NEW.direccionPropiedad <> OLD.direccionPropiedad OR 
           NEW.ciudadPropiedad <> OLD.ciudadPropiedad THEN
            RAISE EXCEPTION 'Modificación denegada: Solo es mutable el nombre de la propiedad.';
        END IF;
        RETURN NEW;
    ELSIF (TG_OP = 'DELETE') THEN
        -- Verificar que no existan habitaciones asociadas antes de eliminar
        IF EXISTS (SELECT 1 FROM Habitaciones WHERE idPropiedad = OLD.idPropiedad) THEN
            RAISE EXCEPTION 'No se puede anular la propiedad porque tiene habitaciones asociadas.';
        END IF;
        RETURN OLD;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_mantener_propiedad
BEFORE UPDATE OR DELETE ON Propiedades
FOR EACH ROW
EXECUTE FUNCTION fn_trigger_mantener_propiedad();


--------------------------------------------------
-- REGISTRAR CONTRATO: Evitar que se registren contratos en habitaciones no disponibles, validar fechas y roles del personal
----------------------------------------------------

CREATE OR REPLACE FUNCTION fn_trigger_registrar_contrato()
RETURNS TRIGGER AS $$
DECLARE
    v_estado_hab VARCHAR(30);
    v_cargo_personal VARCHAR(30);
BEGIN
    IF (TG_OP = 'INSERT') THEN
        -- 1. Verificar estado de la habitación (debe estar en 'Disponible')
        SELECT estadoHabitacion INTO v_estado_hab FROM Habitaciones WHERE idHabitacion = NEW.idHabitacion;
        IF v_estado_hab != 'Disponible' THEN
            RAISE EXCEPTION 'La habitación % no se encuentra disponible.', NEW.idHabitacion;
        END IF;

        -- 2. Verificar que el residente esté registrado
        IF NOT EXISTS (SELECT 1 FROM Residentes WHERE idResidente = NEW.idResidente) THEN
            RAISE EXCEPTION 'El residente con ID % no está registrado en el sistema.', NEW.idResidente;
        END IF;

        -- 3. Verificar que el personal que registra tenga rol 'Recepcionista' o 'Administrador'
        SELECT cargoPersonal INTO v_cargo_personal FROM Personal WHERE idPersonal = NEW.idPersonal;
        IF v_cargo_personal NOT IN ('Recepcionista', 'Administrador') THEN
            RAISE EXCEPTION 'El personal registrador debe tener el cargo de Recepcionista o Administrador.';
        END IF;

        -- 4. Validar reglas de fecha (fin máximo a 1 año de la fecha de inicio)
        IF NEW.fechaFin IS NOT NULL THEN
            IF NEW.fechaFin <= NEW.fechaInicio OR NEW.fechaFin > (NEW.fechaInicio + INTERVAL '1 year') THEN
                RAISE EXCEPTION 'La fecha de fin debe ser posterior a la de inicio y a un año máximo de diferencia.';
            END IF;
        END IF;

        RETURN NEW;
        
    ELSIF (TG_OP = 'UPDATE') THEN
        -- Si el contrato pasa a 'Cancelado' o 'Finalizado', liberar la habitación automáticamente
        IF NEW.estadoContrato IN ('Cancelado', 'Finalizado') AND OLD.estadoContrato = 'Vigente' THEN
            UPDATE Habitaciones 
            SET estadoHabitacion = 'Disponible' 
            WHERE idHabitacion = NEW.idHabitacion;
        END IF;
        RETURN NEW;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_registrar_contrato
BEFORE INSERT OR UPDATE ON ContratosOcupacion
FOR EACH ROW
EXECUTE FUNCTION fn_trigger_registrar_contrato();

-- Trigger posterior para cambiar estado de habitación a 'Ocupada' al insertar contrato con éxito
CREATE OR REPLACE FUNCTION fn_post_insertar_contrato()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE Habitaciones 
    SET estadoHabitacion = 'Ocupada' 
    WHERE idHabitacion = NEW.idHabitacion;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_post_contrato_ocupar_hab
AFTER INSERT ON ContratosOcupacion
FOR EACH ROW
EXECUTE FUNCTION fn_post_insertar_contrato();

---------------------------------------------------
-- REGISTAR RESERVA: Evitar reservas en espacios no disponibles, validar aforo y solapamiento de horarios

CREATE OR REPLACE FUNCTION fn_trigger_registrar_reserva()
RETURNS TRIGGER AS $$
DECLARE
    v_estado_espacio VARCHAR(30);
    v_aforo NUMERIC;
BEGIN
    IF (TG_OP = 'INSERT') THEN
        -- 1. Verificar estado del espacio común
        SELECT estadoActualEspacio, aforoEspacio INTO v_estado_espacio, v_aforo 
        FROM EspaciosComunes WHERE idEspacio = NEW.idEspacio;

        IF v_estado_espacio != 'Disponible' THEN
            RAISE EXCEPTION 'El espacio común se encuentra en estado: %. No se puede reservar.', v_estado_espacio;
        END IF;

        -- 2. Validar aforo máximo
        IF NEW.cantidadPersonas > v_aforo THEN
            RAISE EXCEPTION 'La cantidad de personas (%) supera el aforo máximo permitido (%).', NEW.cantidadPersonas, v_aforo;
        END IF;

        -- 3. Comprobar solapamiento de horarios para la misma fecha y espacio
        IF EXISTS (
            SELECT 1 FROM ReservasEspacios
            WHERE idEspacio = NEW.idEspacio
              AND DATE(fechaReserva) = DATE(NEW.fechaReserva)
              AND estadoReserva = 'Confirmada'
              AND (NEW.horaInicio < horaFin AND NEW.horaFin > horaInicio)
        ) THEN
            RAISE EXCEPTION 'Existe un cruce de horario con otra reserva confirmada en este espacio.';
        END IF;

        RETURN NEW;
        
    ELSIF (TG_OP = 'UPDATE') THEN
        -- Al anular/cancelar la reserva, asegurar que el estado sea 'Cancelada'
        IF NEW.estadoReserva = 'Cancelada' AND OLD.estadoReserva != 'Cancelada' THEN
            -- La franja queda libre automáticamente al cambiar el estado a cancelada
            RETURN NEW;
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_registrar_reserva
BEFORE INSERT OR UPDATE ON ReservasEspacios
FOR EACH ROW
EXECUTE FUNCTION fn_trigger_registrar_reserva();



----------------------------------------------------
-- MANTENER PERSONA: Evitar duplicados de documento o correo, bloquear modificación del documento principal y validar eliminación de residentes con contratos vigentes

CREATE OR REPLACE FUNCTION fn_trigger_mantener_persona()
RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'INSERT') THEN
        -- Verificar duplicados de documento o correo electrónico
        IF EXISTS (SELECT 1 FROM Personas WHERE idPersona = NEW.idPersona OR correoPersona = NEW.correoPersona) THEN
            RAISE EXCEPTION 'El documento de identidad o el correo electrónico ya se encuentran registrados.';
        END IF;
        RETURN NEW;
        
    ELSIF (TG_OP = 'UPDATE') THEN
        -- Bloquear modificación del documento de identidad principal
        IF NEW.idPersona <> OLD.idPersona THEN
            RAISE EXCEPTION 'No está permitido modificar el documento de identidad principal.';
        END IF;
        RETURN NEW;
        
    ELSIF (TG_OP = 'DELETE') THEN
        -- Comprobar si es residente y tiene contratos vigentes, deudas, o renovación reciente (< 3 meses)
        IF EXISTS (SELECT 1 FROM Residentes WHERE idResidente = OLD.idPersona) THEN
            IF EXISTS (
                SELECT 1 FROM ContratosOcupacion 
                WHERE idResidente = OLD.idPersona 
                  AND (estadoContrato = 'Vigente' OR fechaFin > CURRENT_DATE - INTERVAL '3 months')
            ) THEN
                RAISE EXCEPTION 'No se puede retirar al residente: tiene contratos vigentes o ha renovado en los últimos 3 meses.';
            END IF;
        END IF;
        RETURN OLD;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_mantener_persona
BEFORE INSERT OR UPDATE OR DELETE ON Personas
FOR EACH ROW
EXECUTE FUNCTION fn_trigger_mantener_persona();


----------------------------------------------------
-- MANTENER INVITADO (Límites, contratos vigentes y control de salidas)

CREATE OR REPLACE FUNCTION fn_trigger_mantener_invitado()
RETURNS TRIGGER AS $$
DECLARE
    v_estado_contrato VARCHAR(20);
    v_cant_invitados INT;
BEGIN
    IF (TG_OP = 'INSERT') THEN
        -- 1. Verificar que el contrato asociado esté en estado 'Vigente'
        SELECT estadoContrato INTO v_estado_contrato FROM ContratosOcupacion WHERE idContrato = NEW.idContrato;
        IF v_estado_contrato != 'Vigente' THEN
            RAISE EXCEPTION 'El contrato asociado no se encuentra vigente.';
        END IF;

        -- 2. Validar límite máximo de dos invitados simultáneos en el mismo contrato
        SELECT COUNT(*) INTO v_cant_invitados 
        FROM Invitado 
        WHERE idContrato = NEW.idContrato AND EstadoInvitado = 'En las instalaciones';

        IF v_cant_invitados >= 2 THEN
            RAISE EXCEPTION 'Se ha alcanzado el límite máximo de 2 invitados activos simultáneamente para este contrato.';
        END IF;

        -- 3. Registrar automáticamente fecha/hora de ingreso y estado inicial
        NEW.fechaHoraIngreso := COALESCE(NEW.fechaHoraIngreso, CURRENT_TIMESTAMP);
        NEW.EstadoInvitado := 'En las instalaciones';

        RETURN NEW;
        
    ELSIF (TG_OP = 'UPDATE') THEN
        -- Si se actualiza la fecha de hora de salida, cambiar estado automático a 'Retirado'
        IF NEW.fechaHoraSalida IS NOT NULL AND OLD.fechaHoraSalida IS NULL THEN
            IF NEW.fechaHoraSalida <= NEW.fechaHoraIngreso THEN
                RAISE EXCEPTION 'La hora de salida debe ser estrictamente mayor a la hora de ingreso.';
            END IF;
            NEW.EstadoInvitado := 'Retirado';
        END IF;

        -- Verificar anulación
        IF NEW.EstadoInvitado = 'Cancelado' AND OLD.EstadoInvitado != 'Cancelado' THEN
            -- Permite anular antes de ingresar
            NULL;
        END IF;

        RETURN NEW;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_mantener_invitado
BEFORE INSERT OR UPDATE ON Invitado
FOR EACH ROW
EXECUTE FUNCTION fn_trigger_mantener_invitado();




------------------------------------------------------------------- 
---------------------- xDisparadores (Triggers) -------------------
------------------------------------------------------------------

DROP TRIGGER IF EXISTS trg_mantener_propiedad ON Propiedades;
DROP FUNCTION IF EXISTS fn_trigger_mantener_propiedad();

DROP TRIGGER IF EXISTS trg_registrar_contrato ON ContratosOcupacion;
DROP TRIGGER IF EXISTS trg_post_contrato_ocupar_hab ON ContratosOcupacion;
DROP FUNCTION IF EXISTS fn_trigger_registrar_contrato();
DROP FUNCTION IF EXISTS fn_post_insertar_contrato();

DROP TRIGGER IF EXISTS trg_registrar_reserva ON ReservasEspacios;
DROP FUNCTION IF EXISTS fn_trigger_registrar_reserva();

DROP TRIGGER IF EXISTS trg_mantener_persona ON Personas;
DROP FUNCTION IF EXISTS fn_trigger_mantener_persona();

DROP TRIGGER IF EXISTS trg_mantener_invitado ON Invitado;
DROP FUNCTION IF EXISTS fn_trigger_mantener_invitado();



----------------------------------------------------
--------- DisparadoresOk (TriggersOk) ----------------
---------------------------------------------------

-- 1. MANTENER PROPIEDAD: Modificar únicamente el nombre de la propiedad (Permitido)
UPDATE Propiedades SET nombrePropiedad = 'Sede Norte Renovada' WHERE idPropiedad = 'COL1234ABCD';

-- 2. MANTENER PERSONA: Insertar nueva persona sin duplicados e ingresarla como residente
INSERT INTO Personas VALUES ('RES99999', 'Sofía Ruiz', 'CC', '3119876543', 'sofia.ruiz@email.com');
INSERT INTO Residentes VALUES ('RES99999');

-- 3. REGISTRAR CONTRATO: 
-- Habitación 'HAB-101' está disponible. El personal 'PER98765' es Recepcionista.
INSERT INTO ContratosOcupacion VALUES ('COP-20-2026', '3001', '2026-07-01', '2026-10-01', 1300000.00, 'Vigente', 'HAB-101', 'RES99999', 'PER98765');
-- Verificación automática del trigger: La habitación 'HAB-101' debió cambiar su estado a 'Ocupada'
SELECT idHabitacion, estadoHabitacion FROM Habitaciones WHERE idHabitacion = 'HAB-101';

-- 4. REGISTRAR RESERVA: Espacio 'ESP-001' está disponible, aforo 25, solicitamos 3 personas (Cumple)
INSERT INTO ReservasEspacios VALUES ('ESP-20-2026', '2026-10-30', '10:00:00', '12:00:00', 'ESP-001', 3, 'Confirmada', 'COP-20-2026');

-- 5. MANTENER INVITADO: Asociar invitado a contrato vigente (Debe registrar hora ingreso automática y estado 'En las instalaciones')
INSERT INTO Invitados (idInvitado, nombreInvitado, fechaHoraIngreso, TipoIdentificacion, EstadoInvitado, idContrato, idPersonal_Registro) 
VALUES ('INV-3001', 'Carlos Vives', LOCALTIMESTAMP, 'CC', 'En las instalaciones', 'COP-20-2026', 'PER98765');
SELECT idInvitado, fechaHoraIngreso, EstadoInvitado FROM Invitados WHERE idInvitado = 'INV-3001';

-----------------------------------------------------------------
---------------- DisparadoresNoOk (TriggersNoOk) ----------------
-----------------------------------------------------------------
-- 1. MANTENER PROPIEDAD: Intentar modificar la dirección o la ciudad (Bloqueado por trigger)
UPDATE Propiedades SET ciudadPropiedad = 'Medellín' WHERE idPropiedad = 'COL1234ABCD';

-- 2. REGISTRAR CONTRATO: Intentar asociar una habitación que YA está ocupada ('HAB-101')
INSERT INTO ContratosOcupacion VALUES ('COP-2026-0021', '3002', '2026-08-01', '2026-09-01', 1300000.00, 'Vigente', 'HAB-101', 'RES99999', 'PER98765');

-- 3. REGISTRAR CONTRATO: Intentar registrar un contrato con fecha de fin superior a 1 año desde la fecha de inicio
INSERT INTO ContratosOcupacion VALUES ('COP-2026-0050', '3003', '2026-01-01', '2028-01-01', 1300000.00, 'Vigente', 'HAB-102', 'RES99999', 'PER98765');

-- 4. REGISTRAR RESERVA: Intentar reservar superando el aforo máximo del espacio común (Aforo es 25)
INSERT INTO ReservasEspacios VALUES ('ESP-21-0201', '2026-10-30', '14:00:00', '16:00:00', 'ESP-001', 30, 'Confirmada', 'COP-20-2026');

-- 5. REGISTRAR RESERVA: Intentar un solapamiento de horario para el mismo espacio y fecha (Ya hay reserva de 10:00 a 12:00)
INSERT INTO ReservasEspacios VALUES ('ESP-22-0202', '2026-10-30', '11:00:00', '13:00:00', 'ESP-001', 2, 'Confirmada', 'COP-20-2026');

-- 6. MANTENER PERSONA: Intentar duplicar un correo electrónico ya existente
INSERT INTO Personas VALUES ('RES88888', 'Otro Usuario', 'CC', '3000000000', 'sofia.ruiz@email.com');

-- 7. MANTENER INVITADO: Intentar registrar un tercer invitado simultáneo (El límite máximo es 2 por contrato)
INSERT INTO Invitado (idInvitado, nombreInvitado, TipoIdentificacion, EstadoInvitado, idContrato, idPersonal_Registro) 
VALUES ('INV-3002', 'Invitado Extra 1', 'CC', 'En las instalaciones', 'COP-20-2026', 'PER98765');
INSERT INTO Invitado (idInvitado, nombreInvitado, TipoIdentificacion, EstadoInvitado, idContrato, idPersonal_Registro) 
VALUES ('INV-3003', 'Invitado Extra 2', 'CC', 'En las instalaciones', 'COP-20-2026', 'PER98765');
-- Este tercer INSERT lanzará la excepción del trigger por superar el límite de 2:
INSERT INTO Invitado (idInvitado, nombreInvitado, TipoIdentificacion, EstadoInvitado, idContrato, idPersonal_Registro) 
VALUES ('INV-3004', 'Invitado Tercero', 'CC', 'En las instalaciones', 'COP-20-2026', 'PER98765');