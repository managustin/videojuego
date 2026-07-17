# Flujo de trabajo con IA

## Fuentes de verdad

Antes de modificar el proyecto, revisar:

1. `MASTER_CONTEXT.md` para el estado y las restricciones generales.
2. `docs/CURRENT_TASK.md` para el objetivo inmediato.
3. La escena y el script reales relacionados con el pedido.
4. `docs/gameplay.md` y `docs/technical_design.md` si cambia el comportamiento.

La implementación real prevalece sobre una descripción histórica desactualizada; cuando difieran, corregir la documentación en el mismo cambio.

## Forma de colaboración

El flujo habitual es:

1. La IA prepara nodos, scripts, variables exportadas y conexiones.
2. El usuario carga texturas, fondos, `SpriteFrames` y ajusta posiciones desde el Inspector.
3. El código coordina la secuencia sin volver a cargar ni sustituir esos recursos mediante rutas rígidas.

Si el usuario ya modificó una escena en Godot, se deben preservar sus posiciones, escalas, animaciones, textos y recursos. No regenerar archivos `.tscn` completos cuando alcance con un cambio localizado.

## Reglas

- Usar Godot 4 y GDScript legible.
- Exponer en el Inspector los tiempos que necesiten ajuste visual o sonoro.
- Nombrar las variables según su orden y función narrativa, preferentemente en español.
- Mantener los cambios pequeños y verificables.
- No alterar los diálogos de la escena 02: están escritos así de forma intencional.
- En la escena 03, el acierto del segundo QTE debe producir un solo disparo del personaje.
- Conservar `project.godot` iniciando en `main_menu.tscn` para probar el juego completo.
- Mantener el patio anterior bajo `archive/patio_scene_v1/` y fuera de la importación de Godot.

## Documentación que debe acompañar cambios

- Mecánica o narrativa: `docs/gameplay.md` y `docs/game_overview.md`.
- Arquitectura, nodos o flujo: `docs/technical_design.md`.
- Estado del trabajo: `docs/CURRENT_TASK.md` y `docs/task_list.md`.
- Hitos: `docs/roadmap.md`.

## Verificación mínima

- Confirmar que las rutas de nodos del script existan en el `.tscn`.
- Confirmar que los recursos asignados por el usuario sigan referenciados.
- Probar la rama modificada y, si afecta el flujo, ejecutar desde F5.
- Revisar errores y advertencias del depurador.
- No afirmar que una prueba pasó si Godot no pudo ejecutarse.
