# Hoja de Ruta

## Fase 1: Base (MVP) ✅

Objetivo: Crear una versión mínima jugable con un flujo completo.

- [x] Estructura del proyecto y de carpetas
- [x] Documentación (README, visión general del juego, jugabilidad, diseño técnico, hoja de ruta, flujo con IA)
- [x] Escena del menú principal
- [x] Autoload GameManager (vidas, flujo de escenas, resultado de partidas)
- [x] Componente QTE reutilizable
- [x] Primera escena de juego con un encuentro QTE
- [x] Pantalla de resultados (victoria y derrota)
- [x] Flujo de juego completo de principio a fin: Menú → Escena → QTE → Resultado → Menú

## Fase 2: Arte y Mecánica de Duelo ← Actual

Objetivo: Reemplazar placeholders con sprites reales e implementar mecánica de duelo completa.

- [x] Fondo visual añadido a la Escena 01
- [x] Sprites del personaje principal con animaciones (caminata, disparo, muerte)
- [x] Sprite del enemigo con animación de disparo
- [x] Mecánica de QTE cambiada de presionar tecla a clic sobre hitbox (Area2D)
- [x] Lógica de 3 caminos: acierto, fallo por clic erróneo, fallo por tiempo agotado
- [x] Sistema de reintentos con reseteo de animaciones
- [x] Traducción completa de la interfaz al español
- [ ] Animación de muerte del enemigo cuando el jugador acierta

## Fase 3: Expansión

Objetivo: Añadir más contenido, variedad y un minijuego.

- [ ] Añadir una segunda escena de juego con un QTE diferente
- [ ] Añadir una segunda variación de QTE (ej. machacar teclas o secuencia)
- [ ] Añadir un minijuego simple (ej. juego de reacción de duelo del oeste)
- [ ] Mejorar la retroalimentación visual y de la interfaz (animaciones, señales de sonido)
- [ ] Añadir transiciones entre escenas (fundido de entrada/salida)
- [ ] Añadir más texto narrativo y variedad de escenas
- [ ] Expandir `scene_order` en GameManager

## Fase 4: Pulido

Objetivo: Mejorar la sensación del juego, la presentación y los detalles finales.

- [ ] Añadir música de fondo
- [ ] Añadir efectos de sonido (disparo, muerte, clics del menú)
- [ ] Mejorar la tipografía y el tema visual
- [ ] Añadir progresión de dificultad (tiempos más cortos en escenas posteriores)
- [ ] Secuencia final de escenas (5-8 escenas en total)
- [ ] Pruebas de juego y ajustes de balance
- [ ] Limpieza final de la documentación
