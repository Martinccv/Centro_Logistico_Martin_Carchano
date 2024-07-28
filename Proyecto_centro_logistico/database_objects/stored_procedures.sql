USE CentroLogistico;

-- Aprueba o rechaza una solicitud de materiales o máquinas
DROP PROCEDURE IF EXISTS sp_AprobarORechazarSolicitud;

DELIMITER //

CREATE PROCEDURE sp_AprobarORechazarSolicitud(
    IN p_ID_Solicitud INT,
    IN p_ID_Socio_Gerente INT,
    IN p_Accion VARCHAR(10) -- 'Aprobar' o 'Rechazar'
)
BEGIN
    IF p_Accion = 'Aprobar' THEN
        UPDATE Autorizaciones
        SET Estado = 'Aprobada', Fecha = NOW()
        WHERE ID_Solicitud = p_ID_Solicitud AND ID_Socio_Gerente = p_ID_Socio_Gerente;

        UPDATE Solicitudes
        SET Estado = 'Aprobada'
        WHERE ID_Solicitud = p_ID_Solicitud;
    ELSEIF p_Accion = 'Rechazar' THEN
        UPDATE Autorizaciones
        SET Estado = 'Rechazada', Fecha = NOW()
        WHERE ID_Solicitud = p_ID_Solicitud AND ID_Socio_Gerente = p_ID_Socio_Gerente;

        UPDATE Solicitudes
        SET Estado = 'Rechazada'
        WHERE ID_Solicitud = p_ID_Solicitud;
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Acción no válida. Debe ser "Aprobar" o "Rechazar".';
    END IF;
END //

DELIMITER ;

-- Registra una nueva solicitud
DELIMITER //

CREATE PROCEDURE CrearSolicitud(
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


-- Realizar una autorizacion de una solicitud
DELIMITER //

CREATE PROCEDURE AutorizarSolicitud(
    IN ID_Solicitud INT,
    IN ID_Socio_Gerente INT,
    IN Estado ENUM('Aprobada', 'Rechazada')
)
BEGIN
    -- Actualizar el estado de la solicitud en la tabla 'Solicitudes'
    UPDATE Solicitudes
    SET Estado = Estado
    WHERE ID_Solicitud = ID_Solicitud;

    -- Registrar la autorización en la tabla 'Autorizaciones'
    INSERT INTO Autorizaciones (ID_Solicitud, ID_Socio_Gerente, Estado, Fecha)
    VALUES (ID_Solicitud, ID_Socio_Gerente, Estado, CURDATE());
END;
//

DELIMITER ;

-- Realizar un movimiento una vez tenga una solicitud aprobada
DELIMITER //

CREATE PROCEDURE RealizarMovimiento(
    IN p_ID_Solicitud INT,
    IN p_ID_Empleado INT,
    IN p_ID_Centro_Destino INT
)
BEGIN
    DECLARE v_Tipo ENUM('Material', 'Maquina');
    DECLARE v_ID_Material INT;
    DECLARE v_ID_Maquina INT;
    DECLARE v_Cantidad INT;
    DECLARE v_ID_Almacen_Material INT;
    DECLARE v_ID_Almacen_Material_Destino INT;
    DECLARE v_ID_Almacen_Maquina INT;
    DECLARE v_ID_Almacen_Maquina_Destino INT;
    DECLARE v_ID_Movimiento INT;

    -- Verificar si la solicitud está aprobada
    IF (SELECT Estado FROM Solicitudes WHERE ID_Solicitud = p_ID_Solicitud) != 'Aprobada' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La solicitud no está aprobada';
    END IF;

    -- Registrar el movimiento en la tabla 'Movimientos'
    INSERT INTO Movimientos (Fecha, Tipo, ID_Empleado)
    VALUES (CURDATE(), 'Transferencia', p_ID_Empleado);

    -- Obtener el ID del movimiento recién creado
    SET v_ID_Movimiento = LAST_INSERT_ID();

    -- Declarar el cursor para los detalles de la solicitud
    DECLARE cursor2 CURSOR FOR
        SELECT Tipo, ID_Material, ID_Maquina, Cantidad
        FROM Detalle_Solicitudes
        WHERE ID_Solicitud = p_ID_Solicitud;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_Tipo = NULL;

    OPEN cursor2;

    read_loop: LOOP
        FETCH cursor2 INTO v_Tipo, v_ID_Material, v_ID_Maquina, v_Cantidad;

        IF v_Tipo IS NULL THEN
            LEAVE read_loop;
        END IF;

        -- Procesar materiales
        IF v_Tipo = 'Material' THEN
            -- Actualizar stock en el centro de origen y destino
            UPDATE Almacenes_Materiales
            SET Cantidad = Cantidad - v_Cantidad
            WHERE ID_Centro = (SELECT ID_Centro FROM Solicitudes WHERE ID_Solicitud = p_ID_Solicitud)
            AND ID_Material = v_ID_Material;

            UPDATE Almacenes_Materiales
            SET Cantidad = Cantidad + v_Cantidad
            WHERE ID_Centro = p_ID_Centro_Destino
            AND ID_Material = v_ID_Material;

            -- Obtener los IDs de los almacenes
            SET v_ID_Almacen_Material = (SELECT ID_Almacen_Material FROM Almacenes_Materiales WHERE ID_Centro = (SELECT ID_Centro FROM Solicitudes WHERE ID_Solicitud = p_ID_Solicitud) AND ID_Material = v_ID_Material);
            SET v_ID_Almacen_Material_Destino = (SELECT ID_Almacen_Material FROM Almacenes_Materiales WHERE ID_Centro = p_ID_Centro_Destino AND ID_Material = v_ID_Material);

            -- Registrar el detalle del movimiento
            INSERT INTO Detalle_Movimientos (ID_Movimiento, ID_Almacen_Origen, ID_Almacen_Destino, ID_Material, Cantidad)
            VALUES (v_ID_Movimiento, v_ID_Almacen_Material, v_ID_Almacen_Material_Destino, v_ID_Material, v_Cantidad);

        ELSE
            -- Procesar máquinas
            -- Actualizar stock en el centro de origen y destino
            DELETE FROM Almacenes_Maquinas
            WHERE ID_Centro = (SELECT ID_Centro FROM Solicitudes WHERE ID_Solicitud = p_ID_Solicitud)
            AND ID_Maquina = v_ID_Maquina;

            INSERT INTO Almacenes_Maquinas (ID_Centro, ID_Maquina)
            VALUES (p_ID_Centro_Destino, v_ID_Maquina);

            -- Obtener los IDs de los almacenes
            SET v_ID_Almacen_Maquina = (SELECT ID_Almacen_Maquina FROM Almacenes_Maquinas WHERE ID_Centro = (SELECT ID_Centro FROM Solicitudes WHERE ID_Solicitud = p_ID_Solicitud) AND ID_Maquina = v_ID_Maquina);
            SET v_ID_Almacen_Maquina_Destino = (SELECT ID_Almacen_Maquina FROM Almacenes_Maquinas WHERE ID_Centro = p_ID_Centro_Destino AND ID_Maquina = v_ID_Maquina);

            -- Registrar el detalle del movimiento
            INSERT INTO Detalle_Movimientos (ID_Movimiento, ID_Almacen_Origen, ID_Almacen_Destino, ID_Maquina)
            VALUES (v_ID_Movimiento, v_ID_Almacen_Maquina, v_ID_Almacen_Maquina_Destino, v_ID_Maquina);
        END IF;

    END LOOP;

    CLOSE cursor2;

END //

DELIMITER ;



--  generar pedido de compras desde una solicitud aprobada
DELIMITER //

CREATE PROCEDURE GenerarPedidoCompras(
    IN ID_Solicitud INT,
    IN ID_Empleado_Compras INT
)
BEGIN
    DECLARE ID_Material INT;
    DECLARE Cantidad_Solicitada INT;
    DECLARE Cantidad_Disponible INT;
    DECLARE Cantidad_Faltante INT;
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

    -- Iterar sobre los detalles de la solicitud aprobada
    DECLARE cursor1 CURSOR FOR
        SELECT ID_Material, Cantidad
        FROM Detalle_Solicitudes
        WHERE ID_Solicitud = ID_Solicitud
          AND ID_Material IS NOT NULL;

    DECLARE CONTINUE HANDLER FOR NOT FOUND CLOSE cursor1;

    OPEN cursor1;

    read_loop: LOOP
        FETCH cursor1 INTO ID_Material, Cantidad_Solicitada;

        IF NOT (ID_Material IS NOT NULL) THEN
            LEAVE read_loop;
        END IF;

        -- Obtener la cantidad disponible del material en todos los centros
        SET Cantidad_Disponible = (SELECT SUM(Cantidad) FROM Almacenes_Materiales WHERE ID_Material = ID_Material);

        -- Calcular la cantidad faltante
        SET Cantidad_Faltante = Cantidad_Solicitada - IFNULL(Cantidad_Disponible, 0);

        IF Cantidad_Faltante > 0 THEN
            -- Insertar el detalle del pedido de compras para los materiales faltantes
            INSERT INTO Detalle_Pedidos_Compras (ID_Pedido, ID_Material, Cantidad_Pendiente)
            VALUES (ID_Pedido, ID_Material, Cantidad_Faltante);
        END IF;

    END LOOP;

    CLOSE cursor1;

END;
//

DELIMITER ;

