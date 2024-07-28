USE CentroLogistico;

-- Validar los estados de solicitud
CREATE TRIGGER validar_estado_solicitud
BEFORE INSERT ON Autorizaciones
FOR EACH ROW
BEGIN
    DECLARE estado_actual ENUM('Pendiente', 'Parcial', 'Aprobada', 'Rechazada');
    
    SELECT Estado INTO estado_actual FROM Solicitudes WHERE ID_Solicitud = NEW.ID_Solicitud;
    
    IF estado_actual != 'Pendiente' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La solicitud no está en estado Pendiente.';
    END IF;
END;
//
DELIMITER ;

-- 
DELIMITER //

CREATE TRIGGER actualizar_stock_materiales
AFTER INSERT ON Detalle_Movimientos
FOR EACH ROW
BEGIN
    DECLARE cantidad_disponible INT;
    
    -- Actualizar stock en el centro de origen
    IF NEW.ID_Almacen_Origen IS NOT NULL THEN
        SET cantidad_disponible = (SELECT Cantidad FROM Almacenes_Materiales WHERE ID_Almacen_Material = NEW.ID_Almacen_Origen);
        UPDATE Almacenes_Materiales
        SET Cantidad = cantidad_disponible - NEW.Cantidad
        WHERE ID_Almacen_Material = NEW.ID_Almacen_Origen;
    END IF;

    -- Actualizar stock en el centro de destino
    IF NEW.ID_Almacen_Destino IS NOT NULL THEN
        SET cantidad_disponible = (SELECT Cantidad FROM Almacenes_Materiales WHERE ID_Almacen_Material = NEW.ID_Almacen_Destino);
        UPDATE Almacenes_Materiales
        SET Cantidad = cantidad_disponible + NEW.Cantidad
        WHERE ID_Almacen_Material = NEW.ID_Almacen_Destino;
    END IF;
END;

//

DELIMITER ;

-- 
