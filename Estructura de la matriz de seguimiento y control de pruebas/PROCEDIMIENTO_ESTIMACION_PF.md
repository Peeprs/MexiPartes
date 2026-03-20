# Procedimiento de la Estimación de Puntos de Función

El procedimiento de estimación de puntos de función es una técnica utilizada para medir el **tamaño funcional** de un sistema de software. Su objetivo es evaluar qué tan grande es un sistema o aplicación en términos de las funcionalidades que proporciona al usuario, en lugar de centrarse en líneas de código o el esfuerzo técnico.

Este procedimiento cuantifica las funcionalidades basándose en cinco componentes principales y luego aplica factores de ajuste.

---

## Componentes Principales

Para realizar la estimación se evalúan los siguientes 5 elementos:

1.  **Entradas Externas (EE):** Datos o información que ingresan al sistema desde el exterior (formularios, pantallas de entrada).
2.  **Salidas Externas (SE):** Resultados generados por el sistema hacia el exterior (informes, pantallas de salida).
3.  **Consultas Externas (CE):** Peticiones de datos al sistema que resultan en información inmediata.
4.  **Archivos Lógicos Internos (ALI):** Bases de datos o archivos gestionados dentro del sistema.
5.  **Interfaces de Archivos Externos (IAE):** Bases de datos externas que el sistema accede pero no gestiona.

## ¿Para qué sirven los Puntos de Función?

1.  **Medición Objetiva:** Miden el tamaño funcional del software independientemente del lenguaje o tecnología.
2.  **Estimación de Esfuerzo:** Sirven para estimar el esfuerzo en recursos humanos y tiempo.
3.  **Comparación:** Permiten comparar proyectos de software diferentes.
4.  **Planificación:** Facilitan la presupuestación al prever la cantidad de recursos necesarios.

---

## Procedimiento de Cálculo

El proceso se divide en los siguientes pasos:

### 1. Identificación de componentes
Clasificar las funcionalidades del software en uno de los 5 tipos (EE, SE, CE, ALI, IAE).

### 2. Asignación de Pesos
Se asigna un peso a cada componente según su complejidad (Baja, Media, Alta) utilizando tablas estándar:

| Componente | Complejidad Baja | Complejidad Media | Complejidad Alta |
| :--- | :---: | :---: | :---: |
| **Entradas Externas (EE)** | 3 | 4 | 6 |
| **Salidas Externas (SE)** | 4 | 5 | 7 |
| **Consultas Externas (CE)** | 3 | 4 | 6 |
| **Archivos Lógicos Internos (ALI)** | 7 | 10 | 15 |
| **Interfaces de Archivos Externos (IAE)** | 5 | 7 | 10 |

### 3. Cálculo de Puntos No Ajustados (PFNA)
Se multiplica la cantidad de cada elemento por su peso y se suman los resultados totales.

### 4. Ajuste de Puntos de Función
Se consideran 14 factores de ajuste (como eficiencia, rendimiento, etc.) para obtener un Factor de Ajuste (VAF) que varía entre 0.65 y 1.35.

Formula:
$$ PF_{Ajustados} = PF_{NoAjustados} \times VAF $$

### 5. Estimación del Esfuerzo
Se utilizan los puntos ajustados para determinar el esfuerzo del proyecto.

---

## Ejemplo Paso a Paso

Supongamos un sistema con las siguientes características:

*   **Entradas Externas:** 5 formularios (3 medios, 2 altos).
*   **Salidas Externas:** 2 informes (2 bajos).
*   **Consultas Externas:** 4 consultas (4 medias).
*   **Archivos Lógicos Internos:** 3 archivos (1 alto, 2 medios).
*   **Interfaces Ext:** 1 interfaz (1 baja).

**Cálculo:**

*   **EE:** `(3 * 4) + (2 * 6) = 12 + 12 = 24`
*   **SE:** `(2 * 4) = 8`
*   **CE:** `(4 * 4) = 16`
*   **ALI:** `(1 * 15) + (2 * 10) = 15 + 20 = 35`
*   **IAE:** `(1 * 5) = 5`

**Total Puntos No Ajustados:** `68`

**Ajuste:**
Si el factor de ajuste es **1.1**:
`88 * 1.1 = 96.8` (aprox **97 puntos**)

---

## Ejercicios Propuestos

### Ejercicio 1
Un sistema tiene:
*   4 Entradas Externas (2 baja, 2 alta)
*   3 Salidas Externas (3 media)
*   2 Consultas Externas (2 baja)
*   2 Archivos Lógicos Internos (2 media)
*   1 Interfaz de Archivos Externos (1 alta)

**Tareas:**
a) Calcular los puntos de función no ajustados.
b) Si el factor de ajuste es 1.2, calcular los puntos de función ajustados.

---

### Ejercicio 2
Un sistema tiene:
*   6 Entradas Externas (4 baja, 2 alta)
*   5 Salidas Externas (3 baja, 2 media)
*   3 Consultas Externas (2 media, 1 baja)
*   3 Archivos Lógicos Internos (1 baja, 2 alta)
*   2 Interfaces de Archivos Externos (2 media)

**Tareas:**
a) Determinar los puntos de función no ajustados.
b) Calcular los puntos ajustados si el factor de ajuste es 0.9.

---

### Ejercicio 3: Sistema de Inventario
Características:
*   5 Entradas Externas (3 baja, 2 media)
*   3 Salidas Externas (1 alta, 2 baja)
*   4 Consultas Externas (2 alta, 2 baja)
*   2 Archivos Lógicos Internos (2 alta)
*   2 Interfaces de Archivos Externos (2 media)

**Tareas:**
a) Calcular los puntos de función no ajustados.
b) Si el factor de ajuste es 1.05, calcular los puntos de función ajustados.

---

### Ejercicio 4: Gestión de Empleados
Características:
*   6 Entradas Externas (4 alta, 2 media)
*   5 Salidas Externas (3 baja, 2 media)
*   3 Consultas Externas (1 baja, 1 media, 1 alta)
*   4 Archivos Lógicos Internos (2 alta, 2 media)
*   1 Interfaz de Archivos Externos (1 alta)

**Tareas:**
a) Determinar los puntos de función no ajustados.
b) Calcular los puntos de función ajustados si el factor de ajuste es 0.95.

---

### Ejercicio 5: Plataforma de Comercio Electrónico
Características:
*   8 Entradas Externas (5 baja, 3 media)
*   6 Salidas Externas (4 alta, 2 baja)
*   5 Consultas Externas (5 media)
*   3 Archivos Lógicos Internos (1 alta, 2 media)
*   3 Interfaces de Archivos Externos (2 baja, 1 alta)

**Tareas:**
a) Estimar los puntos de función no ajustados.
b) Si el factor de ajuste es 1.15, calcular los puntos de función ajustados de este e-commerce.
