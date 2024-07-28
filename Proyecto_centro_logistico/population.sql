USE CentroLogistico;

SET GLOBAL local_infile = true;

-- Proveedores
LOAD DATA LOCAL INFILE './Proyecto_centro_logistico/data_csv/Proveedores.csv'
INTO TABLE Proveedores
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(Nombre, Direccion, Telefono, Rubro);

-- Materiales
LOAD DATA LOCAL INFILE './Proyecto_centro_logistico//data_csv/Materiales.csv'
INTO TABLE Materiales
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(Nombre, Descripcion, Unidad, ID_Proveedor);

-- Maquinas
LOAD DATA LOCAL INFILE './Proyecto_centro_logistico//data_csv/Maquinas.csv'
INTO TABLE Maquinas
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(Nombre, Descripcion, Estado, ID_Proveedor);

-- Clientes
LOAD DATA LOCAL INFILE './Proyecto_centro_logistico//data_csv/Clientes.csv'
INTO TABLE Clientes
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(Nombre, Direccion, Telefono);

-- Empleados
LOAD DATA LOCAL INFILE './Proyecto_centro_logistico//data_csv/Empleados.csv'
INTO TABLE Empleados
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(Nombre,Cargo,Telefono,ID_Centro,Tipo);

-- Centros
LOAD DATA LOCAL INFILE './Proyecto_centro_logistico//data_csv/Centros.csv'
INTO TABLE Centros
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(Nombre,Direccion,Tipo);

-- Socios_gerentes 
LOAD DATA LOCAL INFILE './Proyecto_centro_logistico//data_csv/Socios_Gerentes.csv'
INTO TABLE Socios_Gerentes
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(Nombre, Telefono);

-- Solicitudes
-- LOAD DATA LOCAL INFILE './Proyecto_centro_logistico//data_csv/Solicitudes.csv'
-- INTO TABLE Solicitudes
-- FIELDS TERMINATED BY ',' ENCLOSED BY '"'
-- LINES TERMINATED BY '\n'
-- IGNORE 1 LINES
-- (Fecha, Tipo, ID_Cliente, ID_Empleado_Obra, ID_Empleado_Deposito, Estado, ID_Material, ID_Maquina, Cantidad, ID_Proveedor, ID_Obra, ID_Deposito);

-- Autorizaciones
-- LOAD DATA LOCAL INFILE './Proyecto_centro_logistico//data_csv/Autorizaciones.csv'
-- INTO TABLE Autorizaciones
-- FIELDS TERMINATED BY ',' ENCLOSED BY '"'
-- LINES TERMINATED BY '\n'
-- IGNORE 1 LINES
-- ( ID_Solicitud, ID_Socio_Gerente, Estado, Fecha);

-- Movimientos
-- LOAD DATA LOCAL INFILE './Proyecto_centro_logistico//data_csv/Movimientos.csv'
-- INTO TABLE Movimientos
-- FIELDS TERMINATED BY ',' ENCLOSED BY '"'
-- LINES TERMINATED BY '\n'
-- IGNORE 1 LINES
-- (Fecha, Tipo, ID_Deposito, ID_Obra_Origen, ID_Obra_Destino, ID_Material, ID_Maquina, Cantidad, ID_Empleado_Obra, ID_Empleado_Deposito, ID_Autorizacion);

-- Pedido_compras
-- LOAD DATA LOCAL INFILE './Proyecto_centro_logistico//data_csv/Pedidos_Compras.csv'
-- INTO TABLE Pedidos_Compras
-- FIELDS TERMINATED BY ',' ENCLOSED BY '"'
-- LINES TERMINATED BY '\n'
-- IGNORE 1 LINES
-- (ID_Solicitud, ID_Material, Cantidad_Pendiente, Fecha, ID_Empleado_Compras);
