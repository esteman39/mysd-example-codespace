-- =======================
-- --- XSeguridad---------
-- =======================


DROP SCHEMA IF EXISTS recepcionista, administrador, gerente CASCADE;

-- Retira los permisos que los roles aun tengan (p. ej. sobre los componentes)
DROP OWNED BY rol_recepcionista, rol_administrador, rol_gerente;

DROP ROLE IF EXISTS usr_recepcion, usr_admin, usr_gerente;
DROP ROLE IF EXISTS rol_recepcionista, rol_administrador, rol_gerente;
