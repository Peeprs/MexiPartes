# Estimación por Puntos de Historia de Usuario (Story Points)

La técnica de estimación por Puntos de Historia de Usuario (Story Points) es clave cuando trabajas con metodologías ágiles (Scrum, XP) y encaja perfecto después de ver Puntos de Función y Casos de Uso, porque cambia el enfoque: no mide tamaño técnico, mide esfuerzo relativo.

**Los Puntos de Historia son una medida relativa de esfuerzo, no de tiempo.**
Evalúan qué tan “difícil” es implementar una historia de usuario comparada con otras.

Se basan en tres factores principales:
1.  **Complejidad** – Qué tan difícil es la lógica
2.  **Esfuerzo** – Cuánto trabajo implica
3.  **Incertidumbre / Riesgo** – Qué tanto desconocimiento existe

> **Importante:** 1 punto ≠ 1 hora. Los puntos no se convierten directamente a tiempo.

## ¿Qué es una Historia de Usuario?

Es una explicación breve, informal y centrada en el usuario de una funcionalidad de software, redactada desde la perspectiva del cliente final. Se utiliza en metodologías ágiles (Scrum, Kanban) para definir requisitos funcionales en lenguaje sencillo, enfocándose en qué se necesita y por qué, en lugar de en los detalles técnicos.

### Formato clásico:
> **Como** [tipo de usuario]
> **quiero** [funcionalidad (realizar una acción/necesidad)]
> **para** [obtener un valor/beneficio]

### Ejemplos:
*   *Como usuario, quiero iniciar sesión para acceder a mis datos personales.*
*   *Como gestor de proyecto, quiero generar un informe de estado del proyecto para poder compartir el progreso con las partes interesadas.*
*   *Como administrador, quiero ver estadísticas de uso de los usuarios en el panel para monitorear la plataforma.*

### Características y Componentes Principales:
*   **Formato Ágil:** Se escriben en tarjetas o herramientas digitales (como Jira) y se enfocan en la colaboración, no en la documentación exhaustiva.
*   **Criterios de Aceptación:** Definen los límites de la historia y establecen cuándo se considera terminada (definición de "Done").
*   **Valor para el usuario:** El objetivo es mejorar la experiencia del usuario y proporcionar valor tangible en cada iteración o sprint.
*   **Estimación:** Suelen medirse en "puntos de historia" para estimar la complejidad y el esfuerzo.

**Importancia:**
Es este trabajo sobre las historias de usuario lo que ayuda a los equipos de scrum a mejorar en la estimación y planificación de sprints, lo que conduce a un pronóstico más preciso y a una mayor agilidad. Gracias a las historias, los equipos de kanban aprenden a gestionar el trabajo en curso (WIP) y pueden perfeccionar aún más sus flujos de trabajo.

Las historias de usuario son también los componentes básicos de los marcos ágiles más grandes, como los epics y las iniciativas. Los epics son grandes elementos de trabajo divididos en un conjunto de historias, y varios epics constituyen una iniciativa. Estas estructuras más grandes garantizan que el trabajo diario del equipo de desarrollo contribuya a los objetivos de la organización incorporados en los epics y las iniciativas.

## Escala de Puntos de Historia (Fibonacci)

Se usa una escala no lineal, comúnmente la serie de Fibonacci, porque refleja que la incertidumbre crece con el tamaño:

| Puntos | Significado |
| :--- | :--- |
| **1** | Muy simple |
| **2** | Simple |
| **3** | Media |
| **5** | Compleja |
| **8** | Muy compleja |
| **13** | Extremadamente compleja |
| **21+** | Demasiado grande (debe dividirse) |

> **NOTA:** Si una historia supera 13–21 puntos, no se estima: se divide.

## Procedimiento paso a paso

### Paso 1: Definir el backlog
El equipo lista de forma ordenada y dinámica todas las historias de usuario (características, mejoras, errores, tareas técnicas) necesarias para un proyecto. Es el "sistema nervioso central" del desarrollo ágil, priorizado por el **Product Owner** para asegurar que el equipo trabaje en lo más valioso.

**Ejemplo:**
*   Registro de usuario
*   Inicio de sesión
*   Visualización de perfil
*   Generar reporte

**Características y tipos principales:**
*   **Product Backlog:** Lista completa y de alto nivel de todo el trabajo del producto.
*   **Sprint Backlog:** Subconjunto del product backlog seleccionado para completarse en un período corto (Sprint).
*   **Contenido:** Incluye historias de usuario, correcciones de errores (bugs), trabajo técnico y mejoras de infraestructura.
*   **Dinamismo:** El backlog se revisa, refina y reordena continuamente, ya que no es un documento inamovible.

### Paso 2: Elegir una historia de referencia
Se selecciona una historia bien entendida y se le asigna un valor base (ej. 3 puntos).

**Ejemplo:**
*   “Inicio de sesión” = 3 puntos

Esta historia será la referencia para comparar las demás.

### Paso 3: Estimación relativa
Las demás historias se comparan con la referencia:
*   ¿Es más simple? → menos puntos
*   ¿Es más compleja? → más puntos
*   ¿Tiene más riesgo? → sube puntos

**Ejemplo:**
*   Registro de usuario → 5 puntos
*   Ver perfil → 2 puntos
*   Reporte → 8 puntos

### Paso 4: Uso de Planning Poker (opcional pero ideal)
**Planning Poker** es una técnica de planificación y estimación que utilizan los equipos ágiles tras la creación del backlog del producto. Ayuda a estimar plazos, mejorar la colaboración y planificar el trabajo.

> [Más información sobre Planning Poker](https://asana.com/es/resources/planning-poker)

**Proceso:**
1.  Cada integrante elige una carta con un número de puntos.
2.  Votan en cada historia de usuario y todos muestran su carta al mismo tiempo.
3.  Se discuten diferencias.
4.  Se llega a consenso.
5.  Planifica tu sprint.

Esto hace visibles los supuestos distintos del equipo.

## Factores que influyen en la estimación

Consideren explícitamente:

| Factor | Pregunta guía |
| :--- | :--- |
| **Complejidad** | ¿Cuánta lógica implica?<br>¿Cuántas personas deberán trabajar en esta historia? |
| **Conocimiento** | ¿Ya hemos hecho algo similar?<br>¿Cómo responderán las partes interesadas si hay alguna demora con esta historia? |
| **Dependencias** | ¿Depende de otros módulos o APIs? |
| **Riesgo** | ¿Hay incertidumbre técnica? |
| **Esfuerzo** | ¿Cuántas tareas técnicas involucra?<br>¿Cuáles son las diferentes técnicas que podemos usar para completar esa historia? |

## De puntos a planeación: Velocidad del equipo

La velocidad es el número de puntos que un equipo completa por iteración (sprint).

**Ejemplo:**
*   Sprint 1: 18 puntos
*   Sprint 2: 20 puntos
*   **Velocidad promedio ≈ 19 puntos/sprint**

Esto permite:
*   Planear sprints
*   Estimar duración del proyecto
*   Ajustar expectativas

## Ventajas y limitaciones

### ✔ Ventajas
*   Fomenta trabajo en equipo
*   Acepta la incertidumbre
*   Ideal para requisitos cambiantes
*   Fácil de ajustar con experiencia

### ⚠ Limitaciones
*   Subjetiva
*   No comparable entre equipos
*   Requiere disciplina y reflexión

## Diferencia clave con Puntos de Función

| Puntos de Función | Puntos de Historia |
| :--- | :--- |
| Tamaño funcional | Esfuerzo relativo |
| Enfoque técnico | Enfoque del equipo |
| Más formal | Más flexible |
| Requisitos estables | Requisitos cambiantes |

---

## Actividad sugerida: Estimación ágil del proyecto

1.  Definir 8–12 historias de usuario.
2.  Elegir una historia base (3 puntos).
3.  Estimar usando Fibonacci.
4.  Justificar las 3 historias con mayor puntaje.
5.  Reflexionar:
    *   ¿Dónde hubo más discusión?
    *   ¿Qué supuestos influyeron?

> “Los puntos de historia no miden tiempo, miden incertidumbre.”
> “Estimar es una conversación, no una fórmula.”
