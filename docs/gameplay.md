# Jugabilidad

## Flujo completo

1. El menú principal permite iniciar la partida o salir.
2. Una cinemática automática de 11 imágenes presenta el mundo.
3. La escena 01 introduce el QTE de disparo.
4. La escena 02 desarrolla la entrada y los diálogos de la taberna.
5. La escena 03 plantea un duelo de cobertura y contraataque.
6. La escena 04 cierra el nivel mediante una cinemática en tres tomas.
7. Un fundido conduce a la pantalla verde `CONTINUARÁ...`.

## Vidas y resultados

- La partida comienza con tres vidas compartidas por las escenas.
- Un fallo de QTE resta una vida.
- Si quedan vidas, el encuentro se reinicia.
- Al llegar a cero se abre la pantalla roja de derrota.
- Completar el duelo de la taberna habilita la cinemática final y el resultado verde.

## Cinemática introductoria

`intro_cinematic.tscn` reproduce `0.png` a `10.png` desde `assets/cinematics/intro/`. Cada imagen tiene una duración ajustable. La primera usa fade-in y zoom; la última termina con fade-out y llama a `GameManager.start_first_scene()`.

## Escena 01: duelo exterior

El protagonista entra caminando y se activa un QTE de disparo. El jugador debe hacer clic sobre la hitbox del enemigo.

| Acción | Resultado |
|---|---|
| Clic sobre el enemigo | Disparo del personaje, muerte del enemigo y avance |
| Clic fuera del enemigo | Disparan ambos, muere el personaje y pierde una vida |
| Tiempo agotado | Dispara el enemigo, muere el personaje y pierde una vida |

Los sonidos `disparo1.MP3` y `disparo2.MP3` tienen demoras independientes para acierto, fallo por clic y fallo por tiempo. Tras la victoria hay diálogo, zoom hacia la taberna, caminata y fundido.

## Escena 02: taberna narrativa

No contiene QTE. Alterna fondos mediante cortes a negro y presenta:

1. entrada animada del protagonista;
2. primer diálogo del protagonista;
3. plano del enemigo sentado y su diálogo;
4. regreso al protagonista y dos diálogos consecutivos;
5. fundido hacia el duelo.

Los textos y duraciones se configuran desde el Inspector. Los diálogos actuales son intencionales y no deben reescribirse automáticamente.

## Escena 03: duelo de la taberna

### Fase 1: cobertura

El enemigo sentado inicia `enemigo2_sentado_dispara`. Cuando aparece `TOMA COBERTURA`, el jugador debe hacer clic sobre la hitbox de la columna.

- Acierto: el protagonista reproduce `pj_cubrirse` y pasa a la fase 2.
- Fallo: reproduce `pj_muere2`, pierde una vida y reinicia el duelo completo si todavía puede continuar.

### Fase 2: contraataque

El jugador debe hacer clic sobre el enemigo antes de que termine el segundo QTE.

- Acierto: reproduce `pj_dispara_duelo`; debe escucharse exactamente un disparo, el del personaje. El enemigo reproduce `enemigo_muere` y se avanza a la escena 04.
- Fallo o tiempo agotado: el personaje reproduce `pj_dispara_pero_muere` y el enemigo `enemigo_parado_dispara`. Cada disparo de esta rama tiene una demora independiente.

En `GameScene03 → Audio de disparos`, los controles están ordenados así:

1. fase 1, enemigo sentado;
2. fase 2A, personaje al acertar;
3. fase 2B, personaje y enemigo al fallar.

Las demoras se cuentan desde el inicio de la animación correspondiente. No se programa un disparo enemigo durante la rama exitosa de la fase 2.

## Escena 04: cinemática de cierre

La escena contiene tres tomas dentro de un mismo `Control`:

1. Fondo inicial y animación `pj_que_quilombo`; aparece “Qué quilombo...”. Luego se muestra “¡HEY!” y la raíz hace zoom hacia una ventana.
2. El primer fondo y el protagonista se ocultan. Aparecen `EnemyBackground`, el enemigo animado `enemigo_gritando` y dos acompañantes estáticos. El diálogo dice “¡Salí de ahí! ¡Te metiste con el patrón!”.
3. Se oculta la toma enemiga y aparece `ThirdBackground`, que ya incluye al protagonista renderizado. Un segundo después aparecen “¡No me dejaban dormir!” y luego “... ahora tengo que ver cómo soluciono esto.”

Finalmente `FadeOverlay` cubre la pantalla y se abre `result_screen.tscn` con resultado `victory`.

## Controles

- Ratón: botones del menú y clic sobre hitboxes durante los QTE.
- F5: ejecutar el juego completo desde el menú principal.
