-- ==========================================
-- POBLADO DE BASE DE DATOS - SISTEMA DE ALOJAMIENTO
-- ==========================================

-- 1. PROPIEDADES (2 registros)
INSERT INTO Propiedades (idPropiedad, nombrePropiedad, direccionPropiedad, ciudadPropiedad) VALUES
('BOG-001-001', 'Residencial Los Andes', 'Calle 123 #45-67', 'Bogotá'),
('MED-002-002', 'Apartahotel El Poblado', 'Carrera 43A #12-34', 'Medellín');

-- 2. TIPOS DE HABITACIONES (4 registros)
INSERT INTO TiposDeHabitaciones (idTipoHabitacion, nombreTipoHabitacion, descripcionTipoHabitacion, capacidadMaxima, tarifaBase, modalidad) VALUES
('Individual', 'Habitación Individual', 'Habitación para una persona con cama sencilla', 1, 150000.00, 'Corto Plazo'),
('Doble', 'Habitación Doble', 'Habitación para dos personas con cama doble', 2, 250000.00, 'Largo Plazo'),
('Compartida', 'Habitación Compartida', 'Habitación con dos camas sencillas', 2, 200000.00, 'Corto Plazo'),
('Suite', 'Suite Premium', 'Habitación amplia con sala y jacuzzi', 3, 450000.00, 'Largo Plazo');

-- 3. ESPACIOS COMUNES (5 registros)
INSERT INTO EspaciosComunes (idEspacio, nombreEspacio, aforoEspacio, estadoActualEspacio, idPropiedad) VALUES
('ESP-01', 'Salón de Eventos', 50, 'Disponible', 'BOG-001-001'),
('ESP-02', 'Gimnasio', 20, 'Disponible', 'BOG-001-001'),
('ESP-03', 'Piscina', 30, 'En Mantenimiento', 'BOG-001-001'),
('ESP-04', 'Sala de Juntas', 10, 'Disponible', 'MED-002-002'),
('ESP-05', 'Zona de BBQ', 15, 'Disponible', 'MED-002-002');

-- 4. HABITACIONES (55 registros)
-- Se generan 55 habitaciones para asegurar más de 50 contratos sin repetir habitaciones en estado 'Disponible'
DO $$
BEGIN
    FOR i IN 101..155 LOOP
        INSERT INTO Habitaciones (idHabitacion, TipoHabitacion, estadoHabitacion, idPropiedad)
        VALUES (
            'HAB-' || i, 
            CASE WHEN i % 4 = 0 THEN 'Individual' WHEN i % 4 = 1 THEN 'Doble' WHEN i % 4 = 2 THEN 'Compartida' ELSE 'Suite' END,
            'Disponible',
            CASE WHEN i <= 128 THEN 'BOG-001-001' ELSE 'MED-002-002' END
        );
    END LOOP;
END $$;

-- 5. PERSONAS (60 registros)
DO $$
BEGIN
    FOR i IN 1001..1060 LOOP
        INSERT INTO Personas (idPersona, nombrePersona, TipoIdentificacion, telefonoPersona, correoPersona)
        VALUES (
            'CC' || i,
            'Persona ' || i,
            CASE WHEN i % 3 = 0 THEN 'CC' WHEN i % 3 = 1 THEN 'CE' ELSE 'PP' END,
            '300' || LPAD(i::text, 7, '0'),
            'persona' || i || '@correo.com'
        );
    END LOOP;
END $$;

-- 6. RESIDENTES (30 registros - Subconjunto de Personas 1001 a 1030)
DO $$
BEGIN
    FOR i IN 1041..1055 LOOP
        INSERT INTO Residentes (idResidente) VALUES ('CC' || i);
    END LOOP;
END $$;

-- 7. PERSONAL (10 registros - 1 Admin, 2 Recep, 7 Mantenimiento)
-- IDs: 1031 a 1040
INSERT INTO Personal (idPersonal, cargoPersonal, salarioBase) VALUES
('CC1031', 'Administrador', 3500000.00),
('CC1032', 'Recepcionista', 1800000.00),
('CC1033', 'Recepcionista', 1800000.00),
('CC1034', 'Mantenimiento', 1500000.00),
('CC1035', 'Mantenimiento', 1500000.00),
('CC1036', 'Mantenimiento', 1500000.00),
('CC1037', 'Mantenimiento', 1500000.00),
('CC1038', 'Mantenimiento', 1500000.00),
('CC1039', 'Mantenimiento', 1500000.00),
('CC1040', 'Mantenimiento', 1500000.00);

-- 8. CONTACTOS DE EMERGENCIA (30 registros - 1 por residente, todos principales para evitar conflicto de trigger)
DO $$
BEGIN
    FOR i IN 1..30 LOOP
        INSERT INTO ContactosEmergencia (idContactoEmergencia, parentescoContacto, esPrincipal, idResidente)
        VALUES ('CC' || (1040 + i), 'Padre', TRUE, 'CC' || (1000 + i));
    END LOOP;
END $$;


-- 9. CONTRATOS DE OCUPACIÓN (55 registros)
-- Usamos habitaciones 101 a 155. Estados variados para no bloquear triggers.
DO $$
BEGIN
    FOR i IN 101..155 LOOP
        INSERT INTO ContratosOcupacion (idContrato, numeroContrato, fechaInicio, fechaFin, valorContrato, estadoContrato, idHabitacion, idResidente, idPersonal)
        VALUES (
            'COP-' || i || '-2026',
            LPAD((i - 100)::text, 4, '0'),
            '2026-01-15',
            CASE WHEN i % 2 = 0 THEN DATE '2026-07-15' ELSE DATE '2026-02-15' END, -- Pares largo plazo, impares corto
            1500000.00 + (i * 10000),
            CASE WHEN i % 5 = 0 THEN 'Vigente' WHEN i % 5 = 1 THEN 'Finalizado' ELSE 'Borrador' END,
            'HAB-' || i,
            'CC' || (1000 + ((i - 101) % 30) + 1),   -- solo CC1001 a CC1030 -- Residentes 1001 a 1055 (reusamos algunos)
            'CC1032' -- Recepcionista
        );
    END LOOP;
END $$;

-- 10. CONTRATOS LARGO PLAZO (30 registros - Contratos pares 102, 104... 154)
DO $$
BEGIN
    FOR i IN 102..154 BY 2 LOOP
        INSERT INTO ContratosLargoPlazo (idContrato, diaCorteMensual)
        VALUES ('COP-' || i || '-2026', 15);
    END LOOP;
END $$;

-- 11. CONTRATOS CORTO PLAZO (25 registros - Contratos impares 101, 103... 155)
DO $$
BEGIN
    FOR i IN 101..155 BY 2 LOOP
        INSERT INTO ContratosCortoPlazo (idContrato, fechaInicio, totalNoches)
        VALUES ('COP-' || i || '-2026', DATE '2026-01-15', 30);
    END LOOP;
END $$;

-- 12. TIENE POLÍTICAS (25 registros - Asociadas a Contratos Corto Plazo)
DO $$
BEGIN
    FOR i IN 101..155 BY 2 LOOP
        INSERT INTO TienePoliticas (idContrato, politicaCancelacion)
        VALUES ('COP-' || i || '-2026', 'No reembolsable si se cancela con menos de 48 horas de antelación.');
    END LOOP;
END $$;

-- 13. TIENE CLÁUSULAS (30 registros - Asociadas a Contratos Largo Plazo)
DO $$
BEGIN
    FOR i IN 102..154 BY 2 LOOP
        INSERT INTO TieneClausulas (idContrato, clausula)
        VALUES ('COP-' || i || '-2026', 'El residente debe mantener el seguro de arrendamiento activo durante toda la vigencia.');
    END LOOP;
END $$;

-- 14. RESERVAS DE ESPACIOS (55 registros)
-- Usamos diferentes fechas para evitar el trigger de solapamiento (tg_espacio_ocupado)
DO $$
BEGIN
    FOR i IN 1..55 LOOP
        INSERT INTO ReservasEspacios (idReserva, fechaReserva, horaInicio, horaFin, idEspacio, cantidadPersonas, estadoReserva, idContrato)
        VALUES (
            'ESP-' || LPAD(((i - 1) % 5 + 1)::text, 2, '0') || '-' || LPAD(i::text, 4, '0'),
            TIMESTAMP '2026-02-01 00:00:00' + (((i - 1) % 14) * INTERVAL '1 day'),
            TIME '08:00:00',
            TIME '10:00:00',
            'ESP-0' || ((i - 1) % 5 + 1),
            5 + (i % 10),
            'Confirmada',
            'COP-' || (100 + i) || '-2026'
        );
    END LOOP;
END $$;


-- 15. INVITADOS (55 registros)
-- Solo los contratos 'Vigente' (i % 5 = 0 -> 105, 110, 115...) pueden tener invitados.
-- Máximo 2 invitados 'En las instalaciones' por contrato.
DO $$
DECLARE
    v_cont INT := 0;
    v_contrato TEXT;
BEGIN
    FOR i IN 105..155 BY 5 LOOP -- Contratos vigentes: 105, 110, 115, 120, 125, 130, 135, 140, 145, 150, 155 (11 contratos)
        v_contrato := 'COP-' || i || '-2026';
        -- 2 invitados activos por contrato
        INSERT INTO Invitados (idInvitado, nombreInvitado, TipoIdentificacion, fechaHoraIngreso, fechaHoraSalida, EstadoInvitado, idContrato, idPersonal_Registro)
        VALUES ('INV-' || LPAD((v_cont + 1)::text, 4, '0'), 'Invitado A ' || i, 'CC', '2026-11-15 10:00:00', NULL, 'En las instalaciones', v_contrato, 'CC1031');
        v_cont := v_cont + 1;
        
        INSERT INTO Invitados (idInvitado, nombreInvitado, TipoIdentificacion, fechaHoraIngreso, fechaHoraSalida, EstadoInvitado, idContrato, idPersonal_Registro)
        VALUES ('INV-' || LPAD((v_cont + 1)::text, 4, '0'), 'Invitado B ' || i, 'CE', '2026-11-15 11:00:00', '2026-11-15 18:00:00', 'Retirado', v_contrato, 'CC1032');
        v_cont := v_cont + 1;
        
        -- 3 invitados retirados/cancelados para completar 55 sin romper el límite de 2 activos
        INSERT INTO Invitados (idInvitado, nombreInvitado, TipoIdentificacion, fechaHoraIngreso, fechaHoraSalida, EstadoInvitado, idContrato, idPersonal_Registro)
        VALUES ('INV-' || LPAD((v_cont + 1)::text, 4, '0'), 'Invitado C ' || i, 'PP', '2026-11-10 09:00:00', '2026-11-10 17:00:00', 'Retirado', v_contrato, 'CC1033');
        v_cont := v_cont + 1;
        
        INSERT INTO Invitados (idInvitado, nombreInvitado, TipoIdentificacion, fechaHoraIngreso, fechaHoraSalida, EstadoInvitado, idContrato, idPersonal_Registro)
        VALUES ('INV-' || LPAD((v_cont + 1)::text, 4, '0'), 'Invitado D ' || i, 'CC', '2026-11-01 08:00:00', '2026-11-01 12:00:00', 'Cancelado', v_contrato, 'CC1031');
        v_cont := v_cont + 1;
        
        INSERT INTO Invitados (idInvitado, nombreInvitado, TipoIdentificacion, fechaHoraIngreso, fechaHoraSalida, EstadoInvitado, idContrato, idPersonal_Registro)
        VALUES ('INV-' || LPAD((v_cont + 1)::text, 4, '0'), 'Invitado E ' || i, 'CE', '2026-11-05 14:00:00', '2026-11-05 20:00:00', 'Retirado', v_contrato, 'CC1032');
        v_cont := v_cont + 1;
    END LOOP;
END $$;

-- 16. INVENTARIOS HABITACIONES (55 registros - 1 por habitación)
DO $$
BEGIN
    FOR i IN 101..155 LOOP
        INSERT INTO InventariosHabitaciones (idInventario, descripcionActivo, categoriaActivo, nombreActivo, estadoInicial, estadoFinal, idHabitacion)
        VALUES (
            CASE WHEN i % 6 = 0 THEN 'MOB' WHEN i % 6 = 1 THEN 'ELE' WHEN i % 6 = 2 THEN 'COM' WHEN i % 6 = 3 THEN 'COC' WHEN i % 6 = 4 THEN 'TEX' ELSE 'SEG' END || '-ACT-' || LPAD(i::text, 4, '0'),
            'Activo estándar para habitación ' || i,
            CASE WHEN i % 6 = 0 THEN 'MOB' WHEN i % 6 = 1 THEN 'ELE' WHEN i % 6 = 2 THEN 'COM' WHEN i % 6 = 3 THEN 'COC' WHEN i % 6 = 4 THEN 'TEX' ELSE 'SEG' END,
            'Activo ' || i,
            'Nuevo',
            NULL,
            'HAB-' || i
        );
    END LOOP;
END $$;

-- ==========================================
-- FIN DEL POBLADO
-- ==========================================