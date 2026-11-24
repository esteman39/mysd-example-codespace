-------------------------------------------------------
------------------ xPoblar ----------------------------
-------------------------------------------------------
DO $$
DECLARE
    v_tablas text;
BEGIN
    SELECT string_agg(t, ', ')
      INTO v_tablas
      FROM unnest(ARRAY[
            'ReservasEspacios', 'Invitados', 'InventariosHabitaciones',
            'ContactosEmergencia', 'TienePoliticas', 'TieneClausulas',
            'ContratosLargoPlazo', 'ContratosCortoPlazo', 'ContratosOcupacion',
            'Habitaciones', 'TiposDeHabitaciones', 'EspaciosComunes',
            'Personal', 'Residentes', 'Personas', 'Propiedades']) AS t
     WHERE to_regclass(t) IS NOT NULL;

    IF v_tablas IS NOT NULL THEN
        EXECUTE 'TRUNCATE TABLE ' || v_tablas;
    END IF;
END $$;