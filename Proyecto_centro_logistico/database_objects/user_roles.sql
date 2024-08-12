USE CentroLogistico;

-- Creamos los roles:
DROP ROLE IF EXISTS Deposito_Responsable, Deposito_Administrativo, Obra_Jefe, Obra_Capataz, Compras_Responsable, Compras_Administrativo, Desarrollo_Dev, Socio_Gerente ;

CREATE ROLE Deposito_Responsable;
CREATE ROLE Deposito_Administrativo;
CREATE ROLE Obra_Jefe;
CREATE ROLE Obra_Capataz;
CREATE ROLE Compras_Responsable;
CREATE ROLE Compras_Administrativo;
CREATE ROLE Desarrollo_Dev;
CREATE ROLE Socio_Gerente;


-- Asignación de privilegios

-- Deposito_Responsable: Tiene control completo sobre las tablas relacionadas con depósitos y puede realizar movimientos y solicitudes.
GRANT SELECT, INSERT, UPDATE, DELETE ON CentroLogistico.Almacenes_Materiales TO Deposito_Responsable;
GRANT SELECT, INSERT, UPDATE, DELETE ON CentroLogistico.Almacenes_Maquinas TO Deposito_Responsable;
GRANT SELECT, INSERT, UPDATE, DELETE ON CentroLogistico.Movimientos TO Deposito_Responsable;
GRANT SELECT, INSERT, UPDATE, DELETE ON CentroLogistico.Detalle_Movimientos TO Deposito_Responsable;
GRANT SELECT, INSERT, UPDATE, DELETE ON CentroLogistico.Solicitudes TO Deposito_Responsable;
GRANT SELECT, INSERT, UPDATE, DELETE ON CentroLogistico.Detalle_Solicitudes TO Deposito_Responsable;
GRANT SELECT ON CentroLogistico.Pedidos_Compras TO Deposito_Responsable;
GRANT SELECT ON CentroLogistico.Autorizaciones TO Deposito_Responsable;

-- Deposito_Administrativo: Puede realizar los registros relacionados con depósitos y movimientos.
GRANT SELECT, INSERT, UPDATE ON CentroLogistico.Almacenes_Materiales TO Deposito_Administrativo;
GRANT SELECT, INSERT, UPDATE ON CentroLogistico.Almacenes_Maquinas TO Deposito_Administrativo;
GRANT SELECT, INSERT, UPDATE ON CentroLogistico.Movimientos TO Deposito_Administrativo;
GRANT SELECT, INSERT, UPDATE ON CentroLogistico.Detalle_Movimientos TO Deposito_Administrativo;

-- Obra_Jefe: Tiene control sobre las tablas relacionadas con las obras y puede ver las solicitudes y los movimientos.
GRANT SELECT, INSERT, UPDATE ON CentroLogistico.Almacenes_Materiales TO Obra_Jefe;
GRANT SELECT, INSERT, UPDATE ON CentroLogistico.Almacenes_Maquinas TO Obra_Jefe;
GRANT SELECT, INSERT, UPDATE, DELETE ON CentroLogistico.Solicitudes TO Obra_Jefe;
GRANT SELECT, INSERT, UPDATE, DELETE ON CentroLogistico.Detalle_Solicitudes TO Obra_Jefe;
GRANT SELECT, INSERT, UPDATE ON CentroLogistico.Movimientos TO Obra_Jefe;
GRANT SELECT, INSERT, UPDATE ON CentroLogistico.Detalle_Movimientos TO Obra_Jefe;
GRANT SELECT ON CentroLogistico.Autorizaciones TO Obra_Jefe;

-- Obra_Capataz: Puede ver y actualizar las solicitudes, pero no tiene privilegios de eliminación.
GRANT SELECT ON CentroLogistico.Almacenes_Materiales TO Obra_Capataz;
GRANT SELECT ON CentroLogistico.Almacenes_Maquinas TO Obra_Capataz;
GRANT SELECT ON CentroLogistico.Solicitudes TO Obra_Capataz;
GRANT SELECT ON CentroLogistico.Detalle_Solicitudes TO Obra_Capataz;

-- Compras_Responsable: Tiene control sobre las tablas relacionadas con pedidos de compras y puede ver proveedores.
GRANT SELECT, INSERT, UPDATE, DELETE ON CentroLogistico.Pedidos_Compras TO Compras_Responsable;
GRANT SELECT, INSERT, UPDATE, DELETE ON CentroLogistico.Detalle_Pedidos_Compras TO Compras_Responsable;
GRANT SELECT, INSERT, UPDATE ON CentroLogistico.Proveedores TO Compras_Responsable;
GRANT SELECT ON CentroLogistico.Autorizaciones TO Compras_Responsable;

-- Compras_Administrativo: Puede ver y actualizar los pedidos de compras, pero no tiene privilegios de eliminación.
GRANT SELECT, INSERT, UPDATE ON CentroLogistico.Pedidos_Compras TO Compras_Administrativo;
GRANT SELECT, INSERT, UPDATE ON CentroLogistico.Detalle_Pedidos_Compras TO Compras_Administrativo;

-- Desarrollo_Dev: Tiene privilegios de lectura sobre todas las tablas para poder desarrollar, pero no puede modificar datos.
GRANT ALL PRIVILEGES ON CentroLogistico.* TO Desarrollo_Dev;

-- Socio_Gerente: Tiene privilegios completos sobre todas las tablas, dado su rol de gestión.
GRANT SELECT ON CentroLogistico.* TO Socio_Gerente;
GRANT SELECT, INSERT, UPDATE, DELETE ON CentroLogistico.Centros TO Socio_Gerente;
GRANT SELECT, INSERT, UPDATE, DELETE ON CentroLogistico.Empleados TO Socio_Gerente;
GRANT SELECT, INSERT, UPDATE, DELETE ON CentroLogistico.Autorizaciones TO Socio_Gerente;

-- Garantizar acceso a las vistas para los roles correspondientes
-- Deposito_Responsable: Tiene acceso a todas las vistas relacionadas con depósitos y movimientos.
GRANT SELECT ON CentroLogistico.Vista_Materiales_Deposito TO Deposito_Responsable;
GRANT SELECT ON CentroLogistico.Vista_Maquinas_Deposito TO Deposito_Responsable;
GRANT SELECT ON CentroLogistico.Vista_Movimientos TO Deposito_Responsable;
GRANT SELECT ON CentroLogistico.Vista_Stock_Materiales TO Deposito_Responsable;
GRANT SELECT ON CentroLogistico.Vista_Stock_Maquinas TO Deposito_Responsable;

-- Deposito_Administrativo: Puede consultar las vistas relacionadas con depósitos.
GRANT SELECT ON CentroLogistico.Vista_Materiales_Deposito TO Deposito_Administrativo;
GRANT SELECT ON CentroLogistico.Vista_Maquinas_Deposito TO Deposito_Administrativo;
GRANT SELECT ON CentroLogistico.Vista_Stock_Materiales TO Deposito_Administrativo;
GRANT SELECT ON CentroLogistico.Vista_Stock_Maquinas TO Deposito_Administrativo;

-- Obra_Jefe: Puede consultar las vistas de solicitudes y movimientos.
GRANT SELECT ON CentroLogistico.Vista_SolicitudesPendientes TO Obra_Jefe;
GRANT SELECT ON CentroLogistico.Vista_Solicitudes TO Obra_Jefe;
GRANT SELECT ON CentroLogistico.Vista_Movimientos TO Obra_Jefe;

-- Obra_Capataz: Tiene acceso a las vistas de solicitudes.
GRANT SELECT ON CentroLogistico.Vista_SolicitudesPendientes TO Obra_Capataz;
GRANT SELECT ON CentroLogistico.Vista_Solicitudes TO Obra_Capataz;

-- Compras_Responsable: Puede consultar las vistas de stock y movimientos.
GRANT SELECT ON CentroLogistico.Vista_Stock_Materiales TO Compras_Responsable;
GRANT SELECT ON CentroLogistico.Vista_Stock_Maquinas TO Compras_Responsable;
GRANT SELECT ON CentroLogistico.Vista_Movimientos TO Compras_Responsable;

-- Compras_Administrativo: Tiene acceso a las vistas de stock.
GRANT SELECT ON CentroLogistico.Vista_Stock_Materiales TO Compras_Administrativo;
GRANT SELECT ON CentroLogistico.Vista_Stock_Maquinas TO Compras_Administrativo;

-- Garantizar privilegios en procedimientos
-- 1. Privilegios para aprobar o rechazar solicitudes
GRANT EXECUTE ON PROCEDURE CentroLogistico.SP_AprobarORechazarSolicitud TO 'Socio_Gerente';

-- 2. Privilegios para crear solicitudes
GRANT EXECUTE ON PROCEDURE CentroLogistico.SP_CrearSolicitud TO 'Obra_Jefe', 'Deposito_Administrativo', 'Deposito_Responsable';

-- 3. Privilegios para registrar entradas de materiales o máquinas
GRANT EXECUTE ON PROCEDURE CentroLogistico.SP_RegistrarEntrada TO 'Deposito_Responsable', 'Deposito_Administrativo';

-- 4. Privilegios para registrar salidas de materiales o máquinas
GRANT EXECUTE ON PROCEDURE CentroLogistico.SP_RegistrarSalida TO 'Deposito_Responsable', 'Deposito_Administrativo';

-- 5. Privilegios para realizar movimientos de materiales con una solicitud aprobada
GRANT EXECUTE ON PROCEDURE CentroLogistico.SP_RealizarMovimientoMateriales TO 'Obra_Jefe', 'Deposito_Responsable', 'Deposito_Administrativo';

-- 6. Privilegios para realizar movimientos de máquinas con una solicitud aprobada
GRANT EXECUTE ON PROCEDURE CentroLogistico.SP_RealizarMovimientoMaquinas TO 'Obra_Jefe', 'Deposito_Responsable', 'Deposito_Administrativo';

-- 7. Privilegios para generar pedidos de compras desde una solicitud aprobada
GRANT EXECUTE ON PROCEDURE CentroLogistico.SP_GenerarPedidoCompras TO 'Compras_Responsable', 'Compras_Administrativo';

-- Garantizar a los usuarios acceso a las funciones
-- 1. Privilegios para obtener el estado de un equipo en particular
GRANT EXECUTE ON FUNCTION CentroLogistico.Funcion_ObtenerEstadoMaquina TO 'Deposito_Responsable', 'Obra_Jefe', 'Socio_Gerente';
-- 2. Privilegios para obtener la cantidad de stock de un material en todos los centros
GRANT EXECUTE ON FUNCTION CentroLogistico.Funcion_ObtenerCantidadMaterialPorCentro TO 'Deposito_Responsable', 'Compras_Responsable', 'Compras_Administrativo', 'Socio_Gerente';
-- 3. Privilegios para obtener el stock de un material de un centro en particular
GRANT EXECUTE ON FUNCTION CentroLogistico.Funcion_ObtenerCantidadMaterialCentro TO 'Deposito_Responsable', 'Deposito_Administrativo', 'Obra_Jefe', 'Compras_Responsable','Compras_Administrativo', 'Socio_Gerente';

-- Creación de usuarios de prueba y asignación de roles

CREATE USER 'deposito_resp_user'@'%' IDENTIFIED BY '1234';
GRANT Deposito_Responsable TO 'deposito_resp_user'@'%';

CREATE USER 'deposito_admin_user'@'%' IDENTIFIED BY '1234';
GRANT Deposito_Administrativo TO 'deposito_admin_user'@'%';

CREATE USER 'obra_jefe_user'@'%' IDENTIFIED BY '2345';
GRANT Obra_Jefe TO 'obra_jefe_user'@'%';

CREATE USER 'obra_capataz_user'@'%' IDENTIFIED BY '2345';
GRANT Obra_Capataz TO 'obra_capataz_user'@'%';

CREATE USER 'compras_resp_user'@'%' IDENTIFIED BY '3456';
GRANT Compras_Responsable TO 'compras_resp_user'@'%';

CREATE USER 'compras_admin_user'@'%' IDENTIFIED BY '3456';
GRANT Compras_Administrativo TO 'compras_admin_user'@'%';

CREATE USER 'dev_user'@'%' IDENTIFIED BY '4321';
GRANT Desarrollo_Dev TO 'dev_user'@'%';

CREATE USER 'gerente_user'@'%' IDENTIFIED BY '5432';
GRANT Socio_Gerente TO 'gerente_user'@'%';

SET DEFAULT ROLE Deposito_Responsable TO 'deposito_resp_user'@'%';
SET DEFAULT ROLE Deposito_Administrativo TO 'deposito_admin_user'@'%';
SET DEFAULT ROLE Obra_Jefe TO 'obra_jefe_user'@'%';
SET DEFAULT ROLE Obra_Capataz TO 'obra_capataz_user'@'%';
SET DEFAULT ROLE Compras_Responsable TO 'compras_resp_user'@'%';
SET DEFAULT ROLE Compras_Administrativo TO 'compras_admin_user'@'%';
SET DEFAULT ROLE Desarrollo_Dev TO 'dev_user'@'%';
SET DEFAULT ROLE Socio_Gerente TO 'gerente_user'@'%';

FLUSH PRIVILEGES;