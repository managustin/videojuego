# MASTER_CONTEXT.md

## Project Title
Western QTE Game

## Purpose of this File
This file is the master context for any AI coding agent working on this repository.

The agent must treat this file as the primary source of truth for:
- product vision
- project scope
- technical decisions
- coding conventions
- folder structure
- documentation requirements
- implementation priorities

If there is ambiguity, the agent should prefer:
1. simplicity
2. modularity
3. small working increments
4. maintainability
5. compatibility with Godot 4 and GDScript

The agent must not over-engineer the project.

---

# 1. Project Summary

This is a small 2D university project made by two students.

The game is a short narrative-driven 2D game with:
- static scenes
- quick time events (QTEs)
- a western setting
- a few simple minigames between scenes

The overall vibe is:
- tense
- a little gritty
- western-themed
- simple in presentation
- feasible for a small student team

This is **not** a large commercial game.
This is **not** an open world game.
This is **not** a physics-heavy action game.
This is **not** a complex animation-based game.

The project must remain small and realistic.

---

# 2. Core Design Philosophy

The game should be designed around:
- static or mostly static scenes
- simple interactions
- strong feedback
- short game duration
- low technical complexity
- easy iteration
- high feasibility for beginners using AI assistance

The project should prioritize:
- getting a playable version quickly
- building a "vertical slice" first
- then expanding with more scenes and polish

The first goal is not to finish the full game immediately.
The first goal is to create a minimal playable version with:
- one menu
- one playable scene
- one QTE
- simple health/lives tracking
- success/failure result

---

# 3. Game Concept

## Setting
A western-inspired environment.

## Premise
The protagonist lives near dangerous criminal neighbors or hostile outlaws and gets involved in violent confrontations. The game progresses through a sequence of static scenes where enemies or hazards attack, forcing the player to react quickly through QTEs.

There may be small narrative transitions between scenes.

## Structure
The player advances scene by scene.
Each scene presents:
- a background
- one or more threats
- one or more QTE moments
- a win/fail outcome

Between some scenes there may be minigames.

---

# 4. Scope Constraints

This project must stay small.

Preferred target scope:
- 5 to 8 total scenes
- 2 simple minigames maximum
- 10 to 15 minutes total playtime
- a small number of reusable mechanics

The agent must avoid proposing:
- large combat systems
- free movement exploration
- inventory systems unless explicitly requested
- complex enemy AI
- procedural generation
- dialogue trees with massive branching
- online systems
- advanced save systems unless explicitly needed
- unnecessary plugins or dependencies

Keep the architecture simple.

---

# 5. MVP Definition

The MVP is the minimum playable version.

## MVP must include
- main menu
- one gameplay scene
- one QTE mechanic
- health or lives system
- transition to victory or defeat
- simple UI feedback
- basic project documentation

## MVP should not depend on
- final art
- final sound
- multiple minigames
- polished transitions
- advanced effects

Use placeholder assets if necessary.

---

# 6. Gameplay Design

## Core Loop
1. Show static scene
2. Present enemy, threat, or dangerous event
3. Trigger a QTE
4. If player succeeds, continue
5. If player fails, lose life or take damage
6. Continue to next event or scene
7. Repeat until victory or defeat

## Possible QTE Types
These are preferred because they are simple and appropriate:
- press a specific key in time
- press one of multiple keys shown on screen
- short key sequence
- mash a key repeatedly
- hold a key for a short duration
- reaction timing after a signal

The first implementation should use the simplest possible QTE:
- show a prompt
- start a timer
- wait for correct key
- success if correct input arrives before timeout
- failure otherwise

## Minigame Ideas
Keep minigames simple.
Examples:
- western duel reaction game
- short memory sequence
- lockpick-like simplified timing game
- shooting target popup event

Only implement minigames after the MVP works.

---

# 7. Technical Stack

## Engine
Godot 4

## Language
GDScript

## Editor / IDE
The repository may be edited in:
- Godot editor
- VS Code or Antigravity

The code and project structure must remain fully compatible with Godot 4.

The agent must not assume Unity, C#, Phaser, or any other stack.

---

# 8. Development Workflow

The project is being developed with heavy AI assistance.

The agent must work in a way that helps beginners.

This means:
- prefer simple implementations
- explain file purpose clearly
- keep code modular but not overcomplicated
- generate readable code
- avoid clever abstractions unless clearly useful
- avoid large uncontrolled rewrites

The preferred workflow is incremental:
1. define structure
2. create documentation
3. build one working feature
4. test
5. iterate
6. expand

The agent should optimize for:
- ease of understanding
- easy debugging
- quick testing inside Godot

---

# 9. Repository and File Structure

The project should use a clean and simple structure like this:

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
│  └─ minigames/
├─ scripts/
│  ├─ autoload/
│  │  └─ game_manager.gd
│  ├─ managers/
│  │  └─ qte_manager.gd
│  ├─ ui/
│  ├─ scenes/
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

If some folders are not immediately needed, they may be created later, but the overall structure should remain organized.

---

# 10. Documentation Requirements

The agent should generate and maintain documentation.

At minimum, the agent should create:

## README.md
Should include:
- project name
- short description
- engine and version
- how to run the project
- current state of the project
- MVP goals

## docs/game_overview.md
Should describe:
- premise
- setting
- tone
- target duration
- project goals

## docs/gameplay.md
Should describe:
- player loop
- current mechanics
- QTE types
- failure and success conditions
- minigame ideas

## docs/technical_design.md
Should describe:
- folder structure
- main scenes
- global systems
- autoload usage
- scene transitions
- coding conventions

## docs/roadmap.md
Should describe:
- MVP stage
- post-MVP stage
- polish stage

## docs/task_list.md
Should describe:
- tasks already done
- tasks in progress
- next implementation steps

## docs/ai_workflow.md
Should describe:
- how AI should work in this repo
- that changes should be small and testable
- that the code must stay beginner-friendly

The agent should keep documentation aligned with the implementation.

---

# 11. Coding Standards

## General Principles
The code must be:
- simple
- readable
- modular
- beginner-friendly
- easy to debug

## Naming
Use snake_case for:
- file names
- variables
- functions
- scene file names

Examples:
- game_manager.gd
- main_menu.tscn
- current_health
- start_qte()

## Script Responsibilities
Prefer one clear responsibility per script.

Do not put unrelated systems into one large script if avoidable.

## Comments
Use comments sparingly but usefully.
Comments should explain:
- purpose of a file
- non-obvious logic
- assumptions

Avoid excessive comments for obvious code.

## Defensive Coding
If an implementation depends on a node path or exported variable, make this clear and stable.
Use Godot 4 syntax only.

---

# 12. Architecture Guidance

## Recommended Main Systems

### GameManager
Use an autoload for shared global state such as:
- player health or lives
- current scene progression
- game reset
- basic result state

Keep it simple.

### QTE System
Create a reusable QTE component or manager that can:
- display prompt text or keys
- start a timer
- detect correct input
- emit success/failure result
- be reused across scenes

The first version should be minimal and robust.

### Scene Flow
Scenes should be separate and easy to swap.
Transitions can initially be basic scene changes.

### UI
Keep UI minimal:
- prompt text
- timer if needed
- health/lives display
- result messages

Do not create a highly complex UI architecture unless necessary.

---

# 13. Preferred Build Order

The agent should prioritize work in this order:

## Phase 1: Foundation
- create docs
- create folder structure
- create main menu scene
- create game manager autoload
- create first gameplay scene
- create reusable basic QTE system
- create result screen
- connect flow end-to-end

## Phase 2: Expansion
- add more scene content
- add second QTE variation
- add one simple minigame
- improve UI feedback
- improve transitions

## Phase 3: Polish
- add sound
- add placeholder art improvements
- add final scene progression
- improve feedback and pacing
- clean code and docs

The agent must not skip directly to polish before Phase 1 works.

---

# 14. Asset Policy

The project may use placeholder assets initially.

Preferred placeholder strategy:
- plain color backgrounds
- simple text labels
- temporary shapes or sprites
- basic UI boxes
- simple free or generated placeholder art if allowed

The code should not depend on final art being available.

---

# 15. Beginner-Friendly AI Collaboration Rules

This repository is being worked on by people with little or no prior game development experience.

The agent must therefore:
- prefer clarity over sophistication
- explain structural decisions in docs
- avoid hidden complexity
- avoid giant monolithic scripts
- avoid fragile code
- avoid changing many unrelated files at once

When adding a feature, the agent should:
1. update or create relevant docs
2. implement the smallest useful version
3. keep the file layout organized
4. avoid breaking existing work

If there is uncertainty, choose the simpler implementation.

---

# 16. What the Agent Should Do First

When first working on this repo, the agent should:

1. Inspect the repository state.
2. Create missing base documentation files.
3. Propose or create the initial folder structure.
4. Ensure the project is aligned with Godot 4.
5. Prepare the first implementation target:
   - main menu
   - one gameplay scene
   - one basic QTE
   - game manager
   - result flow

If implementation is requested, prioritize a fully playable minimal version rather than broad unfinished scaffolding.

---

# 17. Immediate Deliverables Expected from the Agent

Unless the user asks otherwise, the best initial output should include:

- a clean repository structure
- foundational documentation
- a basic README
- technical design notes
- a task list
- a minimal architecture plan
- optionally the first set of Godot scenes and scripts for the MVP

The agent should be able to bootstrap the project professionally but simply.

---

# 18. Example MVP Scene Flow

This example is intended as guidance.

## Flow
- Main Menu
- Scene 1: static western background, hostile event appears
- QTE prompt appears: press a key in time
- Success: continue to result or next scene
- Failure: lose life
- If lives reach zero: defeat screen
- Otherwise: retry or continue
- Victory screen if scene objective is completed

This example can be used to implement the first playable version.

---

# 19. Non-Goals

The following are currently out of scope unless explicitly requested later:
- large branching narrative systems
- open-ended movement
- multiplayer
- networking
- advanced physics gameplay
- advanced AI enemies
- deep combat systems
- RPG systems
- inventory/crafting
- procedural content
- complex save/load architecture
- plugin-heavy solutions

---

# 20. Final Instruction to the Agent

You are working on a small student-made Godot 4 game.
Your job is to help create a clean, playable, well-documented project.

Always optimize for:
- simplicity
- clarity
- small testable progress
- maintainable structure
- beginner-friendly code

Do not over-engineer.
Do not make assumptions beyond this file unless the user asks for them.
Do not introduce unnecessary complexity.
Build the smallest version that works, then iterate.

If asked to implement, prefer producing:
- documentation
- clear file structure
- simple Godot scenes
- readable GDScript
- incremental progress