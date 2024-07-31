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
- Materiales.ID_Proveedor → Proveedores.ID_Proveedor, relación: 1 Proveedor - * Materiales
### 3. Máquinas - Proveedores:
- Maquinas.ID_Proveedor → Proveedores.ID_Proveedor, relación: 1 Proveedor - * Maquinas
### 4. Empleados - Centros: 
- Empleados.ID_Centro → Centros.ID_Centro, relación: 1 Centro - * Empleados
### 5. Almacenes_Materiales - Centros, Materiales:
- Almacenes_Materiales.ID_Centro → Centros.ID_Centro, relación: 1 Centro - * Almacenes_Materiales
- Almacenes_Materiales.ID_Material → Materiales.ID_Material, relación: * Materiales - * Almacenes_Materiales
### 5. Almacenes_Maquinas - Centros, Máquinas:
- Almacenes_Maquinas.ID_Centro → Centros.ID_Centro, relación: 1 Centro - * Almacenes_Maquinas
- Almacenes_Maquinas.ID_Maquina → Maquinas.ID_Maquina, relación: * Maquinas - * Almacenes_Maquinas
### 6. Solicitudes - Clientes, Empleados, Proveedores, Centros:
- Solicitudes.ID_Cliente → Clientes.ID_Cliente, relación: 1 Cliente - * Solicitudes
- Solicitudes.ID_Empleado → Empleados.ID_Empleado, relación: 1 Empleado - * Solicitudes
- Solicitudes.ID_Proveedor → Proveedores.ID_Proveedor, relación: 1 Proveedor - * Solicitudes
- Solicitudes.ID_Centro → Centros.ID_Centro, relación: 1 Centro - * Solicitudes
### 7. Detalle_Solicitudes - Solicitudes, Materiales, Máquinas:
- Detalle_Solicitudes.ID_Solicitud → Solicitudes.ID_Solicitud, relación: 1 Solicitud - * Detalle_Solicitudes
- Detalle_Solicitudes.ID_Material → Materiales.ID_Material, relación: * Materiales - * Detalle_Solicitudes
- Detalle_Solicitudes.ID_Maquina → Maquinas.ID_Maquina, relación: * Maquinas - * Detalle_Solicitudes
### 8. Autorizaciones - Solicitudes, Socios Gerentes:
- Autorizaciones.ID_Solicitud → Solicitudes.ID_Solicitud, relación: 1 Autorización - 1 Solicitud
- Autorizaciones.ID_Socio_Gerente → Socios_Gerentes.ID_Socio_Gerente, relación: 1 Socio_Gerente - * Autorizaciones
### 9. Movimientos - Empleados, Autorizaciones:
- Movimientos.ID_Empleado → Empleados.ID_Empleado, relación: 1 Empleado - * Movimientos
- Movimientos.ID_Autorizacion → Autorizaciones.ID_Autorizacion, relación: 1 Autorización - * Movimientos
### 10. Detalle_Movimientos - Movimientos, Centros, Materiales, Máquinas:
- Detalle_Movimientos.ID_Movimiento → Movimientos.ID_Movimiento, relación: 1 Movimiento - * Detalle_Movimientos
- Detalle_Movimientos.ID_Almacen_Origen → Centros.ID_Centro, relación: 1 Centro origen - * Detalle_Movimientos
- Detalle_Movimientos.ID_Almacen_Destino → Centros.ID_Centro, relación: 1 Centro destino - * Detalle_Movimientos
- Detalle_Movimientos.ID_Material → Materiales.ID_Material, relación: * Materiales - * Detalle_Movimientos
- Detalle_Movimientos.ID_Maquina → Maquinas.ID_Maquina, relación: * Maquinas - * Detalle_Movimientos
### 11. Pedidos_Compras - Solicitudes, Empleados:
- Pedidos_Compras.ID_Solicitud → Solicitudes.ID_Solicitud, relación: 1 Solicitud - * Pedidos_Compras
- Pedidos_Compras.ID_Empleado_Compras → Empleados.ID_Empleado, relación: 1 Empleado - * Pedidos_Compras
### 12. Detalle_Pedidos_Compras - Pedidos_Compras, Materiales:
- Detalle_Pedidos_Compras.ID_Pedido → Pedidos_Compras.ID_Pedido, relación: 1 Pedido_Compras - * Detalles_Pedido_Compras
Detalle_Pedidos_Compras.ID_Material → Materiales.ID_Material, relación: * Materiales - * Detalle_Pedido_Compras 

# Stored Procedures, Triggers, Vistas y Funciones

# Vistas

## 1. Vista_SolicitudesPendientes

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
```sql
SELECT * FROM Vista_SolicitudesPendientes;
```

## 2. Vista_Materiales_Centro

### Descripción:
Muestra los materiales disponibles en un centro específico que está clasificado como depósito. Incluye el nombre del centro, el nombre del material y la cantidad disponible.

### Campos:

- Nombre_Centro: Nombre del centro donde están almacenados los materiales.
- Nombre_Material: Nombre del material disponible.
- Cantidad: Cantidad disponible del material en el centro.
### Uso:
Esta vista permite a los usuarios consultar rápidamente los materiales disponibles en centros clasificados como depósitos, facilitando la gestión de inventario y el seguimiento de existencias.
```sql
SELECT * FROM Vista_Materiales_Centro;
```

## 3. Vista_Maquinas_Centro

### Descripción:
Muestra las máquinas disponibles en un centro específico clasificado como depósito. Incluye el nombre del centro, el nombre de la máquina, una breve descripción y el estado de la máquina.

### Campos:

- Nombre_Centro: Nombre del centro donde están almacenadas las máquinas.
- Nombre_Maquina: Nombre de la máquina disponible.
- Descripcion: Descripción de la máquina.
- Estado: Estado actual de la máquina (por ejemplo, disponible, en reparación, etc.).
### Uso:
Esta vista es útil para consultar el inventario de máquinas en los centros de depósito, ayudando en la planificación y gestión de los recursos disponibles.
```sql
SELECT * FROM Vista_Maquinas_Centro;
```

## 4. Vista_Movimientos

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
```sql
SELECT * FROM Vista_Movimientos;
```

## 5. Vista_Solicitudes

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
```sql
SELECT * FROM Vista_Solicitudes;
```

# Funciones

## 1. Funcion_ObtenerEstadoMaquina

### Descripción:
Devuelve el estado de una máquina específica en función de su identificador.

### Parámetros:

ID_Maquina: INT — Identificador de la máquina para la que se desea obtener el estado.
### Valor Retornado:

VARCHAR(50) — Estado de la máquina.
### Ejemplo de Uso:

```sql
SELECT Funcion_ObtenerEstadoMaquina(1);
```
Este ejemplo devolverá el estado de la máquina con ID_Maquina igual a 1.

## 2. Funcion_ObtenerCantidadMaterialPorCentro

### Descripción:
Verifica y devuelve la cantidad de un material específico en todos los centros. La función utiliza un cursor para iterar sobre los centros y concatenar los resultados en una cadena de texto.

### Parámetros:

p_ID_Material: INT — Identificador del material para el cual se desea conocer la cantidad en los diferentes centros.
Valor Retornado:

TEXT — Una cadena de texto que enumera cada centro y la cantidad del material en ese centro.
### Ejemplo de Uso:

```sql
SELECT Funcion_ObtenerCantidadMaterialPorCentro(5);
```
Este ejemplo devolverá una cadena de texto con la cantidad del material con ID_Material igual a 5 en cada centro.

## 3. Funcion_ObtenerCantidadMaterialCentro

### Descripción:
Calcula y devuelve la cantidad de un material específico en un centro determinado. Si el material no está disponible en el centro, la función retorna 0.

### Parámetros:

centro_id: INT — Identificador del centro en el cual se desea verificar la cantidad del material.
material_id: INT — Identificador del material cuya cantidad se desea conocer en el centro especificado.
Valor Retornado:

INT — Cantidad del material en el centro. Retorna 0 si el material no está presente en el centro.
### Ejemplo de Uso:

```sql
SELECT Funcion_ObtenerCantidadMaterialCentro(2, 2);
```
Este ejemplo devolverá la cantidad del material con ID_Material igual a 5 en el centro con ID_Centro igual a 3.
  
# Stored Procedures

## 1. SP_AprobarORechazarSolicitud

### Descripción:
Aprueba o rechaza una solicitud de materiales o máquinas. Actualiza el estado en las tablas `Autorizaciones` y `Solicitudes`.

### Parámetros:
- `p_ID_Solicitud`: `INT` — Identificador de la solicitud que se desea aprobar o rechazar.
- `p_ID_Socio_Gerente`: `INT` — Identificador del socio gerente que está realizando la acción.
- `p_Accion`: `VARCHAR(10)` — Acción a realizar. Debe ser `'Aprobar'` o `'Rechazar'`.

### Valor Retornado:
Ninguno.

### Ejemplo de Uso:
```sql
CALL SP_AprobarORechazarSolicitud(1,1, 'Aprobar');
```
Este ejemplo aprueba la solicitud con ID_Solicitud igual a 1 por parte del socio gerente con ID_Socio_Gerente igual a 101.

## 2. SP_CrearSolicitud

### Descripción:
Registra una nueva solicitud de materiales o máquinas. Crea una entrada en la tabla Solicitudes y añade detalles a Detalle_Solicitudes a partir de un JSON que contiene los elementos y cantidades.

### Parámetros:

- p_Tipo: ENUM('Material', 'Maquina') — Tipo de solicitud. Puede ser 'Material' o 'Maquina'.
- p_ID_Cliente: INT — Identificador del cliente que realiza la solicitud.
- p_ID_Empleado: INT — Identificador del empleado que realiza la solicitud.
- p_ID_Centro: INT — Identificador del centro donde se requiere el material o máquina.
- p_DetallesSolicitud: JSON — JSON que contiene los detalles de la solicitud, incluyendo IDs de materiales o máquinas y sus cantidades.
### Valor Retornado:
Ninguno.

### Ejemplo de Uso:

```sql
CALL SP_CrearSolicitud('Material', 1, 3, 3, '[{"ID_Item": 5, "Cantidad": 10}]');
```
Este ejemplo crea una solicitud de materiales para el cliente con ID_Cliente igual a 1, el empleado con ID_Empleado igual a 202, en el centro con ID_Centro igual a 303, solicitando 10 unidades del material con ID_Item igual a 5.

## 3. SP_RegistrarSalida

### Descripción:
Registra la salida de materiales o máquinas de un centro. Crea un registro en la tabla Movimientos y actualiza la tabla correspondiente (Almacenes_Materiales o Almacenes_Maquinas).

### Parámetros:

p_Tipo: ENUM('Material', 'Maquina') — Tipo de ítem. Puede ser 'Material' o 'Maquina'.
p_ID_Centro: INT — Identificador del centro del que se realiza la salida.
p_ID_Item: INT — Identificador del material o máquina que se está retirando.
p_Cantidad: INT — Cantidad del material a retirar. Ignorado para máquinas.
p_ID_Empleado: INT — Identificador del empleado que realiza la salida.
### Valor Retornado:
Ninguno.

### Ejemplo de Uso:

```sql
CALL SP_RegistrarSalida('Material', 3, 2, 10, 8);
```
Este ejemplo registra la salida de 10 unidades del material con ID_Material igual a 5 del centro con ID_Centro igual a 303, realizada por el empleado con ID_Empleado igual a 202.

## 4. SP_RegistrarIngreso

### Descripción:
Registra el ingreso de materiales o máquinas a un centro. Crea un registro en la tabla Movimientos y actualiza o inserta en la tabla correspondiente (Almacenes_Materiales o Almacenes_Maquinas).

### Parámetros:

p_Tipo: ENUM('Material', 'Maquina') — Tipo de ítem. Puede ser 'Material' o 'Maquina'.
p_ID_Centro: INT — Identificador del centro al que se ingresa el material o máquina.
p_ID_Item: INT — Identificador del material o máquina que se está ingresando.
p_Cantidad: INT — Cantidad del material a ingresar. Ignorado para máquinas.
p_ID_Empleado: INT — Identificador del empleado que realiza el ingreso.
Valor Retornado:
Ninguno.

### Ejemplo de Uso:

```sql
CALL SP_RegistrarIngreso('Material', 3, 5,1, 2);
```
## 5. SP_RealizarMovimiento

### Propósito
El procedimiento SP_RealizarMovimiento se utiliza para registrar un movimiento de transferencia de materiales y máquinas entre centros, basado en una solicitud previamente aprobada. Este procedimiento permite especificar los materiales y máquinas que se desean mover, así como las cantidades exactas de cada uno.

### Parámetros
**p_ID_Solicitud (INT):**

- Descripción: El identificador único de la solicitud que se está procesando.
- Requisitos: Debe existir en la tabla Solicitudes y estar en estado "Aprobada".
**p_ID_Empleado (INT):**

- Descripción: El identificador del empleado que está registrando el movimiento.
- Requisitos: Debe existir en la tabla Empleados.
**p_ID_Centro_Origen (INT):**

- Descripción: El identificador del centro desde el cual se realizará el movimiento de materiales y máquinas.
- Requisitos: Debe existir en la tabla Centros.
**p_Materiales (JSON):**

- Descripción: Un JSON que contiene los identificadores de los materiales y las cantidades a mover.
- Formato:
json
```sql
    {"ID_Material": INT, "Cantidad": INT},
    ...
```

- Requisitos: Los ID_Material deben existir en el sistema y Cantidad debe ser un número positivo.
**p_Maquinas (JSON):**

- Descripción: Un JSON que contiene los identificadores de las máquinas que se desean mover.
- Formato:
json

```sql
    {"ID_Maquina": INT, "Cantidad": INT=1},
    ...
```
- Requisitos: Los ID_Maquina deben existir en el sistema.

### Funcionamiento
1. **Verificación de la Solicitud:**

Se verifica que la solicitud esté en estado "Aprobada". Si no lo está, el procedimiento lanza una excepción con el mensaje "La solicitud no está aprobada".
2. **Registro del Movimiento:**

Se inserta un nuevo registro en la tabla Movimientos para documentar la transferencia.
3. **Procesamiento de Materiales:**

El procedimiento itera sobre el JSON p_Materiales, registrando cada material y cantidad en Detalle_Movimientos.
Se deduce la cantidad especificada de cada material en el centro de origen.
4. **Procesamiento de Máquinas:**

Similar al procesamiento de materiales, se registran las máquinas especificadas en p_Maquinas en Detalle_Movimientos.
Las máquinas se eliminan del centro de origen y se registran en el centro de destino.

### Excepciones
El procedimiento lanza una excepción si la solicitud no está aprobada.
Si se proporcionan datos inválidos o inconsistentes, el procedimiento puede fallar y registrar el error correspondiente.

### Ejemplo de Uso
```sql
    CALL SP_RealizarMovimiento(
    1,                -- ID de la solicitud aprobada
    5,                  -- ID del empleado que registra el movimiento
    1,                  -- ID del centro de origen
    '[{"ID_Material": 1, "Cantidad": 50}, {"ID_Material": 2, "Cantidad": 20}]', -- Materiales a mover
    '[{"ID_Maquina": 3}, {"ID_Maquina": 4}]' -- Máquinas a mover
    );
```

Este procedimiento debe ejecutarse con los permisos adecuados para modificar las tablas Movimientos, Detalle_Movimientos, Almacenes_Materiales, y Almacenes_Maquinas.

## 6. SP_GenerarPedidoCompras

### Propósito
El procedimiento SP_GenerarPedidoCompras se utiliza para generar un pedido de compras basado en una solicitud de materiales aprobada. Este procedimiento asegura que se compre solo la cantidad de materiales que no está disponible en los centros clasificados como depósitos.

### Parámetros

**ID_Solicitud (INT)**:
  - Descripción: El identificador único de la solicitud aprobada que se está procesando.
  - Requisitos: La solicitud debe estar en estado "Aprobada".

**ID_Empleado_Compras (INT)**:
  - Descripción: El identificador del empleado responsable de realizar el pedido de compras.
  - Requisitos: Debe existir en la tabla `Empleados`.

### Funcionamiento

1. **Verificación de la Solicitud**:
   - Se verifica que la solicitud esté en estado "Aprobada". Si no lo está, el procedimiento lanza una excepción con el mensaje "La solicitud no está aprobada".

2. **Registro del Pedido de Compras**:
   - Se inserta un nuevo registro en la tabla `Pedidos_Compras` con el `ID_Solicitud`, la fecha actual, y el `ID_Empleado_Compras`.

3. **Cálculo de Materiales Faltantes**:
   - Se calcula la cantidad de materiales faltantes para cada material solicitado en función del stock disponible en centros clasificados como "Depósito".
   - Solo se incluye en el pedido de compras la cantidad faltante, es decir, la diferencia entre la cantidad solicitada y la cantidad disponible en depósitos.

4. **Inserción de Detalles del Pedido de Compras**:
   - Se insertan los detalles del pedido de compras en la tabla `Detalle_Pedidos_Compras`, especificando el material y la cantidad faltante para cada material que no esté completamente disponible en los depósitos.

### Excepciones
- El procedimiento lanza una excepción si la solicitud no está aprobada.
- Si se proporcionan datos inválidos o inconsistentes, el procedimiento puede fallar y registrar el error correspondiente.

### Ejemplo de Uso

```sql
CALL SP_GenerarPedidoCompras(
    10,    -- ID de la solicitud aprobada
    3       -- ID del empleado de compras
);
```
Este procedimiento es crucial para gestionar eficientemente los pedidos de materiales, asegurando que solo se compren materiales que realmente se necesitan y no están disponibles en los depósitos.

# Triggers en la Base de Datos

## 1. Trigger_ValidarEstadoSolicitud

### Descripción
Este trigger se activa antes de insertar un nuevo registro en la tabla `Autorizaciones` y valida que el estado de la solicitud correspondiente sea 'Pendiente'.

### Propósito
Garantizar que solo se puedan autorizar solicitudes que estén en estado 'Pendiente'.

## 2. Trigger_ActualizarEstadoSolicitudAprobada

### Descripción
Este trigger se activa después de insertar un registro en Autorizaciones y actualiza el estado de la solicitud a 'Aprobada' si la autorización fue aprobada.

### Propósito
Automatizar la actualización del estado de las solicitudes cuando se aprueban las autorizaciones.

## 3. Trigger_VerificarMovimientoMaquinas

### Descripción
Este trigger se activa antes de insertar un registro en Almacenes_Maquinas y verifica la disponibilidad de stock para movimientos de salida o transferencia de máquinas.

### Propósito
Asegurar que las máquinas solo se transfieran o salgan si hay suficiente stock disponible y evitar duplicación de máquinas en distintos centros.

## 4. Trigger_VerificarIngresoMaquinas

### Descripción
Este trigger se activa antes de insertar un registro en Almacenes_Maquinas y asegura que una máquina no sea registrada en más de un centro.

### Propósito
Evitar duplicidad de registros de máquinas en distintos centros.

## 5. Trigger_VerificarSalidaTransferenciaMaquinas

### Descripción
Este trigger se activa antes de insertar un registro en Detalle_Movimientos para verificar que haya suficiente stock de máquinas en el centro de origen antes de una salida o transferencia.

### Propósito
Asegurar que no se intenten salidas o transferencias con stock insuficiente.

## 6. Trigger_VerificarMovimientoMateriales
### Descripción
Este trigger se activa antes de insertar un registro en Almacenes_Materiales para verificar la disponibilidad de stock para movimientos de salida o transferencia de materiales.

### Propósito
Garantizar que los movimientos de salida o transferencia de materiales se realicen solo si hay suficiente stock disponible.

## 7. Trigger_VerificarDetalleMovimientoMateriales

### Descripción
Este trigger se activa antes de insertar un registro en Detalle_Movimientos para verificar que haya suficiente stock de materiales en el centro de origen antes de una salida o transferencia.

### Propósito
Asegurar que no se intenten salidas o transferencias de materiales con stock insuficiente o inexistente.
