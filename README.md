# proyecto_final_programacion_con_dio

Estructura base del proyecto final para el curso de Programación III. Esta aplicación combina la versatilidad de **Flutter** para la interfaz gráfica y la potencia de **C++** a bajo nivel mediante **FFI (Foreign Function Interface)** para la gestión avanzada de estructuras de datos y memoria RAM.

---

## Características Principales (Fase 1)

- **Mapeo de Datos Robusto:** Consumo asíncrono de la API externa (`/todos` de JSONPlaceholder).
- **Cliente HTTP Avanzado:** Implementación de la librería `Dio` para un manejo eficiente de peticiones y control de excepciones (`DioException`).
- **Seguridad y Configuración:** Uso de variables de entorno mediante `flutter_dotenv` para centralizar datos sensibles (URL de la API) fuera del código fuente.
- **Estructuras Nativas (C++):** Definición de nodos autorreferenciados listos para la gestión manual de memoria en las siguientes fases.
- **Arquitectura Modular:** Separación estricta de responsabilidades en carpetas independientes (`pages`, `services`, `models`).

---

## Estructura del Proyecto

```text
├── native_lib/               # Código Fuente en C++
│   └── src/
│       └── todo_node.h       # Estructura autorreferenciada (Nodo)
├── lib/                      # Código Fuente en Dart/Flutter
│   ├── models/               # Modelos de datos (Mapeo JSON)
│   ├── pages/                # Pantallas (Login, Home)
│   ├── services/             # Servicios de API y lógica nativa
│   └── main.dart             # Punto de entrada de la aplicación
├── .env                      # Variables de entorno (No se comparte en producción)
└── pubspec.yaml              # Dependencias del proyecto