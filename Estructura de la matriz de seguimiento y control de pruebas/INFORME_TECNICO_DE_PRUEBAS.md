# Informe Técnico de Pruebas de Desarrollo de Software

**Proyecto:** MexiPartes  
**Documento:** Informe Técnico de Resultados de Pruebas  
**Versión:** 1.0  
**Fecha:** 13 de Marzo 2026  
**Responsable:** Equipo de Pruebas y Aseguramiento de Calidad (QA)  

---

## 01. Información General: Objetivo del Informe

El objetivo de este informe es documentar los resultados obtenidos durante la ejecución de las pruebas al sistema y aplicación móvil de **MexiPartes**, validando sus funcionalidades mediante enfoques de caja negra, blanca y gris, así como evaluar el cumplimiento de requisitos funcionales, no funcionales e identificar hallazgos críticos previo a su liberación.

---

## 02. Alcance de las Pruebas

Se evaluaron los siguientes componentes y módulos funcionales críticos de la plataforma MexiPartes:
*   Módulo de Autenticación (Registro, Inicio de sesión, Recuperación de cuenta).
*   Catálogo y Motor de Búsqueda (Filtro de piezas por compatibilidad en "Mi Garage").
*   Carrito de Compras y Lógica de Negocio (Cálculo de subtotales).
*   Proceso de Compra / Checkout (Pasarela de Pago e Integración).

**Tipo de pruebas ejecutadas:**
*   Pruebas Unitarias, Integración, Sistema, Regresión, Humo y Sanidad.
*   Pruebas No Funcionales (Rendimiento, Usabilidad).
*   Evaluaciones de Caja Negra, Blanca y Gris (Focalizadas en el flujo de Checkout).

---

## 03. Entorno de Pruebas

Las pruebas fueron ejecutadas simulando condiciones reales de operación de la aplicación móvil y la comunicación con el Backend:
*   **Aplicación:** Aplicación Móvil Híbrida (Flutter - Dart).
*   **Hardware / Sistema Operativo:** Entornos de simulación iOS/Android (Smartphones y adaptación a Tablet).
*   **Conexiones:** Simulación de redes lentas (4G) y sin conexión.
*   **Servicios Externos / Backend:** `ApiService` de MexiPartes y comunicación de Base de Datos / Sistema de Stock.
*   **Almacenamiento Local:** Integración con `SharedPreferences`.

---

## 04. Resumen de ejecución y resultados

De acuerdo con la Matriz de Pruebas Ejecutadas:
*   **Total de Pruebas Registradas en Matriz de Seguimiento:** 14
*   **Aprobadas:** 14 (Respecto al flujo feliz documentado)
*   **Hallazgos paralelos en evaluación rigurosa (Caja Negra, Blanca, Gris):** 5 defectos (registrados en sección 07).

---

## 05. Casos de Prueba Ejecutados

Lista representativa de los flujos validados:

| ID | Nivel / Tipo | Caso de Prueba (Descripción) |
| :--- | :--- | :--- |
| PU-01 | Unitaria / Funcional | Cálculo de subtotal en carrito. |
| PI-01 | Integración / Funcional | Comunicación de Autenticación (`AuthProvider` a `ApiService`). |
| PS-01 | Sistema / Funcional | Flujo Completo de Compra (Login, Carrito, Checkout, Pago). |
| PA-01 | Aceptación / Funcional | Filtro de piezas compatibles según modelo en el Garage. |
| PF-01/03 | Sistema / Funcional | Inicio de Sesión y Registro con datos válidos / inválidos. |
| PNF-01 | Sistema / No Funcional | Rendimiento de conexión API en autenticación (Tiempo de Respuesta). |

---

## 06. Resultados de las Pruebas Ejecutadas

| ID | Resultado Esperado | Resultado Obtenido | Estado |
| :--- | :--- | :--- | :--- |
| PU-01 | Subtotal calculado correctamente y devuelto por el modelo. | Suma y cálculos exactos. | 🟢 Aprobado |
| PI-01 | Token recibido; estado de proveedor actualizado tras Login. | Recepción del Token HTTP / Estado Actualizado. | 🟢 Aprobado |
| PS-01 | Orden creada en la base de datos con historial de pedido. | Orden ID #1024 generada. | 🟢 Aprobado |
| PA-01 | Sólo se ven piezas que hagan *match* con el auto activo. | Muestra solo piezas compatibles. | 🟢 Aprobado |

---

## 07. Registro de Defectos

A raíz de la evaluación a nivel de arquitectura y lógica profunda, se detectaron los siguientes errores (Bugs/Mejoras):

| ID Error | Descripción del Defecto | Severidad | Estado |
| :--- | :--- | :--- | :--- |
| **BUG-01** | **(Caja Negra)** El sistema acepta cantidades negativas en el carrito de compras, restando al total final de la compra. | Crítica | Abierto |
| **BUG-02** | **(Caja Blanca)** Condición de "Carrera" (*Race Condition*) en el PaymentController. Pagos simultáneos a un mismo producto dejan el inventario en negativo al no existir bloqueo en la Base de Datos. | Crítica | Abierto |
| **BUG-03** | **(Caja Gris - Seguridad)** Inyección de Precios: El precio se envía desde el cliente al servidor sin verificación por este último en el Checkout. | Crítica | Abierto |
| **DEF-04** | **(UX)** Al intentar pagar sin conexión a internet, el spinner de carga se queda en un ciclo infinito sin mensaje claro. | Media | Abierto |
| **DEF-05** | **(Integración)** Falta de "timeout" definido. Tiempos excesivos en la API de pagos pueden causar dobles cobros si el usuario reactiva el flujo. | Alta | Abierto |

---

## 08. Análisis de Resultados de Métricas de Calidad

Los resultados cualitativos y cuantitativos muestran lo siguiente basado en el alcance del Módulo de Autenticación:
1.  **Complejidad Ciclomática (Mantenibilidad):** Nivel 4 (Baja Complejidad). Excelente, los métodos son muy fáciles de mantener y carecen de anidaciones perjudiciales.
2.  **Rendimiento:** Tiempos de UI inmediatos (< 1 seg), aprovechando el uso adecuado de concurrencia y retroalimentación asíncrona constante (Loading Spinners).
3.  **Confiabilidad:** Alta (0 *crashes* durante la suite). El control de excepciones globales y el `try-catch` demuestran resiliencia.
4.  **Usabilidad:** Tasa de éxito del 90%. Diseño responsivo adecuado que facilita la navegación cross-platform.

---

## 09. Conclusiones y Recomendaciones

**Conclusión:**
El sistema e-commerce de **MexiPartes** demuestra contar con una base estructural sólida, especialmente en áreas de fluidez móvil, usabilidad y respuestas de interfaz, cumpliendo exitosamente el camino feliz de los requerimientos. Sin embargo, su **arquitectura de procesos de pago e inventario es altamente vulnerable e inconsistente.**

**Recomendaciones Inmediatas (Go/No-Go):**
1.  **NO APROBADO PARA PRODUCCIÓN** mientras existan BUG-01, BUG-02 y BUG-03.
2.  **Seguridad de Checkout:** El backend debe ser la única fuente de verdad sobre el precio del producto; eliminar dependencias del cliente (App).
3.  **Confiabilidad de Pagos:** Implementar bloqueos en bases de datos para compras simultáneas (*Race Conditions*) y añadir aserciones a números positivos en las unidades del carrito.
4.  **Sistemas de Monitoreo:** Instalar de manera integral integraciones pasivas como *Sentry* o *Firebase Crashlytics* para atrapar errores futuros.
5.  **Cifrado:** Cambiar el almacenamiento `SharedPreferences` por alternativas altamente cifradas como `Flutter Secure Storage` para la manipulación de credenciales de usuario.
