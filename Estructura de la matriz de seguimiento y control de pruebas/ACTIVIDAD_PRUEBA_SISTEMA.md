# Actividad: Lista de Verificación para Evaluar una Prueba de Sistema

**Propósito:** Verificar que el sistema completo (App Móvil Mexipartes), ya integrado, funciona conforme a los requisitos funcionales en un entorno lo más cercano posible al real.

---

## 1. Selección del Caso de Uso Completo
**Caso de Uso:** **"Registro de Nuevo Usuario y Acceso Automático"**
Este flujo es crítico porque es la puerta de entrada de nuevos clientes a la plataforma. Involucra la interfaz de usuario, validaciones locales, comunicación con el servidor, persistencia de datos y navegación.

---

## 2. Diseño de la Prueba de Sistema
**Escenario:** Un usuario nuevo descarga la app y crea una cuenta válida.

**Pasos de Ejecución (Script de Prueba Manual/Automatizada):**
1.  **Inicio:** Abrir la aplicación en un dispositivo Android/iOS real o emulado.
2.  **Navegación:** Tocar el botón "Crear Cuenta" en la pantalla de Login.
3.  **Entrada de Datos:** Completar el formulario con datos válidos no registrados previamente:
    *   Nombre: "Sistema"
    *   Apellido: "Test"
    *   Correo: "systest_[TIMESTAMP]@gmail.com" (único)
    *   Contraseña: "Password123!"
4.  **Acción:** Tocar el botón "Registrarse".
5.  **Verificación Visual (UI):** Esperar indicador de carga (`CircularProgressIndicator`).
6.  **Validación de Salida:** Verificar que la app navega automáticamente a la "Pantalla Principal" (Home).
7.  **Persistencia:** Cerrar la app completamente (kill process) y volver a abrirla.
8.  **Verificación Final:** Validar que la sesión se mantiene activa y no pide login nuevamente.

---

## 3. Evaluación de la Prueba (Lista de Verificación)

### 1. Alcance del sistema
| Marca | Criterio | Observaciones |
| :---: | :--- | :--- |
| ✔️ | **Sistema integrado** | Frontend (Flutter) + Backend (ASP.NET) + BD conectados. |
| ✔️ | **Requisitos cubiertos** | Cubre RF-01 (Registro) y RF-02 (Inicio de Sesión). |
| ✔️ | **Casos de uso** | Flujo principal cubierto. |
| ❌ | **Flujos alternos** | Esta prueba específica solo cubre el "Camino Feliz". Falta prueba de "Correo Duplicado". |
| ✔️ | **Dependencias externas** | API REST en `mexipartesdb.runasp.net` es la dependencia principal. |

### 2. Pruebas funcionales del sistema
| Marca | Criterio | Observaciones |
| :---: | :--- | :--- |
| ✔️ | **Funcionalidades clave** | El registro es bloqueante y crítico; se valida correctamente. |
| ✔️ | **Reglas de negocio** | Se valida que el correo sea único (backend) y formato de pass (frontend). |
| ✔️ | **Validaciones** | El formulario impide envío si faltan campos. |
| ✔️ | **Mensajes del sistema** | Muestra "Cargando..." y mensajes de error si falla. |
| ✔️ | **Navegación** | Redirige correctamente de Registro -> Home tras éxito. |

### 3. Pruebas no funcionales
| Marca | Criterio | Observaciones |
| :---: | :--- | :--- |
| ⚠️ | **Rendimiento** | Depende de la red, no se midió estrictamente el tiempo (< 3s). |
| ✔️ | **Seguridad** | La contraseña viaja en HTTPS (SSL) al servidor. |
| ✔️ | **Usabilidad** | El flujo es intuitivo para un usuario móvil estándar. |
| ✔️ | **Confiabilidad** | El sistema no crashea si se ingresan datos raros. |
| ✔️ | **Compatibilidad** | Probado en Android (Emulador). Falta iOS. |

### 4. Datos y entorno de prueba
| Marca | Criterio | Observaciones |
| :---: | :--- | :--- |
| ✔️ | **Entorno definido** | App en modo Debug conectada a API Producción/Staging. |
| ✔️ | **Datos reales/simulados** | Se usa un correo real (formato) y datos coherentes. |
| ✔️ | **Persistencia** | Se verifica con `SharedPreferences` al reiniciar la app. |
| ❌ | **Recuperación** | No aplica limpieza automática; el usuario "systest" queda en la BD hasta que se borre manual. |
| ⚠️ | **Limpieza** | Deja "basura" en la base de datos (usuario de prueba). |

### 5. Manejo de errores y excepciones
| Marca | Criterio | Observaciones |
| :---: | :--- | :--- |
| ✔️ | **Errores controlados** | Si se corta WiFi, muestra "Error de conexión". |
| ✔️ | **Mensajes al usuario** | "El correo ya está registrado" es claro. |
| ✔️ | **Registro de errores** | Logs en consola de Flutter/Sentry (si hubiese). |
| ✔️ | **Recuperación** | Permite reintentar registrarse tras corregir datos. |

### 6. Resultados y documentación
| Marca | Criterio | Observaciones |
| :---: | :--- | :--- |
| ✔️ | **Resultado esperado** | Usuario creado + Redirección a Home. |
| ✔️ | **Resultado obtenido** | Documentado en reporte de ejecución. |
| ✔️ | **Evidencia** | Screenshot de la pantalla Home con el perfil del usuario. |
| ✔️ | **Estado de la prueba** | Aprobada (Pass). |

### 7. Buenas prácticas de prueba de sistema
| Marca | Criterio | Observaciones |
| :---: | :--- | :--- |
| ✔️ | **Enfoque integral** | Se evalúa "end-to-end" (E2E). |
| ✔️ | **Independiente** | No requiere saber cómo funciona el código interno. |
| ✔️ | **Repetible** | Requiere cambiar el correo en cada ejecución (único inconveniente). |
| ✔️ | **Escenarios reales** | Simula exactamente lo que hará un cliente real. |

---

## 4. Evaluación Final (Rúbrica)
**Calificación:** 🟢 **Bueno (aprox. 85%)**
*   **Fortalezas:** Cubre un flujo crítico de extremo a extremo, valida persistencia y navegación.
*   **Debilidades:** Falta automatización total (limpieza de datos) y probar flujos de error (correo duplicado) en esta misma sesión.

---

## 5. Riesgo del Sistema Completo Detectado

**Riesgo:** **Inconsistencia de Datos en Entornos Compartidos (Dirty Data).**

*   **Descripción del Riesgo:** Al ejecutar pruebas de sistema "End-to-End" contra el servidor real (`mexipartesdb.runasp.net`), estamos creando usuarios de prueba permanentemente.
*   **Impacto:**
    1.  Si ejecutamos la prueba 100 veces, tendremos 100 usuarios basura en la base de datos.
    2.  Si intentamos reutilizar el correo `test@gmail.com`, la prueba fallará la segunda vez (Falso Positivo de fallo) porque el usuario ya existe.
*   **Mitigación Propuesta:**
    1.  Implementar un endpoint de API exclusivo para pruebas (ej. `DELETE /api/test/cleanup`) que limpie los datos generados *después* de la prueba.
    2.  O bien, usar una **Base de Datos en Memoria** o contenedores Docker desechables para el entorno de pruebas de sistema, que se reinicien ("nuke") tras cada ejecución.
