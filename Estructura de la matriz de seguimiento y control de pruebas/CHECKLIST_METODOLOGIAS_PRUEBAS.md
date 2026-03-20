# Listas de Verificación para Metodologías de Prueba

Esta guía proporciona checklists prácticos para aplicar diferentes enfoques de prueba (Caja Negra, Blanca y Gris) al desarrollo de software.

---

## ⚫ 1. Pruebas de Caja Negra (Black Box)
**Enfoque:** Funcionalidad y requisitos, desde la perspectiva del usuario final, sin ver el código interno.

### ✅ Preguntas guía / Checklist

#### Sobre requisitos y funciones
- [ ] **¿La funcionalidad cumple con el requisito especificado?**  
  *(Ej. Si el requisito es "filtrar por año", ¿realmente filtra los resultados incorrectos?)*
- [ ] **¿El sistema responde correctamente a entradas válidas?**
- [ ] **¿Se muestran mensajes claros ante errores?**  
  *(Ej. En lugar de "Error 500", ¿dice "Producto no encontrado"?)*
- [ ] **¿El sistema maneja correctamente entradas inválidas?**

#### Sobre entradas y salidas
- [ ] **¿Se validan campos obligatorios?**
- [ ] **¿Se aceptan solo los formatos correctos?**  
  *(Ej. Email debe tener @, Tarjeta debe tener 16 dígitos)*
- [ ] **¿Las salidas son correctas y comprensibles?**

#### Sobre comportamiento
- [ ] **¿El sistema mantiene la consistencia al repetir la acción?**
- [ ] **¿Qué ocurre si el usuario omite un paso?**
- [ ] **¿El sistema se comporta como el usuario espera?**

📌 **Ideal para:** Pruebas funcionales, pruebas de aceptación de usuario (UAT) y pruebas de sistema.

---

## ⚪ 2. Pruebas de Caja Blanca (White Box)
**Enfoque:** Estructura interna, flujo lógico y código fuente. Requiere conocimientos de programación.

### ✅ Preguntas guía / Checklist

#### Sobre el código
- [ ] **¿Se ejecutan todas las rutas posibles del programa?**  
  *(Coverage de código)*
- [ ] **¿Las condiciones (if, else) se evalúan correctamente?**
- [ ] **¿Los ciclos (for, while) terminan adecuadamente?**  
  *(Evitar loops infinitos)*
- [ ] **¿Se cubren casos límite (valores extremos)?**  
  *(Ej. Listas vacías, números negativos, nulls)*

#### Sobre calidad del código
- [ ] **¿Existen variables sin uso o código muerto?**
- [ ] **¿El código es legible y bien estructurado?**
- [ ] **¿Se manejan correctamente las excepciones (try-catch)?**

#### Sobre seguridad y control
- [ ] **¿Hay validaciones antes de procesar datos?**
- [ ] **¿Se evitan accesos no autorizados a nivel de función?**
- [ ] **¿Se previenen errores por datos nulos (NullPointer)?**

📌 **Ideal para:** Pruebas unitarias, revisión de código (Code Review) y análisis estático.

---

## 🔘 3. Pruebas de Caja Gris (Gray Box)
**Enfoque:** Híbrido. Combina la visión del usuario (funcional) con conocimiento parcial de la arquitectura interna (bases de datos, APIs).

### ✅ Preguntas guía / Checklist

#### Sobre integración
- [ ] **¿La comunicación entre módulos es correcta?**  
  *(Ej. El Frontend envía el JSON correcto al Backend)*
- [ ] **¿Los datos se transfieren correctamente entre capas?**
- [ ] **¿Las consultas a la base de datos son consistentes?**  
  *(Verificar en la BD si el registro realmente se guardó)*

#### Sobre lógica interna
- [ ] **¿El sistema maneja correctamente estados intermedios?**  
  *(Ej. "Cargando", "Pendiente de pago")*
- [ ] **¿Qué ocurre si un servicio externo falla?**  
  *(Ej. Si se cae la API de pagos, ¿la app explota o avisa?)*
- [ ] **¿Existen dependencias no controladas?**

#### Sobre seguridad y datos
- [ ] **¿Se protegen los datos sensibles en tránsito y reposo?**
- [ ] **¿Se controla el acceso según el rol del usuario?**  
  *(Ej. Un usuario normal no debe poder borrar productos)*
- [ ] **¿Hay riesgos de inyección SQL o manipulación de datos?**

📌 **Ideal para:** Pruebas de integración, pruebas de API y auditorías de seguridad básica.

---

## 👩‍🏫 Cómo usar estas listas (Actividad Sugerida)

**Actividad rápida (30–40 min):**
1.  **Evaluación:** Toma una funcionalidad de tu proyecto (ej. "Login") y evalúala pasando por los 3 checklists.
2.  **Comparación:**
    *   ¿Qué errores encontró la Caja Negra? (Probablemente errores de diseño/UX).
    *   ¿Qué errores encontró la Caja Blanca? (Probablemente bugs lógicos o fallas de validación).
3.  **Reflexión:** Comparte las diferencias con tu equipo.

> ✨ **Tip clave:**
> "La **caja negra** ve lo que el usuario ve,
> la **caja blanca** ve lo que el programador escribe,
> y la **caja gris** ve cómo todo se conecta."
