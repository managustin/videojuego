# Lista de Tareas

## Completadas

- [x] Estructura de carpetas del proyecto creada
- [x] README.md escrito
- [x] docs/game_overview.md escrito
- [x] docs/gameplay.md escrito
- [x] docs/technical_design.md escrito
- [x] docs/roadmap.md escrito
- [x] docs/ai_workflow.md escrito
- [x] project.godot configurado (nombre, escena principal, autoload, tamaño de ventana)
- [x] Autoload GameManager creado (vidas, flujo de escenas, resultado del juego)
- [x] Componente reutilizable QTE Prompt creado (escena + script)
- [x] Escena del Menú Principal creada (Botones Jugar + Salir)
- [x] Escena de Juego 01 creada (narrativa + encuentro QTE)
- [x] Pantalla de Resultados creada (victoria/derrota + reintentar/menú)
- [x] Flujo de principio a fin conectado: Menú → Escena 01 → QTE → Resultado → Menú
- [x] Fondo visual añadido a la Escena 01 (imagen generada)
- [x] Sprites del personaje principal añadidos con animaciones: `entra_en_escena`, `shoot`, `pj_muere1`
- [x] Sprite del enemigo añadido con animación: `enemigo_dispara`
- [x] Mecánica de QTE cambiada de presionar tecla a clic sobre hitbox del enemigo (Area2D + CollisionShape2D)
- [x] Animación de caminata de entrada con Tween (personaje entra desde fuera de pantalla)
- [x] Detección de acierto/fallo mediante PhysicsPointQueryParameters2D (consulta sincrónica)
- [x] Lógica de 3 caminos implementada: acierto, fallo por clic erróneo, fallo por tiempo agotado
- [x] Animación del enemigo sincronizada con el disparo del jugador
- [x] Secuencia de muerte del personaje con interrupción de animación y temporizadores
- [x] Sistema de reintentos con reseteo de animaciones y estado
- [x] Traducción completa de todos los textos de la interfaz al español

## En Progreso

_(nada en progreso actualmente)_

## Próximos Pasos

- [ ] Añadir animación de muerte del enemigo cuando el jugador acierta
- [ ] Añadir efectos de sonido sincronizados con las animaciones de disparo y muerte
- [ ] Añadir música de fondo
- [ ] Añadir una segunda escena de juego con una variación diferente de QTE
- [ ] Añadir transiciones entre escenas (efectos de fundido)
- [ ] Añadir un minijuego simple
