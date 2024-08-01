USE CentroLogistico;

-- Devuelve el estado de una máquina específica
DROP FUNCTION IF EXISTS Funcion_ObtenerEstadoMaquina;
DELIMITER //

CREATE FUNCTION Funcion_ObtenerEstadoMaquina (ID_Maquina INT)
RETURNS VARCHAR(50)
DETERMINISTIC
BEGIN
    DECLARE Estado VARCHAR(50);
    SELECT m.Estado INTO Estado
    FROM Maquinas m
    WHERE m.ID_Maquina = ID_Maquina;
    RETURN Estado;
END //
DELIMITER ;

-- Obtiene la cantidad de material que se elige por cada centro
DROP FUNCTION IF EXISTS Funcion_ObtenerCantidadMaterialPorCentro;
DELIMITER //

CREATE FUNCTION Funcion_ObtenerCantidadMaterialPorCentro(
    p_ID_Material INT
) RETURNS TEXT
READS SQL DATA
BEGIN
    DECLARE resultado TEXT;
    DECLARE max_len INT DEFAULT 5000; -- Ajusta este valor según sea necesario

    -- Establecer un límite mayor para group_concat_max_len
    SET SESSION group_concat_max_len = max_len;

    -- Usar GROUP_CONCAT para construir la cadena de resultados
    SELECT GROUP_CONCAT(CONCAT('Centro ID: ', c.ID_Centro, ' - ', c.Nombre, ' - Cantidad: ', IFNULL(am.Cantidad, 0)) SEPARATOR '\n')
    INTO resultado
    FROM Centros c
    LEFT JOIN Almacenes_Materiales am ON c.ID_Centro = am.ID_Centro AND am.ID_Material = p_ID_Material;

    RETURN resultado;
END //
DELIMITER ;


-- Calcula el total de materiales asignados a una Centro en especifico
DROP FUNCTION IF EXISTS Funcion_ObtenerCantidadMaterialCentro;
DELIMITER //

CREATE FUNCTION Funcion_ObtenerCantidadMaterialCentro(
    centro_id INT,
    material_id INT
) RETURNS INT
READS SQL DATA
NOT DETERMINISTIC
BEGIN
    DECLARE cantidad INT;
    
    SELECT Cantidad INTO cantidad
    FROM Almacenes_Materiales
    WHERE ID_Centro = centro_id AND ID_Material = material_id;
    
    IF cantidad IS NULL THEN
        RETURN 0; -- Si no se encuentra el material en el centro, retornar 0
    ELSE
        RETURN cantidad;
    END IF;
END; //
DELIMITER ;
