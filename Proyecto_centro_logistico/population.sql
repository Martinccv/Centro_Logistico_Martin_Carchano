USE CentroLogistico;

SET GLOBAL local_infile = true;

LOAD DATA INFILE '/path/to/Proveedores.csv'
INTO TABLE Proveedores
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(ID_Proveedor, Nombre, Direccion, Telefono, Rubro);
