# base-datos-produccion
# Base de Datos: Control de Producción y Paros

Este repositorio contiene la arquitectura y el código SQL para migrar un sistema de registro de producción (previamente manejado en Excel) hacia un modelo de base de datos relacional normalizado.

##  Justificación del Modelo

El archivo Excel original presentaba severos problemas de diseño:
1. **Violación de la 1FN:** Los códigos de paro se registraban como columnas repetitivas, impidiendo consultas dinámicas.
2. **Redundancia de datos:** Nombres de operarios, máquinas y referencias se escribían manualmente, generando errores e inconsistencias.

**Solución Implementada:**
* Se rediseñó el esquema a la **Tercera Forma Normal (3FN)**.
* Se separaron las entidades maestras (`Maquina`, `Referencia`, `Empleado`, `Turno`) de la tabla transaccional (`Registro_Produccion`).
* Se unificó el personal en la tabla `Empleado` gestionada por un `id_rol`.
* Se creó la tabla `Detalle_Paro` para registrar cada evento de tiempo muerto como una fila independiente.

##  Instrucciones de Despliegue

Para implementar este modelo en PostgreSQL:
1. Crea una base de datos en blanco.
2. Ejecuta el script `scripts/01_Esquema.sql` para generar las tablas, vistas e insertar los datos de prueba.

* Tip: Puedes probar este código en vivo sin instalar nada usando [DB Fiddle](https://www.db-fiddle.com/). Asegúrate de seleccionar PostgreSQL.*

##  Vistas Incluidas para Análisis
El script genera automáticamente vistas listas para herramientas de BI:
* `vw_productividad_mensual`: Calcula la eficiencia real vs esperada por máquina y mes.
* `vw_participacion_paros`: Muestra el % de tiempo perdido por cada tipo de paro.
##  Diagrama Entidad-Relación (ERD)

```mermaid
erDiagram
    Rol ||--o{ Empleado : "agrupa"
    Empleado ||--o{ Registro_Produccion : "registra / opera"
    Maquina ||--o{ Registro_Produccion : "produce en"
    Referencia ||--o{ Registro_Produccion : "se empaca"
    Turno ||--o{ Registro_Produccion : "ocurre en"
    Codigo_Paro ||--o{ Subcodigo_Paro : "tiene"
    Registro_Produccion ||--o{ Detalle_Paro : "registra"
    Codigo_Paro ||--o{ Detalle_Paro : "causa"
    Subcodigo_Paro ||--o{ Detalle_Paro : "detalla"
> # **Evidencia del Sistema Previo:**
> El archivo `Control_Produccion.xlsx` (disponible en la raíz de este repositorio) contiene el dataset original previo a la migración. Se incluye como evidencia técnica del estado inicial de los datos, ilustrando las violaciones de 1FN (columnas repetitivas de paros) y la redundancia que motivaron este rediseño a 3FN.
