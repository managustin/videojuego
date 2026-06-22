# Tarea Actual

Cinemática introductoria implementada. Pendiente: asignar script en Godot y probar.

## Objetivo
Agregar una cinemática introductoria que se reproduzca entre el menú y la primera escena de juego.

## Completado
- [x] Carpeta `assets/cinematics/intro/` con 11 imágenes estáticas (0.png a 10.png)
- [x] Escena `intro_cinematic.tscn` creada manualmente en Godot
- [x] Script `intro_cinematic.gd` con soporte secuencial, fade-in/out, zoom y duraciones configurables
- [x] `GameManager` actualizado: `start_game()` → cinemática, nueva función `start_first_scene()`
- [x] Documentación conceptual, técnica e histórica completamente actualizada y sincronizada (README.md, gameplay.md, game_overview.md, technical_design.md, roadmap.md, task_list.md)


## Pendiente
- [ ] Asignar el script `intro_cinematic.gd` al nodo raíz `IntroCinematic` en Godot
- [ ] Probar el flujo completo: Menú → Cinemática → Escena 01
- [ ] Ajustar duraciones individuales de cada imagen desde el Inspector

## Restricciones
- Mantener la arquitectura simple
- Seguir MASTER_CONTEXT.md para las decisiones
- Todos los textos en español