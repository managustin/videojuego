# Diseño técnico

## Base técnica

- Godot 4.6 y GDScript.
- Renderizador GL Compatibility.
- Resolución lógica 1920 × 1080 con escalado `canvas_items`.
- `project.godot` inicia en `scenes/main_menu.tscn`.

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
│  └─ components/qte_prompt.tscn
├─ scripts/
│  ├─ autoload/game_manager.gd
│  ├─ autoload/audio_manager.gd
│  ├─ managers/qte_prompt.gd
│  └─ scenes/
├─ assets/
│  ├─ audio/music/
│  ├─ audio/sfx/
│  ├─ backgrounds/
│  ├─ characters/
│  └─ cinematics/
└─ archive/patio_scene_v1/
```

`dev_start.tscn` es una entrada auxiliar que abre la escena 03, pero no es la escena principal. El patio descartado está bajo `archive/` con `.gdignore`.

## Autoloads

### GameManager

Mantiene `lives`, `current_scene_index` y `game_result`. Su orden jugable es:

```gdscript
[
    "res://scenes/game_scene_01.tscn",
    "res://scenes/game_scene_02.tscn",
    "res://scenes/game_scene_03.tscn",
    "res://scenes/game_scene_04.tscn",
]
```

`start_game()` reinicia el estado y abre la introducción. `go_to_next_scene()` avanza por el array. La escena 04 termina directamente con `game_result = "victory"` y `go_to_result()`.

### AudioManager

Crea un reproductor de música y un pool de ocho `AudioStreamPlayer` para SFX. Intenta reproducir `assets/audio/music/bg_music.ogg` al iniciar. `play_sfx()` permite superponer disparos sin agregar reproductores a cada escena.

## QTEPrompt

`scenes/components/qte_prompt.tscn`, controlado por `scripts/managers/qte_prompt.gd`, expone el tiempo límite y el texto. Emite `qte_success` y `qte_failure`. Las escenas realizan la consulta física de clic mediante `PhysicsPointQueryParameters2D` y resuelven el componente.

## Responsabilidad de las escenas

| Escena | Responsabilidad |
|---|---|
| `main_menu` | Iniciar o salir |
| `intro_cinematic` | Reproducir 11 imágenes con zoom y fundidos |
| `game_scene_01` | QTE exterior de disparo, vidas y entrada a la taberna |
| `game_scene_02` | Secuencia narrativa de entrada y diálogos |
| `game_scene_03` | Duelo de dos fases, reintentos y sonidos sincronizados |
| `game_scene_04` | Cinemática final en tres tomas y fundido de salida |
| `result_screen` | Derrota o cierre verde `CONTINUARÁ...` |

## Sincronización sonora

Las escenas 01 y 03 reutilizan:

- `assets/audio/sfx/disparo1.MP3` para el personaje;
- `assets/audio/sfx/disparo2.MP3` para enemigos.

Los SFX se programan con temporizadores no bloqueantes desde el comienzo de cada animación. En la escena 03 las variables exportadas están agrupadas por orden narrativo. La rama exitosa de la fase 2 solo programa el disparo del personaje; no debe quedar ningún temporizador de disparo enemigo asociado al QTE activo.

## Escena 04

Los recursos visuales se asignan desde el Inspector; el script no carga rutas rígidas. Sus nodos principales son:

```text
GameScene04
├─ Background
├─ PlayerSprite
├─ DialogueBubble
├─ OutsideDialogueBubble
├─ EnemyBackground
├─ EnemySprite
├─ EnemyCompanionLeft
├─ EnemyCompanionRight
├─ EnemyDialogueBubble
├─ ThirdBackground
├─ ThirdDialogueBubble
└─ FadeOverlay
```

El zoom se aplica a la raíz alrededor de `objetivo_zoom`. Al cambiar a la segunda toma se restaura la escala inicial. La tercera toma usa solamente un fondo pre-renderizado y un globo; no necesita un sprite separado del protagonista.

## Pantalla de resultado

Con `game_result == "victory"`, la pantalla usa fondo verde y muestra `CONTINUARÁ...` a 72 px, por encima de `¡Bien!` y `Sobreviviste... por ahora.`. En derrota oculta `CONTINUARÁ...` y usa la variante roja.

## Convenciones

- GDScript y nombres `snake_case`.
- Valores narrativos, posiciones y tiempos ajustables mediante `@export`.
- Los nodos y recursos preparados en código deben aceptar asignaciones manuales desde el Inspector.
- No sobrescribir por código texturas o `SpriteFrames` que el usuario configuró en la escena.
- Textos visibles en español y archivos UTF-8.
- Cambios pequeños, legibles y sin dependencias externas.
