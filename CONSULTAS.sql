---------------------------------------------------
--------------- Consultas -------------------------
---------------------------------------------------


-- C-01 | Recepcionista | Disponibilidad de habitaciones por tipo y propiedad (resumen)
SELECT p.nombrePropiedad,
       t.nombreTipoHabitacion                                                       AS tipo,
       COUNT(*)                                                                     AS total,
       COUNT(*) FILTER (WHERE h.estadoHabitacion = 'Disponible')                    AS disponibles,
       COUNT(*) FILTER (WHERE h.estadoHabitacion = 'Ocupada')                       AS ocupadas,
       COUNT(*) FILTER (WHERE h.estadoHabitacion IN ('Mantenimiento','En Limpieza')) AS no_operativas
FROM Habitaciones h
JOIN Propiedades p        ON p.idPropiedad = h.idPropiedad
JOIN TiposDeHabitaciones t ON t.idTipoHabitacion = h.tipoHabitacion
GROUP BY p.nombrePropiedad, t.nombreTipoHabitacion
ORDER BY p.nombrePropiedad, t.nombreTipoHabitacion;

-- C-02 | Recepcionista | Habitaciones disponibles ahora, con tarifa y modalidad
SELECT p.nombrePropiedad, h.idHabitacion, t.nombreTipoHabitacion AS tipo,
       t.capacidadMaxima, t.tarifaBase, t.modalidad
FROM Habitaciones h
JOIN Propiedades p         ON p.idPropiedad = h.idPropiedad
JOIN TiposDeHabitaciones t ON t.idTipoHabitacion = h.tipoHabitacion
WHERE h.estadoHabitacion = 'Disponible'
ORDER BY p.nombrePropiedad, h.idHabitacion;

-- C-03 | Administrador | Contratos vigentes por modalidad
SELECT CASE WHEN cl.idContrato IS NOT NULL THEN 'Largo Plazo' ELSE 'Corto Plazo' END AS modalidad,
       c.idContrato, c.numeroContrato, per.nombrePersona AS residente, per.telefonoPersona,
       h.idHabitacion, c.fechaInicio, c.fechaFin, c.valorContrato
FROM ContratosOcupacion c
JOIN Residentes r   ON r.idResidente = c.idResidente
JOIN Personas per   ON per.idPersona = r.idResidente
JOIN Habitaciones h ON h.idHabitacion = c.idHabitacion
LEFT JOIN ContratosLargoPlazo cl ON cl.idContrato = c.idContrato
WHERE c.estadoContrato = 'Vigente'
ORDER BY modalidad, c.fechaInicio;

-- C-04 | Administrador | Inventario inicial y final por habitacion (completo)
SELECT h.idHabitacion, inv.idInventario, inv.nombreActivo, inv.categoriaActivo,
       inv.estadoInicial, COALESCE(inv.estadoFinal, '(en uso)') AS estadoFinal
FROM InventariosHabitaciones inv
JOIN Habitaciones h ON h.idHabitacion = inv.idHabitacion
ORDER BY h.idHabitacion, inv.idInventario;

-- C-05 | Administrador | Activos deteriorados, dados de baja o que cambiaron de estado
SELECT h.idHabitacion, inv.idInventario, inv.nombreActivo, inv.estadoInicial, inv.estadoFinal
FROM InventariosHabitaciones inv
JOIN Habitaciones h ON h.idHabitacion = inv.idHabitacion
WHERE inv.estadoFinal IN ('Deteriorado', 'Dado de Baja')
   OR (inv.estadoFinal IS NOT NULL AND inv.estadoInicial <> inv.estadoFinal);

-- C-06 | Recepcionista | Control de asistencia y aforo: reservas confirmadas de hoy
SELECT ec.nombreEspacio, re.idReserva, re.horaInicio, re.horaFin,
       re.cantidadPersonas, ec.aforoEspacio,
       ROUND(100.0 * re.cantidadPersonas / ec.aforoEspacio, 1) AS pct_aforo,
       per.nombrePersona AS residente_responsable, h.idHabitacion
FROM ReservasEspacios re
JOIN EspaciosComunes ec    ON ec.idEspacio = re.idEspacio
JOIN ContratosOcupacion c  ON c.idContrato = re.idContrato
JOIN Personas per          ON per.idPersona = c.idResidente
JOIN Habitaciones h        ON h.idHabitacion = c.idHabitacion
WHERE re.fechaReserva::date = CURRENT_DATE
  AND re.estadoReserva = 'Confirmada'
ORDER BY ec.nombreEspacio, re.horaInicio;

-- C-07 | Recepcionista | Bitacora de invitados activos en el edificio
SELECT i.idInvitado, i.nombreInvitado, i.documentoInvitado, i.fechaHoraIngreso,
       h.idPropiedad, h.idHabitacion,
       pr.nombrePersona AS residente_anfitrion, pp.nombrePersona AS registrado_por
FROM Invitados i
JOIN ContratosOcupacion c ON c.idContrato = i.idContrato
JOIN Habitaciones h       ON h.idHabitacion = c.idHabitacion
JOIN Personas pr          ON pr.idPersona = c.idResidente
JOIN Personas pp          ON pp.idPersona = i.idPersonal_Registro
WHERE i.EstadoInvitado = 'En las instalaciones'
ORDER BY i.fechaHoraIngreso;

-- C-08 | Gerente | Contratos que estuvieron activos en un periodo dado (parametros: inicio y fin)
SELECT c.idContrato, c.numeroContrato, c.estadoContrato, per.nombrePersona AS residente,
       c.fechaInicio, c.fechaFin, c.valorContrato
FROM ContratosOcupacion c
JOIN Personas per ON per.idPersona = c.idResidente
WHERE c.fechaInicio <= DATE '2026-12-31'     -- fin del periodo
  AND c.fechaFin   >= DATE '2026-10-01'      -- inicio del periodo
ORDER BY c.fechaInicio;

-- C-09 | Gerente | Demanda de espacios comunes por franja horaria
SELECT ec.nombreEspacio,
       CASE WHEN re.horaInicio < TIME '12:00' THEN 'Mañana'
            WHEN re.horaInicio < TIME '18:00' THEN 'Tarde'
            ELSE 'Noche' END                                   AS franja,
       COUNT(*)                                                AS reservas,
       SUM(re.cantidadPersonas)                                AS asistentes,
       ROUND(AVG(100.0 * re.cantidadPersonas / ec.aforoEspacio), 1) AS pct_aforo_promedio
FROM ReservasEspacios re
JOIN EspaciosComunes ec ON ec.idEspacio = re.idEspacio
WHERE re.estadoReserva <> 'Cancelada'
GROUP BY ec.nombreEspacio, 2
ORDER BY ec.nombreEspacio, 2;

-- C-10 | Gerente | Ingresos contratados por tipo de habitacion (contratos no cancelados ni en borrador)

SELECT t.nombreTipoHabitacion AS tipo, t.modalidad,
       COUNT(*)                AS contratos,
       SUM(c.valorContrato)    AS ingresos_contratados,
       ROUND(AVG(c.valorContrato), 0) AS valor_promedio
FROM ContratosOcupacion c
JOIN Habitaciones h        ON h.idHabitacion = c.idHabitacion
JOIN TiposDeHabitaciones t ON t.idTipoHabitacion = h.tipoHabitacion
WHERE c.estadoContrato IN ('Vigente', 'Finalizado')
GROUP BY t.nombreTipoHabitacion, t.modalidad
ORDER BY ingresos_contratados DESC;