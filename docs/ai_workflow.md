# Flujo de Trabajo con IA

## Cómo Debería Funcionar la IA en Este Repositorio

Este proyecto se desarrolla con gran asistencia de IA. El agente de IA debe seguir estas pautas:

### Principios Generales

1. **Leer MASTER_CONTEXT.md primero** — es la principal fuente de verdad para todas las decisiones.
2. **Mantener los cambios pequeños y testeables** — evitar grandes reescrituras a lo largo de muchos archivos.
3. **Preferir la simplicidad** — la solución más simple que funcione es la mejor solución.
4. **Mantenerse amigable para principiantes** — los desarrolladores son estudiantes aprendiendo desarrollo de juegos.

### Antes de Hacer Cambios

1. Revisar `docs/CURRENT_TASK.md` para ver en qué trabajar.
2. Revisar `docs/task_list.md` para entender el progreso actual.
3. Revisar código existente relacionado antes de modificar o crear nuevos archivos.

### Cuando se Implementan Funciones

1. Actualizar o crear la documentación relevante primero.
2. Implementar la versión mínima útil de la función.
3. Probar que el cambio no rompe la funcionalidad existente.
4. Actualizar `docs/task_list.md` para reflejar el progreso.

### Reglas de Calidad del Código

- Escribir GDScript legible con nombres de variables claros
- Añadir un comentario en la parte superior de cada archivo explicando su propósito
- Usar `@export` para valores que deban ser configurables en el editor de Godot
- Usar señales para comunicación entre nodos
- Mantener una responsabilidad por script
- Usar solo sintaxis de Godot 4 (variables tipadas, `@onready`, `.emit()`)

### Lo Que Hay Que Evitar

- Complicar en exceso (over-engineering) o añadir abstracciones innecesarias
- Grandes scripts monolíticos
- Cambios en archivos no relacionados dentro de la misma tarea
- Introducir plugins o dependencias externas
- Jerarquías de herencia complejas
- Funciones no solicitadas en la tarea actual

### Actualizaciones de Documentación

Mantener la documentación sincronizada con la implementación. Cuando se añade una función:
- Actualizar `docs/task_list.md`
- Actualizar `docs/technical_design.md` si la arquitectura cambia
- Actualizar `docs/gameplay.md` si las mecánicas cambian
- Actualizar `docs/roadmap.md` si se completan hitos
