----------------------------------------
--------------- DOMINIOS ---------------
----------------------------------------
-- 1. Dominio para el identificador catastral del inmueble
CREATE DOMAIN TCHIP AS VARCHAR(30)
CHECK (VALUE ~ '^[A-Z0-9\-]+$' AND VALUE ~ '^[A-Z]{2,3}');

-- 2. Dominio para el identificador único de la habitación
CREATE DOMAIN TIdHabitacion AS VARCHAR(15)
CHECK ( VALUE ~ '^HAB-[A-Z0-9]{1,10}$');

-- 3. Dominio de texto con restricción de valores permitidos para el tipo de habitación
CREATE DOMAIN TTipoHabitacion AS VARCHAR(30)
CHECK (VALUE IN ('Individual', 'Compartida', 'Doble', 'Suite'));

-- 4. Dominio para el identificador de activos del inventario
CREATE DOMAIN TActivo AS VARCHAR(20)
CHECK (VALUE ~ '^[A-Z]{3}-[A-Z]+-[0-9]{4}$');

-- 5. Dominio con restricción de valores permitidos para el estado de los bienes muebles
CREATE DOMAIN TEstadoActivo AS VARCHAR(20)
CHECK (VALUE IN ('Nuevo', 'Bueno', 'Deteriorado', 'Dado de Baja'));

-- 6. Dominio para el identificador de las zonas compartidas
CREATE DOMAIN TEspacioComun AS VARCHAR(10)  
CHECK ( VALUE ~ '^ESP-[0-9]{1,5}$');

-- 7. Dominio para la disponibilidad de la zona
CREATE DOMAIN TEstadoEspacio AS VARCHAR(30)
CHECK (VALUE IN ('Disponible', 'En Mantenimiento', 'Clausurado'));

-- 8. Dominio para el identificador único de la transacción de préstamo de zona común
CREATE DOMAIN TReservaEspacio AS VARCHAR(20)
CHECK (VALUE ~ '^ESP-[0-9]{2}-[0-9]{4}$');

-- 9. Dominio para el ciclo de vida de la reserva
CREATE DOMAIN TEstadoReserva AS VARCHAR(20)
CHECK (VALUE IN ('Confirmada', 'Cancelada', 'Completada'));

-- 10. Dominio para el número de documento de identidad oficial
CREATE DOMAIN TIdentificacion AS VARCHAR(20)
CHECK (VALUE ~ '^[A-Z0-9]{2,20}$');

-- 11. Dominio para los tipos de documentos permitidos
CREATE DOMAIN TTipoDocumento AS VARCHAR(5)
CHECK (VALUE IN ('CC', 'CE', 'PP'));

-- 12. Dominio para los roles del personal administrativo
CREATE DOMAIN TCargo AS VARCHAR(30)
CHECK (VALUE IN ('Recepcionista', 'Administrador', 'Mantenimiento'));

-- 13. Dominio para el identificador único del acuerdo de ocupación
CREATE DOMAIN TIdContrato AS VARCHAR(20)
CHECK (VALUE ~ '^COP-[0-9]+-[0-9]{4}$');

-- 14. Dominio para el tipo de dato numérico con precisión decimal para valores monetarios
CREATE DOMAIN TMoneda AS DECIMAL(12,2)
CHECK (VALUE >= 0);

-- 15. Dominio para la vigencia del contrato
CREATE DOMAIN TEstadoContrato AS VARCHAR(20)
CHECK (VALUE IN ('Borrador', 'Vigente', 'Finalizado', 'Cancelado'));

-- 16. Dominio para el identificador único del registro de visita
CREATE DOMAIN TIdInvitado AS VARCHAR(20)
CHECK (VALUE ~ '^INV-[0-9]{4}$');

-- 17. Dominio para el documento de identidad del visitante externo
CREATE DOMAIN TDocumentoInvitado AS VARCHAR(20)
CHECK (VALUE ~ '^[A-Z0-9]{6,20}$');

-- 18. Dominio para el estado de acceso en tiempo real
CREATE DOMAIN TEstadoAcceso AS VARCHAR(25)
CHECK (VALUE IN ('En las instalaciones', 'Retirado', 'Cancelado'));

-- 19. Dominnio para la direccion de el lugar de residencia
CREATE DOMAIN TDireccion AS VARCHAR(200)
CHECK (VALUE ~ '^[A-Za-z0-9áéíóúÁÉÍÓÚñÑ\s\.,#/\-@()]+$');


-- 20. Dominio para el numero de contrato
CREATE DOMAIN TNumeroContrato AS VARCHAR(4)
CHECK (VALUE ~'^[0-9]{4}$');
    
-- 21. Dominio para la categoria de los activos
CREATE DOMAIN TCategoriaActivo AS VARCHAR(50)
CHECK (VALUE IN ('MOB', 'ELE', 'COM', 'COC', 'TEX', 'SEG'));

-- 22. Dominio para el estado de una habitación
CREATE DOMAIN TEstadoHabitacion AS VARCHAR(20)
CHECK (VALUE IN ('Disponible', 'Ocupada', 'Mantenimiento', 'En Limpieza'));

-- 23. Dominio para la modalidad de contrato
CREATE DOMAIN TModalidadContrato AS VARCHAR(20)
CHECK (VALUE IN ('Largo Plazo', 'Corto Plazo'));

-- 24. Dia de corte mensual: 1 a 28, asi existe en todos los meses (febrero incluido)
CREATE DOMAIN TDiaCorte AS NUMERIC
CHECK (VALUE BETWEEN 1 AND 28);

-- 25. Cantidad entera positiva: aforo, asistentes, capacidad y noches
CREATE DOMAIN TCantidad AS NUMERIC
CHECK (VALUE > 0);

-- 26. Telefono: solo digitos, con '+' opcional
CREATE DOMAIN TTelefono AS VARCHAR(15)
CHECK (VALUE ~ '^\+?[0-9]{7,14}$');

-- 27. Correo electronico: formato minimo algo@algo.algo, sin espacios
CREATE DOMAIN TCorreo AS VARCHAR(50)
CHECK (VALUE ~ '^[^@[:space:]]+@[^@[:space:]]+\.[^@[:space:]]+$');
