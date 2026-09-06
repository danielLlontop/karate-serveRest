# Suite de Automatización API — ServeRest

[![Karate DSL](https://img.shields.io/badge/Karate_DSL-1.5.2-ff6b6b.svg?logo=karate)](https://github.com/karatelabs/karate)
[![Java](https://img.shields.io/badge/Java-21-007396.svg?logo=openjdk)](https://www.oracle.com/java/)
[![Maven](https://img.shields.io/badge/Apache_Maven-3.9+-c71a36.svg?logo=apachemaven)](https://maven.apache.org/)
[![JUnit 5](https://img.shields.io/badge/JUnit-5-25a162.svg?logo=junit5)](https://junit.org/junit5/)
[![Datafaker](https://img.shields.io/badge/Datafaker-2.2.2-blue.svg)](https://www.datafaker.net/)

Suite integral de pruebas automatizadas Backend (API Testing) para la **API de Gestión de Usuarios de ServeRest** ([https://serverest.dev/](https://serverest.dev/)), desarrollada con **Karate DSL**, **Java 21**, **Datafaker** y **Apache Maven**.

El proyecto está diseñado bajo estándares de calidad empresarial: validación estricta de esquemas JSON (Contract Testing), generación dinámica de datos de prueba con patrón Data Factory, aislamiento total de escenarios para ejecución concurrente y cobertura exhaustiva de operaciones CRUD, casos borde y reglas de integridad referencial.

---

## 🚀 Guía Rápida para el Evaluador (Quick Start)

Para clonar y ejecutar toda la suite de pruebas en menos de 2 minutos:

```bash
# 1. Clonar el repositorio
git clone https://github.com/danielLlontop/karate-serveRest.git
cd karate-serveRest

# 2. Ejecutar la suite completa en paralelo con Maven
mvn clean test

# 3. Abrir el reporte interactivo de Karate en el navegador
# En Windows (PowerShell / CMD):
start target/karate-reports/karate-summary.html
```

---

## 🎯 Alcance y Escenarios Automatizados

La suite cubre al 100% las historias de usuario y criterios de aceptación solicitados para el recurso `/usuarios`, ejecutando **21 escenarios de prueba**:

| Endpoint | Feature / Tag | Tipo | Descripción y Validaciones Clave |
|---|---|---|---|
| `GET /usuarios` | `get-users.feature`<br>`@EC01 @EC02` | Happy Path | 1. Listado general de usuarios, validación de contrato `users-list.schema.json` y conteo de registros (`quantidade`).<br>2. Filtrado por query param (`administrador=true`) verificando que cada item cumpla la condición. |
| `GET /usuarios/{_id}` | `get-users.feature`<br>`@EC03 - @EC05` | Happy Path / Negative | 1. Consulta por ID existente con esquema `user-info.schema.json`.<br>2. ID inexistente (`400 Bad Request` - `Usuário não encontrado`).<br>3. ID con longitud inválida distinta a 16 caracteres (`400 Bad Request`). |
| `POST /usuarios` | `post-users.feature`<br>`@EC06 - @EC08` | Happy Path / Negative | 1. Registro exitoso con payload dinámico generado por Datafaker (`201 Created`).<br>2. Intento de registro con email duplicado (`400 Bad Request`).<br>3. Parametrización (Scenario Outline) de emails inválidos (sin arroba, sin extensión, sin usuario, doble arroba). |
| `PUT /usuarios/{_id}` | `put-users.feature`<br>`@EC09 - @EC12` | Happy Path / Edge Cases | 1. Actualización de datos de usuario existente (`200 OK`).<br>2. Validación de emails inválidos en actualización (Scenario Outline).<br>3. Comportamiento **Upsert**: creación de usuario cuando el ID no existe (`201 Created`).<br>4. Bloqueo de Upsert si el email coincide con otro usuario ya registrado (`400 Bad Request`). |
| `DELETE /usuarios/{_id}` | `delete-users.feature`<br>`@EC13 - @EC15` | Happy Path / Edge Cases | 1. Eliminación exitosa de usuario aprovisionado dinámicamente (`200 OK`).<br>2. **Idempotencia**: intento de eliminar ID inexistente (`200 OK` - `Nenhum registro excluído`).<br>3. **Integridad referencial**: bloqueo de eliminación si el usuario posee un carrito de compras activo (`400 Bad Request`). |

---

## 🏗 Arquitectura del Proyecto

El proyecto sigue una estructura limpia, modular y desacoplada respetando las convenciones de Karate DSL y Maven:

```text
karate-ServeRest/
├── pom.xml                               # Dependencias (Karate 1.5.2, Datafaker, JUnit 5)
├── README.md                             # Guía principal de uso e instalación
├── ESTRATEGIA.md                         # Informe técnico de arquitectura y patrones (Entregable 3)
└── src/test/java/
    ├── env-config.json                   # Configuración de URLs por ambiente (dev, local, qa)
    ├── karate-config.js                  # Inicialización global (timeouts, headers, setup)
    ├── logback-test.xml                  # Configuración de niveles de log en consola y archivo
    ├── utils/
    │   └── DataGenerator.java            # Data Factory Pattern con Datafaker (Español)
    └── serveRest/
        ├── RunnerTest.java               # Runner principal JUnit 5 para ejecución en paralelo
        ├── data/
        │   └── users/                    # Contratos de Esquemas JSON
        │       ├── user-info.schema.json
        │       ├── users-list.schema.json
        │       └── user-create-response.schema.json
        └── features/
            ├── carts/
            │   ├── carts.feature         # Helper de carritos para pruebas de integridad referencial
            │   └── CartsRunner.java      # Runner JUnit específico para carritos
            ├── common/
            │   └── common-utils.feature  # Funciones utilitarias JS reutilizables
            └── users/                    # Especificaciones BDD por endpoint CRUD
                ├── get-users.feature     # Escenarios GET (Listado general y por ID)
                ├── post-users.feature    # Escenarios POST (Creación y validaciones)
                ├── put-users.feature     # Escenarios PUT (Actualización y Upsert)
                ├── delete-users.feature  # Escenarios DELETE (Eliminación e integridad)
                └── UsersRunner.java      # Runner JUnit modular para Usuarios
```

---

## 💡 Aspectos Técnicos Destacados para la Evaluación

1. **Data Factory Pattern con Datafaker (`DataGenerator.java`):**
   * Desacoplamiento total de datos quemados (*hardcoded*). Utiliza `net.datafaker.Faker` configurado en idioma español (`Locale.of("es")`) para producir nombres, emails seguros, contraseñas robustas y roles aleatorios en cada petición.
2. **Aislamiento Total e Independencia de Pruebas (Zero Flaky Tests):**
   * Ningún escenario depende del estado previo de la base de datos pública. Los escenarios de `PUT` y `DELETE` aprovisionan su propio registro en tiempo de ejecución utilizando el helper modular `@CreateUserHelper`, asegurando que las pruebas corran en cualquier orden y en paralelo sin colisiones.
3. **Contract Testing con Validación Estricta de Esquemas JSON:**
   * Todas las respuestas exitosas y de listado se validan contra archivos `.schema.json` externos mediante `match response == schema`.
   * Incluye expresiones regulares estrictas (e.g. IDs alfanuméricos de 16 caracteres: `'#regex ^[a-zA-Z0-9]{16}$'`).
4. **Pruebas Parametrizadas (Data-Driven Testing con `Scenario Outline`):**
   * Validación sistemática de sintaxis de email en `POST` y `PUT` probando casos borde: sin extensión (`user@domain`), sin arroba (`userdomain.com`), sin nombre de usuario (`@domain.com`) y con doble arroba (`user@@domain.com`).
5. **Manejo de Reglas de Negocio Avanzadas y Casos Borde:**
   * **Comportamiento Upsert:** Validación de creación dinámica cuando no existe el ID en `PUT`.
   * **Idempotencia:** Verificación del estándar REST donde `DELETE` sobre recurso no existente responde `200 OK`.
   * **Integridad Referencial:** Uso de `carts.feature` para interceptar usuarios con carritos activos y comprobar el bloqueo de eliminación con `400 Bad Request`.
6. **Ejecución Paralela de Alto Rendimiento:**
   * Configuración concurrente con JUnit 5 Runner (`RunnerTest.java`). Los 21 escenarios se completan en aproximadamente **10 a 11 segundos**.

---

## 📊 Reportes y Trazabilidad (Observabilidad)

Karate genera automáticamente un reporte HTML interactivo con el registro exacto de cabeceras HTTP, cuerpos de petición/respuesta y tiempos de latencia por petición:

* **Reporte Resumen (HTML):**
  ```text
  target/karate-reports/karate-summary.html
  ```
* **Reporte Detallado por Endpoint:**
  ```text
  target/karate-reports/serveRest.features.users.[get|post|put|delete]-users.html
  ```

Para abrir el reporte tras finalizar:

```bash
# En Windows PowerShell / CMD:
start target/karate-reports/karate-summary.html
```

---

## ⌨️ Comandos de Ejecución con Maven

| Comando | Descripción |
|---|---|
| `mvn clean test` | Ejecuta **toda la suite de pruebas** en paralelo. |
| `mvn test "-Dkarate.options=--tags @UsersCRUD"` | Ejecuta todas las operaciones CRUD de Usuarios. |
| `mvn test "-Dkarate.options=--tags @GetUsers"` | Ejecuta únicamente los escenarios de consulta (`GET`). |
| `mvn test "-Dkarate.options=--tags @PostUsers"` | Ejecuta únicamente los escenarios de creación (`POST`). |
| `mvn test "-Dkarate.options=--tags @PutUsers"` | Ejecuta únicamente los escenarios de edición/upsert (`PUT`). |
| `mvn test "-Dkarate.options=--tags @DeleteUsers"` | Ejecuta únicamente los escenarios de eliminación (`DELETE`). |
| `mvn test "-Dkarate.options=--tags @HappyPath"` | Filtra y ejecuta exclusivamente escenarios exitosos. |
| `mvn test "-Dkarate.options=--tags @NegativeCase"` | Filtra y ejecuta exclusivamente escenarios negativos de error. |
| `mvn test "-Dkarate.options=--tags @EdgeCase"` | Filtra y ejecuta casos borde (upsert, idempotencia). |
| `mvn test -Dthreads=4` | Ajusta la cantidad de hilos de ejecución concurrente en paralelo. |
| `mvn test -Dkarate.env=dev` | Selecciona el ambiente de ejecución (`dev`, `qa`, `local`). |

---

## 👤 Autor

* **Daniel Llontop** — QA Automation Engineer
* **Email:** danielalama64@gmail.com
* **Documento de Estrategia Técnica:** Consulta [ESTRATEGIA.md](ESTRATEGIA.md) para conocer el análisis de decisiones de diseño, patrones de arquitectura de API y gestión de riesgos.
