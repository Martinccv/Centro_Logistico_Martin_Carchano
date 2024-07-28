USE CentroLogistico;

-- Devuelve el estado de una máquina específica
DROP FUNCTION IF EXISTS fn_ObtenerEstadoMaquina;
DELIMITER //
CREATE FUNCTION fn_ObtenerEstadoMaquina (@ID_Maquina INT)
RETURNS VARCHAR(50)
AS
BEGIN
    DECLARE @Estado VARCHAR(50);
    SELECT @Estado = Estado FROM Maquinas WHERE ID_Maquina = @ID_Maquina;
    RETURN @Estado;
END; //
DELIMITER ;

-- verificar cantidad de materiales en todos los depositos
CREATE FUNCTION TotalMateriales(ID_Material INT) 
RETURNS INT
BEGIN
    DECLARE total INT;
    SELECT SUM(Cantidad) INTO total FROM Almacenes_Materiales WHERE ID_Material = ID_Material;
    RETURN total;
END;

-- Calcula el total de materiales asignados a una Centro en especifico
DROP FUNCTION IF EXISTS fn_CalcularTotalMaterialesCentro;
DELIMITER //
CREATE FUNCTION fn_CalcularTotalMaterialesObra (@ID_Obra INT)
RETURNS INT
AS
BEGIN
    DECLARE @TotalMateriales INT;
    SELECT @TotalMateriales = SUM(Cantidad)
    FROM Centros
    WHERE ID_Centro = @ID_Centro;
    RETURN @TotalMateriales;
END; //
DELIMITER ;
