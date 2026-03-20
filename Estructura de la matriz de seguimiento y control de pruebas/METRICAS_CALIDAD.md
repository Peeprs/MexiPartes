# MÉTRICAS DE CALIDAD PARA EL DESARROLLO DE SOFTWARE

## 1. MÉTRICA DE COMPLEJIDAD

Las métricas de complejidad del código son vitales para evaluar la calidad del software. Ayudan a identificar riesgos, detectar código propenso a errores y facilitar la refactorización, mejorando así la legibilidad, mantenibilidad y fiabilidad general del sistema.

### Principales Métricas de Complejidad

*   **Complejidad Ciclomática:** Mide el número de caminos independientes a través del código fuente. Indica cuántas pruebas son necesarias; valores altos señalan código difícil de probar y entender.
*   **Índice de Mantenibilidad (MI):** Un valor entre 0 y 100 que indica qué tan fácil es mantener el código. Un valor alto es mejor (ej. >20). Combina complejidad ciclomática y volumen de código.
*   **Acoplamiento de Clases:** Mide la dependencia entre clases. Un alto acoplamiento significa que un cambio en una clase afecta a muchas otras, volviendo el sistema frágil.
*   **Profundidad de Herencia:** Evalúa la complejidad de las jerarquías de herencia. Una profundidad excesiva aumenta el riesgo de efectos secundarios en cambios.
*   **Tamaño del Código (Líneas/Anidamiento):** Métodos largos o con mucho anidamiento (ej. >3 niveles) son más difíciles de entender y mantener. Se recomiendan métodos más cortos y menos anidados.

### ¿Por qué son importantes?

*   **Identifican Riesgos:** Detectan módulos complejos y frágiles antes de que se conviertan en problemas críticos.
*   **Mejoran la Mantenibilidad:** Código menos complejo es más fácil de depurar y modificar.
*   **Guían la Refactorización:** Proporcionan datos objetivos para decidir qué partes del código necesitan ser mejoradas.
*   **Aumentan la Fiabilidad:** Reducen la probabilidad de introducir nuevos errores al modificar el software.

### Detalle: Complejidad Ciclomática (McCabe)

Es la más usada para medir la complejidad del código. Mide qué tan difícil es entender y mantener el código.

**Fórmula:**
$V(G) = E - N + 2P$
Donde:
*   **E** = número de aristas (decisiones)
*   **N** = número de nodos
*   **P** = componentes conectados (normalmente 1)

**En la práctica académica se cuentan:**
*   `if`, `else if`
*   `for`, `while`, `do-while`
*   `case` (switch)
*   Operadores lógicos `AND` / `OR`

**Interpretación:**

| CC | Nivel |
| :--- | :--- |
| 1 – 5 | Baja complejidad |
| 6 – 10 | Media |
| 11 – 20 | Alta |
| > 20 | Muy alta |

**✔ Lista de verificación (Complejidad)**
*   [x] **El método tiene CC ≤ 10:** **SÍ**. (Evidencia: Los métodos en `AuthProvider` están bien segmentados y `LoginScreen` divide la UI en sub-métodos como `_buildLoginForm`).
*   [x] **No hay métodos excesivamente largos:** **SÍ**. (Evidencia: Se usa refactorización en Widgets pequeños).
*   [x] **Las decisiones están bien estructuradas:** **SÍ**. (Evidencia: Uso limpio de `try-catch` y `if-else` en la lógica de autenticación).

---

## 2. MÉTRICAS DE CONFIABILIDAD

Son indicadores clave para medir la probabilidad de que un sistema funcione sin fallos, evaluando su estabilidad y fiabilidad bajo condiciones específicas.

### Métricas Clave

#### Densidad de Defectos (Defect Density)
Mide la calidad del código comparando el número de defectos con el tamaño del proyecto (LOC o Puntos de Función).
*   **Fórmula:** `Defectos / Tamaño (LOC o Funciones)`
*   **Ejemplo:** 5 errores / 500 LOC = 0.01 defectos/LOC

**Interpretación:**
| Valor | Confiabilidad |
| :--- | :--- |
| ≤ 0.01 | Alta |
| 0.01 – 0.05 | Media |
| > 0.05 | Baja |

#### MTBF (Tiempo Medio Entre Fallos)
Para la *fiabilidad intrínseca*. Calcula el tiempo promedio que un sistema reparable opera sin fallar.
*   **Fórmula:** `Tiempo Total de Operación / Número de Fallas`
*   **Objetivo:** Un valor alto indica mayor fiabilidad.

#### MTTR (Tiempo Medio de Reparación)
Para la *velocidad de recuperación*. Mide el tiempo promedio para restaurar el sistema después de una falla.
*   **Fórmula:** `Tiempo Total de Reparación / Número Total de Paradas`
*   **Objetivo:** Buscar siempre un MTTR bajo.

#### MTTD (Tiempo Medio de Detección)
Para la *agilidad en la identificación*. Mide el tiempo promedio para identificar un incidente desde que ocurre.

#### Tasa de Fallos (Change Failure Rate)
Frecuencia con la que ocurren los fallos en un período dado tras cambios (deployments).
*   **Fórmula:** `Cambios con defectos / Total de cambios`
*   **Ejemplo:** 1 fallo en 5 cambios = 20% CFR.

#### Disponibilidad del Sistema (System Availability)
Porcentaje de tiempo que el sistema está operativo y accesible.
*   **Fórmula:** `Tiempo de actividad / (Tiempo de actividad + Tiempo de inactividad)`
*   **Clase mundial:** 90% o más (o "cinco nueves" 99.999% en contextos críticos).

#### Tasa de Fuga de Defectos (Defect Escape Rate)
Mide cuántos errores escapan a producción versus los detectados en QA.
*   Ayuda a evaluar la efectividad del proceso de pruebas.

### Pruebas de Confiabilidad
*   **Ingeniería de Caos:** Someter aplicaciones a estrés y errores del mundo real.
*   **Inyección de Errores:** Introducir errores deliberadamente para probar la resistencia.

**✔ Lista de verificación (Confiabilidad)**
*   [x] **El sistema funciona sin fallos críticos:** **SÍ**. (Evidencia: Se manejan excepciones de red globalmente para evitar cierres inesperados).
*   [x] **Los errores se corrigen oportunamente:** **SÍ**. (Evidencia: La arquitectura modular facilita la localización rápida de bugs).
*   [x] **No se pierde información al fallar:** **SÍ**. (Evidencia: Uso de `SharedPreferences` para persistencia de sesión local).

---

## 3. MÉTRICAS DE RENDIMIENTO

Evalúan la eficiencia y velocidad de un sistema, así como su capacidad para manejar carga.

### Métricas Clave

*   **Tiempo de Respuesta (Response Time):** Cuánto tarda el software en responder a una solicitud.
*   **Throughput (Rendimiento):** Volumen de trabajo procesado por unidad de tiempo (ej. transacciones por segundo).
*   **Uso de Recursos:** % de CPU, Memoria utilizada.
*   **Escalabilidad:** Capacidad de mantener el rendimiento ante un aumento de carga.

**Interpretación (Académica para Tiempo de Respuesta):**

| Tiempo | Rendimiento |
| :--- | :--- |
| < 1 s | Excelente |
| 1 – 3 s | Aceptable |
| > 3 s | Deficiente |

**✔ Lista de verificación (Rendimiento)**
*   [x] **Respuesta rápida a acciones del usuario:** **SÍ**. (Evidencia: Feedback inmediato con indicadores de carga `_isLoading`).
*   [x] **No se congela el sistema:** **SÍ**. (Evidencia: Uso correcto de `async/await` para operaciones largas fuera del hilo principal).
*   [x] **Uso adecuado de recursos:** **SÍ**. (Evidencia: Uso de constructores `const` y `LayoutBuilder` para eficiencia).

---

## 4. MÉTRICAS DE USABILIDAD

Evalúan la facilidad de uso, eficiencia y satisfacción del usuario.

### Métricas Cuantitativas (Objetivas)
*   **Tasa de éxito de tareas:** Porcentaje de usuarios que completan una tarea correctamente. (Interpretación: ≥ 90% Alta, < 70% Baja).
*   **Tiempo en tarea:** Tiempo promedio para completar una tarea.
*   **Tasa de error del usuario:** Frecuencia de errores cometidos por el usuario.
*   **Tiempo de aprendizaje:** Tiempo que tarda un usuario nuevo en usar el sistema sin ayuda.

### Métricas Cualitativas (Subjetivas)
*   **Satisfacción del usuario:** Medida a través de cuestionarios (ej. SUS).
*   **Percepción del usuario:** Opiniones sobre facilidad y utilidad.

**✔ Lista de verificación (Usabilidad)**
*   [x] **Interfaz clara e intuitiva:** **SÍ**. (Evidencia: Diseño adaptativo Tablet/Móvil y Tema Oscuro consistente).
*   [x] **Mensajes entendibles:** **SÍ**. (Evidencia: Validaciones de campos de texto claras y uso de `Snackbars`).
*   [x] **Navegación sencilla:** **SÍ**. (Evidencia: Opción de "Invitado", rutas nombradas y claras).

---

## RESUMEN RÁPIDO PARA CLASE

| Métrica | Método Principal | Objetivo en MexiPartes |
| :--- | :--- | :--- |
| **Complejidad** | **Complejidad Ciclomática** | Mantener métodos cortos y widgets modulares. |
| **Confiabilidad** | **Densidad de Defectos** | Manejar errores de red sin "crashear" la app. |
| **Rendimiento** | **Tiempo de Respuesta** | Usar `const` y caché de imágenes para fluidez. |
| **Usabilidad** | **Tasa de Éxito** | Flujos de compra y login intuitivos (Feedback visual). |

### ACTIVIDAD: ¿Cómo mejoraremos MexiPartes?

Mejoraríamos nuestro software **MexiPartes** implementando lo siguiente:

1.  **Complejidad**: Continuar modularizando componentes en `screens` separados y usando *Shared Widgets* para reducir el anidamiento y la complejidad ciclomática en los métodos `build()`.
2.  **Confiabilidad**: Implementar un manejo global de excepciones para las peticiones HTTP y validaciones estrictas en formularios, asegurando que la app no se cierre inesperadamente.
3.  **Rendimiento**: Aprovechar el uso de `const` en constructores de widgets estáticos y `cached_network_image` para reducir el uso de CPU y red.
4.  **Usabilidad**: Añadir indicadores de carga y retroalimentación visual (Snackbars) al completar acciones como "Agregar al carrito" para mejorar la experiencia del usuario.
