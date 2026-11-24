-------------------------------------------------------------------
---------------------- XDisparadores ------------------------------
-------------------------------------------------------------------


DROP TRIGGER IF EXISTS trg_actualizar_propiedad       ON Propiedades;
DROP TRIGGER IF EXISTS tg_ins_contrato                ON ContratosOcupacion;
DROP TRIGGER IF EXISTS tg_contrato_confirmado         ON ContratosOcupacion;
DROP TRIGGER IF EXISTS tg_asignacion_tcontrato        ON ContratosOcupacion;
DROP TRIGGER IF EXISTS tg_habitacion_libre            ON ContratosOcupacion;
DROP TRIGGER IF EXISTS tg_ins_reservaespacio          ON ReservasEspacios;
DROP TRIGGER IF EXISTS tg_espacio_ocupado             ON ReservasEspacios;
DROP TRIGGER IF EXISTS tg_eliminar_reserva            ON ReservasEspacios;
DROP TRIGGER IF EXISTS tg_agregar_contacto            ON ContactosEmergencia;
DROP TRIGGER IF EXISTS tg_contacto_principal          ON ContactosEmergencia;
DROP TRIGGER IF EXISTS tg_restricciones_actualizacion ON Personas;
DROP TRIGGER IF EXISTS tg_roles_trabajadores          ON Personal;
DROP TRIGGER IF EXISTS tg_ins_invitado                ON Invitados;
DROP TRIGGER IF EXISTS tg_invitado_ingresado          ON Invitados;
DROP TRIGGER IF EXISTS tg_invitado_fuera              ON Invitados;
DROP TRIGGER IF EXISTS tg_ele_invitado                ON Invitados;
DROP TRIGGER IF EXISTS tg_adicionar_habitacion        ON Habitaciones;

DROP FUNCTION IF EXISTS fn_tg_actualizar_propiedad();
DROP FUNCTION IF EXISTS fn_tg_ins_contrato();
DROP FUNCTION IF EXISTS fn_tg_contrato_confirmado();
DROP FUNCTION IF EXISTS fn_tg_asignacion_tcontratol();
DROP FUNCTION IF EXISTS fn_tg_habitacion_libre();
DROP FUNCTION IF EXISTS fn_tg_ins_reservaespacio();
DROP FUNCTION IF EXISTS fn_tg_espacio_ocupado();
DROP FUNCTION IF EXISTS fn_tg_eliminar_reserva();
DROP FUNCTION IF EXISTS fn_tg_agregar_contacto();
DROP FUNCTION IF EXISTS fn_tg_contacto_principal();
DROP FUNCTION IF EXISTS fn_tg_restricciones_actualizacion();
DROP FUNCTION IF EXISTS fn_tg_roles_trabajadores();
DROP FUNCTION IF EXISTS fn_tg_ins_invitado();
DROP FUNCTION IF EXISTS fn_tg_invitado_ingresado();
DROP FUNCTION IF EXISTS fn_tg_invitado_fuera();
DROP FUNCTION IF EXISTS fn_tg_ele_invitado();
DROP FUNCTION IF EXISTS fn_tg_adicionar_habitacion();