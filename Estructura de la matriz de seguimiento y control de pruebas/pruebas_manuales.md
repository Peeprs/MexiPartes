# PRUEBAS MANUALES

## ¿QUÉ SON LAS PRUEBAS MANUALES?

Las pruebas manuales son aquellas en las que el **tester ejecuta directamente los casos de prueba**, sin apoyo de herramientas de automatización, interactuando con el sistema como lo haría un usuario final.

### Objetivo

Su objetivo es verificar y validar que el software:

- ✅ Cumple con los requisitos establecidos
- ✅ Funciona correctamente
- ✅ Es usable, confiable y de calidad

---

## TIPOS DE PRUEBAS MANUALES

### 1️⃣ Pruebas Funcionales

**Función:** Verifican que cada función del sistema haga lo que debe hacer.

**Ejemplos:**
- Registro de usuario
- Inicio de sesión
- Generación de reportes

### 2️⃣ Pruebas de Integración

**Función:** Evalúan la interacción entre módulos o componentes del sistema.

**Ejemplo:**
- El módulo de ventas se comunica correctamente con el módulo de inventarios

### 3️⃣ Pruebas de Sistema

**Función:** Validan el sistema completo funcionando como una sola unidad.

**Ejemplo:**
- Flujo completo desde: Registro → Compra → Pago → Confirmación

### 4️⃣ Pruebas Exploratorias

**Función:** El tester explora el sistema sin casos estrictos, basándose en experiencia e intuición.

**Ejemplo:**
- Probar combinaciones inesperadas de acciones del usuario

### 5️⃣ Pruebas de Humo (Smoke Testing)

**Función:** Verifican rápidamente las funcionalidades más básicas del sistema.

**Ejemplos:**
- El sistema abre
- Se puede iniciar sesión

### 6️⃣ Pruebas de Sanidad (Sanity Testing)

**Función:** Evalúan rápidamente que un cambio específico funciona correctamente.

**Ejemplo:**
- Verificar solo el módulo corregido

---

## CRITERIOS DE DESEMPEÑO EN LAS PRUEBAS MANUALES

Los criterios de desempeño permiten **medir la calidad de las pruebas**, no solo del software.

| Criterio | Descripción |
|----------|-------------|
| **Cobertura** | Grado en que se prueban funcionalidades y requisitos |
| **Efectividad** | Capacidad de detectar errores reales |
| **Repetibilidad** | Que la prueba pueda ejecutarse nuevamente con el mismo resultado |
| **Claridad** | Casos de prueba comprensibles y bien documentados |
| **Trazabilidad** | Relación entre requisitos y pruebas |
| **Tiempo de ejecución** | Esfuerzo y tiempo requerido |
| **Resultados esperados** | Claridad en los resultados previstos |

---

## DIFERENCIAR LOS CRITERIOS DE DESEMPEÑO

### Preguntas Clave:

- 🔹 **Cobertura** → ¿Qué tanto del sistema se prueba?
- 🔹 **Efectividad** → ¿Qué tan buenos somos encontrando errores?
- 🔹 **Repetibilidad** → ¿Otro tester puede ejecutar la misma prueba?
- 🔹 **Claridad** → ¿Las instrucciones se entienden sin explicación adicional?
- 🔹 **Trazabilidad** → ¿La prueba está ligada a un requisito?
- 🔹 **Tiempo** → ¿La prueba es eficiente o consume demasiado recurso?

---

## COMPARACIÓN DE CRITERIOS DE DESEMPEÑO

| Criterio | En Pruebas Bien Diseñadas | En Pruebas Deficientes |
|----------|---------------------------|------------------------|
| **Cobertura** | Se prueban todos los módulos | Se omiten funciones |
| **Efectividad** | Se detectan errores críticos | Los errores llegan a producción |
| **Repetibilidad** | Cualquier tester la ejecuta | Depende de la persona |
| **Claridad** | Pasos claros y ordenados | Ambigüedad |
| **Trazabilidad** | Relación directa con requisitos | No se sabe qué se prueba |
| **Tiempo** | Optimizado | Excesivo |

---

## DETERMINAR LOS CRITERIOS DE DESEMPEÑO DE UNA APLICACIÓN

### Pasos:

1. Analizar los requisitos del sistema
2. Identificar funcionalidades críticas
3. Definir qué se evaluará en cada prueba
4. Establecer métricas simples

### Ejemplo de Criterios Definidos:

- ✅ Cobertura mínima del 90%
- ✅ Todos los casos deben tener resultado esperado
- ✅ Tiempo máximo de ejecución por prueba: 10 minutos
- ✅ Evidencia de ejecución (captura o comentario)

---

## DISEÑAR PRUEBAS MANUALES DE UNA APLICACIÓN DE SOFTWARE

### ESTRUCTURA DE UN CASO DE PRUEBA MANUAL

| Elemento | Descripción | Ejemplo |
|----------|-------------|---------|
| **ID del caso** | Identificador único | CP-01 |
| **Nombre del caso** | Título descriptivo | Inicio de sesión válido |
| **Módulo** | Parte del sistema | Autenticación |
| **Requisito asociado** | Trazabilidad | RF-01 |
| **Precondición** | Estado previo del sistema | Usuario registrado |
| **Pasos de ejecución** | Instrucciones detalladas | 1. Ingresar usuario<br>2. Ingresar contraseña<br>3. Clic en ingresar |
| **Resultado esperado** | Comportamiento esperado | Acceso exitoso |
| **Resultado obtenido** | Comportamiento real | (Se llena al ejecutar) |
| **Estado** | Aprobado / Fallido | Aprobado |
| **Evidencia** | Captura, comentario | (Opcional) |
| **Observaciones** | Comentarios adicionales | (Opcional) |
| **Tester** | Responsable de la ejecución | Alejandro Vargas |
| **Fecha** | Cuándo se ejecutó | 09/02/2026 |

---

## EJEMPLOS DE OBSERVACIONES

### ✅ Caso Exitoso

> **Observaciones:** El inicio de sesión se realizó correctamente. No se detectaron errores funcionales. La respuesta del sistema fue inmediata.

### ⚠️ Caso con Advertencia

> **Observaciones:** El usuario inició sesión correctamente; sin embargo, el tiempo de respuesta fue ligeramente mayor a lo esperado (aprox. 4 segundos). Podría afectar la experiencia del usuario.

### ❌ Caso Fallido

> **Observaciones:** El sistema no permitió el acceso con credenciales válidas. No se mostró mensaje de error. Se recomienda revisar la validación del formulario.

---

## DIFERENCIA ENTRE CASO DE PRUEBA Y PRUEBAS MANUALES

La diferencia no está en los campos, sino en:
- 🔹 **El énfasis**
- 🔹 **El nivel de detalle**
- 🔹 **Los criterios de desempeño**

### En las "Pruebas Manuales"

**Enfoque:** Ejecución, desempeño y control

El caso de prueba se ve como:
- Una **herramienta operativa** para evaluar la calidad del software
- Por eso se amplía para incluir **criterios de desempeño**

---

## PROPÓSITO DE CADA CAMPO EN PRUEBAS MANUALES

| Campo | ¿Para Qué Sirve Aquí? |
|-------|------------------------|
| **Precondiciones** | Garantizar repetibilidad |
| **Datos de prueba** | Control de entradas |
| **Resultado obtenido** | Evidenciar resultado real |
| **Estado** | Métrica de avance |
| **Observaciones** | Calidad y análisis |
| **Fecha/Tester** | Trazabilidad del proceso |

### Preguntas que Responde el Campo "Observaciones":

- ❓ ¿Ocurrió algo inesperado?
- ❓ ¿Hubo algo que pudiera mejorar?
- ❓ ¿Se detecta algún riesgo futuro?
- ❓ ¿La experiencia del usuario fue adecuada?

---

## PLANTILLA DE CASO DE PRUEBA

```
ID: CP-___
Nombre: _____________________
Módulo: _____________________
Requisito: RF-___

Precondición:
_____________________________

Pasos:
1. _________________________
2. _________________________
3. _________________________

Resultado Esperado:
_____________________________

Resultado Obtenido:
_____________________________

Estado: [ ] Aprobado  [ ] Fallido

Observaciones:
_____________________________

Tester: _______________
Fecha: ___/___/______
```

---

## CONCLUSIÓN

Las pruebas manuales son una herramienta fundamental para garantizar la calidad del software. Su correcta planificación, ejecución y documentación permiten:

- ✅ Detectar errores antes de producción
- ✅ Validar que el sistema cumple con los requisitos
- ✅ Mejorar la experiencia del usuario
- ✅ Establecer métricas de calidad medibles

**Recuerda:** Un buen caso de prueba debe ser claro, repetible, trazable y eficiente.
