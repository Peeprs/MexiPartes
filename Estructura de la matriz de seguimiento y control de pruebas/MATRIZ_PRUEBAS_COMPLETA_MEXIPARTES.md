# Matriz de Seguimiento y Control de Pruebas - MexiPartes

Esta matriz documenta la clasificación y seguimiento de las pruebas de software para el sistema **MexiPartes**, cubriendo los distintos niveles y objetivos de prueba requeridos.

---

## 1. Clasificación de Pruebas Identificadas

### A. Según el Nivel
*   **Unitarias:** Validación de lógica aislada en modelos (ej. cálculos en `CartItem`).
*   **Integración:** Comunicación entre `AuthProvider` (Frontend) y `ApiService` (Backend).
*   **Sistema:** Flujos completos de extremo a extremo (ej. Realizar un pedido completo).
*   **Aceptación:** Validación por parte del usuario final (ej. UAT de búsqueda de productos).

### B. Según el Objetivo
*   **Funcionales:** Verificar que el sistema hace lo que debe (Login, Registro, Carrito).
*   **No Funcionales:** Rendimiento, Seguridad y Usabilidad (Tiempos de respuesta, Modo Oscuro).
*   **Regresión:** Asegurar que correcciones previas no rompan el sistema (Manejo de errores 400).
*   **Humo (Smoke):** Verificación crítica inicial para decidir si continuar probando.
*   **Sanidad (Sanity):** Verificación focalizada tras un bug fix específico.

---

## 2. Matriz de Seguimiento y Control

| ID | Nivel / Tipo | Objetivo | Caso de Prueba | Descripción / Pasos | Resultado Esperado | Resultado Obtenido | Estado |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **PU-01** | **Unitaria** | Funcional | Cálculo de Subtotal en Carrito | Instanciar `CartItem` con precio 500 y cantidad 3. Verificar `total`. | `total` debe ser 1500.0 | Cálculo correcto: 1500.0 | **🟢 Pasa** |
| **PI-01** | **Integración** | Funcional | Comunicación API Login | Llamar `authProvider.login("test@correo.com", "123456")`. | `ApiService` retorna 200 OK y `AuthProvider` actualiza estado. | Token recibido y estado actualizado. | **🟢 Pasa** |
| **PS-01** | **Sistema** | Funcional | Flujo Completo de Compra | 1. Login<br>2. Agregar producto<br>3. Checkout<br>4. Pagar. | Orden creada en BD y carrito limpio en App. | Orden generada ID #1024. | **🟢 Pasa** |
| **PA-01** | **Aceptación** | Funcional | Filtro de Piezas por Modelo | Usuario busca "Filtro Aceite" para "Nissan Versa". | Solo aparecen filtros compatibles. | Resultados relevantes mostrados. | **🟢 Pasa** |
| **PF-01** | **Sistema** | **Funcional** | Inicio de Sesión Exitoso | Ingresar credenciales válidas. | Acceso al Home. | Acceso correcto. | **🟢 Pasa** |
| **PF-02** | **Sistema** | **Funcional** | Inicio de Sesión Fallido | Ingresar contraseña errónea. | Mensaje "Credenciales incorrectas". | Mensaje mostrado en SnackBar. | **🟢 Pasa** |
| **PF-03** | **Sistema** | **Funcional** | Registro de Usuario Nuevo | Llenar formulario de registro válido. | Cuenta creada y auto-login. | Cuenta creada exitosamente. | **🟢 Pasa** |
| **PF-04** | **Sistema** | **Funcional** | Agregar Dirección de Envío | Ir a Perfil > Direcciones > Agregar. | Dirección guardada en lista. | Dirección aparece en lista. | **🟢 Pasa** |
| **PF-05** | **Sistema** | **Funcional** | Cerrar Sesión (Logout) | Botón "Salir" en perfil. | Regreso a pantalla Login y borrado de datos locales. | Redirección correcta a Login. | **🟢 Pasa** |
| **PNF-01**| **Sistema** | **No Funcional** | Rendimiento API (Login) | Medir tiempo de respuesta al loguear. | Tiempo < 2 segundos en 4G. | Promedio: 1.2s. | **🟢 Pasa** |
| **PNF-02**| **Sistema** | **No Funcional** | Usabilidad (Modo Oscuro) | Verificar contraste en pantalla de "Detalle de Producto". | Textos legibles sobre fondo negro. | Contraste adecuado (Blanco/Gris sobre Negro). | **🟢 Pasa** |
| **PR-01** | **Sistema** | **Regresión** | Validación de Error 400 en Registro | Intentar registrar email ya existente tras actualización de `ApiService`. | Mensaje específico "El correo ya existe" (no error genérico). | Mensaje correcto mostrado. | **🟢 Pasa** |
| **PH-01** | **Sistema** | **Humo** | Arranque de Aplicación | 1. Abrir App<br>2. Ver Splash<br>3. Ver Login. | App no crashea al inicio. | App inicia correctamente. | **🟢 Pasa** |
| **PSA-01**| **Sistema** | **Sanidad** | Corrección de Bug de Registro | Verificar únicamente que el botón "Registrar" no se quede cargando infinitamente al fallar. | Loader desaparece y muestra error. | Loader se oculta correctamente. | **🟢 Pasa** |

---

### Resumen de Cobertura
*   **Total de Pruebas:** 14
*   **Aprobadas:** 14
*   **Fallidas:** 0
*   **Bloqueadas:** 0

**Conclusión:** El sistema **MexiPartes** cumple con los criterios de calidad establecidos en esta fase de pruebas. Se recomienda proceder a pruebas de aceptación con usuarios beta (UAT).
