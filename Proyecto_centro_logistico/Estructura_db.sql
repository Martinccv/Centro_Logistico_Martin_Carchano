-- Eliminar base de dato con el mismo nombre si existe

DROP DATABASE IF EXISTS CentroLogistico;

-- Creación de la base de datos

CREATE DATABASE CentroLogistico;
USE CentroLogistico;

-- Creación de tablas

-- Tabla de Proveedores
CREATE TABLE Proveedores (
    ID_Proveedor INT AUTO_INCREMENT PRIMARY KEY,
    Nombre VARCHAR(255) NOT NULL,
    Direccion VARCHAR(255),
    Telefono VARCHAR(20),
    Rubro VARCHAR(100)
);

-- Tabla de Materiales
CREATE TABLE Materiales (
    ID_Material INT AUTO_INCREMENT PRIMARY KEY,
    Nombre VARCHAR(255) NOT NULL,
    Descripcion TEXT,
    Unidad VARCHAR(10),
    ID_Proveedor INT
);

-- Tabla de Maquinas
CREATE TABLE Maquinas (
    ID_Maquina INT AUTO_INCREMENT PRIMARY KEY,
    Nombre VARCHAR(255) NOT NULL,
    Descripcion TEXT,
    Estado VARCHAR(50),
    ID_Proveedor INT
);

-- Tabla de Clientes
CREATE TABLE Clientes (
    ID_Cliente INT AUTO_INCREMENT PRIMARY KEY,
    Nombre VARCHAR(255) NOT NULL,
    Direccion VARCHAR(255),
    Telefono VARCHAR(20)
);

-- Tabla unificada de Centros de almacenamiento (Obras y Depósitos)
CREATE TABLE Centros (
    ID_Centro INT AUTO_INCREMENT PRIMARY KEY,
    Nombre VARCHAR(255) NOT NULL,
    Direccion VARCHAR(255),
    Tipo ENUM('Obra', 'Deposito') NOT NULL
);

-- Tabla de Empleados
CREATE TABLE Empleados (
    ID_Empleado INT AUTO_INCREMENT PRIMARY KEY,
    Nombre VARCHAR(255) NOT NULL,
    Cargo VARCHAR(50),
    Telefono VARCHAR(20),
    ID_Centro INT,
    Tipo ENUM('Obra', 'Deposito', 'Compras') NOT NULL
);

-- Tabla de Socios Gerentes
CREATE TABLE Socios_Gerentes (
    ID_Socio_Gerente INT AUTO_INCREMENT PRIMARY KEY,
    Nombre VARCHAR(255) NOT NULL,
    Telefono VARCHAR(20)
);

-- Tabla de Almacenes de Materiales
CREATE TABLE Almacenes_Materiales (
    ID_Almacen_Material INT AUTO_INCREMENT PRIMARY KEY,
    ID_Centro INT,
    ID_Material INT,
    Cantidad INT DEFAULT 0
);

-- Tabla de Almacenes de Maquinas
CREATE TABLE Almacenes_Maquinas (
    ID_Almacen_Maquina INT AUTO_INCREMENT PRIMARY KEY,
    ID_Centro INT,
    ID_Maquina INT
);

-- Tabla de Solicitudes
CREATE TABLE Solicitudes (
    ID_Solicitud INT AUTO_INCREMENT PRIMARY KEY,
    Fecha DATE,
    Tipo ENUM('Material', 'Maquina') NOT NULL,
    ID_Cliente INT,
    ID_Empleado INT,
    Estado ENUM('Pendiente', 'Parcial', 'Aprobada', 'Rechazada') DEFAULT 'Pendiente',
    ID_Proveedor INT,
    ID_Centro INT NOT NULL
);

-- Tabla de Detalle de Solicitudes
CREATE TABLE Detalle_Solicitudes (
    ID_Detalle_Solicitud INT AUTO_INCREMENT PRIMARY KEY,
    ID_Solicitud INT,
    ID_Material INT,
    ID_Maquina INT,
    Cantidad INT
);

-- Tabla de Autorizaciones
CREATE TABLE Autorizaciones (
    ID_Autorizacion INT AUTO_INCREMENT PRIMARY KEY,
    ID_Solicitud INT,
    ID_Socio_Gerente INT,
    Estado ENUM('Aprobada', 'Rechazada', 'Pendiente') DEFAULT 'Pendiente',
    Fecha DATE
);

-- Tabla de Movimientos
CREATE TABLE Movimientos (
    ID_Movimiento INT AUTO_INCREMENT PRIMARY KEY,
    Fecha DATE,
    Tipo ENUM('Entrada', 'Salida', 'Transferencia') NOT NULL,
    ID_Empleado INT,
    ID_Autorizacion INT
);

-- Tabla de Detalle de Movimientos
CREATE TABLE Detalle_Movimientos (
    ID_Detalle_Movimiento INT AUTO_INCREMENT PRIMARY KEY,
    ID_Movimiento INT,
    ID_Almacen_Origen INT,
    ID_Almacen_Destino INT,
    ID_Material INT,
    ID_Maquina INT,
    Cantidad INT
);

-- Tabla de Pedidos de Compras
CREATE TABLE Pedidos_Compras (
    ID_Pedido INT AUTO_INCREMENT PRIMARY KEY,
    ID_Solicitud INT,
    Fecha DATE,
    ID_Empleado_Compras INT
);

-- Tabla de Detalle de Pedidos de Compras
CREATE TABLE Detalle_Pedidos_Compras (
    ID_Detalle_Pedido INT AUTO_INCREMENT PRIMARY KEY,
    ID_Pedido INT,
    ID_Material INT,
    Cantidad_Pendiente INT
);

-- Relaciones entre tablas
ALTER TABLE Materiales
    ADD CONSTRAINT FK_Proveedor_Materiales
    FOREIGN KEY (ID_Proveedor) REFERENCES Proveedores(ID_Proveedor);

ALTER TABLE Maquinas
    ADD CONSTRAINT FK_Proveedor_Maquinas
    FOREIGN KEY (ID_Proveedor) REFERENCES Proveedores(ID_Proveedor);

ALTER TABLE Empleados
    ADD CONSTRAINT FK_Centros_Empleados
    FOREIGN KEY (ID_Centro) REFERENCES Centros(ID_Centro);

ALTER TABLE Almacenes_Materiales
    ADD CONSTRAINT FK_Centros_Almacenes_Materiales
    FOREIGN KEY (ID_Centro) REFERENCES Centros(ID_Centro),
    ADD CONSTRAINT FK_Material_Almacenes_Materiales
    FOREIGN KEY (ID_Material) REFERENCES Materiales(ID_Material);

ALTER TABLE Almacenes_Maquinas
    ADD CONSTRAINT FK_Centros_Almacenes_Maquinas
    FOREIGN KEY (ID_Centro) REFERENCES Centros(ID_Centro),
    ADD CONSTRAINT FK_Maquina_Almacenes_Maquinas
    FOREIGN KEY (ID_Maquina) REFERENCES Maquinas(ID_Maquina);

ALTER TABLE Solicitudes
    ADD CONSTRAINT FK_Cliente_Solicitudes
    FOREIGN KEY (ID_Cliente) REFERENCES Clientes(ID_Cliente),
    ADD CONSTRAINT FK_Empleado_Solicitudes
    FOREIGN KEY (ID_Empleado) REFERENCES Empleados(ID_Empleado),
    ADD CONSTRAINT FK_Proveedor_Solicitudes
    FOREIGN KEY (ID_Proveedor) REFERENCES Proveedores(ID_Proveedor),
    ADD CONSTRAINT FK_Centros_Solicitudes
    FOREIGN KEY (ID_Centro) REFERENCES Centros(ID_Centro);

ALTER TABLE Detalle_Solicitudes
    ADD CONSTRAINT FK_Solicitud_Detalle_Solicitudes
    FOREIGN KEY (ID_Solicitud) REFERENCES Solicitudes(ID_Solicitud),
    ADD CONSTRAINT FK_Material_Detalle_Solicitudes
    FOREIGN KEY (ID_Material) REFERENCES Materiales(ID_Material),
    ADD CONSTRAINT FK_Maquina_Detalle_Solicitudes
    FOREIGN KEY (ID_Maquina) REFERENCES Maquinas(ID_Maquina);

ALTER TABLE Autorizaciones
    ADD CONSTRAINT FK_Solicitud_Autorizaciones
    FOREIGN KEY (ID_Solicitud) REFERENCES Solicitudes(ID_Solicitud),
    ADD CONSTRAINT FK_Socio_Gerente_Autorizaciones
    FOREIGN KEY (ID_Socio_Gerente) REFERENCES Socios_Gerentes(ID_Socio_Gerente);

ALTER TABLE Movimientos
    ADD CONSTRAINT FK_Empleado_Movimientos
    FOREIGN KEY (ID_Empleado) REFERENCES Empleados(ID_Empleado),
    ADD CONSTRAINT FK_Autorizacion_Movimientos
    FOREIGN KEY (ID_Autorizacion) REFERENCES Autorizaciones(ID_Autorizacion);

ALTER TABLE Detalle_Movimientos
    ADD CONSTRAINT FK_Movimiento_Detalle_Movimientos
    FOREIGN KEY (ID_Movimiento) REFERENCES Movimientos(ID_Movimiento),
    ADD CONSTRAINT FK_Almacen_Origen_Detalle_Movimientos
    FOREIGN KEY (ID_Almacen_Origen) REFERENCES Centros(ID_Centro),
    ADD CONSTRAINT FK_Almacen_Destino_Detalle_Movimientos
    FOREIGN KEY (ID_Almacen_Destino) REFERENCES Centros(ID_Centro),
    ADD CONSTRAINT FK_Material_Detalle_Movimientos
    FOREIGN KEY (ID_Material) REFERENCES Materiales(ID_Material),
    ADD CONSTRAINT FK_Maquina_Detalle_Movimientos
    FOREIGN KEY (ID_Maquina) REFERENCES Maquinas(ID_Maquina);

ALTER TABLE Pedidos_Compras
    ADD CONSTRAINT FK_Solicitud_Pedidos_Compras
    FOREIGN KEY (ID_Solicitud) REFERENCES Solicitudes(ID_Solicitud),
    ADD CONSTRAINT FK_Empleado_Compras_Pedidos_Compras
    FOREIGN KEY (ID_Empleado_Compras) REFERENCES Empleados(ID_Empleado);

ALTER TABLE Detalle_Pedidos_Compras
    ADD CONSTRAINT FK_Pedido_Detalle_Pedidos_Compras
    FOREIGN KEY (ID_Pedido) REFERENCES Pedidos_Compras(ID_Pedido),
    ADD CONSTRAINT FK_Material_Detalle_Pedidos_Compras
    FOREIGN KEY (ID_Material) REFERENCES Materiales(ID_Material);
