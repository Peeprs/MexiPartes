# Metodologías Ágiles Aplicadas al Proyecto MexiPartes

Este documento presenta un cuadro comparativo de metodologías ágiles y detalla la aplicación práctica de tres de ellas (Scrum, Kanban y XP) específicamente adaptadas al desarrollo de la plataforma MexiPartes.

---

## 1. Cuadro Comparativo de Metodologías Ágiles

| Característica | **Scrum** | **Kanban** | **Extreme Programming (XP)** |
| :--- | :--- | :--- | :--- |
| **Enfoque Principal** | Gestión del proyecto y entregas iterativas. | Flujo de trabajo continuo y reducción del desperdicio. | Excelencia técnica y satisfacción del cliente. |
| **Planificación** | Por Sprints (periodos fijos de 1-4 semanas). | Continua, basada en la capacidad (WIP Limits). | Diaria y por Release, muy flexible a cambios. |
| **Roles** | Product Owner, Scrum Master, Equipo de Desarrollo. | No prescribe roles específicos (evolutivo). | Cliente (en sitio), Entrenador, Rastreador, Programador. |
| **Métricas** | Velocidad (Puntos de Historia), Burndown Chart. | Lead Time (Tiempo de entrega), Cycle Time. | Velocidad del proyecto, Pruebas unitarias pasadas. |
| **Cambios** | No se aceptan cambios a mitad del Sprint. | Se aceptan en cualquier momento si hay capacidad. | Se aceptan y abrazan cambios incluso tardíos. |
| **Prácticas Clave** | Daily, Sprint Planning, Review, Retrospective. | Tablero visual, Limitar WIP, Gestionar flujo. | TDD, Pair Programming, Integración Continua, Refactoring. |
| **Mejor para...** | Proyectos con requisitos evolutivos y equipos que necesitan estructura. | Equipos de soporte/mantenimiento o flujo continuo de peticiones. | Proyectos con requisitos muy vagos o riesgo técnico alto. |

---

## 2. Aplicación Práctica en MexiPartes

Para el desarrollo exitoso de MexiPartes, hemos seleccionado y aplicado prácticas específicas de estas tres metodologías.

### A. Aplicación de SCRUM (Gestión del Ciclo de Vida)
Utilizamos Scrum como el marco principal para organizar el tiempo y las entregas del MVP.

*   **Sprints de 2 Semanas:** Dividimos el desarrollo en bloques manejables.
    *   *Ejemplo:* **Sprint 1** enfocado solo en el módulo "Mi Garage" y Registro. **Sprint 2** enfocado en el "Catálogo".
*   **Roles Definidos:**
    *   *Product Owner:* Define qué autopartes y marcas son prioridad cargar primero.
    *   *Scrum Master:* Elimina bloqueos (ej. "No tenemos acceso a la API del proveedor").
    *   *Dev Team:* Construye la app Flutter.
*   **Artefacto (Backlog):** Usamos el [Backlog de Historias de Usuario](ESTIMACION_POR_PUNTOS_DE_HISTORIA.md) que creamos previamente, priorizando por valor de negocio.
*   **Ceremonias:**
    *   *Daily Standup:* 15 minutos diarios para ver avance.
    *   *Sprint Review:* Al final de las 2 semanas, mostramos la App funcionando (no diapositivas) a los interesados.

### B. Aplicación de KANBAN (Gestión Visual del Flujo)
Utilizamos Kanban para gestionar el flujo de tareas *dentro* del Sprint y para el mantenimiento posterior (soporte).

*   **Tablero Visual:** Implementamos un tablero (Trello/Jira) con columnas:
    1.  `Por Hacer (Backlog)`
    2.  `En Diseño (UX/UI)`
    3.  `En Desarrollo (Coding)`
    4.  `En Revisión (Code Review)`
    5.  `En Pruebas (QA)`
    6.  `Terminado (Done)`
*   **Límites WIP (Work In Progress):**
    *   *Regla:* No se puede tener más de 3 tareas en "En Desarrollo" al mismo tiempo. Esto evita que el equipo empiece muchas cosas y no termine ninguna (multitasking ineficiente).
*   **Gestión de "Bugs":** Si sale un error crítico (ej. "No se puede pagar"), entra como tarjeta roja de "Expedite" (Urgente) saltándose la fila, práctica típica de Kanban.

### C. Aplicación de XP (Extreme Programming - Calidad Técnica)
Utilizamos prácticas de XP para asegurar que el código sea robusto y mantenible, dado que es una app financiera (e-commerce).

*   **Programación en Pareja (Pair Programming):**
    *   Para la funcionalidad crítica de **"Algoritmo de Compatibilidad"**, dos desarrolladores trabajan juntos en una sola maquina: uno escribe (conductor) y el otro revisa la lógica en tiempo real (navegante). Esto redujo errores en la lógica compleja de años/modelos.
*   **Desarrollo Guiado por Pruebas (TDD):**
    *   Antes de programar el carrito de compras, escribimos la prueba: *"Si agrego 2 amortiguadores de $500, el total debe ser $1000"*. La prueba falló (porque no había código), luego escribimos el código para pasar la prueba.
*   **Integración Continua (CI):**
    *   Cada vez que un desarrollador sube cambios al repositorio, se ejecutan automáticamente las pruebas unitarias y de seguridad (Caja Blanca/Gris) que definimos en el [Plan de Pruebas](PLAN_DE_PRUEBAS_SOFTWARE.md).
*   **Refactorización:**
    *   No tenemos miedo de mejorar el código. Si vemos que el módulo de "Login" está desordenado, lo limpiamos para que sea más legible, sin cambiar su funcionalidad.

---

## Conclusión de la Integración
En MexiPartes no somos puristas; somos pragmáticos combinando lo mejor de los tres mundos:
1.  **Scrum** nos da el ritmo y la fecha de entrega.
2.  **Kanban** nos da la transparencia y el control del flujo diario.
3.  **XP** nos da la calidad técnica para que la app no falle.
