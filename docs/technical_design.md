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
| Menú Principal (Main Menu) | `scenes/main_menu.tscn` | Pantalla de título con botones de Jugar y Salir |
| Escena de Juego 01 (Game Scene 01) | `scenes/game_scene_01.tscn` | Primer encuentro de juego con QTE |
| Pantalla de Resultados (Result Screen) | `scenes/result_screen.tscn` | Pantalla de victoria o derrota |
| Prompt de QTE (QTE Prompt) | `scenes/components/qte_prompt.tscn` | Componente reutilizable de QTE |

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
- `target_key: Key` — qué tecla debe presionar el jugador (por defecto: KEY_F)
- `time_limit: float` — segundos antes del tiempo de espera agotado (por defecto: 2.0)
- `prompt_text: String` — texto mostrado al jugador

**Señales:**
- `qte_success` — el jugador presionó la tecla correcta a tiempo
- `qte_failure` — se agotó el temporizador

## Transiciones de Escenas

Todas las transiciones de escenas usan `get_tree().change_scene_to_file(path)` a través del `GameManager`.

**Flujo:**
```text
Menú Principal → Escena de Juego 01 → Pantalla de Resultados → Menú Principal (bucle)
```

El array `GameManager.scene_order` define la secuencia de las escenas de juego. Añadir una nueva escena es tan simple como añadir su ruta al array.

## Convenciones de Código

- **Nomenclatura:** snake_case para todo (archivos, variables, funciones, escenas)
- **Scripts:** Una responsabilidad clara por script
- **Comentarios:** Explicar el propósito en la parte superior de cada archivo; explicar lógica no evidente en la misma línea
- **Señales sobre polling:** Usar señales de Godot para comunicación entre nodos
- **Exports para configuración:** Usar `@export` para valores que deban ser ajustables en el editor
- **No herencia profunda:** Mantener jerarquías de clase planas
- **Sólo sintaxis de Godot 4:** Usar variables tipadas, `@onready`, `@export`, `.emit()` para señales
