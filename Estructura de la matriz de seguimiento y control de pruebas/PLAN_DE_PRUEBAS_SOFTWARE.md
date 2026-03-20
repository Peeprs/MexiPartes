# Evaluación y Plan de Pruebas de Software - MexiPartes

Este documento aplica los principios de pruebas de software al proyecto MexiPartes, abarcando desde la comprensión del sistema hasta el diseño de casos de prueba funcionales y no funcionales.

## 🟢 Parte 1: Comprensión del sistema

El sistema **MexiPartes** es una plataforma de e-commerce móvil especializada en la venta de autopartes, diseñada para conectar a dueños de vehículos y mecánicos con refacciones compatibles.

### 1. Funciones Principales
*   **Gestión de Vehículos (Mi Garage):** Registrar marca, modelo y año para filtrar productos.
*   **Búsqueda y Catálogo:** Buscar piezas por nombre/categoría/número de parte.
*   **Filtrado de Compatibilidad:** Mostrar solo piezas que le quedan al auto seleccionado.
*   **Proceso de Compra (Checkout):** Gestión del carrito, dirección de envío y pago.
*   **Gestión de Cuenta:** Registro, login, historial de pedidos.

### 2. Posibles Puntos de Falla
*   **Compatibilidad Incorrecta:** Que el sistema diga que una pieza "Le queda" a un auto cuando en realidad no le queda (falso positivo).
*   **Sincronización de Stock:** Comprar una pieza que ya no está disponible en inventario.
*   **Falla en Pasarela de Pago:** Error al procesar la tarjeta y que el pedido quede en el limbo (cobrado pero no generado).
*   **Rendimiento en Búsqueda:** Que la búsqueda tarde demasiado si la base de datos de productos crece mucho.

---

## 🟢 Parte 2: Identificación de tipos de prueba

| Requisito | Tipo de prueba | Justificación |
| :--- | :--- | :--- |
| **Filtro de Compatibilidad de Piezas** | Funcional (Lógica de Negocio) | Verifica que el algoritmo cruce correctamente el ID del auto con el ID de compatibilidad de la pieza. |
| **Tiempo de carga del catálogo** | No funcional (Rendimiento) | Evalúa si la app sigue siendo rápida con miles de productos cargados. |
| **Cifrado de datos de tarjeta** | No funcional (Seguridad) | Asegura que la información sensible no sea legible por terceros. |
| **Agregar al Carrito** | Funcional | Verifica la acción del usuario de sumar un ítem a su lista de compra. |
| **Uso en modo sin conexión** | No funcional (Fiabilidad) | Evalúa cómo se comporta la app si se pierde el internet a mitad de uso. |

---

## 🟢 Parte 3: Diseño de casos de prueba funcionales

A continuación, se presentan 5 casos de prueba críticos para el flujo principal de MexiPartes.

| ID | Caso de prueba | Entrada (Datos) | Resultado esperado | Tipo |
| :--- | :--- | :--- | :--- | :--- |
| **CP-01** | Búsqueda de pieza existente | Texto: "Bujía NGK Jetta 2015" | Muestra lista con bujías compatibles; no muestra alternadores o llantas. | Funcional |
| **CP-02** | Filtrado por Garage vacío | Garage: "Sin auto seleccionado" | Muestra advertencia: "Selecciona un auto para verificar compatibilidad" o muestra catálogo general. | Funcional |
| **CP-03** | Agregar producto sin stock | Producto: "Batería LTH (Stock: 0)" | Botón "Agregar" deshabilitado o mensaje "Producto agotado". | Funcional |
| **CP-04** | Pago con tarjeta inválida | Tarjeta: "4000 0000 0000 (Vencida)" | Mensaje de error: "Tarjeta rechazada" y no se genera el pedido. | Funcional |
| **CP-05** | Cálculo de Total en Carrito | Carrito: 2 Amortiguadores ($500 c/u) | Total mostrado: $1,000. (Verificar también sumas con decimales). | Funcional |

---

## 🟢 Parte 4: Identificación de pruebas no funcionales

### ¿Qué aspectos no funcionales deberían probarse?

1.  **Rendimiento (Performance):** El tiempo que tarda el filtro de compatibilidad en responder.
    *   *Importancia:* Los usuarios compran en el momento; si la app tarda 10 segundos en decir si una pieza le queda a su auto, abandonarán la compra.

2.  **Usabilidad (UX):** Facilidad para agregar un vehículo al garage.
    *   *Importancia:* Si el usuario no puede registrar su auto fácilmente, la función principal de "compatibilidad garantizada" no se usará.

3.  **Seguridad (Security):** Protección de los datos personales (dirección) y financieros.
    *   *Importancia:* Una filtración de datos destruiría la confianza en la marca MexiPartes.

4.  **Compatibilidad de Dispositivos:** Visualización correcta en pantallas pequeñas (iPhone SE) y grandes (Pro Max).
    *   *Importancia:* La app debe verse bien no solo en el teléfono del desarrollador.

---

## 🟢 Parte 5: Reflexión final

### 1. ¿Por qué son importantes las pruebas de software?
Porque reducen el riesgo de entregar un producto defectuoso. En MexiPartes, un error de software puede traducirse en una pieza mecánica incorrecta entregada a un cliente, lo cual implica costos de devolución, pérdida de dinero y clientes molestos. Las pruebas aseguran calidad y confianza.

### 2. ¿Qué errores detectaste que no habías considerado antes?
No había considerado el caso **CP-02 (Navegar sin auto seleccionado)**. Asumía que el usuario siempre tendría un auto en su garage, pero un usuario nuevo no lo tiene. El sistema debe manejar esa "ausencia de contexto" sin fallar y guiando al usuario para que lo registre.

### 3. ¿Qué tipo de pruebas te parecieron más relevantes?
Las **Funcionales de Lógica de Negocio (Compatibilidad)**. Para este proyecto en específico, la característica "killer" es saber si la pieza le queda al auto. Si el login es perfecto y el pago es rápido, pero la recomendación de pieza está mal, el negocio fracasa. Por eso, probar esa lógica es lo más vital.
