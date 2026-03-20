# Análisis de Puntos de Función - MexiPartes

Este documento detalla la asignación de pesos de Puntos de Función para componentes clave del sistema MexiPartes, basándose en la complejidad funcional determinada por sus características técnicas (DET y FTR/RET) según el estándar IFPUG.

## Conceptos Base

Los pesos se asignan en función del esfuerzo relativo para analizar, diseñar, desarrollar y probar cada componente.

*   **DET (Data Element Types):** Campos únicos reconocibles por el usuario (ej. Nombre, Correo, Calle).
*   **FTR (File Type Referenced):** Archivos o tablas que el proceso lee o mantiene.
*   **RET (Record Element Types):** Subgrupos lógicos dentro de un archivo.

---

## Análisis de Componentes

### 1. Registro de Nueva Dirección de Envío
**Tipo:** Entrada Externa (EE)
*Proceso que ingresa datos de ubicación al sistema para futuras entregas.*

*   **Identificación de Variables:**
    *   **DET (11 Campos):** Identificados en `AddressModel`: `id`, `name`, `lastNamePaternal`, `lastNameMaternal`, `street`, `postalCode`, `extNum`, `intNum`, `colony`, `phone`, `betweenStreets`.
    *   **FTR (1 Archivo):** Interactúa con la tabla de **Direcciones**.
*   **Complejidad:** **Baja**
    *   *Justificación:* La operación maneja pocos archivos (1) y un número moderado de campos (< 15), cayendo en el rango inferior de la matriz de complejidad.
*   **Peso Asignado:** **3 Puntos**

### 2. Registro de Nuevo Usuario
**Tipo:** Entrada Externa (EE)
*Proceso de alta de un nuevo cliente o vendedor en la plataforma.*

*   **Identificación de Variables:**
    *   **DET (8 Campos):** Identificados en `UsuarioModel`: `id`, `strNombre`, `strApellidoPaterno`, `strApellidoMaterno`, `strCorreo`, `strPassword`, `bitEsVendedor`, `bitCorreoVerificado`.
    *   **FTR (1 Archivo):** Interactúa con la tabla de **Usuarios**.
*   **Complejidad:** **Baja**
    *   *Justificación:* Es una operación CRUD estándar con una cantidad reducida de datos y afectación a una sola entidad lógica principal.
*   **Peso Asignado:** **3 Puntos**

### 3. Archivo Lógico de Direcciones (Addresses)
**Tipo:** Archivo Lógico Interno (ALI)
*Grupo de datos mantenidos internamente por el sistema.*

*   **Identificación de Variables:**
    *   **DET (11 Datos):** Corresponden a los atributos almacenados de la dirección.
    *   **RET (1 Subgrupo):** Tipo de registro único (Dirección Estándar).
*   **Complejidad:** **Baja**
    *   *Justificación:* Estructura plana (1 RET) con un número bajo de atributos (11 DETs). Según IFPUG, 1-19 DETs con 1 RET es complejidad baja.
*   **Peso Asignado:** **7 Puntos**

---

## Resumen de Puntos de Función

| Componente | Tipo | DET | FTR/RET | Complejidad | Peso |
| :--- | :---: | :---: | :---: | :---: | :---: |
| **Registrar Dirección** | EE | 11 | 1 | Baja | **3** |
| **Registrar Usuario** | EE | 8 | 1 | Baja | **3** |
| **Tabla Direcciones** | ALI | 11 | 1 | Baja | **7** |
| **TOTAL ANALIZADO** | | | | | **13** |

> **Nota:** Un mayor puntaje indica una mayor complejidad funcional, lo que se traduce en mayor esfuerzo de desarrollo y pruebas.
