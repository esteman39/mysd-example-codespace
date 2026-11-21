-- =========================================
-- ------------ PoblarNoOK -----------------
-- =========================================

-- N-01 TCHIP en minusculas
-- Debe fallar: value for domain tchip violates check constraint "tchip_check"
INSERT INTO Propiedades VALUES ('aaa0999xxxx','Sede Error','Calle Falsa 123','Bogotá');

-- N-02 TCHIP sin letras iniciales
-- Debe fallar: value for domain tchip violates check constraint "tchip_check"
INSERT INTO Propiedades VALUES ('12345678','Sede Error','Calle Falsa 123','Bogotá');

-- N-03 TTipoHabitacion fuera del catalogo
-- Debe fallar: value for domain ttipohabitacion violates check constraint "ttipohabitacion_check"
INSERT INTO TiposDeHabitaciones VALUES ('Penthouse','Penthouse','Lujosa',2,500000,'Largo Plazo');

-- N-04 TMoneda negativa
-- Debe fallar: value for domain tmoneda violates check constraint "tmoneda_check"
INSERT INTO Personal VALUES ('1000000009','Mantenimiento',-100);

-- N-05 TEstadoActivo invalido
-- Debe fallar: value for domain testadoactivo violates check constraint "testadoactivo_check"
INSERT INTO InventariosHabitaciones VALUES ('MOB-MESA-0101','Mesa','MOB','Mesa','Excelente',NULL,'HAB-101');

-- N-06 TCantidad en cero (aforo)
-- Debe fallar: value for domain tcantidad violates check constraint "tcantidad_check"
INSERT INTO EspaciosComunes VALUES ('ESP-009','Sala',0,'Disponible','AAA0123NORT');

-- N-07 TTelefono con letras
-- Debe fallar: value for domain ttelefono violates check constraint "ttelefono_check"
INSERT INTO Personas VALUES ('1030000001','Ana','CC','abc123','ana@correo.com');

-- N-08 TCorreo sin arroba
-- Debe fallar: value for domain tcorreo violates check constraint "tcorreo_check"
INSERT INTO Personas VALUES ('1030000001','Ana','CC','3001234567','ana.correo.com');

-- N-09 TDiaCorte 30
-- Debe fallar: value for domain tdiacorte violates check constraint "tdiacorte_check"
INSERT INTO ContratosLargoPlazo VALUES ('COP-2026-0004',30);

-- N-10 TIdContrato con formato incorrecto
-- Debe fallar: value for domain tidcontrato violates check constraint "tidcontrato_check"
INSERT INTO ReservasEspacios VALUES ('ESP-26-0099',CURRENT_DATE,'10:00','11:00','ESP-001',2,'Confirmada','COP-2026-003');


-- NOT NULL (23502) ------------------------------
-- N-11 nombrePropiedad nulo
-- Debe fallar: null value in column "nombrepropiedad" of relation "propiedades" violates not-null constraint
INSERT INTO Propiedades VALUES ('AAA0777TEST',NULL,'Carrera 7 # 1-1','Bogotá');

-- N-12 fechaFin nula
-- Debe fallar: null value in column "fechafin" of relation "contratosocupacion" violates not-null constraint
INSERT INTO ContratosOcupacion VALUES ('COP-2026-0020','0020','2026-12-01',NULL,1000000,'Borrador','HAB-203','1010000005','1000000002');

-- N-13 invitado sin documento
-- Debe fallar: null value in column "documentoinvitado" of relation "invitados" violates not-null constraint
INSERT INTO Invitados (idInvitado,nombreInvitado,TipoIdentificacion,fechaHoraIngreso,EstadoInvitado,idContrato,idPersonal_Registro) VALUES ('INV-0050','X','CC',now(),'En las instalaciones','COP-2026-0001','1000000002');


-- PRIMARY KEY (23505) ------------------------------
-- N-14 PK duplicada en Propiedades
-- Debe fallar: duplicate key value violates unique constraint "pk_propiedad"
INSERT INTO Propiedades VALUES ('AAA0123NORT','Otra','Calle 1 # 1-1','Cali');

-- N-15 PK compuesta duplicada (politica repetida)
-- Debe fallar: duplicate key value violates unique constraint "pk_tienepoliticas"
INSERT INTO TienePoliticas VALUES ('COP-2026-0004','Cancelación gratuita hasta 48 horas antes del ingreso.');

-- N-16 PK compuesta duplicada (mismo contacto y residente)
-- Debe fallar: duplicate key value violates unique constraint "pk_contactoemergencia"
INSERT INTO ContactosEmergencia VALUES ('1020000001','Madre',FALSE,'1010000001');


-- N-17 correo duplicado
-- Debe fallar: duplicate key value violates unique constraint "uq_persona_correo"
INSERT INTO Personas VALUES ('1030000002','Otro','CC','3009999999','sofia.ruiz@correo.com');

-- N-18 numeroContrato duplicado
-- Debe fallar: duplicate key value violates unique constraint "uq_contrato_numero"
INSERT INTO ContratosOcupacion VALUES ('COP-2026-0021','0001','2026-12-01','2026-12-05',1000000,'Borrador','HAB-203','1010000005','1000000002');

-- N-19 direccion repetida en la misma ciudad
-- Debe fallar: duplicate key value violates unique constraint "uq_propiedad_direccion"
INSERT INTO Propiedades VALUES ('AAA0888COPY','Copia','Calle 63 # 9-25','Bogotá');

-- N-20 tipo de habitacion repetido (PK)
-- Debe fallar: duplicate key value violates unique constraint "pk_tipohabitacion"
INSERT INTO TiposDeHabitaciones VALUES ('Suite','Otra Suite','x',3,1,'Corto Plazo');


-- N-21 habitacion en propiedad inexistente
-- Debe fallar: insert or update on table "habitaciones" violates foreign key constraint "fk_habitaciones_propiedad"
INSERT INTO Habitaciones VALUES ('HAB-999','Individual','Disponible','AAA9999ZZZZ');

-- N-22 inventario en habitacion inexistente
-- Debe fallar: insert or update on table "inventarioshabitaciones" violates foreign key constraint "fk_inventarioshabitaciones_habitaciones"
INSERT INTO InventariosHabitaciones VALUES ('MOB-SILLA-0999','Silla','MOB','Silla','Nuevo',NULL,'HAB-999');

-- N-23 contrato con residente inexistente
-- Debe fallar: insert or update on table "contratosocupacion" violates foreign key constraint "fk_contratosocupacion_residente"
INSERT INTO ContratosOcupacion VALUES ('COP-2026-0022','0022','2026-12-01','2026-12-05',1000000,'Borrador','HAB-203','1099999999','1000000002');

-- N-24 contrato con personal que no es personal
-- Debe fallar: insert or update on table "contratosocupacion" violates foreign key constraint "fk_contratosocupacion_personal"
INSERT INTO ContratosOcupacion VALUES ('COP-2026-0023','0023','2026-12-01','2026-12-05',1000000,'Borrador','HAB-203','1010000005','1010000001');

-- N-25 contacto de emergencia que no es Persona
-- Debe fallar: insert or update on table "contactosemergencia" violates foreign key constraint "fk_contactosemergencia_personas"
INSERT INTO ContactosEmergencia VALUES ('1099999998','Tío',FALSE,'1010000003');

-- N-26 residente que no es Persona
-- Debe fallar: insert or update on table "residentes" violates foreign key constraint "fk_residentes_persona"
INSERT INTO Residentes VALUES ('1099999997');

-- N-27 politica en contrato de LARGO plazo
-- Debe fallar: insert or update on table "tienepoliticas" violates foreign key constraint "fk_tienepoliticas_contratoscortoplazo"
INSERT INTO TienePoliticas VALUES ('COP-2026-0001','Politica en contrato largo');

-- N-28 clausula en contrato de CORTO plazo
-- Debe fallar: insert or update on table "tieneclausulas" violates foreign key constraint "fk_tieneclausulas_contratoslargoplazo"
INSERT INTO TieneClausulas VALUES ('COP-2026-0004','Clausula en contrato corto');

-- N-29 reserva en espacio inexistente
-- Debe fallar: insert or update on table "reservasespacios" violates foreign key constraint "fk_reservasespacios_espacioscomunes"
INSERT INTO ReservasEspacios VALUES ('ESP-26-0090',CURRENT_DATE,'10:00','11:00','ESP-999',2,'Confirmada','COP-2026-0001');

-- N-30 invitado en contrato inexistente
-- Debe fallar: insert or update on table "invitados" violates foreign key constraint "fk_invitados_contratosocupacion"
INSERT INTO Invitados VALUES ('INV-0060','X','1234567890','CC',now(),NULL,'En las instalaciones','COP-2026-9999','1000000002');


-- TIPOS DE DATO (22XXX) ------------------------------
-- N-31 fecha con formato invalido
-- Debe fallar: invalid input syntax for type date: "no-es-fecha"
INSERT INTO ContratosOcupacion VALUES ('COP-2026-0024','0024','no-es-fecha','2026-12-05',1000000,'Borrador','HAB-203','1010000005','1000000002');

-- N-32 texto demasiado largo (nombre > 100)
-- Debe fallar: value too long for type character varying(100)
INSERT INTO Propiedades VALUES ('AAA0666LARG', repeat('x',101),'Calle 6 # 6-6','Bogotá');

-- N-33 numero con formato invalido en monto
-- Debe fallar: invalid input syntax for type numeric: "mucho"
INSERT INTO Personal VALUES ('1000000008','Mantenimiento','mucho');

-- N-34 monto fuera de rango DECIMAL(12,2)
-- Debe fallar: numeric field overflow
INSERT INTO Personal VALUES ('1000000009','Mantenimiento',99999999999.99);

