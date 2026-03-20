# 🤖 Pruebas Automatizadas y Estrategias de Validación 

Este documento detalla los conceptos clave, tipos, criterios y estrategias para la implementación efectiva de pruebas automatizadas en el desarrollo de software, incluyendo el uso de herramientas modernas como APIDog y Postman.

## 🛠️ Herramientas de Automatización: Videos y Recursos

### 1. APIDog: Simulación y Pruebas Integrales
**Recurso:** [Tutorial APIDog](https://youtu.be/Q8b5AeHcELk)

APIDog es una herramienta integral que permite:
*   **Simulación de Módulos:** Generar proyectos que simulan los módulos reales de tu sistema para pruebas tempranas.
*   **Generación de Casos de Prueba:** Crear automáticamente casos de prueba de rendimiento e integración.
*   **Detección y Depuración:** Identificar errores, depurar código y aplicar correcciones de manera eficiente.
*   **Trabajo Colaborativo:** Compartir proyectos con el equipo para trabajar en conjunto en tiempo real.
*   **Visualización de Rendimiento:** Acceder a gráficas detalladas sobre el comportamiento del sistema bajo carga.
*   **Importación de Especificaciones:** Importar endpoints desde especificaciones existentes con escenarios prediseñados.
*   **Pruebas con Datos Reales:** Ejecutar pruebas dinámicas importando archivos **CSV** o **JSON**.

### 2. Postman: Evaluación y Validación JSON
**Recurso:** [Tutorial Postman](https://youtu.be/AtRBTki2oeY)

Postman facilita la validación de proyectos web mediante:
*   **Carga de Proyectos:** Subir tu proyecto con formato JSON para estructurar las peticiones.
*   **Evaluación de Endpoints:** Verificar el correcto funcionamiento de las rutas de la API.
*   **Validación de Respuestas:** Asegurar que los datos devueltos coincidan con los esperados.

---

## 🧪 Tipos de Pruebas Automatizadas

| Tipo de Prueba | Descripción | Objetivo Principal | Cuándo se Ejecuta |
| :--- | :--- | :--- | :--- |
| **Pruebas Unitarias** | Verifican funciones, métodos o clases individuales de forma aislada. | Asegurar que la unidad más pequeña de código funcione correctamente. | Durante el desarrollo (TDD). |
| **Pruebas Funcionales** | Validan que el software cumpla con los requisitos funcionales especificados. | Simular acciones reales del usuario (clics, navegación, formularios). | Durante el ciclo de QA. |
| **Pruebas de Integración** | Verifican la interacción y comunicación entre diferentes módulos o componentes. | Detectar fallos en la interfaz entre componentes que funcionan bien por separado. | Tras integrar módulos. |
| **Pruebas de Regresión** | Se ejecutan después de realizar cambios o actualizaciones en el código. | Asegurar que las nuevas modificaciones no hayan roto funcionalidades existentes. | Después de cada cambio/fix. |
| **Pruebas de Rendimiento** | Miden tiempos de respuesta, carga, estabilidad y escalabilidad. | Evaluar comportamiento bajo condiciones normales y extremas (estrés). | Antes del lanzamiento. |
| **Pruebas de Seguridad** | Detectan vulnerabilidades, fallos de seguridad y accesos no autorizados. | Proteger el sistema contra ataques comunes (ej. Inyección SQL). | Continuamente / Auditorías. |

---

## 📝 Ejemplos de Pruebas Automatizadas

*   **Unitarias:** Probar automáticamente que una función `calcularTotal(precio, impuesto)` devuelva el resultado matemático exacto.
*   **Funcionales:** Comprobar que el módulo de "búsqueda de productos" devuelva resultados relevantes y coincida con los filtros aplicados.
*   **Integración:** Verificar que el "Módulo de Login" se comunique correctamente con la "Base de Datos de Usuarios" y devuelva el token de sesión.
*   **Regresión:** Verificar que después de actualizar la pasarela de pagos, el "Carrito de Compras" sigue permitiendo agregar y eliminar productos correctamente.
*   **Rendimiento:** Simular 100 usuarios intentando comprar el mismo artículo simultáneamente para medir el tiempo de respuesta del servidor.
*   **Seguridad:** Ejecutar scripts automatizados que intenten realizar inyección SQL en el campo de contraseña para validar la sanitización de entradas.

---

## 📊 Criterios de Desempeño

Para evaluar la efectividad de una prueba automatizada, utilizamos los siguientes indicadores:

1.  **Eficiencia:** Rapidez en la ejecución y uso óptimo de recursos (CPU, memoria).
2.  **Repetibilidad:** La prueba debe producir exactamente los mismos resultados bajo las mismas condiciones, siempre.
3.  **Cobertura:** Porcentaje del sistema probado (funciones, ramas lógicas, líneas de código).
4.  **Confiabilidad:** Resultados consistentes, minimizando falsos positivos (fallos irreales) o falsos negativos (errores no detectados).
5.  **Mantenibilidad:** Facilidad para actualizar el script de prueba cuando el software cambia.
6.  **Automatización Efectiva:** Nivel de intervención humana requerido (debe ser mínimo o nulo).
7.  **Escalabilidad:** Capacidad de ejecutar pruebas con mayor volumen de datos, usuarios o transacciones.

### Comparación de Importancia e Impacto

| Criterio | Importancia | Impacto en la Calidad |
| :--- | :--- | :--- |
| **Eficiencia** | Alta | Reduce tiempos de ciclo y costos operativos. |
| **Cobertura** | Muy Alta | Detecta más errores antes de llegar a producción. |
| **Repetibilidad** | Alta | Genera confianza en los resultados de las pruebas. |
| **Confiabilidad** | **Crítica** | Evita decisiones erróneas basadas en datos incorrectos. |
| **Mantenibilidad** | Media-Alta | Facilita la evolución sostenible del sistema y las pruebas. |
| **Escalabilidad** | Media | Permite validar el crecimiento del sistema a futuro. |
| **Automatización** | Alta | Mejora drásticamente la productividad del equipo QA. |

---

## 📐 Diseño de Pruebas Automatizadas

El diseño efectivo requiere un análisis previo del sistema bajo prueba (SUT).

### 1. Análisis y Definición del Sistema
El alumno debe analizar el contexto:
*   **Tipo de Sistema:** Web, Móvil, Escritorio, API, Empresarial, Académico.
*   **Qué Evaluar:** Funcionalidad, Rendimiento, Seguridad, Estabilidad, Usabilidad.

### 2. Selección de Criterios (Ejemplo Aplicado)
Para una **App de Inicio de Sesión**:

| Aspecto | Criterio Seleccionado | Meta |
| :--- | :--- | :--- |
| **Funcional** | Cobertura | Cubrir el 90% de escenarios de acceso (válido, inválido, bloqueado). |
| **Rendimiento** | Eficiencia | Ejecución de la prueba de login en menos de 5 segundos. |
| **Regresión** | Confiabilidad | Resultados consistentes tras actualizaciones de UI. |

### 3. Pasos para el Diseño del Script

1.  **Identificar Funcionalidades Críticas:** Login, Registro, Pagos, Consultas principales.
2.  **Definir Casos de Prueba:** Estructura `Entrada` -> `Acción` -> `Resultado Esperado`.
3.  **Seleccionar Herramienta:** 
    *   *Web:* Selenium, Cypress.
    *   *Unitarias Java:* JUnit.
    *   *APIs:* Postman, APIDog.
4.  **Diseñar el Script:** Codificar la simulación de acciones y las validaciones (assertions).
5.  **Definir Criterios de Aceptación:** Qué condiciones exactas determinan "Pasa" o "Falla".

---

## 🔎 Caso de Estudio: Automatización de Login

### Especificación del Caso de Prueba
**Nombre:** Inicio de Sesión Válido

*   **Entrada:** 
    *   Usuario: `admin@mexipartes.com`
    *   Contraseña: `SuperSecretPassword123!`
*   **Acción:** 
    *   Navegar a `/login`.
    *   Escribir usuario.
    *   Escribir contraseña.
    *   Hacer clic en botón "Iniciar Sesión".
*   **Resultado Esperado:** 
    *   Redirección exitosa al `Dashboard`.
    *   Mensaje de bienvenida visible: "Bienvenido, Admin".
*   **Criterios de Desempeño:**
    *   Tiempo de respuesta < 3 segundos.
    *   Resultado correcto en el 100% de 50 ejecuciones concurrentes.

### Ejemplo Sencillo de Script (Pseudocódigo/Cypress)
```javascript
describe('Prueba de Login MexiPartes', () => {
  it('Debe permitir acceso con credenciales válidas', () => {
    // 1. Visitar página
    cy.visit('https://mexipartes.com/login');

    // 2. Ingresar credenciales
    cy.get('#email').type('admin@mexipartes.com');
    cy.get('#password').type('SuperSecretPassword123!');

    // 3. Acción
    cy.get('#btn-login').click();

    // 4. Validación (Assertion)
    cy.url().should('include', '/dashboard');
    cy.contains('Bienvenido, Admin').should('be.visible');
  });
});
```

> "Las pruebas automatizadas no solo verifican que el software funcione, sino que permiten medir su calidad, eficiencia y confiabilidad de forma objetiva."
