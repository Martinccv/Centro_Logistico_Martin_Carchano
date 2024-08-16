USE CentroLogistico;

-- 1. Aprueba o rechaza una solicitud de materiales o máquinas
DROP PROCEDURE IF EXISTS SP_AprobarORechazarSolicitud;
DELIMITER //

CREATE PROCEDURE SP_AprobarORechazarSolicitud(
    IN p_ID_Solicitud INT,
    IN p_ID_Socio_Gerente INT,
    IN p_Accion VARCHAR(10) -- 'Aprobada' o 'Rechazada'
)
BEGIN

    DECLARE v_Accion_Valida BOOLEAN DEFAULT FALSE;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        -- Si ocurre un error, deshacer la transacción
        ROLLBACK;
    END;

    START TRANSACTION;
    -- Comprobar si la acción es válida
    IF p_Accion = 'Aprobada' OR p_Accion = 'Rechazada' THEN
        SET v_Accion_Valida = TRUE;
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Acción no válida. Debe ser "Aprobada" o "Rechazada".';
    END IF;

    -- Crear o actualizar una autorización en la tabla Autorizaciones
    IF v_Accion_Valida THEN
        INSERT INTO Autorizaciones (ID_Solicitud, ID_Socio_Gerente, Estado, Fecha)
        VALUES (p_ID_Solicitud, p_ID_Socio_Gerente, p_Accion, NOW())
        ON DUPLICATE KEY UPDATE Estado = p_Accion, Fecha = NOW();

        -- Actualizar el estado de la solicitud en la tabla Solicitudes
        UPDATE Solicitudes
        SET Estado = p_Accion
        WHERE ID_Solicitud = p_ID_Solicitud;
    END IF;
    COMMIT;
END //
DELIMITER ;

-- 2. Registra una nueva solicitud
DROP PROCEDURE IF EXISTS SP_CrearSolicitud;
DELIMITER //

CREATE PROCEDURE SP_CrearSolicitud(
    IN p_Tipo ENUM('Material', 'Maquina'),
    IN p_ID_Cliente INT,
    IN p_ID_Empleado INT,
    IN p_ID_Centro INT,
    IN p_DetallesSolicitud JSON
)
BEGIN
    
    DECLARE v_ID_Solicitud INT;
    DECLARE v_ID_Item INT;
    DECLARE v_Cantidad INT;
    DECLARE v_Index INT DEFAULT 0;
    DECLARE v_Limit INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        -- Si ocurre un error, deshacer la transacción
        ROLLBACK;
    END;

    START TRANSACTION;
    -- Obtener el número de elementos en el JSON
    SET v_Limit = JSON_LENGTH(p_DetallesSolicitud);

    -- Crear la solicitud con estado 'Pendiente'
    INSERT INTO Solicitudes (Fecha, Tipo, ID_Cliente, ID_Empleado, ID_Centro, Estado)
    VALUES (CURDATE(), p_Tipo, p_ID_Cliente, p_ID_Empleado, p_ID_Centro, 'Pendiente');

    -- Obtener el ID de la solicitud recién creada
    SET v_ID_Solicitud = LAST_INSERT_ID();

    -- Iterar sobre los detalles de la solicitud
    WHILE v_Index < v_Limit DO
        -- Extraer ID_Item y Cantidad
        SET v_ID_Item = CAST(JSON_UNQUOTE(JSON_EXTRACT(p_DetallesSolicitud, CONCAT('$[', v_Index, '].ID_Item'))) AS UNSIGNED);
        SET v_Cantidad = CAST(JSON_UNQUOTE(JSON_EXTRACT(p_DetallesSolicitud, CONCAT('$[', v_Index, '].Cantidad'))) AS UNSIGNED);

        -- Insertar en Detalle_Solicitudes según el tipo (Material o Maquina)
        IF p_Tipo = 'Material' THEN
            INSERT INTO Detalle_Solicitudes (ID_Solicitud, ID_Material, Cantidad)
            VALUES (v_ID_Solicitud, v_ID_Item, v_Cantidad);
        ELSE
            INSERT INTO Detalle_Solicitudes (ID_Solicitud, ID_Maquina)
            VALUES (v_ID_Solicitud, v_ID_Item);
        END IF;

        -- Incrementar el índice para la próxima iteración
        SET v_Index = v_Index + 1;
    END WHILE;
    COMMIT;
END //
DELIMITER ;

-- 3. Registrar entrada de materiales o maquinas a un centro
DROP PROCEDURE IF EXISTS SP_RegistrarEntrada;
DELIMITER //

CREATE PROCEDURE SP_RegistrarEntrada(
    IN p_Tipo ENUM('Material', 'Maquina'),
    IN p_ID_Centro INT,
    IN p_ID_Item INT,
    IN p_Cantidad INT,
    IN p_ID_Empleado INT
)
BEGIN

    DECLARE v_ID_Movimiento INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        -- Si ocurre un error, deshacer la transacción
        ROLLBACK;
    END;

    START TRANSACTION;
    -- Registrar el movimiento en la tabla 'Movimientos'
    INSERT INTO Movimientos (Fecha, Tipo, ID_Empleado)
    VALUES (CURDATE(), 'Entrada', p_ID_Empleado);

    -- Obtener el ID del movimiento recién creado
    SET v_ID_Movimiento = LAST_INSERT_ID();

    IF p_Tipo = 'Material' THEN
        -- Registrar el detalle del movimiento para Materiales con cantidad positiva
        INSERT INTO Almacenes_Materiales (ID_Centro, ID_Material, Cantidad)
        VALUES (p_ID_Centro, p_ID_Item, p_Cantidad);
        
        -- Registrar el detalle del movimiento en Detalle_Movimientos
        INSERT INTO Detalle_Movimientos (ID_Movimiento, ID_Almacen_Destino, Cantidad, ID_Material)
        VALUES (v_ID_Movimiento, p_ID_Centro, p_Cantidad, p_ID_Item);
    ELSE
        -- Registrar el detalle del movimiento para Maquinas
        INSERT INTO Almacenes_Maquinas (ID_Centro, ID_Maquina)
        VALUES (p_ID_Centro, p_ID_Item);

        -- Registrar el detalle del movimiento en Detalle_Movimientos
        INSERT INTO Detalle_Movimientos (ID_Movimiento, ID_Almacen_Destino, Cantidad, ID_Maquina)
        VALUES (v_ID_Movimiento, p_ID_Centro, 1, p_ID_Item);
    END IF;
    COMMIT;
END //
DELIMITER ;

-- 4. Procedimiento para registrar la salida de materiales y máquinas
DROP PROCEDURE IF EXISTS SP_RegistrarSalida;
DELIMITER //

CREATE PROCEDURE SP_RegistrarSalida(
    IN p_Tipo ENUM('Material', 'Maquina'),
    IN p_ID_Centro INT,
    IN p_ID_Item INT,
    IN p_Cantidad INT,
    IN p_ID_Empleado INT
)
BEGIN
    

    
    DECLARE v_ID_Movimiento INT;

     DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        -- Si ocurre un error, deshacer la transacción
        ROLLBACK;
    END;
    
    START TRANSACTION;
    -- Registrar el movimiento en la tabla 'Movimientos'
    INSERT INTO Movimientos (Fecha, Tipo, ID_Empleado)
    VALUES (CURDATE(), 'Salida', p_ID_Empleado);

    -- Obtener el ID del movimiento recién creado
    SET v_ID_Movimiento = LAST_INSERT_ID();

    IF p_Tipo = 'Material' THEN
        -- Registrar el detalle del movimiento para Materiales con cantidad negativa
        INSERT INTO Almacenes_Materiales (ID_Centro, ID_Material, Cantidad)
        VALUES (p_ID_Centro, p_ID_Item, -p_Cantidad);
        
        -- Registrar el detalle del movimiento en Detalle_Movimientos
        INSERT INTO Detalle_Movimientos (ID_Movimiento, ID_Almacen_Destino, Cantidad, ID_Material)
        VALUES (v_ID_Movimiento, p_ID_Centro, -p_Cantidad, p_ID_Item);
    ELSE
        -- Registrar el detalle del movimiento para Maquinas con cantidad negativa
        INSERT INTO Almacenes_Maquinas (ID_Centro, ID_Maquina, Cantidad)
        VALUES (p_ID_Centro, p_ID_Item, -1); -- se maneja de a una máquina

        -- Registrar el detalle del movimiento en Detalle_Movimientos
        INSERT INTO Detalle_Movimientos (ID_Movimiento, ID_Almacen_Destino, Cantidad, ID_Maquina)
        VALUES (v_ID_Movimiento, p_ID_Centro, -1, p_ID_Item);
    END IF;
    COMMIT;
END //
DELIMITER ;

-- 5. Realizar movimiento de materiales con una solicitud aprobada
DROP PROCEDURE IF EXISTS SP_RealizarMovimientoMateriales;
DELIMITER //

CREATE PROCEDURE SP_RealizarMovimientoMateriales(
    IN p_ID_Solicitud INT,
    IN p_ID_Empleado INT,
    IN p_ID_Centro_Origen INT,
    IN p_Materiales JSON -- JSON con pares {ID_Material:, Cantidad:}
)
BEGIN
    
    DECLARE v_ID_Centro_Destino INT;
    DECLARE v_ID_Movimiento INT;
    DECLARE v_Cantidad INT;
    DECLARE v_ID_Material INT;
    DECLARE v_Indice INT DEFAULT 0;
    -- DECLARE v_Id_Autorizacion INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        -- Si ocurre un error, deshacer la transacción
        ROLLBACK;
    END;

    START TRANSACTION;
    -- Obtener el centro de destino de la solicitud
    SELECT ID_Centro INTO v_ID_Centro_Destino
    FROM Solicitudes
    WHERE ID_Solicitud = p_ID_Solicitud;
    -- SELECT ID_Autorizacion INTO v_ID_Autorizacion
    -- FROM Autorizaciones
    -- WHERE ID_Solicitud = p_ID_Solicitud;

    -- Verificar si la solicitud está aprobada y es de tipo 'Material'
    IF (SELECT Estado FROM Solicitudes WHERE ID_Solicitud = p_ID_Solicitud) != 'Aprobada'
        OR (SELECT Tipo FROM Solicitudes WHERE ID_Solicitud = p_ID_Solicitud) != 'Material' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La solicitud no está aprobada o no es de tipo Material';
    END IF;

    -- Registrar el movimiento en la tabla 'Movimientos'
     INSERT INTO Movimientos (Fecha, Tipo, ID_Empleado) -- Agregar ID_Autorizacion
    VALUES (CURDATE(), 'Transferencia', p_ID_Empleado); -- Agregar v_ID_Autorizacion

    -- Obtener el ID del movimiento recién creado
    SET v_ID_Movimiento = LAST_INSERT_ID();

    -- Procesar los materiales
    WHILE v_Indice < JSON_LENGTH(p_Materiales) DO
        SET v_ID_Material = JSON_UNQUOTE(JSON_EXTRACT(p_Materiales, CONCAT('$[', v_Indice, '].ID_Material')));
        SET v_Cantidad = JSON_UNQUOTE(JSON_EXTRACT(p_Materiales, CONCAT('$[', v_Indice, '].Cantidad')));

        INSERT INTO Almacenes_Materiales (ID_Centro, ID_Material, Cantidad)
        VALUES (p_ID_Centro_Origen, v_ID_Material, -v_Cantidad);
        INSERT INTO Almacenes_Materiales (ID_Centro, ID_Material, Cantidad)
        VALUES (v_ID_Centro_Destino, v_ID_Material, v_Cantidad);
        INSERT INTO Detalle_Movimientos (ID_Movimiento, ID_Almacen_Origen, ID_Almacen_Destino, ID_Material, Cantidad)
        VALUES (v_ID_Movimiento, p_ID_Centro_Origen, v_ID_Centro_Destino, v_ID_Material, v_Cantidad);
        SET v_Indice = v_Indice + 1;
    END WHILE;
    COMMIT;
END //
DELIMITER ;

-- 6. Realizar movimientos de maquinas tomando una solicitud aprobada
DROP PROCEDURE IF EXISTS SP_RealizarMovimientoMaquinas;
DELIMITER //

CREATE PROCEDURE SP_RealizarMovimientoMaquinas(
    IN p_ID_Solicitud INT,
    IN p_ID_Empleado INT,
    IN p_ID_Centro_Origen INT,
    IN p_Maquinas JSON -- JSON con pares {ID_Maquina:}
)
BEGIN
    
    DECLARE v_ID_Centro_Destino INT;
    DECLARE v_ID_Movimiento INT;
    DECLARE v_ID_Maquina INT;
    DECLARE v_Indice INT DEFAULT 0;
    -- DECLARE v_ID_Autorizacion INT;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        -- Si ocurre un error, deshacer la transacción
        ROLLBACK;
    END;

    START TRANSACTION;
    -- Obtener el centro de destino de la solicitud
    SELECT ID_Centro INTO v_ID_Centro_Destino
    FROM Solicitudes
    WHERE ID_Solicitud = p_ID_Solicitud;
    -- SELECT ID_Autorizacion INTO v_ID_Autorizacion
    -- FROM Autorizaciones
    -- WHERE ID_Solicitud = p_ID_Solicitud;

    -- Verificar si la solicitud está aprobada
    IF (SELECT Estado FROM Solicitudes WHERE ID_Solicitud = p_ID_Solicitud) != 'Aprobada' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La solicitud no está aprobada';
    END IF;

    -- Registrar el movimiento en la tabla 'Movimientos'
    INSERT INTO Movimientos (Fecha, Tipo, ID_Empleado) -- Agregar ID_Autorizacion
    VALUES (CURDATE(), 'Transferencia', p_ID_Empleado); -- Agregar v_ID_Autorizacion

    -- Obtener el ID del movimiento recién creado
    SET v_ID_Movimiento = LAST_INSERT_ID();

    -- Procesar las máquinas
    WHILE v_Indice < JSON_LENGTH(p_Maquinas) DO
        SET v_ID_Maquina = JSON_UNQUOTE(JSON_EXTRACT(p_Maquinas, CONCAT('$[', v_Indice, '].ID_Maquina')));

        INSERT INTO Almacenes_Maquinas (ID_Centro, ID_Maquina, Cantidad)
        VALUES (p_ID_Centro_Origen, v_ID_Maquina, -1);
        INSERT INTO Almacenes_Maquinas (ID_Centro, ID_Maquina)
        VALUES (v_ID_Centro_Destino, v_ID_Maquina);
        INSERT INTO Detalle_Movimientos (ID_Movimiento, ID_Almacen_Origen, ID_Almacen_Destino, ID_Maquina)
        VALUES (v_ID_Movimiento, p_ID_Centro_Origen, v_ID_Centro_Destino, v_ID_Maquina);

        SET v_Indice = v_Indice + 1;
    END WHILE;
    COMMIT;
END //
DELIMITER ;

--  7. generar pedido de compras desde una solicitud aprobada
DROP PROCEDURE IF EXISTS SP_GenerarPedidoCompras;
DELIMITER //

CREATE PROCEDURE SP_GenerarPedidoCompras(
    IN p_ID_Solicitud INT,
    IN p_ID_Empleado_Compras INT
)
BEGIN
    DECLARE v_ID_Material INT;
    DECLARE v_Cantidad INT;
    DECLARE v_CantidadDisponible INT;
    DECLARE v_CantidadPedir INT;
    DECLARE v_ID_Pedido INT;
    DECLARE done INT DEFAULT 0;
    DECLARE msj INT DEFAULT 0;
    DECLARE detalle_cursor CURSOR FOR
        SELECT ID_Material, Cantidad
        FROM Detalle_Solicitudes
        WHERE ID_Solicitud = p_ID_Solicitud;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    START TRANSACTION;
    -- Verificar si la solicitud está aprobada
    IF (SELECT COUNT(*) FROM Solicitudes WHERE ID_Solicitud = p_ID_Solicitud AND Estado = 'Aprobada') = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La solicitud no está aprobada o no existe.';
    END IF;

    -- Crear el registro del pedido de compras para cada material
    INSERT INTO Pedidos_Compras (ID_Solicitud, Fecha, ID_Empleado_Compras)
    VALUES (p_ID_Solicitud, CURDATE(), p_ID_Empleado_Compras);

    -- Obtener el ID del pedido de compras recién creado
    SET v_ID_Pedido = LAST_INSERT_ID();

    -- Abrir el cursor
    OPEN detalle_cursor;

    -- Bucle para cada material en el detalle de la solicitud
    read_loop: LOOP
        FETCH detalle_cursor INTO v_ID_Material, v_Cantidad;
        IF done THEN
            LEAVE read_loop;
        END IF;

        -- Obtener la cantidad disponible en centros de tipo "Deposito"
        SELECT IFNULL(SUM(Cantidad), 0) INTO v_CantidadDisponible
        FROM Almacenes_Materiales
        WHERE ID_Material = v_ID_Material AND ID_Centro IN (7, 8, 9);

        -- Si la cantidad disponible es suficiente, emitir advertencia y continuar
        IF v_CantidadDisponible >= v_Cantidad THEN
            -- Todo el material está disponible en depósitos, advertir y no crear pedido
            SET msj = 1; -- Salir del bucle en este caso

        ELSE
            -- Cantidad a pedir es la requerida menos la disponible en depósitos
            SET v_CantidadPedir = v_Cantidad - v_CantidadDisponible;

            -- Insertar el detalle del pedido de compras
            INSERT INTO Detalle_Pedidos_Compras (ID_Pedido, ID_Material, Cantidad_Pendiente)
            VALUES (v_ID_Pedido, v_ID_Material, v_CantidadPedir);
        END IF;

    END LOOP;

    -- Cerrar el cursor
    CLOSE detalle_cursor;
    
     -- Eliminar el pedido de compras si no se han creado detalles
    IF NOT EXISTS (SELECT 1 FROM Detalle_Pedidos_Compras WHERE ID_Pedido = v_ID_Pedido) THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se ha generado pedido de compras, el stock es suficiente';
    END IF;
    COMMIT;
    -- Señalar una advertencia al final del procedimiento si hay materiales completamente disponibles
    IF msj = 1 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'ADVERTENCIA: Uno o más materiales están completamente disponibles en depósitos.';
    END IF;
END //
DELIMITER ;