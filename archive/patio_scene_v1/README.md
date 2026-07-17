# Escena del patio archivada

Esta carpeta conserva la versión descartada de `game_scene_04`, retirada del flujo activo el 17 de julio de 2026. Incluía un combate en el patio con animaciones que no se utilizaron en el primer nivel definitivo.

La escena 04 activa es ahora una cinemática de cierre con tres tomas: protagonista junto a la ventana, grupo de enemigos afuera y respuesta final del protagonista.

## Contenido preservado

- `scenes/game_scene_04.tscn` original;
- `scenes/game_scene_04.gd` y su UID;
- `assets/backgrounds/patio_taberna.png`;
- animaciones de los enemigos del patio;
- animaciones del protagonista para cubrirse, morir y arrojar dinamita;
- secuencia de explosión.

La estructura interna conserva las rutas originales. El archivo `.gdignore` evita que Godot importe estos recursos mientras permanezcan dentro de `archive/patio_scene_v1/`.

## Restauración opcional

Restaurar este material reemplazaría la escena 04 actual. Solo debe hacerse si se decide rediseñar el patio explícitamente.

1. Hacer una copia de la `game_scene_04` activa.
2. Copiar el contenido archivado de `scenes/` y `assets/` a sus rutas originales.
3. Resolver conflictos de nombres y UIDs.
4. Verificar que `GameManager.scene_order` mantenga `game_scene_04.tscn` después de `game_scene_03.tscn`.
5. Abrir Godot, esperar la importación y reconstruir las animaciones defectuosas.

El archivo archivado conserva referencias antiguas de `enemigo_1_dispara`; deben revisarse antes de usarlo nuevamente.
