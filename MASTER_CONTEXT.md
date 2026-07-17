# MASTER_CONTEXT.md

## Propósito

Este archivo es la fuente principal de contexto para cualquier agente que trabaje en el repositorio. Describe el juego que existe actualmente, su flujo, las decisiones técnicas vigentes y las restricciones de colaboración.

Si existe una diferencia entre este documento y el proyecto, se debe inspeccionar la implementación, resolver la discrepancia y actualizar la documentación. No se debe conservar información histórica como si todavía describiera el juego activo.

## Proyecto

`Western QTE Game` es un videojuego narrativo 2D realizado por dos estudiantes para Introducción al Desarrollo de Videojuegos. Está hecho en Godot 4.6 con GDScript y GL Compatibility.

El alcance activo es un primer nivel completo, breve y lineal. Combina:

- una introducción ilustrada;
- dos duelos con QTE basados en clics;
- secuencias narrativas con fondos y animaciones pre-renderizadas;
- tres vidas compartidas;
- música y disparos;
- un cierre `CONTINUARÁ...`.

No es un mundo abierto ni un sistema de combate general. No requiere inventario, IA compleja, físicas avanzadas, guardado elaborado, multijugador ni plugins externos.

## Ejecución y flujo vigente

`project.godot` debe iniciar en:

```text
res://scenes/main_menu.tscn
```

El recorrido de F5 es:

```text
Menú principal
→ intro_cinematic
→ game_scene_01
→ game_scene_02
→ game_scene_03
→ game_scene_04
→ result_screen verde
```

`scenes/dev_start.tscn` abre directamente la escena 03 para desarrollo, pero no debe configurarse como escena principal durante la validación o entrega.

## Narrativa actual

La introducción presenta un pueblo fronterizo hostil. En la escena 01, el protagonista sobrevive a un duelo exterior y entra en una taberna. La escena 02 desarrolla su entrada y un intercambio con un enemigo sentado. La escena 03 convierte ese conflicto en un duelo de cobertura y contraataque.

Después de ganar, la escena 04 muestra al protagonista mirando hacia afuera:

1. dice “Qué quilombo...”;
2. una voz grita “¡HEY!” y la cámara hace zoom hacia la ventana;
3. un enemigo acompañado por otros dos dice “¡Salí de ahí! ¡Te metiste con el patrón!”;
4. el protagonista responde “¡No me dejaban dormir!”;
5. agrega “... ahora tengo que ver cómo soluciono esto.”;
6. la imagen funde a negro y aparece `CONTINUARÁ...`.

Los diálogos de `game_scene_02` son intencionales. No deben ser reescritos ni “corregidos” sin un pedido explícito.

## Escenas

### `main_menu.tscn`

Pantalla inicial con fondo animado y botones Jugar/Salir. Jugar llama a `GameManager.start_game()`.

### `intro_cinematic.tscn`

Reproduce 11 imágenes (`0.png` a `10.png`) desde `assets/cinematics/intro/`. Las duraciones son independientes. La primera imagen usa fade-in y zoom; la última usa fade-out.

### `game_scene_01.tscn`

Primer QTE jugable. El protagonista entra caminando y debe disparar haciendo clic sobre la hitbox del enemigo.

- Acierto: dispara el protagonista, muere el enemigo y se avanza.
- Clic errado: disparan ambos, muere el protagonista y pierde una vida.
- Timeout: dispara el enemigo, muere el protagonista y pierde una vida.

La detección usa `PhysicsPointQueryParameters2D`. Los sonidos del protagonista y enemigo y sus demoras se exponen en el Inspector.

### `game_scene_02.tscn`

Secuencia narrativa dentro de la taberna. Alterna dos fondos mediante fundidos cortos, reproduce `entra_taberna` y muestra diálogos configurables. No contiene QTE.

### `game_scene_03.tscn`

Duelo de la taberna en dos fases.

Fase 1:

- el enemigo sentado reproduce `enemigo2_sentado_dispara`;
- el jugador debe hacer clic en `CoverHitbox`;
- el acierto reproduce `pj_cubrirse`;
- el fallo reproduce `pj_muere2`.

Fase 2:

- el jugador debe hacer clic sobre `EnemyHitbox`;
- el acierto reproduce `pj_dispara_duelo` y debe generar un solo disparo del personaje;
- luego el enemigo reproduce `enemigo_muere`;
- el fallo reproduce `pj_dispara_pero_muere` y `enemigo_parado_dispara`, con demoras sonoras separadas.

Los controles de `Audio de disparos` están ordenados por fase y resultado. No debe programarse un sonido enemigo durante la rama exitosa de la fase 2.

### `game_scene_04.tscn`

Cinemática final compuesta dentro de una única escena:

- toma 1: `Background`, `PlayerSprite`, diálogo y zoom a la ventana;
- toma 2: `EnemyBackground`, `EnemySprite` animado, dos `Sprite2D` estáticos y globo enemigo;
- toma 3: `ThirdBackground` pre-renderizado y dos textos del protagonista;
- salida: `FadeOverlay` y `GameManager.go_to_result()`.

No existe un sprite separado del protagonista en la tercera toma porque ya está renderizado en el fondo.

### `result_screen.tscn`

En victoria usa un fondo verde y muestra, en este orden:

1. `CONTINUARÁ...` a 72 px;
2. `¡Bien!`;
3. `Sobreviviste... por ahora.`;
4. botones Reintentar y Menú Principal.

En derrota oculta `CONTINUARÁ...`, usa fondo rojo y conserva las opciones de reintento y menú.

## Sistemas globales

### GameManager

Autoload en `scripts/autoload/game_manager.gd`.

Responsabilidades:

- tres vidas (`lives`, `max_lives`);
- índice de escena;
- resultado `victory` o `defeat`;
- reinicio de partida;
- transiciones.

Orden obligatorio:

```gdscript
var scene_order: Array[String] = [
    "res://scenes/game_scene_01.tscn",
    "res://scenes/game_scene_02.tscn",
    "res://scenes/game_scene_03.tscn",
    "res://scenes/game_scene_04.tscn",
]
```

### AudioManager

Autoload en `scripts/autoload/audio_manager.gd`. Reproduce `assets/audio/music/bg_music.ogg` y mantiene un pool de ocho reproductores para SFX.

Los disparos activos reutilizados en las escenas 01 y 03 son:

- `assets/audio/sfx/disparo1.MP3`: personaje;
- `assets/audio/sfx/disparo2.MP3`: enemigos.

Las demoras se cuentan desde el comienzo de cada animación y no deben bloquearla.

### QTEPrompt

Componente reutilizable en `scenes/components/qte_prompt.tscn`, con script `scripts/managers/qte_prompt.gd`. Expone texto y tiempo límite; emite éxito o fallo.

## Estructura relevante

```text
project_root/
├─ project.godot
├─ README.md
├─ MASTER_CONTEXT.md
├─ docs/
├─ scenes/
│  ├─ main_menu.tscn
│  ├─ intro_cinematic.tscn
│  ├─ game_scene_01.tscn
│  ├─ game_scene_02.tscn
│  ├─ game_scene_03.tscn
│  ├─ game_scene_04.tscn
│  ├─ result_screen.tscn
│  ├─ dev_start.tscn
│  └─ components/
├─ scripts/
│  ├─ autoload/
│  ├─ managers/
│  └─ scenes/
├─ assets/
│  ├─ audio/
│  ├─ backgrounds/
│  ├─ characters/
│  └─ cinematics/
└─ archive/patio_scene_v1/
```

## Escena del patio archivada

La versión anterior de `game_scene_04`, ambientada en el patio y con animaciones defectuosas, fue retirada. Está preservada bajo `archive/patio_scene_v1/` con sus rutas internas y un `.gdignore` para impedir su importación.

No restaurarla ni mezclar sus recursos con la escena 04 activa salvo pedido explícito.

## Forma de trabajo con recursos visuales

La IA prepara nodos, scripts, hitboxes y variables. El usuario coloca fondos, texturas, `SpriteFrames`, posiciones y escalas desde el Inspector.

Reglas:

- no sobrescribir recursos asignados en el Inspector mediante `load()` o rutas rígidas;
- conservar cambios hechos por el usuario en `.tscn`;
- agregar nodos vacíos cuando el usuario todavía debe cargar el material;
- exponer tiempos útiles con nombres claros, ordenados y preferentemente en español;
- usar textos exportados como fuente de verdad en ejecución y explicar dónde se editan.

## Estándares

- Godot 4.6 y GDScript.
- Nombres de archivos, funciones y variables en `snake_case`.
- Código sencillo y legible.
- Comentarios solo para lógica no evidente.
- Textos visibles en español.
- Archivos UTF-8.
- Sin dependencias ni plugins innecesarios.
- Cambios pequeños que preserven el trabajo del Inspector.

## Estado y prioridad

El primer nivel está implementado. La prioridad actual no es agregar sistemas nuevos, sino:

1. probar F5 de principio a fin;
2. recorrer todas las ramas de QTE;
3. ajustar sonidos al frame exacto;
4. revisar tamaños, posiciones y tiempos;
5. resolver advertencias reales del depurador;
6. preparar la entrega.

La documentación debe actualizarse cuando cambien la narrativa, el flujo, los nodos principales, los QTE o el estado de la entrega.
