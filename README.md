# Centro Logístico de Materiales y Máquinas

## Descripción del Modelo

El modelo está diseñado para gestionar el flujo de materiales y máquinas entre depósitos y obras, además de las solicitudes y autorizaciones necesarias para dichos movimientos. Los empleados, tanto de obra como de depósito y compras, juegan roles cruciales en el proceso, asegurando que los recursos sean utilizados de manera eficiente y que las solicitudes sean autorizadas correctamente.

Cada tabla en el modelo tiene una relación definida con otras tablas, estableciendo un flujo claro de datos y procesos que soporta la operación del centro logístico.

## Diagrama Entidad-Relación

El siguiente diagrama muestra el modelo de entidad-relación del sistema:

<a href="https://miro.com/app/board/uXjVK4abNrw=/" target="_blank">Diagrama ER en Miro</a>

## Tablas y Relaciones

### Materiales

- **ID_Material** (PK)
- Nombre
- Descripción
- Unidad
- ID_Proveedor (FK)

### Máquinas

- **ID_Máquina** (PK)
- Nombre
- Descripción
- Estado
- ID_Proveedor (FK)

### Proveedores

- **ID_Proveedor** (PK)
- Nombre
- Dirección
- Teléfono
- Rubro

### Clientes

- **ID_Cliente** (PK)
- Nombre
- Dirección
- Teléfono

### Depósito

- **ID_Deposito** (PK)
- ID_Material (FK)
- ID_Máquina (FK)
- Cantidad

### Empleados_Obra

- **ID_Empleado** (PK)
- Nombre
- Cargo
- Teléfono
- ID_Obra (FK, nullable)

### Empleados_Depositos

- **ID_Empleado** (PK)
- Nombre
- Cargo
- Teléfono
- ID_Deposito (FK, nullable)

### Empleados_Compras

- **ID_Empleado** (PK)
- Nombre
- Cargo
- Teléfono

### Solicitudes

- **ID_Solicitud** (PK)
- Fecha
- Tipo (Máquina o Material)
- ID_Cliente (FK, nullable)
- ID_Encargado_Obra (FK)
- ID_Encargado_Deposito (FK)
- Estado (Pendiente, Parcial, Aprobada, Rechazada)
- ID_Material (FK, nullable)
- ID_Máquina (FK, nullable)
- Cantidad
- ID_Proveedor (FK, nullable)
- ID_Obra
- ID_Deposito

### Movimientos

- **ID_Movimiento** (PK)
- Fecha
- Tipo (Entrada, Salida, Transferencia)
- ID_Deposito
- ID_Obra_Origen (FK, nullable)
- ID_Obra_Destino (FK, nullable)
- ID_Material (FK, nullable)
- ID_Máquina (FK, nullable)
- Cantidad
- ID_Empleado_Obra (FK, nullable)
- ID_Empleado_Depositos (FK, nullable)
- ID_Autorización (FK)

### Obras

- **ID_Obra** (PK)
- Nombre
- Dirección
- Estado
- ID_Material (FK, nullable)
- ID_Máquina (FK, nullable)
- Cantidad

### Autorizaciones

- **ID_Autorización** (PK)
- ID_Solicitud (FK)
- ID_Socio_Gerente (FK)
- Estado (Aprobada, Rechazada)
- Fecha

### Socios_Gerentes

- **ID_Socio_Gerente** (PK)
- Nombre
- Teléfono

### Pedidos_Compras

- **ID_Pedido** (PK)
- ID_Solicitud (FK)
- ID_Material (FK)
- Cantidad_Pendiente
- Fecha
- ID_Empleado_Compras

# Centro Logístico de Materiales y Máquinas

Este repositorio contiene el modelo de datos para la implementación de un centro logístico de materiales y máquinas. A continuación se describe el diseño del modelo entidad-relación y las cardinalidades de las relaciones.

## Descripción del Modelo

### Tablas Principales

- **Proveedores:** Información de los proveedores que suministran materiales y máquinas.
- **Materiales:** Detalles de los materiales gestionados en el centro logístico.
- **Máquinas:** Información sobre las máquinas disponibles.
- **Obras:** Datos de las obras donde se utilizan los materiales y máquinas.
- **Clientes:** Información de los clientes que solicitan materiales y máquinas.
- **Solicitudes:** Registro de solicitudes de materiales y máquinas por parte de clientes y empleados de obra.
- **Autorizaciones:** Detalles de las autorizaciones de las solicitudes, gestionadas por los socios gerentes.
- **Movimientos:** Registro de los movimientos de materiales y máquinas entre depósitos y obras.
- **Pedidos_Compras:** Detalles de los pedidos de materiales realizados al sector de compras.

### Cardinalidades de las Relaciones

1. **Proveedores - Materiales**
   - Un proveedor puede suministrar múltiples materiales.
   - Un material es suministrado por un único proveedor.
   - Cardinalidad: 1 - *

2. **Proveedores - Máquinas**
   - Un proveedor puede suministrar múltiples máquinas.
   - Una máquina es suministrada por un único proveedor.
   - Cardinalidad: 1 - *

3. **Materiales - Depósitos**
   - Un material puede estar en múltiples depósitos.
   - Un depósito puede contener múltiples materiales.
   - Cardinalidad: * - *

4. **Máquinas - Depósitos**
   - Una máquina puede estar en múltiples depósitos.
   - Un depósito puede contener múltiples máquinas.
   - Cardinalidad: *-*
     
5. **Clientes - Solicitudes**
   - Un cliente puede realizar múltiples solicitudes.
   - Una solicitud es realizada por un único cliente.
   - Cardinalidad: 1 - *

6. **Obras - Solicitudes**
   - Una obra puede tener múltiples solicitudes.
   - Una solicitud puede estar asociada a una única obra.
   - Cardinalidad: 1 - *

7. **Materiales - Solicitudes**
   - Un material puede estar en múltiples solicitudes.
   - Una solicitud puede incluir múltiples materiales.
   - Cardinalidad: * - *

8. **Máquinas - Solicitudes**
   - Una máquina puede estar en múltiples solicitudes.
   - Una solicitud puede incluir múltiples máquinas.
   - Cardinalidad: * - *

9. **Empleados_Obra - Obras**
   - Un empleado de obra puede estar asignado a múltiples obras.
   - Una obra puede tener múltiples empleados de obra asignados.
   - Cardinalidad: 1 - *
     
10. **Empleados_Depositos - Depósitos**
    - Un empleado de depósito está asignado a un único depósito.
    - Un depósito puede tener múltiples empleados de depósito asignados.
    - Cardinalidad: 1 - 1

11. **Empleados_Depositos - Solicitudes**
    - Un empleado de depósito puede gestionar múltiples solicitudes.
    - Una solicitud puede ser gestionada por un único empleado de depósito.
    - Cardinalidad: 1 - *

12. **Empleados_Obra - Solicitudes**
    - Un empleado de obra puede realizar múltiples solicitudes.
    - Una solicitud puede ser realizada por un único empleado de obra.
    - Cardinalidad: 1 - *

13. **Movimientos - Depósitos**
    - Un depósito puede tener múltiples movimientos asociados.
    - Un movimiento puede involucrar un único depósito.
    - Cardinalidad: 1 - *

14. **Movimientos - Obras (origen y destino)**
    - Una obra puede ser origen o destino de múltiples movimientos.
    - Un movimiento tiene una obra de origen y una obra de destino.
    - Cardinalidad: 1 - *

15. **Movimientos - Materiales**
    - Un material puede estar en múltiples movimientos.
    - Un movimiento puede tener múltiples materiales.
    - Cardinalidad: * - *

16. **Movimientos - Máquinas**
    - Una máquina puede estar en múltiples movimientos.
    - Un movimiento puede tener múltiples máquinas.
    - Cardinalidad: * - *

17. **Movimientos - Empleados_Obra**
    - Un empleado de obra puede gestionar múltiples movimientos.
    - Un movimiento tiene un único empleado de obra.
    - Cardinalidad: 1 - *
18. **Movimientos - Empleados_Depositos**
    - Un empleado de depósito puede gestionar múltiples movimientos.
    - Un movimiento tiene un único empleado de depósito.
    - Cardinalidad: 1 - *
19. **Movimientos - Autorizaciones**
    - Una autorización puede estar asociada a múltiples movimientos.
    - Un movimiento tiene una única autorización.
    - Cardinalidad: 1 - *

20. **Solicitudes - Pedidos_Compras**
    - Una solicitud puede generar múltiples pedidos de compras.
    - Un pedido de compras pertenece a una única solicitud.
    - Cardinalidad: 1 - *

21. **Materiales - Pedidos_Compras**
    - Un material puede estar en múltiples pedidos de compras.
    - Un pedido de compras puede contener múltiples materiales.
    - Cardinalidad: * - *

22. **Empleados_Compras - Pedidos_Compras**
    - Un empleado de compras puede gestionar múltiples pedidos de compras.
    - Un pedido de compras tiene un único empleado de compras.
    - Cardinalidad: 1 - *

23. **Socios_Gerentes - Autorizaciones**
    - Un socio gerente puede autorizar múltiples solicitudes.
    - Una autorización tiene un único socio gerente.
    - Cardinalidad: 1 - *
      
24. **Materiales - Obra**
    - Un material puede estar en varias obras.
    - Una obra puede tener muchos materiales.
    - Cardinalidad: * - *
   
25. **Máquinas - Obra**
    - Una máquina puede estar en varias obras.
    - Una obra puede tener varias máquinas.
    - Cardinalidad: * - *

26. **Proveedor - Solicitudes**
    - Un proveedor puede estar en varias solicitudes.
    - Una solicitud puede tener un solo proveedor.
    - Cardinalidad: 1 - *

27. **Solicitud - Autorizaciones**
    - Una solicitud puede tener una autorizacion.
    - Una autorizacion puede contener una solicitud.
    - Cardinalidad: 1 - 1
   
28. **Depositos - Solicitudes**
    - Un deposito puede estar en varias solicitudes.
    - Una solicitud puede tener un solo deposito.
    - Cardinalidad: 1 - *

## Funcionalidades del Sistema
### 1. Gestión de Solicitudes de Materiales y Máquinas

- **Creación de Solicitudes**: 
  - Los encargados de obra crean una `Solicitud` en el sistema, especificando el tipo (Material o Máquina) y los detalles necesarios. 
  - Los clientes también pueden solicitar materiales y máquinas, pero estas solicitudes son ingresadas al sistema por el encargado del sector correspondiente.

- **Aprobación de Solicitudes**:
  - Las solicitudes deben ser autorizadas por el encargado del sector correspondiente (`ID_Encargado_Sector`).
  - Si una solicitud no puede ser atendida completamente por el inventario existente, se marca como "Parcial" y los materiales pendientes se envían al sector de compras (`Pedidos_Compras`) para que realice el pedido al proveedor.

### 2. Gestión de Movimientos de Materiales y Máquinas

- **Movimientos de Obra a Obra**:
  - Los movimientos de materiales y máquinas entre obras se registran en la tabla `Movimientos`.

- **Devoluciones a Depósitos**:
  - Las devoluciones de materiales y máquinas a los depósitos se registran en la tabla `Obras` actualizando el stock en la obra correspondiente que también sirve como depósito.

### 3. Gestión de Inventario

- **Actualización de Inventario**:
  - La tabla `Depósito` se actualiza automáticamente con cada movimiento de entrada, salida y transferencia de materiales y máquinas.

### 4. Autorización de Movimientos por Socios Gerentes

- **Autorización de Movimientos Importantes**:
  - Los movimientos importantes deben ser autorizados por al menos un socio gerente.
  - La autorización se registra en la tabla `Autorizaciones`.

### 5. Gestión de Pedidos al Proveedor

- **Pedidos de Materiales Pendientes**:
  - Las solicitudes que no pueden ser completamente atendidas se registran en la tabla `Pedidos_Compras`, permitiendo al sector de compras realizar el pedido al proveedor para reponer el stock faltante.

## Cómo Usar el Sistema

1. **Registrar Consumo en Obra**:
   - Inserta un movimiento de salida en la tabla `Movimientos` y actualiza el stock en la tabla `Obras`.

   ```sql
   INSERT INTO Movimientos (Fecha, Tipo, ID_Obra_Origen, ID_Material, Cantidad, ID_Empleado_Obra)
   VALUES (CURRENT_DATE, 'Salida', 1, 101, 50, 5);

   UPDATE Obras
   SET Cantidad = Cantidad - 50
   WHERE ID_Obra = 1 AND ID_Material = 101;
