Esquema
DOMINIOS.sql — Se agregaron dominios: 23 → 27. Los nuevos son TDiaCorte, TCantidad, TTelefono y TCorreo (H-18, H-28).
Tablas.sql
Invitados: se agregó la columna documentoInvitado TDocumentoInvitado NOT NULL (H-07).
TiposDeHabitaciones: la llave es idTipoHabitacion TTipoHabitacion (texto) y Habitaciones.tipoHabitacion la referencia (D1, H-08).
aforoEspacio, capacidadMaxima, cantidadPersonas y totalNoches usan TCantidad; diaCorteMensual usa TDiaCorte (H-28).
fechaFin se mantiene NOT NULL (D2, H-27).
Atributos.sql (nuevo) — DEFAULT para estadoContrato ('Borrador'), estadoHabitacion ('Disponible'), estadoActualEspacio ('Disponible'), estadoReserva ('Confirmada'), esPrincipal (FALSE) y EstadoInvitado ('En las instalaciones') (H-19).
PRIMARY KEYS.sql
TienePoliticas: PK (idContrato, politicaCancelacion).
TieneClausulas: PK (idContrato, clausula) (H-25).
ContactosEmergencia: PK (idResidente, idContactoEmergencia).
UNIQUE.sql — Se agregaron 5 restricciones: correo de persona, nombre de tipo de habitación, número de contrato, (dirección, ciudad) de propiedad y (idPropiedad, nombreEspacio).
FOREIGN KEYS.sql — Se agregó FK_ContactosEmergencia_Personas (H-26). Habitaciones.tipoHabitacion referencia TiposDeHabitaciones(idTipoHabitacion) (H-08).
AccionesReferenciales.sql — Reescrito con la matriz única (D5):
Habitaciones→Propiedad y EspaciosComunes→Propiedad: RESTRICT/RESTRICT, una sola declaración cada una, mismo nombre en DROP y ADD (H-20, H-21, H-22).
Invitados→Contrato y Reservas→Contrato: ON DELETE RESTRICT (H-23).
ContratosLargo/Corto→Contrato, TienePoliticas→CortoPlazo y TieneClausulas→LargoPlazo: CASCADE (H-24).
ContactosEmergencia→Residentes: CASCADE.
ContactosEmergencia→Personas, Residentes→Personas y Personal→Personas: RESTRICT.
Tuplas.sql — Se agregaron 5 CHECK: CHK_Contrato_Fechas, CHK_Contrato_Duracion (1 año, D3), CHK_Reserva_Horas, CHK_Invitado_Fechas y CHK_Inventario_Prefijo (H-28).
Indices.sql — Pasó a 15 índices con IF NOT EXISTS: 7 sobre FK, 5 de consulta/trigger y 3 únicos parciales (ux_hab_un_contrato_vigente, ux_un_administrador, ux_un_contacto_principal) (H-31, D4).
Vistas,.sql (nuevo) — 9 vistas: v_habitaciones_disponibles, v_disponibilidad_por_tipo, v_invitados_activos, v_control_aforo_espacios, v_contratos_vigentes, v_inventario_habitacion, v_personal_publico, v_demanda_espacios_franja y v_ingresos_por_tipo (H-09).
JSON.sql y DescripcionActivoInventarioSchema.json (nuevos) — descripcionActivo a JSONB con CHECK de estructura (campo obligatorio material).
Lógica
Disparadores.sql
fn_tg_restricciones_actualizacion: columnas renombradas a tipoIdentificacion y numeroIdentificacion (H-01).
fn_tg_ins_contrato: la habitación se valida con IS DISTINCT FROM, en INSERT y cuando cambia idHabitacion en UPDATE (H-15, H-16).
fn_tg_invitado_ingresado: la fecha de ingreso usa COALESCE (H-06).
Se eliminó trg_ins_espacio_comun; el estado inicial pasa a DEFAULT en Atributos.sql (H-19).
COMPONENTES.sql
Se quitaron de aquí el trigger tg_asignacion_tcontrato duplicado y los CREATE INDEX (H-05, H-31, H-33).
Los cursores se reemplazaron por funciones co_* que devuelven SETOF (H-35).
Se organizó en 6 paquetes: propiedades, habitaciones, personas, contratos, reservas e invitados.
ad_tipo_habitacion recibe el id como parámetro (D1).
eli_contrato: un solo DELETE; subtipos, políticas y cláusulas salen por CASCADE (H-24).
mod_contrato: bloquea cambios desde Finalizado/Cancelado y recalcula totalNoches al cambiar la fecha fin (H-34).
eli_residente: ya no borra contactos a mano.
mod_contacto: al marcar uno como principal, los demás dejan de serlo.
mod_habitacion: el estado Ocupada solo lo gestionan los contratos.
mod_reserva: una reserva cancelada no se reactiva.
Se agregó el servicio can_invitado, necesario para poder ejecutar eli_invitado.
Las mutaciones traducen el error de FK a mensajes claros (eli_propiedad, eli_espacio, eli_habitacion, eli_tipo_habitacion, eli_residente, eli_contrato, ad_politica, ad_clausula).
CONSULTAS.sql — C-01 a C-10 alineadas a los casos de uso: usan tipoHabitacion, comparan por fechaReserva::date (H-29), agrupan disponibilidad por tipo y propiedad, calculan % de aforo, incluyen contratos por periodo, demanda por franja e ingresos por tipo.
Actores.sql (nuevo) — Esquemas recepcionista, administrador y gerente con funciones y procedimientos delegados a los paquetes:
Recepcionista: 3 consultas + invitados, reservas, personas, residentes, contactos y contratos.
Administrador: 3 consultas + habitaciones, inventario, espacios, contratos, políticas, cláusulas, residentes, contactos y personal.
Gerente: 3 consultas (co_contratos_periodo, co_demanda_espacios, co_ingresos_por_tipo) + propiedades, tipos de habitación y personal.
Seguridad.sql (nuevo) — Roles rol_recepcionista, rol_administrador y rol_gerente con sus usuarios, REVOKE a PUBLIC y GRANT USAGE/EXECUTE por esquema.
Datos
PoblarOk.sql — Ids de espacio unificados (ESP-001..004, H-37), reservas e invitados relativos a CURRENT_DATE (H-40), reservas ligadas a contratos Vigentes de la misma propiedad (H-41), subtipos de contrato insertados a mano porque se carga antes de los triggers (H-38), HAB-101 reservada para pruebas negativas (H-39).
POBLAR EXTREMO.sql — Sin cambios relevantes; sigue siendo el archivo del poblado extremo.
Pruebas
PoblarNoOk, TuplasNoOk, DisparadoresNoOk, ComponetesNoOk — Ids con formato válido para que cada prueba falle por la regla que prueba (H-36).
Archivos de prueba nuevos: ComponetesOk, ComponetesNoOk, IndicesNoOk, IndicesVistasOk, SeguridadOK, SeguridadNoOk y Pruebas. AccionesReferencialesOk/NoOk, DisparadoresOk y TuplasOk fueron reescritos con los datos de PoblarOk.
Scripts de limpieza
xTablas.sql — Un solo DROP TABLE con las 16 tablas (H-12).
xPoblar.sql — Un solo TRUNCATE dinámico de las tablas existentes (H-12).
xDisparadores.sql — Nombres de triggers y funciones actualizados a los vigentes (H-13).
xDominios.sql — Incluye los 27 dominios.
XIndicesVistas.sql — Reemplaza a xIndices; elimina las 9 vistas y los 15 índices.
xComponentes.sql y xSeguridad.sql (nuevos) — Eliminan los 6 paquetes de dominio, y los 3 esquemas de actores con sus roles y usuarios.

En Astah resaltamos los cambos tanto en DATOS como conceptual extendido, se agrego JSON, se agrego también los triggers y material faltante con respecto a los estereotipos y acciones de cada tabla.