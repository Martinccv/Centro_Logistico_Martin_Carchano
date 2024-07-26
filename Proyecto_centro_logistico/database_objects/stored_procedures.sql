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
-- Registra un nuevo movimiento de materiales o máquinas.
DROP PROCEDURE IF EXISTS sp_RegistrarMovimiento;

DELIMITER //
CREATE PROCEDURE sp_RegistrarMovimiento
    @Fecha DATE,
    @Tipo VARCHAR(20),
    @ID_Deposito INT,
    @ID_Obra_Origen INT = NULL,
    @ID_Obra_Destino INT = NULL,
    @ID_Material INT = NULL,
    @ID_Maquina INT = NULL,
    @Cantidad INT,
    @ID_Empleado_Obra INT = NULL,
    @ID_Empleado_Deposito INT = NULL,
    @ID_Autorizacion INT
AS
BEGIN
    INSERT INTO Movimientos (Fecha, Tipo, ID_Deposito, ID_Obra_Origen, ID_Obra_Destino, ID_Material, ID_Maquina, Cantidad, ID_Empleado_Obra, ID_Empleado_Deposito, ID_Autorizacion)
    VALUES (@Fecha, @Tipo, @ID_Deposito, @ID_Obra_Origen, @ID_Obra_Destino, @ID_Material, @ID_Maquina, @Cantidad, @ID_Empleado_Obra, @ID_Empleado_Deposito, @ID_Autorizacion);
END; //

DELIMITER ;