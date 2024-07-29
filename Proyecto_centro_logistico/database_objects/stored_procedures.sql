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
DROP PROCEDURE IF EXISTS CrearSolicitud;
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

USE CentroLogistico;

-- Procedimiento para registrar la salida de materiales y máquinas
DROP PROCEDURE IF EXISTS RegistrarSalida;

DELIMITER //

CREATE PROCEDURE RegistrarSalida(
    IN p_Tipo ENUM('Material', 'Maquina'),
    IN p_ID_Centro INT,
    IN p_ID_Item INT,
    IN p_Cantidad INT,
    IN p_ID_Empleado INT
)
BEGIN
    DECLARE v_ID_Movimiento INT;
    DECLARE v_ID_Almacen_Origen INT;

    -- Registrar el movimiento en la tabla 'Movimientos'
    INSERT INTO Movimientos (Fecha, Tipo, ID_Empleado)
    VALUES (CURDATE(), 'Salida', p_ID_Empleado);

    -- Obtener el ID del movimiento recién creado
    SET v_ID_Movimiento = LAST_INSERT_ID();

    -- Verificar el tipo de ítem y registrar la salida
    IF p_Tipo = 'Material' THEN
        -- Verificar si el material existe en el centro
        IF EXISTS (
            SELECT 1 FROM Almacenes_Materiales 
            WHERE ID_Centro = p_ID_Centro AND ID_Material = p_ID_Item
        ) THEN
            -- Obtener el ID del almacén
            SET v_ID_Almacen_Origen = (SELECT ID_Almacen_Material FROM Almacenes_Materiales 
                                       WHERE ID_Centro = p_ID_Centro AND ID_Material = p_ID_Item);
            
            -- Actualizar la cantidad existente
            UPDATE Almacenes_Materiales
            SET Cantidad = Cantidad - p_Cantidad
            WHERE ID_Centro = p_ID_Centro AND ID_Material = p_ID_Item;

            -- Eliminar el registro si la cantidad llega a cero o menos
            DELETE FROM Almacenes_Materiales
            WHERE ID_Centro = p_ID_Centro AND ID_Material = p_ID_Item AND Cantidad <= 0;

            -- Registrar el detalle del movimiento
            INSERT INTO Detalle_Movimientos (ID_Movimiento, ID_Almacen_Origen, Cantidad, ID_Material)
            VALUES (v_ID_Movimiento, v_ID_Almacen_Origen, p_Cantidad, p_ID_Item);

        ELSE
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El material no está registrado en el centro.';
        END IF;
    ELSE
        -- Procesar máquinas
        -- Verificar si la máquina existe en el centro
        IF EXISTS (
            SELECT 1 FROM Almacenes_Maquinas 
            WHERE ID_Centro = p_ID_Centro AND ID_Maquina = p_ID_Item
        ) THEN
            -- Obtener el ID del almacén
            SET v_ID_Almacen_Origen = (SELECT ID_Almacen_Maquina FROM Almacenes_Maquinas 
                                       WHERE ID_Centro = p_ID_Centro AND ID_Maquina = p_ID_Item);

            -- Eliminar la máquina del centro
            DELETE FROM Almacenes_Maquinas
            WHERE ID_Centro = p_ID_Centro AND ID_Maquina = p_ID_Item;

            -- Registrar el detalle del movimiento
            INSERT INTO Detalle_Movimientos (ID_Movimiento, ID_Almacen_Origen, ID_Maquina)
            VALUES (v_ID_Movimiento, v_ID_Almacen_Origen, p_ID_Item);

        ELSE
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La máquina no está registrada en el centro.';
        END IF;
    END IF;
END //

DELIMITER ;

-- Procedimiento para registrar el ingreso de materiales y máquinas
DROP PROCEDURE IF EXISTS RegistrarIngreso;

DELIMITER //

CREATE PROCEDURE RegistrarIngreso(
    IN p_Tipo ENUM('Material', 'Maquina'),
    IN p_ID_Centro INT,
    IN p_ID_Item INT,
    IN p_Cantidad INT,
    IN p_ID_Empleado INT
)
BEGIN
    DECLARE v_ID_Movimiento INT;
    DECLARE v_ID_Almacen_Origen INT;

    -- Registrar el movimiento en la tabla 'Movimientos'
    INSERT INTO Movimientos (Fecha, Tipo, ID_Empleado)
    VALUES (CURDATE(), 'Ingreso', p_ID_Empleado);

    -- Obtener el ID del movimiento recién creado
    SET v_ID_Movimiento = LAST_INSERT_ID();

    -- Verificar el tipo de ítem y registrar el ingreso
    IF p_Tipo = 'Material' THEN
        -- Verificar si el material ya existe en el centro
        IF EXISTS (
            SELECT 1 FROM Almacenes_Materiales 
            WHERE ID_Centro = p_ID_Centro AND ID_Material = p_ID_Item
        ) THEN
            -- Actualizar la cantidad existente
            UPDATE Almacenes_Materiales
            SET Cantidad = Cantidad + p_Cantidad
            WHERE ID_Centro = p_ID_Centro AND ID_Material = p_ID_Item;

            -- Obtener el ID del almacén
            SET v_ID_Almacen_Origen = (SELECT ID_Almacen_Material FROM Almacenes_Materiales 
                                       WHERE ID_Centro = p_ID_Centro AND ID_Material = p_ID_Item);

        ELSE
            -- Insertar el nuevo registro si el material no existe
            INSERT INTO Almacenes_Materiales (ID_Centro, ID_Material, Cantidad)
            VALUES (p_ID_Centro, p_ID_Item, p_Cantidad);

            -- Obtener el ID del almacén
            SET v_ID_Almacen_Origen = (SELECT ID_Almacen_Material FROM Almacenes_Materiales 
                                       WHERE ID_Centro = p_ID_Centro AND ID_Material = p_ID_Item);
        END IF;

        -- Registrar el detalle del movimiento
        INSERT INTO Detalle_Movimientos (ID_Movimiento, ID_Almacen_Origen, Cantidad, ID_Material)
        VALUES (v_ID_Movimiento, v_ID_Almacen_Origen, p_Cantidad, p_ID_Item);

    ELSE
        -- Procesar máquinas
        -- Verificar si la máquina ya existe en el centro
        IF EXISTS (
            SELECT 1 FROM Almacenes_Maquinas 
            WHERE ID_Centro = p_ID_Centro AND ID_Maquina = p_ID_Item
        ) THEN
            -- No es necesario actualizar la cantidad, ya que las máquinas no tienen cantidad
            -- Obtener el ID del almacén
            SET v_ID_Almacen_Origen = (SELECT ID_Almacen_Maquina FROM Almacenes_Maquinas 
                                       WHERE ID_Centro = p_ID_Centro AND ID_Maquina = p_ID_Item);

        ELSE
            -- Insertar el nuevo registro si la máquina no existe
            INSERT INTO Almacenes_Maquinas (ID_Centro, ID_Maquina)
            VALUES (p_ID_Centro, p_ID_Item);

            -- Obtener el ID del almacén
            SET v_ID_Almacen_Origen = (SELECT ID_Almacen_Maquina FROM Almacenes_Maquinas 
                                       WHERE ID_Centro = p_ID_Centro AND ID_Maquina = p_ID_Item);
        END IF;

        -- Registrar el detalle del movimiento
        INSERT INTO Detalle_Movimientos (ID_Movimiento, ID_Almacen_Origen, ID_Maquina)
        VALUES (v_ID_Movimiento, v_ID_Almacen_Origen, p_ID_Item);

    END IF;
END //

DELIMITER ;


-- realizar movimiento una vez tengo solicitud aprobada
USE CentroLogistico;

DROP PROCEDURE IF EXISTS RealizarMovimiento;

DELIMITER //

CREATE PROCEDURE RealizarMovimiento(
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
DROP PROCEDURE IF EXISTS GenerarPedidoCompras;
DELIMITER //

CREATE PROCEDURE GenerarPedidoCompras(
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

END;
//

DELIMITER ;

