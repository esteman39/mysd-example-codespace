-- ========================================
--  VISTAS
-- ========================================
-- Una vista por necesidad de consulta de los actores. 

-- Recepcionista -------------------------------------------------------
CREATE OR REPLACE VIEW v_habitaciones_disponibles AS
SELECT p.idPropiedad, p.nombrePropiedad, t.idTipoHabitacion, t.nombreTipoHabitacion,
       h.idHabitacion, t.capacidadMaxima, t.tarifaBase, t.modalidad
FROM Habitaciones h
JOIN Propiedades p         ON p.idPropiedad = h.idPropiedad
JOIN TiposDeHabitaciones t ON t.idTipoHabitacion = h.tipoHabitacion
WHERE h.estadoHabitacion = 'Disponible';

CREATE OR REPLACE VIEW v_disponibilidad_por_tipo AS
SELECT p.idPropiedad, p.nombrePropiedad, t.nombreTipoHabitacion,
       COUNT(*)                                                                       AS total,
       COUNT(*) FILTER (WHERE h.estadoHabitacion = 'Disponible')                      AS disponibles,
       COUNT(*) FILTER (WHERE h.estadoHabitacion = 'Ocupada')                         AS ocupadas,
       COUNT(*) FILTER (WHERE h.estadoHabitacion IN ('Mantenimiento', 'En Limpieza')) AS no_operativas
FROM Habitaciones h
JOIN Propiedades p         ON p.idPropiedad = h.idPropiedad
JOIN TiposDeHabitaciones t ON t.idTipoHabitacion = h.tipoHabitacion
GROUP BY p.idPropiedad, p.nombrePropiedad, t.idTipoHabitacion, t.nombreTipoHabitacion;

CREATE OR REPLACE VIEW v_invitados_activos AS
SELECT i.idInvitado, i.nombreInvitado, i.documentoInvitado, i.fechaHoraIngreso,
       h.idPropiedad, h.idHabitacion,
       pr.nombrePersona AS residente_anfitrion, pp.nombrePersona AS registrado_por
FROM Invitados i
JOIN ContratosOcupacion c ON c.idContrato = i.idContrato
JOIN Habitaciones h       ON h.idHabitacion = c.idHabitacion
JOIN Personas pr          ON pr.idPersona = c.idResidente
JOIN Personas pp          ON pp.idPersona = i.idPersonal_Registro
WHERE i.EstadoInvitado = 'En las instalaciones';

CREATE OR REPLACE VIEW v_control_aforo_espacios AS
SELECT ec.idPropiedad, ec.idEspacio, ec.nombreEspacio, ec.aforoEspacio,
       re.idReserva, re.fechaReserva, re.horaInicio, re.horaFin, re.cantidadPersonas,
       ROUND(100.0 * re.cantidadPersonas / ec.aforoEspacio, 1) AS pct_aforo
FROM ReservasEspacios re
JOIN EspaciosComunes ec ON ec.idEspacio = re.idEspacio
WHERE re.estadoReserva <> 'Cancelada';

-- Administrador -------------------------------------------------------
CREATE OR REPLACE VIEW v_contratos_vigentes AS
SELECT c.idContrato, c.numeroContrato,
       CASE WHEN cl.idContrato IS NOT NULL THEN 'Largo Plazo' ELSE 'Corto Plazo' END AS modalidad,
       per.nombrePersona AS residente, per.telefonoPersona,
       h.idPropiedad, h.idHabitacion, c.fechaInicio, c.fechaFin, c.valorContrato
FROM ContratosOcupacion c
JOIN Personas per   ON per.idPersona = c.idResidente
JOIN Habitaciones h ON h.idHabitacion = c.idHabitacion
LEFT JOIN ContratosLargoPlazo cl ON cl.idContrato = c.idContrato
WHERE c.estadoContrato = 'Vigente';

CREATE OR REPLACE VIEW v_inventario_habitacion AS
SELECT h.idPropiedad, h.idHabitacion, inv.idInventario, inv.nombreActivo,
       inv.categoriaActivo, inv.estadoInicial, inv.estadoFinal,
       (inv.estadoFinal IS NOT NULL AND inv.estadoFinal <> inv.estadoInicial) AS cambio_estado
FROM InventariosHabitaciones inv
JOIN Habitaciones h ON h.idHabitacion = inv.idHabitacion;

-- Directorio de personal SIN salario (para los roles que no deben verlo)
CREATE OR REPLACE VIEW v_personal_publico AS
SELECT pe.idPersonal, p.nombrePersona, p.telefonoPersona, p.correoPersona, pe.cargoPersonal
FROM Personal pe
JOIN Personas p ON p.idPersona = pe.idPersonal;

-- Gerente -------------------------------------------------------------
CREATE OR REPLACE VIEW v_demanda_espacios_franja AS
SELECT ec.idPropiedad, ec.idEspacio, ec.nombreEspacio,
       CASE WHEN re.horaInicio < TIME '12:00' THEN 'Mañana'
            WHEN re.horaInicio < TIME '18:00' THEN 'Tarde'
            ELSE 'Noche' END                                        AS franja,
       COUNT(*)                                                     AS reservas,
       SUM(re.cantidadPersonas)                                     AS asistentes,
       ROUND(AVG(100.0 * re.cantidadPersonas / ec.aforoEspacio), 1) AS pct_aforo_prom
FROM ReservasEspacios re
JOIN EspaciosComunes ec ON ec.idEspacio = re.idEspacio
WHERE re.estadoReserva <> 'Cancelada'
GROUP BY ec.idPropiedad, ec.idEspacio, ec.nombreEspacio, 4;

-- Ingresos contratados por tipo de habitacion (el modelo no registra gastos:
-- es ingreso, no rentabilidad)
CREATE OR REPLACE VIEW v_ingresos_por_tipo AS
SELECT t.idTipoHabitacion, t.nombreTipoHabitacion AS tipo, t.modalidad,
       COUNT(*)                       AS contratos,
       SUM(c.valorContrato)           AS ingresos_contratados,
       ROUND(AVG(c.valorContrato), 0) AS valor_promedio
FROM ContratosOcupacion c
JOIN Habitaciones h        ON h.idHabitacion = c.idHabitacion
JOIN TiposDeHabitaciones t ON t.idTipoHabitacion = h.tipoHabitacion
WHERE c.estadoContrato IN ('Vigente', 'Finalizado')
GROUP BY t.idTipoHabitacion, t.nombreTipoHabitacion, t.modalidad;