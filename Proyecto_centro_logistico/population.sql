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

-- Socios_gerentes 
LOAD DATA LOCAL INFILE './Proyecto_centro_logistico//data_csv/Socios_Gerentes.csv'
INTO TABLE Socios_Gerentes
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(Nombre, Telefono);


-- Centros
LOAD DATA LOCAL INFILE './Proyecto_centro_logistico//data_csv/Centros.csv'
INTO TABLE Centros
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(Nombre,Direccion,Tipo);

-- Empleados
LOAD DATA LOCAL INFILE './Proyecto_centro_logistico//data_csv/Empleados.csv'
INTO TABLE Empleados
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(Nombre,Cargo,Telefono,ID_Centro,Tipo);

-- Almacenes_Materiales
 LOAD DATA LOCAL INFILE './Proyecto_centro_logistico//data_csv/Almacenes_Materiales.csv'
 INTO TABLE Almacenes_Materiales
 FIELDS TERMINATED BY ',' ENCLOSED BY '"'
 LINES TERMINATED BY '\n'
 IGNORE 1 LINES
 ( ID_Centro,ID_Material,Cantidad);

 -- Almacenes_Maquinas
 LOAD DATA LOCAL INFILE './Proyecto_centro_logistico//data_csv/Almacenes_Maquinas.csv'
 INTO TABLE Almacenes_Maquinas
 FIELDS TERMINATED BY ',' ENCLOSED BY '"'
 LINES TERMINATED BY '\n'
 IGNORE 1 LINES
 ( ID_Centro,ID_Maquina);


-- Solicitudes
 LOAD DATA LOCAL INFILE './Proyecto_centro_logistico//data_csv/Solicitudes.csv'
 INTO TABLE Solicitudes
 FIELDS TERMINATED BY ',' ENCLOSED BY '"'
 LINES TERMINATED BY '\n'
 IGNORE 1 LINES
 (Fecha,Tipo,ID_Cliente,ID_Empleado,Estado,ID_Proveedor,ID_Centro);

-- Detalle_Solicitudes
 LOAD DATA LOCAL INFILE './Proyecto_centro_logistico//data_csv/Detalle_Solicitudes.csv'
 INTO TABLE Detalle_Solicitudes
 FIELDS TERMINATED BY ',' ENCLOSED BY '"'
 LINES TERMINATED BY '\n'
 IGNORE 1 LINES
 (ID_Solicitud,ID_Material,ID_Maquina,Cantidad);
