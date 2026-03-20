# Actividad: Estimación Ágil del Proyecto MexiPartes

Esta actividad aplica la técnica de **Priority Poker / Story Points** a las funcionalidades clave de la plataforma MexiPartes, siguiendo el procedimiento de estimación relativa.

## 1. Definición de Historias de Usuario (Backlog Inicial)

Se han identificado 10 historias clave para el MVP (Producto Mínimo Viable), priorizando el flujo de compra y la experiencia del usuario automotriz.

| ID | Historia de Usuario | Descripción (Como... Quiero... Para...) |
|---|---|---|
| **HU-01** | Registro de Usuario | Como nuevo usuario, quiero crear una cuenta con mi correo para guardar mis datos de envío y vehículos. |
| **HU-02** | Inicio de Sesión | Como usuario registrado, quiero ingresar con mis credenciales para acceder a mi perfil personal. |
| **HU-03** | Mi Garage (Agregar Vehículo) | Como conductor, quiero registrar mi vehículo (año, marca, modelo) para que la app filtre las piezas compatibles. |
| **HU-04** | Búsqueda por Texto | Como cliente, quiero buscar piezas por nombre o número de parte para encontrar rápidamente lo que necesito. |
| **HU-05** | Filtro de Compatibilidad | Como cliente, quiero ver automáticamente si una pieza le queda a mi auto guardado para evitar errores de compra. |
| **HU-06** | Detalle de Producto | Como comprador, quiero ver fotos, descripción y especificaciones técnicas de la pieza para asegurar mi decisión. |
| **HU-07** | Carrito de Compras | Como comprador, quiero agregar múltiples productos y ver el total calculado para preparar mi pedido. |
| **HU-08** | Procesar Pago (Checkout) | Como comprador, quiero pagar con tarjeta de crédito/débito de forma segura para completar la transacción. |
| **HU-09** | Historial de Pedidos | Como cliente, quiero ver mis compras pasadas y su estatus para dar seguimiento a mis refacciones. |
| **HU-10** | Recuperar Contraseña | Como usuario, quiero poder restablecer mi clave a través de mi correo si la olvido. |

---

## 2. Historia Base (Referencia)

Para nuestra estimación relativa, seleccionamos una historia de complejidad media y bien entendida:

*   **Historia Seleccionada:** HU-02 Inicio de Sesión
*   **Puntos Asignados:** **3 Puntos**
*   **Justificación:** Es una historia estándar que el equip conoce. Requiere:
    *   Interfaz de usuario (Pantalla Login).
    *   Validaciones de formato (Frontend).
    *   Comunicación con API/Backend.
    *   Validación de seguridad (Hash de contraseña) y respuesta (Token).
    *   **No** tiene lógica de negocio compleja ni incertidumbre alta.

Esta será nuestra "regla" de medición: **3 Puntos = Esfuerzo de Login.**

---

## 3. Estimación (Escala Fibonacci)

Comparamos cada historia contra el "Inicio de Sesión" (3 pts).

| ID | Historia | Estimación (Puntos) | Comparativa / Razón |
|---|---|---|---|
| HU-06 | Detalle de Producto | **1** | Más simple. Solo es consultar y mostrar datos (Lectura). Sin formularios complejos. |
| HU-04 | Búsqueda por Texto | **2** | Ligeramente más simple. Es una consulta a base de datos estándar. |
| HU-10 | Recuperar Contraseña | **2** | Simple. Menos validaciones que el registro o login completo. |
| **HU-02** | **Inicio de Sesión** | **3** | **(REFERENCIA)** |
| HU-01 | Registro de Usuario | **3** | Similar. Mismos campos, validaciones y complejidad que el Login. |
| HU-03 | Mi Garage (CRUD) | **3** | Similar. Muestra formularios y guarda datos. (Asumiendo que la lista de autos ya existe). |
| HU-09 | Historial de Pedidos | **3** | Media. Consulta relacional (Usuario -> Pedidos -> Detalle), solo lectura pero con uniones de datos. |
| HU-07 | Carrito de Compras | **5** | Compleja. Requiere manejo de estado local persistente, cálculos matemáticos (IVA, totales) y actualización en tiempo real. |
| HU-05 | Filtro de Compatibilidad | **8** | Muy Compleja. Lógica de negocio difícil. Cruzar specs de pieza vs specs de auto. Riesgo de inconsistencia de datos. |
| HU-08 | Procesar Pago | **13** | Extremadamente Compleja. Integración con API externa (Stripe/Paypal), manejo de seguridad crítica, tokens, errores de banco. |

---

## 4. Justificación de las 3 Historias con Mayor Puntaje

### 1. HU-08 Procesar Pago (Checkout) - 13 Puntos
**Factores:** Alto Riesgo + Dependencias Externas + Alta Complejidad.
*   **Dependencia:** Dependemos totalmente de la documentación y estabilidad de la pasarela de pagos (terceros).
*   **Riesgo:** Si falla, no hay venta. Si hay un error de seguridad, la reputación del proyecto se destruye.
*   **Esfuerzo:** Manejar todos los casos de error (tarjeta rechazada, sin fondos, fraude, timeout) consume más tiempo que el "camino feliz".

### 2. HU-05 Filtro de Compatibilidad - 8 Puntos
**Factores:** Alta Complejidad Lógica + Incertidumbre de Datos.
*   **Lógica:** No es un filtro simple (como filtrar por color). Requiere verificar rangos de años (ej. "compatible con Jetta 2010-2015") y variantes de motor.
*   **Incertidumbre:** ¿Tenemos la base de datos de compatibilidades limpia? Si los datos están sucios, la lógica fallará. Esa limpieza o normalización inicial eleva el esfuerzo.

### 3. HU-07 Carrito de Compras - 5 Puntos
**Factores:** Esfuerzo Técnico (Manejo de Estado).
*   **Complejidad:** A diferencia del Login (stateless), el carrito debe "recordar" cosas mientras navegas. Si cierras la app y vuelves, debe estar ahí. Sincronizar el carrito local con la base de datos (si te logueas después de agregar items) añade lógica extra que no tienen las historias de 3 puntos.

---

## 5. Reflexión del Equipo (Simulación)

### ¿Dónde hubo más discusión?
La mayor discusión se dio en **HU-03 (Mi Garage)**.
*   Un desarrollador votó **8 puntos** porque pensó que teníamos que *crear* la base de datos de todos los autos del mundo (Marcas/Modelos/Años) desde cero.
*   El Product Owner aclaró que **ya tenemos un catálogo cargado** (CSV) y solo se trata de seleccionarlos.
*   Tras aclarar el alcance (solo seleccionar y guardar), la estimación bajó consensuadamente a **3 puntos**.

### ¿Qué supuestos influyeron?
*   En **HU-08 (Pagos)**, asumimos que usaremos una librería oficial (SDK) bien documentada. Si tuviéramos que implementar la conexión "a mano" con el banco, sería de **21+ puntos** (imposible para un sprint).
*   En **HU-05 (Compatibilidad)**, asumimos que la base de datos de piezas ya tiene el campo "vehículos compatibles". Si tuviéramos que llenar ese campo manualmente nosotros, la historia no se podría estimar aún.

### Conclusión de Planeación
Con una velocidad estimada de ~20 puntos por Sprint:
*   **Sprint 1:** Login (3), Registro (3), Garage (3), Búsqueda (2), Detalle (1), Recuperar (2), Historial (3). **Total: 17 Puntos.** (Muchas historias pequeñas).
*   **Sprint 2:** Filtro Compatibilidad (8) + Carrito (5). **Total: 13 Puntos.** (Pocas historias complejas, dejando espacio para imprevistos).
*   **Sprint 3:** Procesar Pago (13). **Total: 13 Puntos.** (Enfoque total en una funcionalidad crítica).
