# Actividad: Lista de Verificación para Evaluar una Prueba Unitaria

**Propósito:** Verificar que una unidad mínima del software (clase `Usuario`) funcione correctamente de manera aislada.

## 1. Código Fuente Analizado
Para esta actividad, analizaremos el **Modelo de Datos `Usuario`** (`lib/models/usuario_model.dart`) y su método `fromJson`, ya que es una unidad lógica pura y fácil de probar unitariamente sin dependencias externas.

```dart
// Código original (simplificado para contexto)
factory Usuario.fromJson(Map<String, dynamic> json) {
  return Usuario(
    id: json['idUsuario'] ?? 0,
    strNombre: json['strNombre'] ?? '',
    strCorreo: json['strCorreo'] ?? '',
    // ... otros campos
  );
}
```

## 2. Prueba Unitaria Diseñada
```dart
void main() {
  test('Usuario.fromJson debería crear una instancia válida con datos completos', () {
    // Arrange
    final json = {
      'idUsuario': 1,
      'strNombre': 'Juan',
      'strCorreo': 'juan@test.com'
    };

    // Act
    final usuario = Usuario.fromJson(json);

    // Assert
    expect(usuario.id, 1);
    expect(usuario.strNombre, 'Juan');
    expect(usuario.strCorreo, 'juan@test.com');
  });
}
```

---

## 3. Lista de Verificación (Checklist)

### 1. Características técnicas de la prueba unitaria
| Marca | Criterio | Descripción |
| :---: | :--- | :--- |
| ✔️ | **Aislamiento** | La prueba evalúa solo `Usuario.fromJson` sin depender de API ni base de datos. |
| ✔️ | **Independencia** | Puede ejecutarse sola sin afectar a otras. |
| ✔️ | **Automatización** | Se ejecuta con `flutter test`. |
| ✔️ | **Repetibilidad** | Siempre da el mismo resultado con el mismo input JSON. |
| ✔️ | **Rapidez** | Se ejecuta en milisegundos (memoria pura). |
| ❌ | **Claridad** | El nombre `'Usuario.fromJson debería crear...'` podría ser más específico sobre *qué* datos. |
| ✔️ | **Determinismo** | No usa `DateTime.now()` ni `Random()`. |
| ✔️ | **Mantenibilidad** | Es corta y fácil de leer. |

### 2. Cobertura de la prueba
| Marca | Criterio | Descripción |
| :---: | :--- | :--- |
| ✔️ | **Caso normal** | Evalúa un JSON completo y válido. |
| ❌ | **Casos límite** | No prueba qué pasa con cadenas vacías o IDs negativos. |
| ❌ | **Casos inválidos** | No prueba qué pasa si el JSON viene `null` o con tipos de datos incorrectos (ej. `id` como String). |
| ✔️ | **Condiciones lógicas** | Evalúa la asignación directa. |
| ✔️ | **Retorno esperado** | Valida que el objeto no sea nulo y tenga los datos. |

### 3. Datos y entorno de prueba
| Marca | Criterio | Descripción |
| :---: | :--- | :--- |
| ✔️ | **Datos controlados** | El mapa JSON está hardcodeado en la prueba. |
| ✔️ | **No depende de BD real** | Correcto, usa datos en memoria. |
| ✔️ | **No depende de red** | Correcto, no llama a `ApiService`. |
| ✔️ | **Limpieza del entorno** | No deja basura (objetos en memoria se limpian solos). |

### 4. Resultados y validación
| Marca | Criterio | Descripción |
| :---: | :--- | :--- |
| ✔️ | **Resultado esperado definido** | Se espera id=1, nombre='Juan'. |
| ✔️ | **Uso de aserciones** | Usa `expect(valor, esperado)`. |
| ⚠️ | **Manejo de excepciones** | El método `fromJson` usa `??` para evitar nulos, pero no lanza excepciones si el formato es crítico. |
| ✔️ | **Resultado comprensible** | Si falla, dirá "Expected: 1, Actual: 0". |

### 5. Buenas prácticas (calidad de la prueba)
| Marca | Criterio | Descripción |
| :---: | :--- | :--- |
| ❌ | **Nombre significativo** | Mejorar a: `fromJson_WithValidData_ReturnsCorrectUserObject`. |
| ✔️ | **Una validación principal** | Valida la correcta construcción del objeto. |
| ✔️ | **No duplicación** | Única prueba para este caso. |
| ✔️ | **Sigue patrón AAA** | Bloques Arrange, Act y Assert están presentes. |
| ✔️ | **Documentación mínima** | El código es autoexplicativo. |

---

## 4. Evaluación Final
**Calificación:** **Bueno (aprox. 80%)**
*   Cumple con la mayoría de criterios técnicos y de entorno.
*   Falla en cobertura de casos borde (edge cases) y nombres explícitos.

## 5. Criterio No Cumplido Detectado
**Criterio:** **Cobertura de Casos Inválidos / Límite**.
*   **Problema:** La prueba actual solo verifica el "Camino Feliz" (JSON perfecto). No verifica qué sucede si la API devuelve un JSON incompleto (ej. falta `idUsuario`), lo cual es común. Según el código `id: json['idUsuario'] ?? 0`, debería asignar 0, pero la prueba no lo confirma.

## 6. Propuesta de Mejora Concreta
Crear una nueva prueba específica para casos de atributos faltantes (Null Safety) y mejorar el nombrado.

```dart
test('fromJson_WithMissingId_AssignsDefaultZero', () {
  // Arrange: JSON sin 'idUsuario'
  final jsonIncompleto = {
    'strNombre': 'Usuario Sin ID',
    'strCorreo': 'noid@test.com'
  };

  // Act
  final usuario = Usuario.fromJson(jsonIncompleto);

  // Assert
  expect(usuario.id, 0, reason: "Debe asignar 0 si el ID no viene en el JSON");
  expect(usuario.strNombre, 'Usuario Sin ID');
});
```
