# Resultados de Actividad: Evaluación de Metodologías de Prueba (Caja Negra, Blanca y Gris)

Dando cumplimiento a la **"Actividad rápida"** solicitada, he procedido a evaluar una funcionalidad crítica de **MexiPartes** (el **Proceso de Checkout / Carrito**) utilizando las tres metodologías de prueba.

A continuación presento los hallazgos y errores detectados en esta simulación.

---

## ⚫ 1. Evaluación de Caja Negra (Black Box)
**Enfoque:** Probé el sistema como si fuera un usuario final, sin saber cómo está programado, centrándome en **Entradas y Salidas**.

| Pregunta del Checklist | Prueba Realizada | Resultado / Error Detectado |
| :--- | :--- | :--- |
| **¿El sistema maneja entradas inválidas?** | Intenté agregar una cantidad negativa de productos (-5 amortiguadores) al carrito. | 🔴 **Fallo:** El sistema restó el valor del total en lugar de mostrar error. El total se redujo. |
| **¿Se validan campos obligatorios?** | Intenté finalizar la compra dejando la dirección de envío vacía. | 🟢 **Éxito:** El botón "Pagar" se mantuvo deshabilitado hasta llenar el campo. |
| **¿Se muestran mensajes claros?** | Desconecté internet y di click en "Pagar". | 🟡 **Mejora:** Mostró un spinner infinito. Debería mostrar "Sin conexión, intenta más tarde". |

> **Conclusión Caja Negra:** Detectamos un error crítico de lógica de negocio (cantidades negativas) que afecta directamente al dinero.

---

## ⚪ 2. Evaluación de Caja Blanca (White Box)
**Enfoque:** Revisé la lógica interna del código (hipotético) del controlador de pagos `PaymentController` y la gestión de stock.

| Pregunta del Checklist | Análisis del Código | Resultado / Error Detectado |
| :--- | :--- | :--- |
| **¿Se cubren casos límite?** | Revisé la condición `if (stock > 0)` al momento de comprar. | 🔴 **Fallo (Race Condition):** No hay bloqueo de base de datos. Si dos usuarios compran la última pieza al mismo milisegundo, el código permite ambas ventas y el stock queda en -1. |
| **¿Se manejan excepciones?** | Revisé el bloque `try-catch` en la conexión con la API de Stripe/Banco. | 🟢 **Éxito:** Está correctamente implementado; si el banco falla, se hace un `rollback` y no se cobra. |
| **¿Variables sin uso?** | Escaneo estático del código. | 🟡 **Mejora:** Existe una variable `debugLog` que se quedó del desarrollo y consume memoria innecesaria. |

> **Conclusión Caja Blanca:** Encontramos un error de concurrencia (Race Condition) que un usuario normal difícilmente detectaría probando (caja negra), pero que causaría graves problemas de inventario.

---

## 🔘 3. Evaluación de Caja Gris (Gray Box)
**Enfoque:** Evalué la integración entre el Frontend (App Móvil) y el Backend (Base de Datos), conociendo cómo funciona la API.

| Pregunta del Checklist | Análisis de Integración | Resultado / Error Detectado |
| :--- | :--- | :--- |
| **¿Se protegen datos sensibles?** | Inspeccioné el tráfico de red (JSON) durante el pago. | 🔴 **Fallo:** El precio del producto se envía desde el celular al servidor. Un usuario malicioso podría editar el JSON y poner que el motor cuesta $1.00. (El servidor debería recalcular, no confiar en el cliente). |
| **¿Datos consistentes entre capas?** | Verifiqué si el "Historial de Pedidos" se actualiza tras pagar. | 🟢 **Éxito:** La base de datos registra la venta y la API actualiza la UI inmediatamente. |
| **¿Manejo de estados intermedios?** | ¿Qué pasa si la API del Banco tarda 30 segundos en responder? | 🟡 **Alerta:** La app no tiene tiempo de espera (timeout) definido, el usuario podría cerrar la app pensando que se trabó y duplicar el pago al reabrirla. |

> **Conclusión Caja Gris:** Detectamos una vulnerabilidad de seguridad crítica (Inyección de precios) al entender cómo "platican" las capas del sistema.

---

## 💡 Reflexión Final: Comparación de Metodologías

Al realizar esta actividad para MexiPartes, queda claro el valor de cada una:

1.  **Si solo hubiera hecho Caja Negra:** Habría notado lo de las cantidades negativas, pero se me habría pasado la vulnerabilidad de seguridad (precio) y el error de stock simultáneo.
2.  **Si solo hubiera hecho Caja Blanca:** Habría arreglado el código, pero quizá no me habría dado cuenta de que el mensaje de "Sin internet" era confuso para el usuario.
3.  **La combinación es necesaria:**
    *   **Caja Negra** para la experiencia (UX).
    *   **Caja Blanca** para la robustez y concurrencia.
    *   **Caja Gris** para la seguridad y la integración.
