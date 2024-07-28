USE CentroLogistico;

-- Aprueba una solicitud de materiales o máquinas
DROP PROCEDURE IF EXISTS sp_AprobarSolicitud;

DELIMITER //
CREATE PROCEDURE sp_AprobarSolicitud
    @ID_Solicitud INT,
    @ID_Socio_Gerente INT
AS
BEGIN
    UPDATE Autorizaciones
    SET Estado = 'Aprobada', Fecha = GETDATE()
    WHERE ID_Solicitud = @ID_Solicitud AND ID_Socio_Gerente = @ID_Socio_Gerente;

    UPDATE Solicitudes
    SET Estado = 'Aprobada'
    WHERE ID_Solicitud = @ID_Solicitud;
END; //
DELIMITER ;

-- Registra una nueva solicitud.
DELIMITER //

CREATE PROCEDURE CrearSolicitud(
    IN Tipo ENUM('Material', 'Maquina'),
    IN ID_Cliente INT,
    IN ID_Empleado INT,
    IN ID_Centro INT,
    IN DetallesSolicitud JSON
)
BEGIN
    DECLARE ID_Solicitud INT;

    -- Crear la solicitud con estado 'Pendiente'
    INSERT INTO Solicitudes (Fecha, Tipo, ID_Cliente, ID_Empleado, ID_Centro, Estado)
    VALUES (CURDATE(), Tipo, ID_Cliente, ID_Empleado, ID_Centro, 'Pendiente');

    -- Obtener el ID de la solicitud recién creada
    SET ID_Solicitud = LAST_INSERT_ID();

    -- Iterar sobre los detalles de la solicitud (Materiales o Maquinas)
    DECLARE ID_Item INT;
    DECLARE Cantidad INT;

    DECLARE cursor1 CURSOR FOR
        SELECT value->>"$.ID_Item", value->>"$.Cantidad"
        FROM JSON_TABLE(DetallesSolicitud, "$[*]"
            COLUMNS (
                ID_Item INT PATH "$.ID_Item",
                Cantidad INT PATH "$.Cantidad"
            )
        ) AS items;

    DECLARE CONTINUE HANDLER FOR NOT FOUND CLOSE cursor1;

    OPEN cursor1;

    read_loop: LOOP
        FETCH cursor1 INTO ID_Item, Cantidad;

        IF NOT (ID_Item IS NOT NULL AND Cantidad > 0) THEN
            LEAVE read_loop;
        END IF;

        -- Insertar en Detalle_Solicitudes según el tipo (Material o Maquina)
        IF Tipo = 'Material' THEN
            INSERT INTO Detalle_Solicitudes (ID_Solicitud, ID_Material, Cantidad)
            VALUES (ID_Solicitud, ID_Item, Cantidad);
        ELSE
            INSERT INTO Detalle_Solicitudes (ID_Solicitud, ID_Maquina)
            VALUES (ID_Solicitud, ID_Item);
        END IF;

    END LOOP;

    CLOSE cursor1;

END;
//

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

DELIMITER //

CREATE PROCEDURE RealizarMovimiento(
    IN ID_Solicitud INT,
    IN ID_Empleado INT,
    IN ID_Centro_Destino INT
)
BEGIN
    DECLARE Tipo ENUM('Material', 'Maquina');
    DECLARE ID_Material INT;
    DECLARE ID_Maquina INT;
    DECLARE Cantidad INT;
    DECLARE ID_Almacen_Material INT;
    DECLARE ID_Almacen_Maquina INT;

    -- Verificar si la solicitud está aprobada
    IF (SELECT Estado FROM Solicitudes WHERE ID_Solicitud = ID_Solicitud) != 'Aprobada' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La solicitud no está aprobada';
    END IF;

    -- Registrar el movimiento en la tabla 'Movimientos'
    INSERT INTO Movimientos (Fecha, Tipo, ID_Empleado)
    VALUES (CURDATE(), 'Transferencia', ID_Empleado);

    -- Obtener el ID del movimiento recién creado
    SET @ID_Movimiento = LAST_INSERT_ID();

    -- Iterar sobre los detalles de la solicitud para realizar el movimiento
    DECLARE cursor2 CURSOR FOR
        SELECT Tipo, ID_Material, ID_Maquina, Cantidad
        FROM Detalle_Solicitudes
        WHERE ID_Solicitud = ID_Solicitud;

    DECLARE CONTINUE HANDLER FOR NOT FOUND CLOSE cursor2;

    OPEN cursor2;

    read_loop: LOOP
        FETCH cursor2 INTO Tipo, ID_Material, ID_Maquina, Cantidad;

        IF NOT (Tipo IS NOT NULL) THEN
            LEAVE read_loop;
        END IF;

        -- Procesar materiales
        IF Tipo = 'Material' THEN
            -- Actualizar stock en el centro de origen y destino
            UPDATE Almacenes_Materiales
            SET Cantidad = Cantidad - Cantidad
            WHERE ID_Centro = (SELECT ID_Centro FROM Solicitudes WHERE ID_Solicitud = ID_Solicitud)
            AND ID_Material = ID_Material;

            UPDATE Almacenes_Materiales
            SET Cantidad = Cantidad + Cantidad
            WHERE ID_Centro = ID_Centro_Destino
            AND ID_Material = ID_Material;

            -- Registrar el detalle del movimiento
            INSERT INTO Detalle_Movimientos (ID_Movimiento, ID_Almacen_Origen, ID_Almacen_Destino, ID_Material, Cantidad)
            VALUES (@ID_Movimiento, (SELECT ID_Almacen_Material FROM Almacenes_Materiales WHERE ID_Centro = (SELECT ID_Centro FROM Solicitudes WHERE ID_Solicitud = ID_Solicitud) AND ID_Material = ID_Material),
                    (SELECT ID_Almacen_Material FROM Almacenes_Materiales WHERE ID_Centro = ID_Centro_Destino AND ID_Material = ID_Material), ID_Material, Cantidad);
        ELSE
            -- Procesar máquinas
            -- Actualizar stock en el centro de origen y destino
            DELETE FROM Almacenes_Maquinas
            WHERE ID_Centro = (SELECT ID_Centro FROM Solicitudes WHERE ID_Solicitud = ID_Solicitud)
            AND ID_Maquina = ID_Maquina;

            INSERT INTO Almacenes_Maquinas (ID_Centro, ID_Maquina)
            VALUES (ID_Centro_Destino, ID_Maquina);

            -- Registrar el detalle del movimiento
            INSERT INTO Detalle_Movimientos (ID_Movimiento, ID_Almacen_Origen, ID_Almacen_Destino, ID_Maquina)
            VALUES (@ID_Movimiento, (SELECT ID_Almacen_Maquina FROM Almacenes_Maquinas WHERE ID_Centro = (SELECT ID_Centro FROM Solicitudes WHERE ID_Solicitud = ID_Solicitud) AND ID_Maquina = ID_Maquina),
                    (SELECT ID_Almacen_Maquina FROM Almacenes_Maquinas WHERE ID_Centro = ID_Centro_Destino AND ID_Maquina = ID_Maquina), ID_Maquina);
        END IF;

    END LOOP;

    CLOSE cursor2;

END;
//

DELIMITER ;
