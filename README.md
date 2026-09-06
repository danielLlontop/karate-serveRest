# 🚀 ServeRest API Automation Suite - Karate DSL

Suite de pruebas automatizadas end-to-end para la **API de Gestión de Usuarios de ServeRest** ([https://serverest.dev/](https://serverest.dev/)), desarrollada con **Karate DSL**.

---

## 📋 Tabla de Contenidos

1. [Objetivo del Proyecto](#-objetivo-del-proyecto)
2. [Stack Tecnológico](#-stack-tecnológico)
3. [Arquitectura del Proyecto](#-arquitectura-del-proyecto)
4. [Estrategia de Automatización y Patrones](#-estrategia-de-automatización-y-patrones-utilizados)
5. [Hallazgos y Escenarios Adicionales Descubiertos](#-hallazgos-y-escenarios-adicionales-descubiertos)
6. [Prerrequisitos y Configuración](#-prerrequisitos-y-configuración)
7. [Comandos de Ejecución](#-comandos-de-ejecución)
8. [Reportes de Ejecución](#-reportes-de-ejecución)

---

## 🎯 Objetivo del Proyecto

Construir una solución robusta, escalable y mantenible para validar las operaciones CRUD sobre el recurso `/usuarios` de la API de ServeRest, cubriendo:

- Listado general y filtrado de usuarios (`GET /usuarios`).
- Creación de usuarios (`POST /usuarios`).
- Consulta individual por identificador (`GET /usuarios/{_id}`).
- Actualización y Upsert de usuarios (`PUT /usuarios/{_id}`).
- Eliminación de usuarios (`DELETE /usuarios/{_id}`).

---

## 🛠️ Stack Tecnológico

- **Framework de Pruebas:** [Karate DSL](https://github.com/karatelabs/karate) `1.5.2`
- **Lenguaje Base:** Java `21`
- **Gestor de Dependencias / Build:** Apache Maven `3.9+`
- **Motor de Datos de Prueba:** [Datafaker](https://www.datafaker.net/) `2.2.2` (Localizado en Español)
- **Motor de Ejecución:** JUnit 5
- **Reportería:** Karate Built-in HTML Reports

---

## 📂 Arquitectura del Proyecto

El proyecto sigue una arquitectura modular orientada a la separación de responsabilidades y cumplimiento de especificaciones por endpoint:

```text
karate-ServeRest/
├── src/test/java/
│   ├── env-config.json                   # Configuración de ambientes (dev, local, qa)
│   ├── karate-config.js                  # Setup global (headers, timeouts, logs)
│   ├── logback-test.xml                  # Configuración de logs de ejecución
│   ├── utils/
│   │   └── DataGenerator.java            # Factory pattern para payloads y datos dinámicos
│   └── serveRest/
│       ├── RunnerTest.java               # Runner paralelo principal para Maven / CI
│       ├── data/
│       │   └── users/                    # Esquemas de contrato JSON
│       │       ├── user-info.schema.json
│       │       ├── users-list.schema.json
│       │       └── user-create-response.schema.json
│       └── features/
│           ├── carts/
│           │   ├── carts.feature         # Helper de carritos para pruebas de dependencias
│           │   └── CartsRunner.java      # Runner JUnit específico de carritos
│           ├── common/
│           │   └── common-utils.feature  # Funciones utilitarias JS compartidas
│           └── users/
│               ├── get-users.feature     # Escenarios GET (Listado y por ID)
│               ├── post-users.feature    # Escenarios POST (Creación y validaciones)
│               ├── put-users.feature     # Escenarios PUT (Actualización y Upsert)
│               ├── delete-users.feature  # Escenarios DELETE (Eliminación e integridad)
│               └── UsersRunner.java      # Runner JUnit específico para módulo Usuarios
├── pom.xml                               # Configuración de dependencias y plugins Maven
└── README.md                             # Documentación técnica y guía de ejecución
```

---

## 🧠 Estrategia de Automatización y Patrones Utilizados

### 1. Principio DRY (Don't Repeat Yourself) & Data Factory Pattern

- Se implementó `DataGenerator.java` con el patrón **Factory** (`buildUserPayload()`) que genera mapas de datos listos para ser transformados a JSON por Karate.

### 2. Aislamiento e Independencia de Pruebas (Self-Contained Dynamic Data)

- **Cero dependencia del orden de ejecución:** Los escenarios de `PUT` y `DELETE` no asumen la existencia de registros previos en la base de datos pública ni borran usuarios de otros flujos.
- Utilizan helpers modulares (`@CreateUserHelper`) para aprovisionar su propia data previa en tiempo de ejecución, eliminando falsos positivos (*flaky tests*) durante la ejecución concurrente en paralelo.

### 3. Validación de Contratos y Esquemas (Contract Testing)

- Cada respuesta es validada rigurosamente contra esquemas JSON (`.schema.json`) centralizados.
- Se valida la integridad estructural, tipos de datos y reglas de negocio complejas mediante expresiones regulares (para IDs alfanuméricos de 16 caracteres, expresiones de email y booleanos).

### 4. Inyección Global de Configuración

- Los headers estándar (`Accept: application/json`), timeouts de conexión/lectura y opciones de prettify de peticiones se gestionan de manera centralizada en `karate-config.js`, desacoplando la infraestructura de la lógica de negocio de los `.feature`.

---

## 🔍 Hallazgos y Escenarios Adicionales Descubiertos

Durante el análisis exploratorio y diseño de cobertura de la API, se identificaron comportamientos y reglas de negocio críticas no explícitas en el requerimiento básico, las cuales fueron cubiertas mediante escenarios dedicados:

| Escenario      | Endpoint                   | Tipo                 | Hallazgo / Comportamiento Validado                                                                                                                                                                                                                                                                    |
| -------------- | -------------------------- | -------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **EC05** | `GET /usuarios/{_id}`    | Negative             | **Validación de longitud de ID:** La API rechaza IDs que no tengan exactamente 16 caracteres alfanuméricos retornando `400 Bad Request` y mensaje descriptivo `id deve ter exatamente 16 caracteres alfanuméricos`.                                                                      |
| **EC08** | `POST /usuarios`         | Negative             | **Validación estricta de sintaxis de Email:** Pruebas con correos sin extensión, sin arroba o caracteres duplicados retornan `400 Bad Request` con mensaje de validación correspondiente.                                                                                                  |
| **EC12** | `PUT /usuarios/{_id}`    | Edge Case            | **Upsert con colisión de unicidad:** Al realizar `PUT` con un ID inexistente, la API intenta crear el registro (Upsert); sin embargo, si el email ya pertenece a otro usuario registrado, la API bloquea la creación retornando `400 Bad Request` (`Este email já está sendo usado`). |
| **EC14** | `DELETE /usuarios/{_id}` | Edge Case            | **Idempotencia en Eliminación:** Intentar eliminar un ID inexistente no genera error 404, sino que responde `200 OK` con el mensaje informativo `Nenhum registro excluído`, respetando la naturaleza idempotente del método DELETE en esta API.                                          |
| **EC15** | `DELETE /usuarios/{_id}` | Negative / Integrity | **Integridad Referencial con Carritos:** No se permite eliminar usuarios que tengan un carrito de compras asociado (`400 Bad Request`). Se utiliza `carts.feature` dinámicamente para localizar usuarios bloqueados por carritos activos.                                                  |

---

## ⚙️ Prerrequisitos y Configuración

- **Java JDK:** Versión 21 instalada y configurada en el `PATH` (`JAVA_HOME`).
- **Maven:** Versión 3.9 o superior.
- **Conexión a Internet:** Para conectarse al entorno público `https://serverest.dev`.

Verificar versiones instaladas:

```bash
java -version
mvn -version
```

---

## 🚀 Comandos de Ejecución

### 1. Ejecución de la Suite Completa en Paralelo

Ejecuta todos los escenarios de prueba utilizando el runner optimizado JUnit 5:

```bash
mvn clean test
```

### 2. Ejecución por Tags (Filtrado de Pruebas)

Permite segmentar la ejecución por tipo de prueba o flujo:

- **Por Funcionalidad en General (CRUD - 4 features):**
  ```Shell
  mvn test -Dkarate.options="--tags @UsersCRUD"
  ```
- **Por Endpoint Específico (feature):**
  ```Shell
  mvn test -Dkarate.options="--tags @PostUsers"
  mvn test -Dkarate.options="--tags @GetUsers"
  mvn test -Dkarate.options="--tags @PutUsers"
  mvn test -Dkarate.options="--tags @DeleteUsers"
  ```  
- **Solo Casos Felices (Happy Path):**
  ```bash
  mvn test -Dkarate.options="--tags @HappyPath"
  ```
- **Solo Casos Negativos:**
  ```bash
  mvn test -Dkarate.options="--tags @NegativeCase"
  ```
- **Solo Casos Borde (Edge Cases):**
  ```bash
  mvn test -Dkarate.options="--tags @EdgeCase"
  ```

### 3. Configuración Dinámica de Hilos (Threads)

Configura el número de hilos de ejecución concurrente según las capacidades de la máquina o pipeline:

```bash
mvn test -Dthreads=4
```

### 4. Ejecución por Ambiente

Soporte para múltiples ambientes configurados en `env-config.json` (por defecto `dev`):

```bash
mvn test -Dkarate.env=dev
```

---

## 📊 Reportes de Ejecución

Una vez concluida la ejecución, Karate genera automáticamente reportes HTML interactivos con el detalle paso a paso, tiempos de respuesta y payloads de cada petición:

- **Reporte Resumen (HTML):**
  ```text
  target/karate-reports/karate-summary.html
  ```
- **Reporte Detallado por Feature:**
  ```text
  target/karate-reports/serveRest.features.users.[get|post|put|delete]-users.html
  ```

> 💡 **Tip para visualizar:** Abre el archivo `target/karate-reports/karate-summary.html` en cualquier navegador web (Chrome, Edge, Firefox) para revisar el informe visual de métricas y trazabilidad de las pruebas.
