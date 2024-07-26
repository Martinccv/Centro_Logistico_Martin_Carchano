USE CentroLogistico;

SET GLOBAL local_infile = true;

-- Proveedores
LOAD DATA INFILE '/data_csv/Proveedores.csv'
INTO TABLE Proveedores
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(Nombre, Direccion, Telefono, Rubro);

-- Materiales
LOAD DATA INFILE '/data_csv/Materiales.csv'
INTO TABLE Materiales
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(Nombre, Descripcion, Unidad, ID_Proveedor);

-- Maquinas
LOAD DATA INFILE '/data_csv/Maquinas.csv'
INTO TABLE Maquinas
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(Nombre, Descripcion, Estado, ID_Proveedor);

-- Clientes
LOAD DATA INFILE '/data_csv/Clientes.csv'
INTO TABLE Clientes
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(Nombre, Dirección, Telefono);

-- Empleado_obra
LOAD DATA INFILE '/data_csv/Empleados_Obra.csv'
INTO TABLE Empleados_Obra
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(Nombre, Cargo, Telefono, ID_Obra);

-- Empleado_deposito
LOAD DATA INFILE '/data_csv/Empleados_Depositos.csv'
INTO TABLE Empleados_Depositos
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(Nombre, Cargo, Telefono, ID_Deposito);

-- Emplado_compras
LOAD DATA INFILE '/data_csv/Empleados_Compras.csv'
INTO TABLE Empleados_Compras
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(Nombre, Cargo, Telefono);

-- Obras
LOAD DATA INFILE '/data_csv/Obras.csv'
INTO TABLE Obras
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(Nombre, Direccion, Estado, ID_Material, ID_Maquina, Cantidad);

-- Depositos
LOAD DATA INFILE '/data_csv/Depositos.csv'
INTO TABLE Depositos
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(ID_Material, ID_Maquina, Cantidad);

-- Socios_gerentes 
LOAD DATA INFILE '/data_csv/Socios_Gerentes.csv'
INTO TABLE Socios_Gerentes
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(Nombre, Telefono);

-- Solicitudes
LOAD DATA INFILE '/data_csv/Solicitudes.csv'
INTO TABLE Solicitudes
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(Fecha, Tipo, ID_Cliente, ID_Empleado_Obra, ID_Empleado_Deposito, Estado, ID_Material, ID_Maquina, Cantidad, ID_Proveedor, ID_Obra, ID_Deposito);

-- Autorizaciones
LOAD DATA INFILE '/data_csv/Autorizaciones.csv'
INTO TABLE Autorizaciones
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(ID_Solicitud, ID_Socio_Gerente, Estado, Fecha);

-- Movimientos
LOAD DATA INFILE '/data_csv/Movimientos.csv'
INTO TABLE Movimientos
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(Fecha, Tipo, ID_Deposito, ID_Obra_Origen, ID_Obra_Destino, ID_Material, ID_Maquina, Cantidad, ID_Empleado_Obra, ID_Empleado_Deposito, ID_Autorizacion);

-- Pedido_compras
LOAD DATA INFILE '/data_csv/Pedidos_Compras.csv'
INTO TABLE Pedidos_Compras
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(ID_Solicitud, ID_Material, Cantidad_Pendiente, Fecha, ID_Empleado_Compras);
