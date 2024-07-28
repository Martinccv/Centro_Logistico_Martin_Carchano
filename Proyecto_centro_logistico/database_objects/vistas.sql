USE CentroLogistico;

-- Lista de solicitudes pendientes de aprobación.
DROP VIEW IF EXISTS vw_SolicitudesPendientes;

CREATE VIEW vw_SolicitudesPendientes AS
SELECT s.ID_Solicitud, c.Nombre AS Cliente, e.Nombre AS Empleado, s.Tipo, s.Estado
FROM Solicitudes s
LEFT JOIN Clientes c ON s.ID_Cliente = c.ID_Cliente
LEFT JOIN Empleados e ON s.ID_Empleado = e.ID_Empleado
WHERE s.Estado = 'Pendiente';

-- Muestra los materiales disponibles en un Centro en especifico
DROP VIEW IF EXISTS Vista_Materiales_Centro;

CREATE VIEW Vista_Materiales_Centro AS
SELECT 
    C.Nombre AS Nombre_Centro,
    M.Nombre AS Nombre_Material,
    AM.Cantidad
FROM 
    Almacenes_Materiales AM
JOIN 
    Centros C ON AM.ID_Centro = C.ID_Centro
JOIN 
    Materiales M ON AM.ID_Material = M.ID_Material
WHERE
    C.ID_Centro = 1; -- Sustituir @ID_Centro por el identificador del centro deseado

-- Muestra las maquinas disponibles en un Centro en especifico
DROP VIEW IF EXISTS Vista_Maquinas_Centro;

CREATE VIEW Vista_Maquinas_Centro AS
SELECT 
    C.Nombre AS Nombre_Centro,
    Maq.Nombre AS Nombre_Maquina,
    Maq.Descripcion,
    Maq.Estado
FROM 
    Almacenes_Maquinas AMQ
JOIN 
    Centros C ON AMQ.ID_Centro = C.ID_Centro
JOIN 
    Maquinas Maq ON AMQ.ID_Maquina = Maq.ID_Maquina
WHERE
    C.ID_Centro = 1; -- Sustituir @ID_Centro por el identificador del centro deseado

-- Vistas para Consultar Información de Movimientos
DROP VIEW IF EXISTS Vista_Movimientos;
CREATE VIEW Vista_Movimientos AS
SELECT 
    M.ID_Movimiento,
    M.Fecha,
    M.Tipo,
    C.Nombre AS Nombre_Centro,
    E.Nombre AS Nombre_Empleado,
    DS.ID_Material,
    DS.ID_Maquina,
    DS.Cantidad,
    CASE
        WHEN DS.ID_Material IS NOT NULL THEN Mat.Nombre
        ELSE Maq.Nombre
    END AS Nombre_Item
FROM 
    Movimientos M
JOIN 
    Empleados E ON M.ID_Empleado = E.ID_Empleado
JOIN 
    Centros C ON E.ID_Centro = C.ID_Centro
LEFT JOIN 
    Detalle_Movimientos DS ON M.ID_Movimiento = DS.ID_Movimiento
LEFT JOIN 
    Materiales Mat ON DS.ID_Material = Mat.ID_Material
LEFT JOIN 
    Maquinas Maq ON DS.ID_Maquina = Maq.ID_Maquina;

-- Vista para consultar informacion sobre Solicitudes
DROP VIEW IF EXISTS Vista_Solicitudes;
CREATE VIEW Vista_Solicitudes AS
SELECT 
    S.ID_Solicitud,
    S.Fecha,
    S.Tipo,
    C.Nombre AS Nombre_Cliente,
    E.Nombre AS Nombre_Empleado,
    CT.Nombre AS Nombre_Centro,
    DS.ID_Material,
    DS.ID_Maquina,
    DS.Cantidad,
    CASE
        WHEN DS.ID_Material IS NOT NULL THEN Mat.Nombre
        ELSE Maq.Nombre
    END AS Nombre_Item,
    S.Estado
FROM 
    Solicitudes S
LEFT JOIN 
    Clientes C ON S.ID_Cliente = C.ID_Cliente
LEFT JOIN 
    Empleados E ON S.ID_Empleado = E.ID_Empleado
LEFT JOIN 
    Centros CT ON S.ID_Centro = CT.ID_Centro
LEFT JOIN 
    Detalle_Solicitudes DS ON S.ID_Solicitud = DS.ID_Solicitud
LEFT JOIN 
    Materiales Mat ON DS.ID_Material = Mat.ID_Material
LEFT JOIN 
    Maquinas Maq ON DS.ID_Maquina = Maq.ID_Maquina;
