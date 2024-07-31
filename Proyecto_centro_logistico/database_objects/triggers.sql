USE CentroLogistico;

-- Validar los estados de solicitud
DROP TRIGGER IF EXISTS Trigger_ValidarEstadoSolicitud;
DELIMITER //
CREATE TRIGGER Trigger_ValidarEstadoSolicitud
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

-- Trigger para actualizar el estado de una solicitud a "Aprobada" cuando se apruebe la autorización
DROP TRIGGER IF EXISTS Trigger_ActualizarEstadoSolicitudAprobada;
DELIMITER //

CREATE TRIGGER Trigger_ActualizarEstadoSolicitudAprobada
AFTER INSERT ON Autorizaciones
FOR EACH ROW
BEGIN
    IF NEW.Estado = 'Aprobada' THEN
        UPDATE Solicitudes
        SET Estado = 'Aprobada'
        WHERE ID_Solicitud = NEW.ID_Solicitud;
    END IF;
END //
DELIMITER ;

-- Verifica el almacen de maquinas para limitar los movimientos
DROP TRIGGER IF EXISTS Trigger_VerificarMovimientoMaquinas;
DELIMITER //

CREATE TRIGGER Trigger_VerificarMovimientoMaquinas
BEFORE INSERT ON Almacenes_Maquinas
FOR EACH ROW
BEGIN
    DECLARE v_StockActual INT;

    -- Obtener el stock actual de la máquina en el centro
    SELECT IFNULL(SUM(Cantidad), 0) INTO v_StockActual
    FROM Almacenes_Maquinas
    WHERE ID_Centro = NEW.ID_Centro AND ID_Maquina = NEW.ID_Maquina;

    -- Verificar si se está intentando realizar una salida o transferencia con cantidad negativa
    IF NEW.Cantidad < 0 THEN
        -- Verificar si hay stock suficiente para permitir la salida o transferencia
        IF v_StockActual + NEW.Cantidad < 0 THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se puede realizar la salida o transferencia: la cantidad es insuficiente.';
        END IF;
    END IF;

    -- Verificar si se está intentando ingresar una máquina cuando ya existe una en el centro
    IF NEW.Cantidad > 0 THEN
        IF v_StockActual >= 1 THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se puede ingresar la máquina: ya existe en un centro.';
        END IF;
    END IF;
END //
DELIMITER ;

-- Verifica el stock de maquinas para limitar los movimientos
DROP TRIGGER IF EXISTS Trigger_VerificarIngresoMaquinas;
DELIMITER //

CREATE TRIGGER Trigger_VerificarIngresoMaquinas
BEFORE INSERT ON Almacenes_Maquinas
FOR EACH ROW
BEGIN
    DECLARE v_StockTotal INT;

    -- Verificar el stock total de la máquina en todos los centros
    SELECT IFNULL(SUM(Cantidad), 0) INTO v_StockTotal
    FROM Almacenes_Maquinas
    WHERE ID_Maquina = NEW.ID_Maquina;

    -- No permitir el ingreso si la máquina ya existe en algún centro
    IF v_StockTotal >= 1 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se puede ingresar la máquina: ya existe en otro centro.';
    END IF;
END //
DELIMITER ;

--  Verificar si la maquina existe en los centros para transferir o dar de baja
DROP TRIGGER IF EXISTS Trigger_VerificarSalidaTransferenciaMaquinas;
DELIMITER //

CREATE TRIGGER Trigger_VerificarSalidaTransferenciaMaquinas
BEFORE INSERT ON Detalle_Movimientos
FOR EACH ROW
BEGIN
    DECLARE v_StockActual INT;

    -- Obtener el stock actual de la máquina en el centro de origen
    SELECT IFNULL(SUM(Cantidad), 0) INTO v_StockActual
    FROM Almacenes_Maquinas
    WHERE ID_Centro = NEW.ID_Almacen_Origen AND ID_Maquina = NEW.ID_Maquina;

    -- Verificar si se está intentando realizar una salida o transferencia con cantidad negativa
    IF NEW.Cantidad < 0 THEN
        IF v_StockActual + NEW.Cantidad < 0 THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se puede realizar la salida o transferencia: la cantidad es insuficiente.';
        END IF;
    END IF;
END //

DELIMITER ;

-- Verifica el almacen de materiales para limitar los movimientos
DROP TRIGGER IF EXISTS Trigger_VerificarMovimientoMateriales;
DELIMITER //

CREATE TRIGGER Trigger_VerificarMovimientoMateriales
BEFORE INSERT ON Almacenes_Materiales
FOR EACH ROW
BEGIN
    DECLARE v_StockActual INT;

    -- Obtener el stock actual del material en el centro
    SELECT IFNULL(SUM(Cantidad), 0) INTO v_StockActual
    FROM Almacenes_Materiales
    WHERE ID_Centro = NEW.ID_Centro AND ID_Material = NEW.ID_Material;

    -- Verificar si se está intentando realizar una salida o transferencia con cantidad negativa
    IF NEW.Cantidad < 0 THEN
        -- Verificar si hay suficiente stock para permitir la salida o transferencia
        IF v_StockActual + NEW.Cantidad < 0 THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se puede realizar la salida o transferencia: stock insuficiente o inexistente.';
        END IF;
    END IF;
END //
DELIMITER ;

-- Verifica el stock de materiales para limitar los movimientos
DROP TRIGGER IF EXISTS Trigger_VerificarDetalleMovimientoMateriales;
DELIMITER //

CREATE TRIGGER Trigger_VerificarDetalleMovimientoMateriales
BEFORE INSERT ON Detalle_Movimientos
FOR EACH ROW
BEGIN
    DECLARE v_StockActual INT;

    -- Verificar el stock actual del material en el centro de origen
    SELECT IFNULL(SUM(Cantidad), 0) INTO v_StockActual
    FROM Almacenes_Materiales
    WHERE ID_Centro = NEW.ID_Almacen_Origen AND ID_Material = NEW.ID_Material;

    -- Verificar si se está intentando realizar una salida o transferencia con cantidad negativa
    IF NEW.Cantidad < 0 THEN
        IF v_StockActual + NEW.Cantidad < 0 THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se puede realizar la salida o transferencia: stock insuficiente o inexistente.';
        END IF;
    END IF;
END //
DELIMITER ;
