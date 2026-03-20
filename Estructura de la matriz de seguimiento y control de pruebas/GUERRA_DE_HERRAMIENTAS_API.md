# ⚔️ GUERRA DE HERRAMIENTAS: EQUIPO PRUEBAS DE API 🛡️

Este documento prepara al equipo de **"Pruebas de API"** para el debate, estructurando la defensa según los roles y requisitos solicitados.

## 👥 Asignación de Roles y Estrategia

*   **Investigador Técnico:** Fundamenta por qué la capa de API es la más crítica.
*   **Analista Crítico:** Desarma a los otros equipos (especialmente UI y Unitarias) mostrando sus debilidades.
*   **Diseñador de Ejemplo:** Prepara la demostración visual (JSON request/response).
*   **Vocero:** Sintetiza todo en el discurso de 3 minutos.

---

## 🚀 1. Tres Argumentos Técnicos Fuertes "Rompe-Hielo"

### Argumento 1: La API es el Cerebro, la UI es solo la Piel (Estabilidad y Rapidez)
*   **El punto:** Las pruebas de interfaz (UI/Selenium) son lentas y frágiles; cualquier cambio en un botón rompe la prueba. Las pruebas de API van directo a la lógica de negocio.
*   **Dato técnico:** Una prueba de API se ejecuta en **milisegundos**, mientras una de UI puede tardar varios segundos o minutos. En un pipeline de CI/CD, probar la API permite detectar el 90% de los errores funcionales críticos antes de que se renderice un solo píxel. Sin API funcionando, no hay aplicación web ni móvil que valga.

### Argumento 2: "Shift Left" Real: Probar antes de que exista el Frontend
*   **El punto:** No necesitamos esperar a que el equipo de frontend termine para asegurar la calidad.
*   **Dato técnico:** Herramientas como **Postman** o **Apidog** permiten trabajar con *Mock Servers* y contratos (OpenAPI/Swagger). Podemos validar la lógica, los códigos de estado (200, 404, 500) y la estructura del JSON mientras el frontend apenas se está diseñando. Esto reduce drásticamente el costo de corregir errores (Ley de Boehm).

### Argumento 3: Aislamiento y Diagnóstico Preciso
*   **El punto:** Cuando falla una prueba E2E (UI), no sabes si fue la red, el navegador, un botón mal puesto o la base de datos.
*   **Dato técnico:** Las pruebas de API te dicen exactamente **dónde** está el fallo: "¿El endpoint `/login` devolvió 500?" Es un error de servidor. "¿Devolvió 400?" Es un error de datos enviados. La precisión de diagnóstico es infinitamente superior a la de herramientas de caja negra.

---

## 🚑 2. Caso Real: "El Salvador del Proyecto"

**Escenario de Terror:**
Es el "Black Friday". La aplicación móvil de una tienda e-commerce empieza a fallar aleatoriamente al momento de pagar. El equipo de Pruebas Móviles (Appium) reporta que "el botón de pagar no hace nada a veces", pero no pueden reproducirlo siempre. El equipo de Rendimiento dice que el servidor responde, pero lento. El pánico se apodera de la sala.

**La Solución con Pruebas de API:**
El equipo de API entra en acción con **Postman/Apidog**. En lugar de usar la app, atacan directamente el endpoint `POST /api/checkout`.
Al enviar los datos crudos, descubren que cuando el carrito tiene un artículo con caracteres especiales ó descuento decimal específico (ej. 10.5%), el backend devuelve un error silencioso de validación JSON que la App Móvil no sabía manejar ni mostrar.

**Resultado:**
Se identificó que el backend fallaba al parsear decimales. Se arregló en 10 minutos en el servidor. Si hubieran dependido solo de probar la UI móvil, habrían tardado horas recompilando la app y buscando en el lugar equivocado. **La herramienta de API salvó las ventas del día.**

---

## 🧪 3. Ejemplo Práctico (Para el Diseñador)

**Herramienta:** Postman / Apidog
**Caso:** Validación de Creación de Usuario (Regla de Negocio: No duplicados).

**Paso 1: Request (Lo que enviamos)**
*Método:* `POST`
*URL:* `https://api.mexipartes.com/v1/usuarios`
*Body (JSON):*
```json
{
  "nombre": "Axel",
  "email": "axel@mexipartes.com",
  "rol": "admin"
}
```

**Paso 2: Response Esperado (Éxito - 201 Created)**
```json
{
  "id": 105,
  "mensaje": "Usuario creado exitosamente",
  "status": "success"
}
```

**Paso 3: La Prueba Automática (Script en Postman)**
```javascript
// Validar que el servidor responda rápido y con éxito
pm.test("Status code is 201", function () {
    pm.response.to.have.status(201);
});

// Validar que no nos devuelva un ID nulo (Integridad de datos)
pm.test("Tiene ID válido", function () {
    var jsonData = pm.response.json();
    pm.expect(jsonData.id).to.be.a('number');
});
```

**Demostración del Fallo (El jaque mate):**
Enviamos el mismo JSON de nuevo.
*Response Esperado:* `409 Conflict` (Usuario ya existe).
*Si devuelve 201:* **¡ERROR CRÍTICO DETECTADO!** Estamos duplicando usuarios. Esto una prueba de UI difícilmente lo nota hasta que la base de datos explota.

---

## 🎙️ 4. Guía para el Debate (Discurso del Vocero)

**Apertura (30 seg):**
"Compañeros, el software moderno no son pantallas bonitas, son datos viajando. Las **Pruebas de API** son la columna vertebral de la calidad. Mientras el equipo de UI pierde tiempo esperando que cargue una imagen, y el equipo de Seguridad busca agujeros complejos, nosotros validamos que la lógica del negocio funcione rápido y bien."

**Cuerpo (Argumentos):**
1.  **Eficiencia:** "Postman y Apidog nos permiten probar miles de escenarios en segundos. Un flujo de compra completo en UI toma 2 minutos; vía API toma 20 milisegundos."
2.  **Diagnóstico:** "Nosotros no adivinamos si falló el botón o el servidor. Nosotros interrogamos al servidor directamente. Si la API falla, NADA funciona. Somos el primer filtro real de calidad."
3.  **Independencia:** "Podemos trabajar sin interfaz gráfica. Somos los únicos que garantizamos que el Backend (donde vive el dinero y los datos) sea robusto."

**Cierre (Impacto):**
"En un proyecto real, una interfaz fea se puede usar. Una API rota hace que la aplicación sea basura inservible. Por costo-beneficio y criticidad, **las pruebas de API son indispensables**."

---

## 🛡️ Prepárate para la Pregunta Incómoda

**Posible ataque del equipo de Performance:** *"Las pruebas de API no simulan la experiencia real del usuario esperando a que cargue la página."*
**Respuesta:** "Exacto, por eso son mejores para detectar errores funcionales. Para la experiencia de usuario estáis vosotros. Pero si mi API tarda 10 segundos en responder, tu experiencia de usuario ya está muerta antes de empezar. Nosotros garantizamos que los cimientos sean sólidos para que ustedes puedan construir encima."

**Posible ataque del equipo de Seguridad:** *"Probar endpoints no es suficiente para evitar hackeos."*
**Respuesta:** "Al contrario, la mayoría de las vulnerabilidades modernas (Inyecciones, Broken Access Control) ocurren en la API. Si aseguras los endpoints desde nuestras pruebas (validando que un usuario normal no pueda borrar datos de admin), has cerrado la puerta principal antes de ponerle alarma a la ventana."
