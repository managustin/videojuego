# Western QTE Game

Videojuego narrativo 2D de temática western desarrollado en Godot 4.6 para la materia Introducción al Desarrollo de Videojuegos. El primer nivel combina una introducción ilustrada, dos duelos con QTE, escenas narrativas dentro y fuera de una taberna y un cierre de “Continuará”.

## Ejecución

1. Abrir `project.godot` con Godot 4.6.
2. Presionar F5.
3. Elegir **Jugar** en el menú principal.

El proyecto inicia en `scenes/main_menu.tscn`. `scenes/dev_start.tscn` se conserva únicamente como herramienta de desarrollo y no participa del recorrido normal.

## Recorrido actual

```text
Menú principal
→ Cinemática introductoria (11 imágenes)
→ Escena 01: duelo exterior con QTE de disparo
→ Escena 02: entrada y diálogos en la taberna
→ Escena 03: duelo de la taberna con QTE de cobertura y contraataque
→ Escena 04: cinemática de cierre en tres tomas
→ Resultado verde: CONTINUARÁ...
```

El jugador dispone de tres vidas. Los fallos en los QTE restan una vida; al llegar a cero se muestra la pantalla de derrota.

## Estado

El primer nivel está implementado de principio a fin. Incluye:

- menú principal y música de fondo;
- cinemática introductoria con tiempos configurables;
- dos encuentros jugables con clic sobre hitboxes;
- escena narrativa de taberna;
- disparos sincronizables desde el Inspector;
- fundidos y cambios de plano;
- cinemática final con zoom, enemigos y diálogos;
- pantallas de derrota y de cierre “Continuará”.

La prioridad restante es probar el recorrido completo, ajustar tiempos, posiciones, volúmenes y presentación final.

## Tecnología

- Godot 4.6
- GDScript
- renderizador GL Compatibility
- resolución base: 1920 × 1080, ventana de prueba: 1280 × 720

## Documentación

- [Contexto maestro](MASTER_CONTEXT.md)
- [Visión general](docs/game_overview.md)
- [Jugabilidad](docs/gameplay.md)
- [Diseño técnico](docs/technical_design.md)
- [Hoja de ruta](docs/roadmap.md)
- [Lista de tareas](docs/task_list.md)
- [Tarea actual](docs/CURRENT_TASK.md)
- [Flujo de trabajo con IA](docs/ai_workflow.md)

La primera versión descartada de la escena del patio está preservada en `archive/patio_scene_v1/` y no es importada por Godot.
