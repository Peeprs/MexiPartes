# Caso de Prueba

## Características de los casos de prueba

Un buen caso de prueba debe tener las siguientes características:

1. **Claro y entendible**: Debe poder ser comprendido por cualquier persona del equipo.
2. **Específico**: Prueba una sola función o comportamiento.
3. **Repetible**: Al ejecutarse varias veces, debe producir el mismo resultado.
4. **Trazable**: Está relacionado con un requisito o caso de uso.
5. **Medible**: El resultado esperado debe ser verificable (correcto / incorrecto).
6. **Independiente**: No debe depender de otros casos de prueba para ejecutarse.
7. **Documentado**: Debe quedar registrado para futuras pruebas.

📌 **“Si no está documentado, no es un caso de prueba”.**

---

## Explicar el proceso de documentación del plan de pruebas

El plan de pruebas es el documento que describe cómo, cuándo, qué y con qué se realizarán las pruebas del software.

### 📄 Proceso de documentación del plan de pruebas

**1. Análisis del sistema**
* Revisar requisitos
* Identificar funcionalidades críticas
* Definir alcance de las pruebas

**2. Definición del alcance**
* Qué se va a probar
* Qué no se va a probar
* Tipos de prueba a utilizar (funcional, no funcional)

**3. Estrategia de pruebas**
* Metodologías (caja negra, blanca, gris)
* Nivel de pruebas (unitarias, integración, sistema)
* Prioridades

**4. Diseño de casos de prueba**
* Identificar escenarios
* Definir datos de entrada
* Establecer resultados esperados

**5. Recursos y responsabilidades**
* Quién prueba
* Herramientas
* Ambiente de pruebas

**6. Criterios de entrada y salida**
* Cuándo iniciar pruebas
* Cuándo finalizar pruebas

📌 **Resultado**: un documento que guía todo el proceso de pruebas.

---

## Formato básico de caso de prueba

| Campo | Descripción |
| :--- | :--- |
| **ID del caso** | Identificador único |
| **Nombre** | Descripción corta |
| **Requisito** | Requisito asociado |
| **Precondición** | Estado previo |
| **Datos de entrada** | Información ingresada |
| **Pasos** | Acciones a ejecutar |
| **Resultado esperado** | Comportamiento esperado |
| **Resultado obtenido** | (opcional) |
| **Estado** | Aprobado / Fallido |

---

## Diseñar los casos de prueba de software

### Sistema: Inicio de sesión (Ejemplo)

| Campo | Contenido |
| :--- | :--- |
| **ID** | CP-01 |
| **Nombre** | Inicio de sesión válido |
| **Requisito** | RF-01 |
| **Precondición** | Usuario registrado |
| **Datos de entrada** | Usuario y contraseña válidos |
| **Pasos** | 1. Ingresar usuario<br>2. Ingresar contraseña<br>3. Clic en iniciar sesión |
| **Resultado esperado** | Acceso correcto al sistema |
| **Estado** | — |

---

## Ejemplo práctico de caso de prueba

### Actividad: “Diseñando casos de prueba para MexiPartes”

A continuación, se presentan **5 casos de prueba funcionales** diseñados para el proyecto **MexiPartes**, cubriendo las áreas de Login, Registro y Carrito de Compras.

#### 1. Caso de Prueba: Registro de Usuario Exitoso

| Campo | Contenido |
| :--- | :--- |
| **ID** | CP-MX-01 |
| **Nombre** | Registro de nuevo usuario con datos completos |
| **Requisito** | RF-Registro-01 |
| **Precondición** | El usuario no debe estar registrado previamente. Estar en la pantalla de "Crear cuenta". |
| **Datos de entrada** | Nombre válido, Correo electrónico nuevo, Contraseña segura, Confirmación de contraseña. |
| **Pasos** | 1. Llenar el campo "Nombre".<br>2. Ingresar un correo electrónico válido.<br>3. Ingresar una contraseña y confirmarla.<br>4. Aceptar términos y condiciones.<br>5. Clic en el botón "Registrarse". |
| **Resultado esperado** | El sistema crea la cuenta, muestra un mensaje de éxito y redirige a la pantalla principal o de inicio de sesión. |
| **Estado** | — |

#### 2. Caso de Prueba: Inicio de Sesión Fallido (Contraseña Incorrecta)

| Campo | Contenido |
| :--- | :--- |
| **ID** | CP-MX-02 |
| **Nombre** | Intento de inicio de sesión con contraseña errónea |
| **Requisito** | RF-Login-02 |
| **Precondición** | El usuario debe estar registrado. Estar en la pantalla de Login. |
| **Datos de entrada** | Correo electrónico registrado, Contraseña incorrecta. |
| **Pasos** | 1. Ingresar el correo electrónico del usuario.<br>2. Ingresar una contraseña incorrecta.<br>3. Clic en el botón "Iniciar Sesión". |
| **Resultado esperado** | El sistema muestra un mensaje de error indicando "Credenciales inválidas" o "Contraseña incorrecta" y no permite el acceso. |
| **Estado** | — |

#### 3. Caso de Prueba: Recuperar Contraseña (Olvido de Contraseña)

| Campo | Contenido |
| :--- | :--- |
| **ID** | CP-MX-03 |
| **Nombre** | Solicitud de restablecimiento de contraseña |
| **Requisito** | RF-Login-03 |
| **Precondición** | Estar en la pantalla de Login. |
| **Datos de entrada** | Correo electrónico registrado. |
| **Pasos** | 1. Clic en el enlace "¿Olvidaste tu contraseña?".<br>2. Ingresar el correo electrónico asociado a la cuenta.<br>3. Clic en "Enviar instrucciones". |
| **Resultado esperado** | El sistema envía un correo con un enlace o código para restablecer la contraseña y muestra un mensaje de confirmación al usuario. |
| **Estado** | — |

#### 4. Caso de Prueba: Agregar Producto al Carrito

| Campo | Contenido |
| :--- | :--- |
| **ID** | CP-MX-04 |
| **Nombre** | Agregar una refacción al carrito de compras |
| **Requisito** | RF-Carrito-01 |
| **Precondición** | El usuario debe haber iniciado sesión y estar viendo el detalle de un producto. |
| **Datos de entrada** | Selección de cantidad del producto (ej. 1 unidad). |
| **Pasos** | 1. Seleccionar la cantidad deseada del producto.<br>2. Clic en el botón "Agregar al carrito". |
| **Resultado esperado** | El icono del carrito actualiza el contador de artículos y se muestra una notificación breve confirmando que el producto fue agregado. |
| **Estado** | — |

#### 5. Caso de Prueba: Proceso de Compra (Checkout)

| Campo | Contenido |
| :--- | :--- |
| **ID** | CP-MX-05 |
| **Nombre** | Iniciar proceso de pago con artículos en el carrito |
| **Requisito** | RF-Carrito-02 |
| **Precondición** | Tener al menos un producto en el carrito de compras. |
| **Datos de entrada** | Carrito con artículos. |
| **Pasos** | 1. Ir a la pantalla del "Carrito de compras".<br>2. Verificar que los productos sean correctos.<br>3. Clic en el botón "Proceder al pago" o "Comprar". |
| **Resultado esperado** | El sistema redirige al usuario a la pantalla de selección de dirección y método de pago. |
| **Estado** | — |

---

📌 **Objetivo**: Comprender que documentar bien evita errores futuros.

💡 **Conclusión**: La documentación del plan de pruebas y los casos de prueba permiten realizar pruebas organizadas, claras y repetibles, asegurando la calidad del software y facilitando su mantenimiento.
