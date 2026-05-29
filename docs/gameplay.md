# Jugabilidad

## Ciclo Principal (Core Loop)

1. **Cinemática introductoria:** secuencia de imágenes que establece el contexto narrativo
2. El personaje entra caminando desde fuera de pantalla hasta su posición de combate
3. Aparece el texto "¡DISPARÁ!" junto con una barra de tiempo que decrece
4. El jugador debe hacer clic izquierdo sobre la hitbox del enemigo antes de que se agote el tiempo
5. Si el jugador acierta → animación completa de disparo → mensaje de éxito → avanza
6. Si el jugador hace clic fuera de la hitbox → animación de disparo + reacción del enemigo → muerte del personaje → pierde una vida
7. Si el tiempo se agota sin disparar → el enemigo dispara → muerte del personaje → pierde una vida
8. Si las vidas llegan a cero → pantalla de derrota
9. Si se completan todas las escenas → pantalla de victoria

## Sistema de Vidas

- El jugador comienza con **3 vidas**
- Cada fallo (errar el disparo o agotar el tiempo) cuesta 1 vida
- Las vidas se mantienen a lo largo de toda la sesión de juego
- Llegar a 0 vidas activa la pantalla de derrota
- Las vidas se muestran en pantalla como corazones (♥)

## Cinemática Introductoria

Antes de la primera escena de juego se reproduce una cinemática no interactiva combinada que establece el contexto narrativo del lejano oeste. Consiste en dos partes bien diferenciadas que se reproducen de manera continua y automática:

### 1. Secuencia Narrativa Estática (Trabajo del Compañero)
Es una secuencia de 11 imágenes artísticas estáticas (`0.png` a `10.png`) con las siguientes características:
- Cada imagen tiene una **duración independiente configurable** desde el Inspector.
- La primera imagen (`0.png`) tiene un **fade-in suave desde negro** y un efecto de **zoom de entrada**.
- La secuencia avanza automáticamente hasta llegar a la imagen `10.png`.

### 2. Escena del Mapache (Animación de Blender)
Inmediatamente después de la secuencia estática, la cinemática pasa a reproducir la escena animada del mapache:
- Consiste en una secuencia continua de **256 fotogramas en 3D** (`dialog0000.png` a `dialog0255.png`).
- Se reproduce de manera fluida y optimizada a **30 FPS** (`1.0 / 30.0` segundos por fotograma).
- Muestra al personaje del mapache dialogando activamente, preparando psicológicamente al jugador para su inminente duelo.
- Al mostrarse el último fotograma (`dialog0255.png`), se realiza un **fade-out a negro** que transiciona de forma limpia hacia la `game_scene_01`.


## Mecánica de Duelo (Escena 01)

### Flujo de Animaciones

1. **Entrada:** El personaje camina desde fuera de pantalla (`x = -300`) hasta su marca, usando un Tween con transición SINE. El enemigo permanece detenido en su primer frame.
2. **QTE activo:** Al terminar la entrada, aparece la barra de tiempo (1.0 segundo por defecto) y el texto "¡DISPARÁ!".
3. **Disparo:** Al hacer clic, ambos personajes disparan simultáneamente (`shoot` + `enemigo_dispara`).
4. **Resolución:**
   - **Acierto:** La animación `shoot` termina completa → éxito.
   - **Fallo por clic erróneo:** Tras 1.8s se interrumpe con `pj_muere1` → pierde vida.
   - **Fallo por tiempo agotado:** El enemigo dispara (`enemigo_dispara`), tras 1.8s se activa `pj_muere1` → pierde vida.

### Tres Caminos Posibles

| Camino | Condición | Resultado |
|--------|-----------|-----------|
| Acierto | Clic dentro de la hitbox | Animación completa → éxito |
| Fallo por disparo erróneo | Clic fuera de la hitbox | Ambos disparan → muerte del jugador → pierde vida |
| Fallo por inacción | No hacer clic antes de que acabe el tiempo | Enemigo dispara → muerte del jugador → pierde vida |

## Tipos de QTE

### Implementados Actualmente

- **Disparar al Enemigo:** Se muestra una señal en pantalla ("¡DISPARÁ!"). El jugador debe hacer clic izquierdo sobre la hitbox del enemigo antes de que se acabe el tiempo.

### Planeados para el Futuro

- Presionar una entre varias teclas mostradas en pantalla
- Secuencia corta de teclas (presionar A, luego B, luego C)
- Machacar una tecla rápidamente para llenar una barra
- Mantener presionada una tecla durante un tiempo corto
- Tiempo de reacción tras una señal visual/auditiva

## Éxito y Fracaso

- **Éxito:** El QTE se resuelve positivamente. El jugador avanza o la amenaza es neutralizada.
- **Fracaso:** El jugador recibe daño (pierde una vida). Si quedan vidas, el duelo se reintenta (con reseteo de animaciones). Si se agotan las vidas, el juego termina en derrota.

## Ideas para Minijuegos (Post-MVP)

Estas aún no están implementadas. Pueden añadirse tras completar el MVP:

- **Duelo del Oeste:** Duelo basado en reacción, espera una señal y luego haz clic en el enemigo lo más rápido posible.
- **Secuencia de Memoria:** Repite una breve secuencia de entradas.
- **Minijuego de Ganzúas (Lockpick):** Detén un indicador móvil en la zona correcta.
- **Galería de Tiro:** Haz clic o presiona teclas en blancos que van apareciendo.
