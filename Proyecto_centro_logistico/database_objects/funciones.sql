USE CentroLogistico;

-- Devuelve el estado de una máquina específica
CREATE FUNCTION fn_ObtenerEstadoMaquina (@ID_Maquina INT)
RETURNS VARCHAR(50)
AS
BEGIN
    DECLARE @Estado VARCHAR(50);
    SELECT @Estado = Estado FROM Maquinas WHERE ID_Maquina = @ID_Maquina;
    RETURN @Estado;
END;

-- Calcula el total de materiales asignados a una obra específica
CREATE FUNCTION fn_CalcularTotalMaterialesObra (@ID_Obra INT)
RETURNS INT
AS
BEGIN
    DECLARE @TotalMateriales INT;
    SELECT @TotalMateriales = SUM(Cantidad)
    FROM Obras
    WHERE ID_Obra = @ID_Obra;
    RETURN @TotalMateriales;
END;
