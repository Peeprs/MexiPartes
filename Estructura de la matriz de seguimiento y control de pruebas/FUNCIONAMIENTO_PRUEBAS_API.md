# ⚙️ Funcionamiento Técnico de las Pruebas de API en MexiPartes

Este documento detalla cómo se ejecutan y validan técnicamente las pruebas de API en el ecosistema **MexiPartes**, alineando la estrategia de defensa con la arquitectura real del proyecto (Flutter + Supabase).

---

## 1. Arquitectura: La "API" es la Infraestructura (Serverless)

**El Argumento:**
A diferencia de aplicaciones tradicionales donde hay un servidor intermedio (como Node.js o .NET), en MexiPartes utilizamos **Supabase**. Esto significa que nuestra Base de Datos **es** también nuestra API REST en tiempo real.

*   **Realidad Técnica:** No probamos un código "backend" tradicional compilado puramente. Probamos la **integridad de las reglas de datos** y los **Endpoints REST autogenerados** por Supabase.
*   **Por qué es crítico probarlo:** La lógica de seguridad (Row Level Security) y la validación de datos (tipos, restricciones únicas) residen aquí. Si la API de Supabase falla o permite datos corruptos, ninguna validación visual en Flutter servirá.
*   **Ubicación en Código:** Lo que en la app hace `ApiService` (lib/services/api_services.dart), nuestras pruebas lo hacen directamente vía HTTP.

---

## 2. Estrategia de Conexión: "Bypassing" el Frontend

**El Argumento:**
Las pruebas de API en MexiPartes funcionan "saltándose" toda la capa visual. Mientras el equipo de UI necesita compilar la app, abrir el emulador y navegar 5 pantallas para llegar al carrito, nosotros atacamos el servidor en milisegundos.

*   **Herramientas:** Postman o Apidog.
*   **El Mecanismo:** Las pruebas se conectan directamente a la nube de Supabase usando las credenciales reales del proyecto, simulando ser la aplicación móvil pero sin su "peso".
    *   **Endpoint Real:** `https://numwrtupwzmdnzbrocje.supabase.co/rest/v1/`
    *   **Autenticación:**
        1.  `apikey`: La llave anónima pública del proyecto.
        2.  `Authorization`: `Bearer <TOKEN_JWT>` (Simulando un usuario logueado).

Esto nos permite aislar si un error es culpa de la pantalla (Flutter) o de la lógica de datos (API/DB).

---

## 3. Validación de Lógica de Negocio (Caso Real: Motor de Ventas)

**El Argumento:**
La prueba de API valida la **lógica financiera/operativa** crítica, algo que una prueba visual no puede garantizar al 100%.

**Caso Práctico: Crear una Orden (Pedido)**
En el código (`api_services.dart`), crear una orden implica verificar stock, restarlo y crear el registro.

*   **La Prueba de API:**
    Enviamos un `POST` directo a `/orders` con un JSON simulado:
    ```json
    {
      "buyer_id": "uuid-usuario-prueba",
      "total": 5500.00,
      "items": [{"id": "prod_123", "quantity": 5}]
    }
    ```

*   **Lo que validamos (El "Jaque Mate"):**
    1.  **Atomicidad:** Si pido 5 y hay 4 de stock, la API debe devolver error `400` o `409` **inmediatamente**. La UI tardaría segundos en mostrar esto; la API lo dice en 50ms.
    2.  **Integridad:** Que no se puedan crear órdenes con precios negativos o sin dueño.

**Conclusión:**
Las pruebas de API en MexiPartes son el guardián de la **integridad de los datos**. Si la prueba de API pasa, el negocio funciona. La UI es solo la forma bonita de mostrarlo.
