# Tarea Actual

Cinemática introductoria implementada. Pendiente: asignar script en Godot y probar.

## Objetivo
Agregar una cinemática introductoria que se reproduzca entre el menú y la primera escena de juego.

## Completado
- [x] Carpeta `assets/cinematics/intro/` con 11 imágenes estáticas (0.png a 10.png) y 256 fotogramas animados (dialog0000.png a dialog0255.png)
- [x] Integración y carga dinámica de la **Escena del Mapache** en Blender en la cinemática
- [x] Escena `intro_cinematic.tscn` creada manualmente en Godot
- [x] Script `intro_cinematic.gd` con soporte secuencial, 30 FPS, fade-in/out, zoom y duraciones configurables
- [x] `GameManager` actualizado: `start_game()` → cinemática, nueva función `start_first_scene()`
- [x] Documentación conceptual, técnica e histórica completamente actualizada y sincronizada para la Escena del Mapache (README.md, gameplay.md, game_overview.md, technical_design.md, roadmap.md, task_list.md)


## Pendiente
- [ ] Asignar el script `intro_cinematic.gd` al nodo raíz `IntroCinematic` en Godot
- [ ] Probar el flujo completo: Menú → Cinemática → Escena 01
- [ ] Ajustar duraciones individuales de cada imagen desde el Inspector

## Restricciones
- Mantener la arquitectura simple
- Seguir MASTER_CONTEXT.md para las decisiones
- Todos los textos en español