-- ============================================================================
-- SEGURIDAD
-- ============================================================================


-- 1. Roles de grupo
CREATE ROLE rol_recepcionista NOLOGIN;
CREATE ROLE rol_administrador NOLOGIN;
CREATE ROLE rol_gerente       NOLOGIN;

-- 2. Usuarios, cada uno miembro de su rol
CREATE ROLE usr_recepcion LOGIN PASSWORD 'Recepcion#2026' IN ROLE rol_recepcionista;
CREATE ROLE usr_admin     LOGIN PASSWORD 'Admin#2026'     IN ROLE rol_administrador;
CREATE ROLE usr_gerente   LOGIN PASSWORD 'Gerente#2026'   IN ROLE rol_gerente;

-- 3. Cerrar lo que PostgreSQL abre por defecto: al crear una funcion, EXECUTE queda
--    concedido a PUBLIC (todos). Se retira de todos los servicios.
REVOKE ALL ON SCHEMA recepcionista, administrador, gerente,
                     propiedades, habitaciones, personas, contratos, reservas, invitados
    FROM PUBLIC;
REVOKE EXECUTE ON ALL ROUTINES IN SCHEMA recepcionista, administrador, gerente,
                     propiedades, habitaciones, personas, contratos, reservas, invitados
    FROM PUBLIC;

-- 4. Permisos de cada rol: USAGE del schema (poder verlo) + EXECUTE de sus servicios
GRANT USAGE ON SCHEMA recepcionista, invitados, reservas TO rol_recepcionista;
GRANT EXECUTE ON ALL ROUTINES IN SCHEMA recepcionista, invitados, reservas TO rol_recepcionista;

GRANT USAGE ON SCHEMA administrador, propiedades, habitaciones, personas, contratos, reservas, invitados
    TO rol_administrador;
GRANT EXECUTE ON ALL ROUTINES IN SCHEMA administrador, propiedades, habitaciones, personas, contratos, reservas, invitados
    TO rol_administrador;

GRANT USAGE ON SCHEMA gerente TO rol_gerente;
GRANT EXECUTE ON ALL ROUTINES IN SCHEMA gerente TO rol_gerente;