# Jugabilidad

## Ciclo Principal (Core Loop)

1. Mostrar una escena estática con un fondo del lejano oeste
2. Presentar una amenaza o evento peligroso mediante texto narrativo
3. Desencadenar un Quick Time Event (QTE)
4. Si el jugador tiene éxito → continuar al siguiente evento o escena
5. Si el jugador falla → pierde una vida
6. Si las vidas llegan a cero → pantalla de derrota
7. Si se completan todas las escenas → pantalla de victoria

## Sistema de Vidas

- El jugador comienza con **3 vidas**
- Cada QTE fallido cuesta 1 vida
- Las vidas se mantienen a lo largo de toda la sesión de juego
- Llegar a 0 vidas activa la pantalla de derrota
- Las vidas se muestran en pantalla como corazones (♥)

## Tipos de QTE

### Implementados Actualmente

- **Pulsar una Tecla:** Se muestra una tecla en pantalla. El jugador debe presionarla antes de que se acabe el tiempo.

### Planeados para el Futuro

- Presionar una entre varias teclas mostradas en pantalla
- Secuencia corta de teclas (presionar A, luego B, luego C)
- Machacar una tecla rápidamente para llenar una barra
- Mantener presionada una tecla durante un tiempo corto
- Tiempo de reacción tras una señal visual/auditiva

## Éxito y Fracaso

- **Éxito:** El QTE se resuelve positivamente. El jugador avanza o la amenaza es neutralizada.
- **Fracaso:** El jugador recibe daño (pierde una vida). Si quedan vidas, el QTE puede reintentarse. Si se agotan las vidas, el juego termina en derrota.

## Ideas para Minijuegos (Post-MVP)

Estas aún no están implementadas. Pueden añadirse tras completar el MVP:

- **Duelo del Oeste:** Duelo basado en reacción, espera una señal y luego presiona una tecla lo más rápido posible.
- **Secuencia de Memoria:** Repite una breve secuencia de entradas.
- **Minijuego de Ganzúas (Lockpick):** Detén un indicador móvil en la zona correcta.
- **Galería de Tiro:** Haz clic o presiona teclas en blancos que van apareciendo.
