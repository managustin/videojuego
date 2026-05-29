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

El proyecto está en su fase de expansión de mecánicas y pulido de narrativa. La versión jugable actual incluye:

- Menú principal con fondo animado
- **Cinemática introductoria combinada:** secuencia de 11 imágenes estáticas seguidas por la **Escena del Mapache** (animación fluida en 3D de 256 fotogramas de diálogo renderizados en Blender a 30 FPS).
- Una escena de juego con un encuentro QTE (duelo del oeste con detección sincrónica por clic sobre hitbox)
- Sistema de vidas (3 vidas) con representación visual
- Pantallas de victoria y derrota con flujo de reintentos

## Objetivos del MVP

- [x] Estructura del proyecto y documentación
- [x] Menú principal con Jugar/Salir (Play/Quit)
- [x] Autoload GameManager (vidas, flujo de escenas)
- [x] Componente QTE reutilizable
- [x] Una escena de juego con QTE
- [x] Pantalla de resultados (victoria/derrota)
- [x] Cinemática introductoria con la escena de diálogo en 3D del mapache
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
