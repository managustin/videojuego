# Diseño Técnico

## Motor

Godot 4.6 con GDScript. Renderizador: Compatibilidad GL (GL Compatibility).

## Estructura de Carpetas

```text
project_root/
├─ project.godot
├─ README.md
├─ MASTER_CONTEXT.md
├─ docs/
│  ├─ game_overview.md
│  ├─ gameplay.md
│  ├─ technical_design.md
│  ├─ roadmap.md
│  ├─ task_list.md
│  └─ ai_workflow.md
├─ scenes/
│  ├─ main_menu.tscn
│  ├─ game_scene_01.tscn
│  ├─ result_screen.tscn
│  ├─ components/
│  │  └─ qte_prompt.tscn
│  └─ minigames/
├─ scripts/
│  ├─ autoload/
│  │  └─ game_manager.gd
│  ├─ managers/
│  │  └─ qte_prompt.gd
│  ├─ ui/
│  ├─ scenes/
│  │  ├─ main_menu.gd
│  │  ├─ game_scene_01.gd
│  │  └─ result_screen.gd
│  └─ minigames/
├─ assets/
│  ├─ backgrounds/
│  ├─ characters/
│  │  ├─ main/
│  │  │  ├─ pj_stop_walking/    (90 frames — animación entra_en_escena)
│  │  │  ├─ pj_dispara/         (160 frames — animación shoot)
│  │  │  └─ pj_muere1/          (64 frames — animación pj_muere1)
│  │  └─ enemigo1/              (160 frames — animación enemigo_dispara)
│  ├─ props/
│  └─ ui/
├─ audio/
│  ├─ music/
│  └─ sfx/
└─ tests/
```

## Escenas Principales

| Escena | Archivo | Propósito |
|-------|------|---------| 
| Menú Principal | `scenes/main_menu.tscn` | Pantalla de título con botones Jugar y Salir |
| Escena de Juego 01 | `scenes/game_scene_01.tscn` | Duelo con QTE basado en clic sobre hitbox |
| Pantalla de Resultados | `scenes/result_screen.tscn` | Pantalla de victoria o derrota |
| Prompt de QTE | `scenes/components/qte_prompt.tscn` | Componente reutilizable de QTE |

## Sistemas Globales

### GameManager (Autoload)

Registrado como autoload `GameManager` en `project.godot`.

**Archivo:** `scripts/autoload/game_manager.gd`

**Responsabilidades:**
- Rastrear las vidas del jugador
- Rastrear el progreso de la escena actual
- Almacenar el resultado del juego (victoria/derrota)
- Manejar transiciones de escenas
- Proveer funciones de `start_game()` y `reset_game()`

**Señales:**
- `lives_changed(new_lives: int)` — emitida cuando las vidas cambian
- `game_over` — emitida cuando las vidas llegan a cero

### Prompt de QTE (Componente)

**Archivo:** `scripts/managers/qte_prompt.gd`

Un componente de escena reutilizable que puede ser instanciado en cualquier escena de juego.

**Propiedades Exportadas:**
- `time_limit: float` — segundos antes del tiempo de espera agotado (por defecto: 1.0)
- `prompt_text: String` — texto mostrado al jugador (vacío = la escena padre lo maneja)

**Señales:**
- `qte_success` — el jugador acertó a tiempo
- `qte_failure` — se agotó el temporizador o el jugador falló

## Escena de Duelo (game_scene_01)

### Estructura de Nodos

```text
GameScene01 (Control)
├─ Background (TextureRect)
├─ NarrativeLabel (Label)
├─ LivesContainer (HBoxContainer)
├─ QTEPrompt (instancia de qte_prompt.tscn)
├─ PlayerSprite (AnimatedSprite2D)
│   └─ Animaciones: entra_en_escena, shoot, pj_muere1
└─ EnemyHitbox (Area2D)
    ├─ EnemySprite (AnimatedSprite2D)
    │   └─ Animación: enemigo_dispara
    └─ CollisionShape2D (CircleShape2D, radio ≈ 20px)
```

### Detección de Acierto

Se utiliza una consulta sincrónica de físicas (`PhysicsPointQueryParameters2D`) en `_input()` para determinar instantáneamente si el clic del jugador cayó sobre el `Area2D` del enemigo. Esto evita condiciones de carrera (race conditions) que existían con el enfoque anterior basado en señales y `await process_frame`.

### Flujo de Estados

```text
_ready() → _iniciar_duelo() → [Tween caminata] → _al_terminar_entrada()
  → [QTE activo: barra de tiempo]
    → Clic detectado en _input():
        → _hit_enemy = true  → await shoot → _resolve_success()
        → _hit_enemy = false → await 1.8s → pj_muere1 → _resolve_failure()
    → Tiempo agotado:
        → enemigo_dispara → await 1.8s → pj_muere1 → _on_qte_failure()
```

## Transiciones de Escenas

Todas las transiciones de escenas usan `get_tree().change_scene_to_file(path)` a través del `GameManager`.

**Flujo:**
```text
Menú Principal → Escena de Juego 01 → Pantalla de Resultados → Menú Principal (bucle)
```

El array `GameManager.scene_order` define la secuencia de las escenas de juego. Añadir una nueva escena es tan simple como añadir su ruta al array.

## Localización

Todos los textos visibles en la interfaz están en español. No se utiliza sistema de localización externo; los textos están directamente en los scripts y escenas `.tscn`. Al añadir nuevos textos, deben escribirse en español.

## Convenciones de Código

- **Nomenclatura:** snake_case para todo (archivos, variables, funciones, escenas)
- **Scripts:** Una responsabilidad clara por script
- **Comentarios:** Explicar el propósito en la parte superior de cada archivo; explicar lógica no evidente en la misma línea
- **Señales sobre polling:** Usar señales de Godot para comunicación entre nodos
- **Exports para configuración:** Usar `@export` para valores que deban ser ajustables en el editor
- **No herencia profunda:** Mantener jerarquías de clase planas
- **Sólo sintaxis de Godot 4:** Usar variables tipadas, `@onready`, `@export`, `.emit()` para señales
- **Codificación:** Todos los archivos deben guardarse en UTF-8 sin BOM
