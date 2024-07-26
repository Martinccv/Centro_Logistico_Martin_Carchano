USE CentroLogistico;

-- Lista de solicitudes pendientes de aprobación.
CREATE VIEW vw_SolicitudesPendientes AS
SELECT s.ID_Solicitud, c.Nombre AS Cliente, e.Nombre AS Empleado, s.Tipo, s.Estado
FROM Solicitudes s
LEFT JOIN Clientes c ON s.ID_Cliente = c.ID_Cliente
LEFT JOIN Empleados_Obra e ON s.ID_Empleado_Obra = e.ID_Empleado_Obra
WHERE s.Estado = 'Pendiente';

-- Muestra los materiales disponibles en cada depósito
CREATE VIEW vw_MaterialesDisponibles AS
SELECT d.ID_Deposito, m.Nombre AS Material, d.Cantidad
FROM Depositos d
JOIN Materiales m ON d.ID_Material = m.ID_Material
WHERE d.Cantidad > 0;
