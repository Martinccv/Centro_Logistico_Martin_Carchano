-- Eliminar base de dato con el mismo nombre si existe

DROP DATABASE IF EXISTS CentroLogistico ;

-- Creación de la base de datos

CREATE DATABASE CentroLogistico;
USE CentroLogistico;

-- Creación de tablas

CREATE TABLE Proveedores (
    ID_Proveedor INT AUTO_INCREMENT PRIMARY KEY,
    Nombre VARCHAR(255) NOT NULL,
    Direccion VARCHAR(255),
    Telefono VARCHAR(20)
);

CREATE TABLE Materiales (
    ID_Material INT AUTO_INCREMENT PRIMARY KEY,
    Nombre VARCHAR(255) NOT NULL,
    Descripcion TEXT,
    Cantidad INT DEFAULT 0,
    ID_Proveedor INT
);

CREATE TABLE Maquinas (
    ID_Maquina INT AUTO_INCREMENT PRIMARY KEY,
    Nombre VARCHAR(255) NOT NULL,
    Descripcion TEXT,
    Estado VARCHAR(50),
    ID_Proveedor INT
);

CREATE TABLE Clientes (
    ID_Cliente INT AUTO_INCREMENT PRIMARY KEY,
    Nombre VARCHAR(255) NOT NULL,
    Dirección VARCHAR(255),
    Telefono VARCHAR(20)
);

CREATE TABLE Empleados_Obra (
    ID_Empleado_Obra INT AUTO_INCREMENT PRIMARY KEY,
    Nombre VARCHAR(255) NOT NULL,
    Cargo VARCHAR(50),
    Telefono VARCHAR(20),
    ID_Obra INT
);

CREATE TABLE Empleados_Depositos (
    ID_Empleado_Deposito INT AUTO_INCREMENT PRIMARY KEY,
    Nombre VARCHAR(255) NOT NULL,
    Cargo VARCHAR(50),
    Telefono VARCHAR(20)
);

CREATE TABLE Empleados_Compras (
    ID_Empleado_Compras INT AUTO_INCREMENT PRIMARY KEY,
    Nombre VARCHAR(255) NOT NULL,
    Cargo VARCHAR(50),
    Telefono VARCHAR(20)
);

CREATE TABLE Obras (
    ID_Obra INT AUTO_INCREMENT PRIMARY KEY,
    Nombre VARCHAR(255) NOT NULL,
    Direccion VARCHAR(255),
    Estado VARCHAR(50),
    ID_Material INT,
    ID_Maquina INT,
    Cantidad INT DEFAULT 0
);

CREATE TABLE Deposito (
    ID_Deposito INT AUTO_INCREMENT PRIMARY KEY,
    ID_Material INT,
    ID_Maquina INT,
    Cantidad INT DEFAULT 0,
    ID_Empleado_Deposito INT
);

CREATE TABLE Socios_Gerentes (
    ID_Socio_Gerente INT AUTO_INCREMENT PRIMARY KEY,
    Nombre VARCHAR(255) NOT NULL,
    Telefono VARCHAR(20)
);

CREATE TABLE Solicitudes (
    ID_Solicitud INT AUTO_INCREMENT PRIMARY KEY,
    Fecha DATE,
    Tipo ENUM('Máquina', 'Material') NOT NULL,
    ID_Cliente INT,
    ID_Empleado_Obra INT,
    ID_Empleado_Deposito INT,
    Estado ENUM('Pendiente', 'Parcial', 'Aprobada', 'Rechazada') DEFAULT 'Pendiente',
    ID_Material INT,
    ID_Maquina INT,
    ID_Proveedor INT
);

CREATE TABLE Autorizaciones (
    ID_Autorizacion INT AUTO_INCREMENT PRIMARY KEY,
    ID_Solicitud INT,
    ID_Socio_Gerente INT,
    Estado ENUM('Aprobada', 'Rechazada',"Pendiente") DEFAULT 'Pendiente',
    Fecha DATE
);

CREATE TABLE Movimientos (
    ID_Movimiento INT AUTO_INCREMENT PRIMARY KEY,
    Fecha DATE,
    Tipo ENUM('Entrada', 'Salida', 'Transferencia') NOT NULL,
    ID_Obra_Origen INT,
    ID_Obra_Destino INT,
    ID_Material INT,
    ID_Maquina INT,
    Cantidad INT,
    ID_Empleado_Obra INT,
    ID_Empleado_Deposito INT,
    ID_Autorizacion INT
);

CREATE TABLE Pedidos_Compras (
    ID_Pedido INT AUTO_INCREMENT PRIMARY KEY,
    ID_Solicitud INT,
    ID_Material INT,
    Cantidad_Pendiente INT,
    Fecha DATE,
    ID_Empleado_Compras INT
);

-- Crear relaciones entre las entidades


ALTER TABLE Materiales
ADD CONSTRAINT FK_Proveedor_Materiales
FOREIGN KEY (ID_Proveedor) REFERENCES Proveedores(ID_Proveedor);

ALTER TABLE Maquinas
ADD CONSTRAINT FK_Proveedor_Maquinas
FOREIGN KEY (ID_Proveedor) REFERENCES Proveedores(ID_Proveedor);

ALTER TABLE Empleados_Obra
ADD CONSTRAINT FK_Obra_Empleados_Obra
FOREIGN KEY (ID_Obra) REFERENCES Obras(ID_Obra);

ALTER TABLE Obras
ADD CONSTRAINT FK_Material_Obras
FOREIGN KEY (ID_Material) REFERENCES Materiales(ID_Material),
ADD CONSTRAINT FK_Maquina_Obras
FOREIGN KEY (ID_Maquina) REFERENCES Maquinas(ID_Maquina);

ALTER TABLE Deposito
ADD CONSTRAINT FK_Material_Deposito
FOREIGN KEY (ID_Material) REFERENCES Materiales(ID_Material),
ADD CONSTRAINT FK_Maquina_Deposito
FOREIGN KEY (ID_Maquina) REFERENCES Maquinas(ID_Maquina),
ADD CONSTRAINT FK_Empleados_Deposito
FOREIGN KEY (ID_Empleado_Deposito) REFERENCES Empleados_Depositos(ID_Empleado_Deposito);

ALTER TABLE Solicitudes
ADD CONSTRAINT FK_Cliente_Solicitudes
FOREIGN KEY (ID_Cliente) REFERENCES Clientes(ID_Cliente),
ADD CONSTRAINT FK_Empleado_Obra_Solicitudes
FOREIGN KEY (ID_Empleado_Obra) REFERENCES Empleados_Obra(ID_Empleado_Obra),
ADD CONSTRAINT FK_Empleado_Deposito_Solicitudes
FOREIGN KEY (ID_Empleado_Deposito) REFERENCES Empleados_Depositos(ID_Empleado_Deposito),
ADD CONSTRAINT FK_Material_Solicitudes
FOREIGN KEY (ID_Material) REFERENCES Materiales(ID_Material),
ADD CONSTRAINT FK_Maquina_Solicitudes
FOREIGN KEY (ID_Maquina) REFERENCES Maquinas(ID_Maquina),
ADD CONSTRAINT FK_Proveedor_Solicitudes
FOREIGN KEY (ID_Proveedor) REFERENCES Proveedores(ID_Proveedor);

ALTER TABLE Autorizaciones
ADD CONSTRAINT FK_Solicitud_Autorizaciones
FOREIGN KEY (ID_Solicitud) REFERENCES Solicitudes(ID_Solicitud),
ADD CONSTRAINT FK_Socio_Gerente_Autorizaciones
FOREIGN KEY (ID_Socio_Gerente) REFERENCES Socios_Gerentes(ID_Socio_Gerente);

ALTER TABLE Movimientos
ADD CONSTRAINT FK_Obra_Origen_Movimientos
FOREIGN KEY (ID_Obra_Origen) REFERENCES Obras(ID_Obra),
ADD CONSTRAINT FK_Obra_Destino_Movimientos
FOREIGN KEY (ID_Obra_Destino) REFERENCES Obras(ID_Obra),
ADD CONSTRAINT FK_Material_Movimientos
FOREIGN KEY (ID_Material) REFERENCES Materiales(ID_Material),
ADD CONSTRAINT FK_Maquina_Movimientos
FOREIGN KEY (ID_Maquina) REFERENCES Maquinas(ID_Maquina),
ADD CONSTRAINT FK_Empleado_Obra_Movimientos
FOREIGN KEY (ID_Empleado_Obra) REFERENCES Empleados_Obra(ID_Empleado_Obra),
ADD CONSTRAINT FK_Empleado_Depositos_Movimientos
FOREIGN KEY (ID_Empleado_Deposito) REFERENCES Empleados_Depositos(ID_Empleado_Deposito),
ADD CONSTRAINT FK_Autorizacion_Movimientos
FOREIGN KEY (ID_Autorizacion) REFERENCES Autorizaciones(ID_Autorizacion);

ALTER TABLE Pedidos_Compras
ADD CONSTRAINT FK_Solicitud_Pedidos_Compras
FOREIGN KEY (ID_Solicitud) REFERENCES Solicitudes(ID_Solicitud),
ADD CONSTRAINT FK_Material_Pedidos_Compras
FOREIGN KEY (ID_Material) REFERENCES Materiales(ID_Material),
ADD CONSTRAINT FK_Empleados_Compras_Pedidos_Compras
FOREIGN KEY (ID_Empleado_Compras) REFERENCES Empleados_Compras(ID_Empleado_Compras);
