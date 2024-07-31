USE CentroLogistico;

-- Aprueba o rechaza una solicitud de materiales o máquinas
DROP PROCEDURE IF EXISTS SP_AprobarORechazarSolicitud;
DELIMITER //

CREATE PROCEDURE SP_AprobarORechazarSolicitud(
    IN p_ID_Solicitud INT,
    IN p_ID_Socio_Gerente INT,
    IN p_Accion VARCHAR(10) -- 'Aprobada' o 'Rechazada'
)
BEGIN
    DECLARE v_Accion_Valida BOOLEAN DEFAULT FALSE;

    -- Comprobar si la acción es válida
    IF p_Accion = 'Aprobada' OR p_Accion = 'Rechazada' THEN
        SET v_Accion_Valida = TRUE;
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Acción no válida. Debe ser "Aprobar" o "Rechazar".';
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
END //
DELIMITER ;

-- Registra una nueva solicitud
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

END //
DELIMITER ;

-- Procedimiento para registrar la salida de materiales y máquinas
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
        VALUES (p_ID_Centro, p_ID_Item, -1); -- Asumiendo que se maneja de a una máquina

        -- Registrar el detalle del movimiento en Detalle_Movimientos
        INSERT INTO Detalle_Movimientos (ID_Movimiento, ID_Almacen_Destino, Cantidad, ID_Maquina)
        VALUES (v_ID_Movimiento, p_ID_Centro, -1, p_ID_Item);
    END IF;
END //
DELIMITER ;

-- Registrar entrada de materiales o maquinas a un centro
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
        -- Asumimos que en `Almacenes_Maquinas` no se maneja el campo `Cantidad`, sino que es 1 por máquina
        INSERT INTO Almacenes_Maquinas (ID_Centro, ID_Maquina)
        VALUES (p_ID_Centro, p_ID_Item);

        -- Registrar el detalle del movimiento en Detalle_Movimientos
        INSERT INTO Detalle_Movimientos (ID_Movimiento, ID_Almacen_Destino, Cantidad, ID_Maquina)
        VALUES (v_ID_Movimiento, p_ID_Centro, 1, p_ID_Item);
    END IF;
END //
DELIMITER ;

-- realizar movimiento una vez tengo solicitud aprobada
DROP PROCEDURE IF EXISTS SP_RealizarMovimiento;
DELIMITER //

CREATE PROCEDURE SP_RealizarMovimiento(
    IN p_ID_Solicitud INT,
    IN p_ID_Empleado INT,
    IN p_ID_Centro_Origen INT
)
BEGIN
    DECLARE v_ID_Centro_Destino INT;
    DECLARE v_Tipo ENUM('Material', 'Maquina');
    DECLARE v_Cantidad INT;
    DECLARE v_ID_Movimiento INT;

    -- Obtener el centro de destino de la solicitud
    SELECT ID_Centro INTO v_ID_Centro_Destino
    FROM Solicitudes
    WHERE ID_Solicitud = p_ID_Solicitud;

    -- Verificar si la solicitud está aprobada
    IF (SELECT Estado FROM Solicitudes WHERE ID_Solicitud = p_ID_Solicitud) != 'Aprobada' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La solicitud no está aprobada';
    END IF;

    -- Registrar el movimiento en la tabla 'Movimientos'
    INSERT INTO Movimientos (Fecha, Tipo, ID_Empleado)
    VALUES (CURDATE(), 'Transferencia', p_ID_Empleado);

    -- Obtener el ID del movimiento recién creado
    SET v_ID_Movimiento = LAST_INSERT_ID();

    -- Procesar los materiales
    INSERT INTO Detalle_Movimientos (ID_Movimiento, ID_Almacen_Origen, ID_Almacen_Destino, ID_Material, Cantidad)
    SELECT 
        v_ID_Movimiento,
        am_origen.ID_Almacen_Material AS ID_Almacen_Origen,
        am_destino.ID_Almacen_Material AS ID_Almacen_Destino,
        ds.ID_Material,
        ds.Cantidad
    FROM Detalle_Solicitudes ds
    JOIN Almacenes_Materiales am_origen ON am_origen.ID_Centro = p_ID_Centro_Origen AND am_origen.ID_Material = ds.ID_Material
    LEFT JOIN Almacenes_Materiales am_destino ON am_destino.ID_Centro = v_ID_Centro_Destino AND am_destino.ID_Material = ds.ID_Material
    WHERE ds.ID_Solicitud = p_ID_Solicitud
    AND ds.Tipo = 'Material';

    -- Actualizar el stock de materiales en el centro de origen y destino
    UPDATE Almacenes_Materiales am
    JOIN Detalle_Solicitudes ds ON am.ID_Centro = p_ID_Centro_Origen AND am.ID_Material = ds.ID_Material
    SET am.Cantidad = am.Cantidad - ds.Cantidad
    WHERE ds.ID_Solicitud = p_ID_Solicitud
    AND ds.Tipo = 'Material';

    INSERT INTO Almacenes_Materiales (ID_Centro, ID_Material, Cantidad)
    SELECT v_ID_Centro_Destino, ds.ID_Material, ds.Cantidad
    FROM Detalle_Solicitudes ds
    WHERE ds.ID_Solicitud = p_ID_Solicitud
    AND ds.Tipo = 'Material'
    ON DUPLICATE KEY UPDATE Cantidad = Cantidad + VALUES(Cantidad);

    -- Procesar las máquinas
    DELETE am
    FROM Almacenes_Maquinas am
    JOIN Detalle_Solicitudes ds ON am.ID_Centro = p_ID_Centro_Origen AND am.ID_Maquina = ds.ID_Maquina
    WHERE ds.ID_Solicitud = p_ID_Solicitud
    AND ds.Tipo = 'Maquina';

    INSERT INTO Almacenes_Maquinas (ID_Centro, ID_Maquina)
    SELECT v_ID_Centro_Destino, ds.ID_Maquina
    FROM Detalle_Solicitudes ds
    WHERE ds.ID_Solicitud = p_ID_Solicitud
    AND ds.Tipo = 'Maquina';

    -- Registrar el detalle del movimiento para máquinas
    INSERT INTO Detalle_Movimientos (ID_Movimiento, ID_Almacen_Origen, ID_Almacen_Destino, ID_Maquina)
    SELECT 
        v_ID_Movimiento,
        am_origen.ID_Almacen_Maquina AS ID_Almacen_Origen,
        am_destino.ID_Almacen_Maquina AS ID_Almacen_Destino,
        ds.ID_Maquina
    FROM Detalle_Solicitudes ds
    LEFT JOIN Almacenes_Maquinas am_origen ON am_origen.ID_Centro = p_ID_Centro_Origen AND am_origen.ID_Maquina = ds.ID_Maquina
    LEFT JOIN Almacenes_Maquinas am_destino ON am_destino.ID_Centro = v_ID_Centro_Destino AND am_destino.ID_Maquina = ds.ID_Maquina
    WHERE ds.ID_Solicitud = p_ID_Solicitud
    AND ds.Tipo = 'Maquina';

END //
DELIMITER ;

--  generar pedido de compras desde una solicitud aprobada
DROP PROCEDURE IF EXISTS SP_GenerarPedidoCompras;
DELIMITER //

CREATE PROCEDURE SP_GenerarPedidoCompras(
    IN ID_Solicitud INT,
    IN ID_Empleado_Compras INT
)
BEGIN
    DECLARE ID_Pedido INT;

    -- Verificar si la solicitud está aprobada
    IF (SELECT Estado FROM Solicitudes WHERE ID_Solicitud = ID_Solicitud) != 'Aprobada' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La solicitud no está aprobada';
    END IF;

    -- Crear el registro del pedido de compras
    INSERT INTO Pedidos_Compras (ID_Solicitud, Fecha, ID_Empleado_Compras)
    VALUES (ID_Solicitud, CURDATE(), ID_Empleado_Compras);

    -- Obtener el ID del pedido de compras recién creado
    SET ID_Pedido = LAST_INSERT_ID();

    -- Insertar los detalles del pedido de compras para materiales faltantes
    INSERT INTO Detalle_Pedidos_Compras (ID_Pedido, ID_Material, Cantidad_Pendiente)
    SELECT 
        ID_Pedido,
        ds.ID_Material,
        ds.Cantidad - IFNULL(am.TotalDisponible, 0) AS Cantidad_Faltante
    FROM Detalle_Solicitudes ds
    LEFT JOIN (
        SELECT ID_Material, SUM(Cantidad) AS TotalDisponible
        FROM Almacenes_Materiales
        GROUP BY ID_Material
    ) am ON ds.ID_Material = am.ID_Material
    WHERE ds.ID_Solicitud = ID_Solicitud
      AND ds.ID_Material IS NOT NULL
      AND ds.Cantidad > IFNULL(am.TotalDisponible, 0);

END; //
DELIMITER ;

