# Evaluación del Modelo de Calidad de Software de McCall - MexiPartes

A continuación se presenta la evaluación del proyecto bajo los criterios del Modelo de McCall, con su respectiva justificación basada en la arquitectura y desarrollo del proyecto.

### 1. Factores de Operación del Producto (Experiencia de uso)

| Factor | Cumple | Justificación en MexiPartes |
| :--- | :---: | :--- |
| **Corrección**<br>*(Correctness)* | ✅ | El software cumple estrictamente con el requisito de filtrar refacciones por vehículo (módulo "Mi Garage"), validado mediante pruebas funcionales y retrospectivas Scrum. |
| **Fiabilidad**<br>*(Reliability)* | ✅ | Se reporta una densidad de defectos baja y estabilidad en el despliegue gracias al ciclo de desarrollo iterativo que corrigió fallas tempranamente. |
| **Eficiencia**<br>*(Efficiency)* | ✅ | El uso de **Flutter** permite un rendimiento nativo (60fps), optimizando el uso de memoria y CPU en dispositivos móviles comparado con soluciones web híbridas. |
| **Integridad**<br>*(Integrity)* | ✅ | Implementa autenticación de usuarios y gestión segura de sesiones para proteger la información personal y los historiales de vehículos ("Mi Garage"). |
| **Usabilidad**<br>*(Usability)* | ✅ | Diseño centrado en el usuario con **Modo Oscuro** y micro-interacciones. Se validó que usuarios sin conocimientos técnicos pueden encontrar piezas fácilmente. |

### 2. Factores de Revisión del Producto (Facilidad de cambio)

| Factor | Cumple | Justificación en MexiPartes |
| :--- | :---: | :--- |
| **Facilidad de Mantenimiento**<br>*(Maintainability)* | ✅ | El uso de la arquitectura **MVVM** separa la lógica de negocio de la interfaz (UI), permitiendo corregir errores en una capa sin afectar a la otra. |
| **Flexibilidad**<br>*(Flexibility)* | ✅ | La estructura modular de Flutter (Widgets) y MVVM permite agregar nuevas características (ej. nuevos filtros o categorías) sin reescribir el sistema base. |
| **Facilidad de Prueba**<br>*(Testability)* | ✅ | La separación de capas en MVVM facilita la creación de pruebas unitarias para los ViewModels y repositorios de datos aislados de la vista. |

### 3. Factores de Transición del Producto (Adaptabilidad a nuevos entornos)

| Factor | Cumple | Justificación en MexiPartes |
| :--- | :---: | :--- |
| **Portabilidad**<br>*(Portability)* | ✅ | Gracias a **Flutter**, el mismo código fuente se compila y ejecuta nativamente tanto en sistemas **iOS** como en **Android**. |
| **Reusabilidad**<br>*(Reusability)* | ✅ | Los componentes gráficos (Widgets) y los servicios de datos fueron diseñados para ser reutilizables en diferentes pantallas de la aplicación. |
| **Interoperabilidad**<br>*(Interoperability)* | ✅ | La aplicación está diseñada para consumir datos de servicios externos (APIs de inventario) e interactuar con servicios nativos del teléfono. |
