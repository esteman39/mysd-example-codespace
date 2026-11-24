
-------------------------------------------------
------------------ PoblarOk ---------------------
-------------------------------------------------

-- 1. PROPIEDADES
INSERT INTO Propiedades (idPropiedad, nombrePropiedad, direccionPropiedad, ciudadPropiedad) VALUES
('AAA0123NORT', 'Convive Chapinero',  'Calle 63 # 9-25',     'Bogotá'),
('AAA0456POBL', 'Convive El Poblado', 'Carrera 43A # 12-34', 'Medellín');

-- 2. TIPOS DE HABITACION (tarifa mensual en largo plazo, por noche en corto plazo)
INSERT INTO TiposDeHabitaciones (idTipoHabitacion, nombreTipoHabitacion, descripcionTipoHabitacion, capacidadMaxima, tarifaBase, modalidad) VALUES
('Individual', 'Habitación Individual', 'Habitación para una persona con baño privado',       1, 1200000.00, 'Largo Plazo'),
('Doble',      'Habitación Doble',      'Habitación para dos personas con dos camas',          2, 1900000.00, 'Largo Plazo'),
('Compartida', 'Habitación Compartida', 'Habitación con dos camas sencillas y baño compartido',2,   90000.00, 'Corto Plazo'),
('Suite',      'Suite Premium',         'Suite con sala, cocineta y balcón',                   3,  250000.00, 'Corto Plazo');

-- 3. ESPACIOS COMUNES
INSERT INTO EspaciosComunes (idEspacio, nombreEspacio, aforoEspacio, estadoActualEspacio, idPropiedad) VALUES
('ESP-001', 'Salón comunal',  25, 'Disponible',       'AAA0123NORT'),
('ESP-002', 'Coworking',      12, 'Disponible',       'AAA0123NORT'),
('ESP-003', 'Gimnasio',       10, 'En Mantenimiento', 'AAA0123NORT'),
('ESP-004', 'Terraza BBQ',    15, 'Disponible',       'AAA0456POBL');

-- 4. HABITACIONES
INSERT INTO Habitaciones (idHabitacion, tipoHabitacion, estadoHabitacion, idPropiedad) VALUES
('HAB-101', 'Individual', 'Ocupada',       'AAA0123NORT'),
('HAB-102', 'Individual', 'Ocupada',       'AAA0123NORT'),
('HAB-103', 'Doble',      'Ocupada',       'AAA0123NORT'),
('HAB-104', 'Compartida', 'Disponible',    'AAA0123NORT'),
('HAB-105', 'Suite',      'Ocupada',       'AAA0123NORT'),
('HAB-106', 'Individual', 'Mantenimiento', 'AAA0123NORT'),
('HAB-201', 'Individual', 'En Limpieza',   'AAA0456POBL'),
('HAB-202', 'Doble',      'Ocupada',       'AAA0456POBL'),
('HAB-203', 'Individual', 'Disponible',    'AAA0456POBL');

-- 5. PERSONAS (5 de personal, 6 residentes, 4 contactos de emergencia)
INSERT INTO Personas (idPersona, nombrePersona, TipoIdentificacion, telefonoPersona, correoPersona) VALUES
('1000000001', 'Laura Mendoza',    'CC', '3001000001', 'laura.mendoza@convive.co'),
('1000000002', 'Andrés Rojas',     'CC', '3001000002', 'andres.rojas@convive.co'),
('1000000003', 'Camila Torres',    'CC', '3001000003', 'camila.torres@convive.co'),
('1000000004', 'Jorge Díaz',       'CC', '3001000004', 'jorge.diaz@convive.co'),
('1000000005', 'Marta Vargas',     'CC', '3001000005', 'marta.vargas@convive.co'),
('1010000001', 'Sofía Ruiz',       'CC', '3101000001', 'sofia.ruiz@correo.com'),
('1010000002', 'Daniel Ruiz',      'CC', '3101000002', 'daniel.ruiz@correo.com'),
('1010000003', 'Valentina Gómez',  'CC', '3101000003', 'valentina.gomez@correo.com'),
('1010000004', 'Mateo Smith',      'CE', '3101000004', 'mateo.smith@correo.com'),
('1010000005', 'Lucía Fernández',  'PP', '3101000005', 'lucia.fernandez@correo.com'),
('1010000006', 'Carlos Pérez',     'CC', '3101000006', 'carlos.perez@correo.com'),
('1020000001', 'Marta Ruiz',       'CC', '3201000001', 'marta.ruiz@correo.com'),
('1020000002', 'Pedro Ruiz',       'CC', '3201000002', 'pedro.ruiz@correo.com'),
('1020000003', 'Julia Gómez',      'CC', '3201000003', 'julia.gomez@correo.com'),
('1020000004', 'Ana Smith',        'CE', '3201000004', 'ana.smith@correo.com');

-- 6. PERSONAL
INSERT INTO Personal (idPersonal, cargoPersonal, salarioBase) VALUES
('1000000001', 'Administrador',  4500000.00),
('1000000002', 'Recepcionista',  2000000.00),
('1000000003', 'Recepcionista',  2000000.00),
('1000000004', 'Mantenimiento',  1600000.00),
('1000000005', 'Mantenimiento',  1600000.00);

-- 7. RESIDENTES
INSERT INTO Residentes (idResidente) VALUES
('1010000001'), ('1010000002'), ('1010000003'), ('1010000004'), ('1010000005'), ('1010000006');

-- 8. CONTACTOS DE EMERGENCIA
-- Marta Ruiz (1020000001) es la madre de dos residentes (hermanos): misma persona, dos residentes.
INSERT INTO ContactosEmergencia (idContactoEmergencia, parentescoContacto, esPrincipal, idResidente) VALUES
('1020000001', 'Madre',   TRUE,  '1010000001'),
('1020000001', 'Madre',   TRUE,  '1010000002'),
('1020000002', 'Padre',   FALSE, '1010000001'),
('1020000003', 'Madre',   TRUE,  '1010000003'),
('1020000004', 'Hermana', TRUE,  '1010000004');

-- 9. CONTRATOS DE OCUPACION
INSERT INTO ContratosOcupacion (idContrato, numeroContrato, fechaInicio, fechaFin, valorContrato, estadoContrato, idHabitacion, idResidente, idPersonal) VALUES
('COP-2026-0001', '0001', '2026-09-01', '2027-02-28',  7200000.00, 'Vigente',    'HAB-101', '1010000001', '1000000002'),
('COP-2026-0002', '0002', '2026-10-15', '2027-04-15',  7200000.00, 'Vigente',    'HAB-102', '1010000002', '1000000002'),
('COP-2026-0003', '0003', '2026-06-01', '2027-05-31', 22800000.00, 'Vigente',    'HAB-103', '1010000003', '1000000003'),
('COP-2026-0004', '0004', '2026-11-15', '2026-11-20',  1250000.00, 'Vigente',    'HAB-105', '1010000004', '1000000003'),
('COP-2026-0005', '0005', '2026-12-01', '2026-12-05',   360000.00, 'Borrador',   'HAB-104', '1010000005', '1000000001'),
('COP-2026-0006', '0006', '2026-01-10', '2026-07-10',  7200000.00, 'Finalizado', 'HAB-201', '1010000006', '1000000002'),
('COP-2026-0007', '0007', '2026-08-01', '2027-07-31', 22800000.00, 'Vigente',    'HAB-202', '1010000006', '1000000003');

-- 10. SUBTIPOS (a mano: aun no hay triggers). diaCorte = dia de fechaInicio; noches = fechaFin - fechaInicio
INSERT INTO ContratosLargoPlazo (idContrato, diaCorteMensual) VALUES
('COP-2026-0001', 1), ('COP-2026-0002', 15), ('COP-2026-0003', 1), ('COP-2026-0006', 10), ('COP-2026-0007', 1);

INSERT INTO ContratosCortoPlazo (idContrato, totalNoches) VALUES
('COP-2026-0004', 5), ('COP-2026-0005', 4);

-- 11. CLAUSULAS (solo largo plazo) y POLITICAS (solo corto plazo)
INSERT INTO TieneClausulas (idContrato, clausula) VALUES
('COP-2026-0001', 'El residente mantiene la habitación en buen estado y reporta daños en 48 horas.'),
('COP-2026-0001', 'El pago se realiza dentro de los primeros 5 días de cada mes.'),
('COP-2026-0002', 'Horario de silencio entre las 10:00 p. m. y las 6:00 a. m.'),
('COP-2026-0003', 'Se permiten máximo dos invitados simultáneos por contrato.'),
('COP-2026-0006', 'El contrato finaliza con entrega de inventario verificado.'),
('COP-2026-0007', 'Renovación sujeta a aprobación de la administración 30 días antes del vencimiento.');

INSERT INTO TienePoliticas (idContrato, politicaCancelacion) VALUES
('COP-2026-0004', 'Cancelación gratuita hasta 48 horas antes del ingreso.'),
('COP-2026-0004', 'Cancelaciones posteriores pagan la primera noche.'),
('COP-2026-0005', 'No reembolsable si se cancela con menos de 24 horas de antelación.');

-- 12. INVENTARIO (estadoFinal solo se llena al terminar la ocupacion: HAB-201)
INSERT INTO InventariosHabitaciones (idInventario, descripcionActivo, categoriaActivo, nombreActivo, estadoInicial, estadoFinal, idHabitacion) VALUES
('MOB-CAMA-0101',      'Cama sencilla con colchón ortopédico', 'MOB', 'Cama sencilla',     'Nuevo',  NULL,          'HAB-101'),
('ELE-NEVERA-0101',    'Nevera pequeña de 90 litros',          'ELE', 'Nevera',            'Bueno',  NULL,          'HAB-101'),
('MOB-CAMA-0102',      'Cama sencilla con colchón ortopédico', 'MOB', 'Cama sencilla',     'Nuevo',  NULL,          'HAB-102'),
('TEX-COBIJA-0103',    'Cobija térmica doble',                 'TEX', 'Cobija',            'Bueno',  NULL,          'HAB-103'),
('COC-ESTUFA-0105',    'Estufa eléctrica de dos puestos',      'COC', 'Estufa',            'Nuevo',  NULL,          'HAB-105'),
('SEG-CERRADURA-0201', 'Cerradura electrónica de la puerta',   'SEG', 'Cerradura',         'Bueno',  'Deteriorado', 'HAB-201'),
('ELE-TV-0201',        'Televisor de 32 pulgadas',             'ELE', 'Televisor',         'Nuevo',  'Bueno',       'HAB-201'),
('COM-ROUTER-0202',    'Router wifi de doble banda',           'COM', 'Router',            'Nuevo',  NULL,          'HAB-202');

-- 13. INVITADOS (solo contratos vigentes; maximo 2 en 'En las instalaciones' por contrato)
INSERT INTO Invitados (idInvitado, nombreInvitado, documentoInvitado, TipoIdentificacion, fechaHoraIngreso, fechaHoraSalida, EstadoInvitado, idContrato, idPersonal_Registro) VALUES
('INV-0001', 'Julián Castro', '1098765001', 'CC', CURRENT_TIMESTAMP - INTERVAL '2 hours',  NULL, 'En las instalaciones', 'COP-2026-0001', '1000000002'),
('INV-0002', 'Paula Ortiz',   '1098765002', 'CC', CURRENT_TIMESTAMP - INTERVAL '1 hour',   NULL, 'En las instalaciones', 'COP-2026-0001', '1000000002'),
('INV-0003', 'Esteban Mora',  '1098765003', 'CC', CURRENT_TIMESTAMP - INTERVAL '29 hours', CURRENT_TIMESTAMP - INTERVAL '26 hours', 'Retirado', 'COP-2026-0001', '1000000003'),
('INV-0004', 'Nicolás Vega',  '1098765004', 'CE', CURRENT_TIMESTAMP - INTERVAL '30 minutes', NULL, 'En las instalaciones', 'COP-2026-0002', '1000000003'),
('INV-0005', 'Diana López',   '1098765005', 'CC', CURRENT_TIMESTAMP - INTERVAL '3 days',   NULL, 'Cancelado',            'COP-2026-0003', '1000000002'),
('INV-0006', 'Sara Molina',   'PP4455667',  'PP', CURRENT_TIMESTAMP - INTERVAL '24 hours', CURRENT_TIMESTAMP - INTERVAL '20 hours', 'Retirado', 'COP-2026-0004', '1000000003');

-- 14. RESERVAS DE ESPACIOS (fechas relativas a hoy; contrato vigente de la misma propiedad)
INSERT INTO ReservasEspacios (idReserva, fechaReserva, horaInicio, horaFin, idEspacio, cantidadPersonas, estadoReserva, idContrato) VALUES
('ESP-26-0001', CURRENT_DATE,     '18:00', '20:00', 'ESP-001',  8, 'Confirmada', 'COP-2026-0001'),
('ESP-26-0002', CURRENT_DATE,     '20:00', '22:00', 'ESP-001',  5, 'Confirmada', 'COP-2026-0002'),
('ESP-26-0003', CURRENT_DATE + 1, '09:00', '11:00', 'ESP-002',  4, 'Confirmada', 'COP-2026-0003'),
('ESP-26-0004', CURRENT_DATE - 3, '14:00', '16:00', 'ESP-002',  3, 'Completada', 'COP-2026-0001'),
('ESP-26-0005', CURRENT_DATE + 2, '18:00', '20:00', 'ESP-001', 10, 'Cancelada',  'COP-2026-0001'),
('ESP-26-0006', CURRENT_DATE + 1, '17:00', '20:00', 'ESP-004', 12, 'Confirmada', 'COP-2026-0007');
