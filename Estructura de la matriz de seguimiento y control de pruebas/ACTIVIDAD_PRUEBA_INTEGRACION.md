# Actividad: Evaluación de una Prueba de Integración
**Proyecto:** Mexipartes (App Móvil)
**Fecha:** 08 de Febrero de 2026

---

## 1. Selección de Módulos
Para este ejercicio, hemos seleccionado dos componentes críticos del sistema de autenticación de la aplicación móvil:

1.  **Módulo A: `AuthProvider`** (`lib/providers/auth_provider.dart`)
    *   **Rol:** Gestión de Estado y Lógica de Negocio.
    *   **Responsabilidad:** Orquestar el inicio de sesión, mantener el estado del usuario en memoria y persistencia local, y notificar a la UI.
2.  **Módulo B: `ApiService`** (`lib/services/api_services.dart`)
    *   **Rol:** Capa de Datos y Comunicación Externa.
    *   **Responsabilidad:** Ejecutar las peticiones HTTP (POST/GET) contra la API remota, serializar JSON y manejar códigos de respuesta HTTP.

---

## 2. Diseño de la Prueba de Integración

**Escenario de Prueba:** Flujo Exitoso de Inicio de Sesión (Login Positive Path).
**Objetivo:** Verificar que el `AuthProvider` integra correctamente la respuesta del `ApiService`, transformando un login exitoso en un cambio de estado de la aplicación.

```dart
// Archivo hipotético: test/integration/auth_integration_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:mexipartes/providers/auth_provider.dart';
import 'package:mexipartes/models/usuario_model.dart';

void main() {
  group('Integración AuthProvider + ApiService', () {
    test('Login exitoso debe actualizar el estado de usuario autenticado', () async {
      // 1. Configuración (Arrange)
      // Instanciamos el Provider, que a su vez instancia internamente el ApiService real.
      final authProvider = AuthProvider();
      
      // Credenciales de un usuario de prueba preexistente en la BD de desarrollo
      const emailTest = "usuario.prueba@mexipartes.com";
      const passwordTest = "Test1234!";

      // 2. Ejecución (Act)
      // Llamamos al método de negocio que desencadena la integración
      bool resultado = await authProvider.login(emailTest, passwordTest);

      // 3. Validación (Assert)
      // Verificamos el contrato de salida del método
      expect(resultado, isTrue, reason: "El método login debería retornar true");

      // Verificamos que el estado interno se actualizó con los datos provenientes del ApiService
      expect(authProvider.isAuthenticated, isTrue);
      expect(authProvider.usuarioActual, isNotNull);
      expect(authProvider.usuarioActual?.strCorreo, emailTest);
      
      // Verificamos que no existan mensajes de error residuales
      expect(authProvider.errorMessage, isNull);
    });
  });
}
```

---

## 3. Evaluación de la Prueba (Lista de Verificación)

A continuación, evaluamos nuestro propio diseño utilizando la lista de verificación proporcionada.

### 1. Alcance e integración de módulos
| Criterio | Estado | Justificación |
| :--- | :---: | :--- |
| **Módulos identificados** | ✔️ | Se especifican `AuthProvider` y `ApiService`. |
| **Interfaces definidas** | ✔️ | Entrada: `String email, pwd`. Salida: `bool`, cambio de estado. |
| **Dependencias controladas** | ❌ | **Fallo:** El `AuthProvider` instancia `ApiService` internamente (`new`), lo que impide inyectar un servicio simulado si la red falla. |
| **Flujo completo** | ✔️ | Cubre desde la solicitud hasta la actualización de estado. |
| **Orden de integración** | ✔️ | Bottom-Up (se integran servicios base hacia lógica superior). |

### 2. Comunicación e intercambio de datos
| Criterio | Estado | Justificación |
| :--- | :---: | :--- |
| **Datos correctos** | ✔️ | Se validan tipos de datos (Strings) y modelos (`Usuario`). |
| **Formato de datos** | ✔️ | ApiService maneja la conversión JSON <-> Objeto Dart. |
| **Validación de datos** | ✔️ | Se verifica integridad del objeto retornado. |
| **Manejo de datos nulos** | ✔️ | Se prueba que `usuarioActual` no sea `null`. |

### 3. Manejo de errores y excepciones
| Criterio | Estado | Justificación |
| :--- | :---: | :--- |
| **Errores controlados** | ✔️ | `AuthProvider` captura excepciones del `ApiService` (bloques try/catch). |
| **Mensajes claros** | ✔️ | Se asignan mensajes amigables en `errorMessage`. |
| **Recuperación** | ✔️ | El sistema permite reintentar el login tras un fallo. |

### 4. Entorno y condiciones de prueba
| Criterio | Estado | Justificación |
| :--- | :---: | :--- |
| **Entorno definido** | ⚠️ | Se asume entorno de Desarrollo, pero depende de la API pública en vivo. |
| **Uso de stubs/mocks** | ❌ | No se usaron mocks; es una prueba de integración "viva" (Live Integration). |
| **Limpieza del entorno** | ⚠️ | No aplica limpieza al ser solo lectura (Login), pero en registro sí haría falta. |

### 5. Resultados y validación
| Criterio | Estado | Justificación |
| :--- | :---: | :--- |
| **Resultado esperado** | ✔️ | `isAuthenticated == true`. |
| **Evidencia** | ✔️ | Los `asserts` del test sirven como evidencia de paso. |

### **Calificación Final Estimada: Bueno (aprox. 75%)**
La prueba es funcional y valida la integración, pero pierde puntos en **control de dependencias** y **aislamiento del entorno**.

---

## 4. Identificación de Riesgos de Integración

### Riesgo Principal: Acoplamiento Fuerte y Dependencia de Red Externa
**Descripción:**
Actualmente, el `AuthProvider` crea directamente la instancia del servicio:
`final ApiService _apiService = ApiService();` (Línea 8 de `auth_provider.dart`).

**Impacto:**
1.  **Falsos Negativos:** Si el servidor `mexipartesdb.runasp.net` está caído o el dispositivo no tiene internet, la prueba de integración fallará, aunque el código de la app esté perfecto.
2.  **Lentitud:** La prueba depende de la latencia de red real.
3.  **Datos Sucios:** Si probamos "Registro", crearemos usuarios reales en la base de datos de producción/desarrollo cada vez que corramos la prueba.

**Mitigación Sugerida (Refactorización):**
Implementar **Inyección de Dependencias** en el constructor del `AuthProvider`:

```dart
// Refactor sugerido
class AuthProvider with ChangeNotifier {
  final ApiService _apiService;

  // Permite inyectar un servicio mock para pruebas, o usar el real por defecto
  AuthProvider({ApiService? apiService}) 
      : _apiService = apiService ?? ApiService(); 
  
  // ... resto del código
}
```
Esto permitiría pasar un `ApiServiceMock` que simule respuestas controladas y permita probar la integración lógica sin depender de internet.
