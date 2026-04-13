# Juego Western con QTE

Un juego corto en 2D, impulsado por una narrativa, ambientado en el lejano oeste y creado en **Godot 4.6** con GDScript.

El jugador se enfrenta a peligrosos encuentros en la frontera y debe reaccionar rápidamente mediante **Quick Time Events (QTEs)** (Eventos de Tiempo Rápido) para sobrevivir.

## Motor y Versión

- **Motor:** Godot 4.6
- **Lenguaje:** GDScript
- **Renderizador:** Compatibilidad GL (GL Compatibility)

## Cómo Ejecutarlo

1. Abre esta carpeta del proyecto en **Godot 4.6** (o en una versión compatible más reciente).
2. Presiona **F5** o haz clic en el botón de **Play** (Reproducir).
3. Aparecerá el menú principal — haz clic en **Jugar** (Play) para comenzar.

## Estado Actual

**MVP — En Progreso**

El proyecto está en su fase inicial de desarrollo. La versión mínima jugable incluye:

- Menú principal
- Una escena de juego con un encuentro QTE
- Sistema de vidas (3 vidas)
- Pantallas de victoria y derrota

## Objetivos del MVP

- [x] Estructura del proyecto y documentación
- [x] Menú principal con Jugar/Salir (Play/Quit)
- [x] Autoload GameManager (vidas, flujo de escenas)
- [x] Componente QTE reutilizable
- [x] Una escena de juego con QTE
- [x] Pantalla de resultados (victoria/derrota)
- [x] Flujo de juego completo de principio a fin

## Estructura del Proyecto

Consulta [docs/technical_design.md](docs/technical_design.md) para ver la distribución completa de carpetas y los detalles de arquitectura.

## Documentación

- [Visión General del Juego](docs/game_overview.md) — premisa, ambientación, tono
- [Jugabilidad](docs/gameplay.md) — mecánicas, tipos de QTE, ciclo de juego
- [Diseño Técnico](docs/technical_design.md) — arquitectura, convenciones
- [Hoja de Ruta](docs/roadmap.md) — fases de desarrollo
- [Lista de Tareas](docs/task_list.md) — seguimiento del progreso
- [Flujo de Trabajo con IA](docs/ai_workflow.md) — cómo la IA ayuda en el desarrollo
