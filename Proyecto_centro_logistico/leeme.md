# Centro Logístico de Materiales y Máquinas
Este documento proporciona una descripción completa de la base de datos del Centro Logístico de Materiales y Máquinas, diseñada para gestionar eficientemente el inventario, las solicitudes, movimientos y compras de materiales y máquinas entre diferentes centros de almacenamiento (obras y depósitos). Además, se incluyen las relaciones entre las tablas, así como los triggers, stored procedures, vistas y funciones que facilitan las operaciones diarias.

## Diagrama Entidad-Relación

El siguiente diagrama muestra el modelo de entidad-relación del sistema:

<a href="https://miro.com/app/board/uXjVK4abNrw=/" target="_blank">Diagrama ER en Miro</a>

## Contenido
### Esquema de Base de Datos

- Proveedores
- Materiales
- Máquinas
- Clientes
- Centros (Obras y Depósitos)
- Empleados
- Socios Gerentes
- Almacenes de Materiales
- Almacenes de Máquinas
- Solicitudes
- Detalle de Solicitudes
- Autorizaciones
- Movimientos
- Detalle de Movimientos
- Pedidos de Compras
- Detalle de Pedidos de Compras
- Relaciones entre Tablas

### Stored Procedures, Triggers, Vistas y Funciones

- Funciones
- Triggers
- Stored Procedures
- Vistas
## Esquema de Base de Datos
### 1. Proveedores
Tabla que almacena la información de los proveedores de materiales y máquinas.

- ID_Proveedor: Identificador único.
- Nombre: Nombre del proveedor.
- Dirección: Dirección del proveedor.
- Teléfono: Teléfono de contacto.
- Rubro: Tipo de productos que provee.
### 2. Materiales
Tabla que almacena la información de los materiales disponibles.

- ID_Material: Identificador único.
- Nombre: Nombre del material.
- Descripción: Descripción detallada del material.
- Unidad: Unidad de medida del material.
- ID_Proveedor: Identificador del proveedor.
### 3. Máquinas
Tabla que almacena la información de las máquinas disponibles.

- ID_Maquina: Identificador único.
- Nombre: Nombre de la máquina.
- Descripción: Descripción detallada de la máquina.
- Estado: Estado actual de la máquina (e.g., operativa, en reparación).
- ID_Proveedor: Identificador del proveedor.
### 4. Clientes
Tabla que almacena la información de los clientes.

- ID_Cliente: Identificador único.
- Nombre: Nombre del cliente.
- Dirección: Dirección del cliente.
- Teléfono: Teléfono de contacto.
### 5. Centros (Obras y Depósitos)
Tabla que almacena la información de los centros de almacenamiento (obras y depósitos).

- ID_Centro: Identificador único.
- Nombre: Nombre del centro.
- Dirección: Dirección del centro.
- Tipo: Tipo de centro ('Obra' o 'Depósito').
### 6. Empleados
Tabla que almacena la información de los empleados.

- ID_Empleado: Identificador único.
- Nombre: Nombre del empleado.
- Cargo: Cargo del empleado.
- Teléfono: Teléfono de contacto.
- ID_Centro: Identificador del centro donde trabaja el empleado.
- Tipo: Tipo de empleado ('Obra', 'Depósito', 'Compras').
### 7. Socios Gerentes
Tabla que almacena la información de los socios gerentes.

- ID_Socio_Gerente: Identificador único.
- Nombre: Nombre del socio gerente.
- Teléfono: Teléfono de contacto.
### 8. Almacenes de Materiales
Tabla que almacena el inventario de materiales en cada centro.

- ID_Almacen_Material: Identificador único.
- ID_Centro: Identificador del centro.
- ID_Material: Identificador del material.
- Cantidad: Cantidad disponible del material.
### 9. Almacenes de Máquinas
Tabla que almacena el inventario de máquinas en cada centro.

- ID_Almacen_Maquina: Identificador único.
- ID_Centro: Identificador del centro.
- ID_Maquina: Identificador de la máquina.
### 10. Solicitudes
Tabla que registra las solicitudes de materiales y máquinas.

- ID_Solicitud: Identificador único.
- Fecha: Fecha de la solicitud.
- Tipo: Tipo de solicitud ('Material' o 'Máquina').
- ID_Cliente: Identificador del cliente.
- ID_Empleado: Identificador del empleado que realiza la solicitud.
- Estado: Estado de la solicitud ('Pendiente', 'Parcial', 'Aprobada', 'Rechazada').
- ID_Proveedor: Identificador del proveedor.
- ID_Centro: Identificador del centro.
### 11. Detalle de Solicitudes
Tabla que almacena el detalle de las solicitudes.

- ID_Detalle_Solicitud: Identificador único.
- ID_Solicitud: Identificador de la solicitud.
- ID_Material: Identificador del material.
- ID_Maquina: Identificador de la máquina.
- Cantidad: Cantidad solicitada.
### 12. Autorizaciones
Tabla que registra las autorizaciones de los movimientos y solicitudes.

- ID_Autorizacion: Identificador único.
- ID_Solicitud: Identificador de la solicitud.
- ID_Socio_Gerente: Identificador del socio gerente que autoriza.
- Estado: Estado de la autorización ('Aprobada', 'Rechazada', 'Pendiente').
- Fecha: Fecha de la autorización.
### 13. Movimientos
Tabla que registra los movimientos de materiales y máquinas.

- ID_Movimiento: Identificador único.
- Fecha: Fecha del movimiento.
- Tipo: Tipo de movimiento ('Entrada', 'Salida', 'Transferencia').
- ID_Empleado: Identificador del empleado responsable.
- ID_Autorizacion: Identificador de la autorización correspondiente.
### 14. Detalle de Movimientos
Tabla que almacena el detalle de los movimientos de materiales y máquinas.

- ID_Detalle_Movimiento: Identificador único.
- ID_Movimiento: Identificador del movimiento.
- ID_Almacen_Origen: Identificador del centro de origen.
- ID_Almacen_Destino: Identificador del centro de destino.
- ID_Material: Identificador del material (si aplica).
- ID_Maquina: Identificador de la máquina (si aplica).
- Cantidad: Cantidad movida.
### 15. Pedidos de Compras
Tabla que registra los pedidos de compras de materiales.

- ID_Pedido: Identificador único.
- ID_Solicitud: Identificador de la solicitud.
- Fecha: Fecha del pedido.
- ID_Empleado_Compras: Identificador del empleado de compras.
### 16. Detalle de Pedidos de Compras
Tabla que almacena el detalle de los pedidos de compras de materiales.

- ID_Detalle_Pedido: Identificador único.
- ID_Pedido: Identificador del pedido.
- ID_Material: Identificador del material.
- Cantidad: Cantidad pendiente de recibir.
## Relaciones entre Tablas
Se establecen las siguientes relaciones clave entre las tablas:

### 1. Materiales - Proveedores:
- Materiales.ID_Proveedor → Proveedores.ID_Proveedor
### 3. Máquinas - Proveedores:
- Maquinas.ID_Proveedor → Proveedores.ID_Proveedor
### 4. Empleados - Centros: 
- Empleados.ID_Centro → Centros.ID_Centro
### 5. Almacenes_Materiales - Centros, Materiales:
- Almacenes_Materiales.ID_Centro → Centros.ID_Centro
- Almacenes_Materiales.ID_Material → Materiales.ID_Material
### 5. Almacenes_Maquinas - Centros, Máquinas:
- Almacenes_Maquinas.ID_Centro → Centros.ID_Centro
- Almacenes_Maquinas.ID_Maquina → Maquinas.ID_Maquina
### 6. Solicitudes - Clientes, Empleados, Proveedores, Centros:
- Solicitudes.ID_Cliente → Clientes.ID_Cliente
- Solicitudes.ID_Empleado → Empleados.ID_Empleado
- Solicitudes.ID_Proveedor → Proveedores.ID_Proveedor
- Solicitudes.ID_Centro → Centros.ID_Centro
### 7. Detalle_Solicitudes - Solicitudes, Materiales, Máquinas:
- Detalle_Solicitudes.ID_Solicitud → Solicitudes.ID_Solicitud
- Detalle_Solicitudes.ID_Material → Materiales.ID_Material
- Detalle_Solicitudes.ID_Maquina → Maquinas.ID_Maquina
### 8. Autorizaciones - Solicitudes, Socios Gerentes:
- Autorizaciones.ID_Solicitud → Solicitudes.ID_Solicitud
- Autorizaciones.ID_Socio_Gerente → Socios_Gerentes.ID_Socio_Gerente
### 9. Movimientos - Empleados, Autorizaciones:
- Movimientos.ID_Empleado → Empleados.ID_Empleado
- Movimientos.ID_Autorizacion → Autorizaciones.ID_Autorizacion
### 10. Detalle_Movimientos - Movimientos, Centros, Materiales, Máquinas:
- Detalle_Movimientos.ID_Movimiento → Movimientos.ID_Movimiento
- Detalle_Movimientos.ID_Almacen_Origen → Centros.ID_Centro
- Detalle_Movimientos.ID_Almacen_Destino → Centros.ID_Centro
- Detalle_Movimientos.ID_Material → Materiales.ID_Material
- Detalle_Movimientos.ID_Maquina → Maquinas.ID_Maquina
### 11. Pedidos_Compras - Solicitudes, Empleados:
- Pedidos_Compras.ID_Solicitud → Solicitudes.ID_Solicitud
- Pedidos_Compras.ID_Empleado_Compras → Empleados.ID_Empleado
### 12. Detalle_Pedidos_Compras - Pedidos_Compras, Materiales:
- Detalle_Pedidos_Compras.ID_Pedido → Pedidos_Compras.ID_Pedido
Detalle_Pedidos_Compras.ID_Material → Materiales.ID_Material

## Stored Procedures, Triggers, Vistas y Funciones
### Funciones
- Función para calcular la cantidad total de un material en todos los almacenes.
- Función para obtener el estado actual de una máquina.
### Triggers
- Trigger para actualizar el inventario de materiales al realizar un movimiento.
- Trigger para notificar a los empleados de compras cuando una solicitud no puede ser completamente satisfecha.
### Stored Procedures
- Procedure para procesar una nueva solicitud.
- Procedure para autorizar un movimiento.
- Procedure para realizar un pedido de compra.

## Vistas
### 1. Vista: vw_SolicitudesPendientes
### Descripción:
Muestra una lista de todas las solicitudes que están pendientes de aprobación. Incluye detalles sobre la solicitud, el cliente asociado y el empleado que la creó.

### Campos:

- ID_Solicitud: Identificador único de la solicitud.
- Cliente: Nombre del cliente asociado a la solicitud.
- Empleado: Nombre del empleado que creó la solicitud.
- Tipo: Tipo de la solicitud (materiales, máquinas, etc.).
- Estado: Estado actual de la solicitud (en este caso, debe ser 'Pendiente').
### Uso:
Esta vista es útil para los gestores y responsables que necesitan revisar y aprobar las solicitudes que están pendientes en el sistema.

### 2. Vista: Vista_Materiales_Centro
### Descripción:
Muestra los materiales disponibles en un centro específico que está clasificado como depósito. Incluye el nombre del centro, el nombre del material y la cantidad disponible.

### Campos:

- Nombre_Centro: Nombre del centro donde están almacenados los materiales.
- Nombre_Material: Nombre del material disponible.
- Cantidad: Cantidad disponible del material en el centro.
### Uso:
Esta vista permite a los usuarios consultar rápidamente los materiales disponibles en centros clasificados como depósitos, facilitando la gestión de inventario y el seguimiento de existencias.

### 3. Vista: Vista_Maquinas_Centro
### Descripción:
Muestra las máquinas disponibles en un centro específico clasificado como depósito. Incluye el nombre del centro, el nombre de la máquina, una breve descripción y el estado de la máquina.

### Campos:

- Nombre_Centro: Nombre del centro donde están almacenadas las máquinas.
- Nombre_Maquina: Nombre de la máquina disponible.
- Descripcion: Descripción de la máquina.
- Estado: Estado actual de la máquina (por ejemplo, disponible, en reparación, etc.).
### Uso:
Esta vista es útil para consultar el inventario de máquinas en los centros de depósito, ayudando en la planificación y gestión de los recursos disponibles.

### 4. Vista: Vista_Movimientos
### Descripción:
Proporciona información detallada sobre los movimientos de materiales y máquinas, incluyendo la fecha del movimiento, el tipo, el centro involucrado, el empleado responsable, y los detalles específicos del material o máquina movida.

### Campos:

- ID_Movimiento: Identificador único del movimiento.
- Fecha: Fecha en que se realizó el movimiento.
- Tipo: Tipo de movimiento (entrada, salida, traslado, etc.).
- Nombre_Centro: Nombre del centro donde se realizó el movimiento.
- Nombre_Empleado: Nombre del empleado que realizó el movimiento.
- ID_Material: Identificador del material involucrado en el movimiento.
- ID_Maquina: Identificador de la máquina involucrada en el movimiento.
- Cantidad: Cantidad de material o máquinas movidas.
- Nombre_Item: Nombre del material o máquina, dependiendo de cuál esté involucrado.
### Uso:
Esta vista es útil para hacer un seguimiento de todos los movimientos de inventario, facilitando la auditoría y el análisis de la gestión de recursos.

### 5. Vista: Vista_Solicitudes
### Descripción:
Muestra información detallada sobre las solicitudes, incluyendo la fecha, tipo, cliente, empleado, centro asociado, y los detalles de los materiales y máquinas solicitados.

### Campos:

- ID_Solicitud: Identificador único de la solicitud.
- Fecha: Fecha en que se realizó la solicitud.
- Tipo: Tipo de solicitud (materiales, máquinas, etc.).
- Nombre_Cliente: Nombre del cliente asociado a la solicitud.
- Nombre_Empleado: Nombre del empleado que realizó la solicitud.
- Nombre_Centro: Nombre del centro donde se requiere el material o máquina.
- ID_Material: Identificador del material solicitado.
- ID_Maquina: Identificador de la máquina solicitada.
- Cantidad: Cantidad de material o máquinas solicitadas.
- Nombre_Item: Nombre del material o máquina solicitado.
- Estado: Estado actual de la solicitud.
### Uso:
Esta vista permite consultar la información detallada de todas las solicitudes en el sistema, facilitando el análisis y seguimiento de las mismas.
