USE CentroLogistico;

-- Audita los movimientos realizados en la tabla Movimientos.
CREATE TRIGGER trg_AuditarMovimientos
ON Movimientos
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    -- Código para auditar cambios en la tabla Movimientos
    -- Ejemplo: Insertar datos en una tabla de auditoría
END;

-- Actualiza el stock de materiales en los depósitos cuando se aprueba una solicitud.
CREATE TRIGGER trg_ActualizarStockMateriales
ON Solicitudes
AFTER UPDATE
AS
BEGIN
    IF UPDATE(Estado)
    BEGIN
        DECLARE @ID_Solicitud INT, @ID_Material INT, @Cantidad INT, @ID_Deposito INT;
        SELECT @ID_Solicitud = ID_Solicitud, @ID_Material = ID_Material, @Cantidad = Cantidad, @ID_Deposito = ID_Deposito
        FROM INSERTED;
        
        IF (SELECT Estado FROM INSERTED) = 'Aprobada'
        BEGIN
            UPDATE Depositos
            SET Cantidad = Cantidad - @Cantidad
            WHERE ID_Deposito = @ID_Deposito AND ID_Material = @ID_Material;
        END
    END
END;
