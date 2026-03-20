# Estructura de la Matriz de Seguimiento y Control de Pruebas

La Matriz de Seguimiento y Control de Pruebas es una herramienta esencial para documentar la trazabilidad entre los requisitos de software y las pruebas realizadas, asegurando que cada funcionalidad crítica haya sido validada antes del despliegue.

## Estructura General

| ID Prueba | Requisito | Módulo | Tipo de Prueba | Caso de Prueba | Resultado Esperado | Resultado Obtenido | Estado | Observaciones |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **Identificador** | **ID Funcional** | **Componente** | **(Unitaria / Integración / Sistema)** | **Descripción breve** | **Comportamiento correcto** | **Lo que realmente sucedió** | **(Aprobada / Rechazada / Bloqueada)** | **Notas adicionales** |

---

## Ejemplo: Matriz Aplicada al Proyecto Mexipartes (Caso de Estudio)

A continuación, se presenta la matriz diligenciada con las pruebas diseñadas en las actividades anteriores (Unitaria, Integración y Sistema).

### Matriz de Pruebas - Proyecto Mexipartes

| ID Prueba | Requisito | Módulo | Tipo de Prueba | Caso de Prueba | Resultado Esperado | Resultado Obtenido | Estado | Observaciones |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **PT-01** | **RQ-01 (Auth)** | **Usuario (Modelo)** | **Unitaria** | Crear objeto `Usuario` desde un JSON válido y completo | Objeto instanciado con ID y nombre correctos | Objeto instanciado correctamente con ID=1 | **✔️ Aprobada** | Prueba de "Camino Feliz" (Happy Path) |
| **PT-02** | **RQ-01 (Auth)** | **Usuario (Modelo)** | **Unitaria** | Crear objeto `Usuario` desde un JSON incompleto (sin ID) | Asignar ID=0 por defecto (Null Safety) | Asignó ID=0 correctamente | **✔️ Aprobada** | Riesgo mitigado por operador `??` en código |
| **PT-03** | **RQ-02 (Sesión)** | **AuthProvider + ApiService** | **Integración** | Iniciar sesión con credenciales válidas contra API real | `isAuthenticated` cambia a `true` y `usuarioActual` != null | Autenticación exitosa y estado actualizado | **✔️ Aprobada** | **Observación Crítica:** Prueba depende de disponibilidad de red e internet |
| **PT-04** | **RQ-02 (Sesión)** | **AuthProvider** | **Integración** | Iniciar sesión con contraseña incorrecta | Retornar `false` y mensaje de error claro | Retornó `false` con mensaje "Datos incorrectos" | **✔️ Aprobada** | — |
| **PT-05** | **RQ-03 (Registro)** | **App Completa (Frontend+Backend)** | **Sistema** | Registro de nuevo usuario (Flujo E2E) con datos únicos | Usuario creado en BD y redirección a Home | Usuario creado, redirigido a Home | **✔️ Aprobada** | Se requiere limpiar el usuario de prueba manualmente en BD después |
| **PT-06** | **RQ-03 (Registro)** | **App Completa** | **Sistema** | Registro con correo ya existente (Duplicado) | Mostrar alerta "El correo ya está registrado" | Alerta mostrada correctamente | **✔️ Aprobada** | Validado que la API retorna 400 Bad Request |
| **PT-07** | **RQ-04 (UI)** | **Pantalla Login** | **Funcional** | Intentar login con campos vacíos | Botón deshabilitado o mensaje de validación | Mensaje "Campo requerido" en rojo | **✔️ Aprobada** | Validación de formulario de Flutter funciona bien |

---

## Leyenda de Estados
*   **Aprobada:** El resultado obtenido coincide con el esperado.
*   **Rechazada:** El resultado obtenido difiere del esperado (Bug/Defecto encontrado).
*   **Bloqueada:** La prueba no pudo ejecutarse por factores externos (ej. servidor caído).
