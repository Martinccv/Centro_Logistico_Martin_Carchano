# Centro Logístico de Materiales y Máquinas

## Descripción del Proyecto

Este proyecto implementa un sistema de gestión para un centro logístico de materiales y máquinas. El sistema permite gestionar solicitudes, movimientos, inventarios, y autorizaciones de materiales y máquinas entre obras, depósitos y proveedores.

## Diagrama Entidad-Relación

El siguiente diagrama muestra el modelo de entidad-relación del sistema:

<a href="https://miro.com/app/live-embed/uXjVK4abNrw=/?moveToViewport=-1502,-368,1934,1560&embedId=948505516614" target="_blank">Diagrama ER en Miro</a>
<a href="https://miro.com/app/board/uXjVK4abNrw=/" target="_blank">Diagrama ER en Miro</a>

## Tablas y Relaciones

### Materiales

- **ID_Material** (PK)
- Nombre
- Descripción
- Cantidad
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
- ID_Empleado_Depositos (FK)

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
- ID_Encargado_Sector (FK)
- Estado (Pendiente, Parcial, Aprobada, Rechazada)
- ID_Material (FK, nullable)
- ID_Máquina (FK, nullable)
- ID_Proveedor (FK, nullable)

### Movimientos

- **ID_Movimiento** (PK)
- Fecha
- Tipo (Entrada, Salida, Transferencia)
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
