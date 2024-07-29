USE CentroLogistico;

USE CentroLogistico;

-- Devuelve el estado de una máquina específica
DROP FUNCTION IF EXISTS fn_ObtenerEstadoMaquina;

DELIMITER //

CREATE FUNCTION fn_ObtenerEstadoMaquina (ID_Maquina INT)
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


-- Verificar cantidad de materiales por centro
DELIMITER //

CREATE FUNCTION ObtenerCantidadMaterialPorCentro(
    p_ID_Material INT
) RETURNS TEXT
READS SQL DATA
NOT DETERMINISTIC
BEGIN
    DECLARE done INT DEFAULT 0;
    DECLARE v_ID_Centro INT;
    DECLARE v_Nombre_Centro VARCHAR(255);
    DECLARE v_Cantidad INT;
    DECLARE resultado TEXT DEFAULT '';

    -- Declarar el cursor para iterar sobre los centros y sus cantidades
    DECLARE cursor1 CURSOR FOR
        SELECT c.ID_Centro, c.Nombre, IFNULL(am.Cantidad, 0)
        FROM Centros c
        LEFT JOIN Almacenes_Materiales am ON c.ID_Centro = am.ID_Centro AND am.ID_Material = p_ID_Material;

    -- Handler para cuando no haya más filas que procesar
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    OPEN cursor1;

    read_loop: LOOP
        FETCH cursor1 INTO v_ID_Centro, v_Nombre_Centro, v_Cantidad;
        IF done THEN
            LEAVE read_loop;
        END IF;

        -- Concatenar los resultados en una cadena de texto
        SET resultado = CONCAT(resultado, 'Centro ID: ', v_ID_Centro, ' - ', v_Nombre_Centro, ' - Cantidad: ', v_Cantidad, '\n');
    END LOOP;

    CLOSE cursor1;

    RETURN resultado;
END //

DELIMITER ;



-- Calcula el total de materiales asignados a una Centro en especifico
DROP FUNCTION IF EXISTS ObtenerCantidadMaterialCentro;
DELIMITER //

CREATE FUNCTION ObtenerCantidadMaterialCentro(
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
END;

//

DELIMITER ;
