# audio_manager.gd
# Gestor global de audio (BGM y SFX).
# Carga automáticamente la música desde la ruta designada si existe.

extends Node

## Ruta por defecto para la música de fondo
const DEFAULT_MUSIC_PATH: String = "res://assets/audio/music/bg_music.ogg"

var music_player: AudioStreamPlayer
var sfx_pool: Array[AudioStreamPlayer] = []
const POOL_SIZE: int = 8

func _ready() -> void:
	# 1. Configurar reproductor de música
	music_player = AudioStreamPlayer.new()
	music_player.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(music_player)
	
	# 2. Configurar pool de efectos de sonido (SFX)
	for i in range(POOL_SIZE):
		var player = AudioStreamPlayer.new()
		add_child(player)
		sfx_pool.append(player)

	# 3. Intentar reproducir música de fondo por defecto al iniciar el juego
	play_default_music()


## Reproduce la música de fondo por defecto si el archivo existe en el disco
func play_default_music() -> void:
	if FileAccess.file_exists(DEFAULT_MUSIC_PATH):
		var music = load(DEFAULT_MUSIC_PATH)
		if music:
			play_music(music, -12.0)
	else:
		push_warning("AudioManager: No se encontró el archivo de música en " + DEFAULT_MUSIC_PATH + ". Pon la música allí para que suene automáticamente.")


## Reproduce una pista de música continua (BGM)
func play_music(stream: AudioStream, volume_db: float = -12.0) -> void:
	if not stream:
		return
	if music_player.stream == stream and music_player.playing:
		return
	
	music_player.stream = stream
	music_player.volume_db = volume_db
	music_player.play()


## Detiene la música de fondo
func stop_music() -> void:
	music_player.stop()


## Reproduce un efecto de sonido corto (SFX) utilizando el pool disponible
func play_sfx(stream: AudioStream, volume_db: float = 0.0) -> void:
	if not stream:
		return
	# Buscar un reproductor que no esté activo
	for player in sfx_pool:
		if not player.playing:
			player.stream = stream
			player.volume_db = volume_db
			player.play()
			return
	
	# Fallback: si todos están ocupados, usar el primero (se interrumpe el sonido más antiguo)
	var fallback_player = sfx_pool[0]
	fallback_player.stream = stream
	fallback_player.volume_db = volume_db
	fallback_player.play()
