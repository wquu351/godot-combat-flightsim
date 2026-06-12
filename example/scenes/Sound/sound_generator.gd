extends Node
class_name SoundGenerator

## 程序化音效生成器 - 通过代码生成简单音效

var audio_player: AudioStreamPlayer
var generator: AudioStreamGenerator
var playback: AudioStreamGeneratorPlayback

# 音效参数
var sample_rate: int = 22050  # 采样率

func _ready():
	# 创建音频播放器
	audio_player = AudioStreamPlayer.new()
	audio_player.volume_db = -10  # 音量
	add_child(audio_player)
	
	# 创建音频生成器
	generator = AudioStreamGenerator.new()
	generator.mix_rate = sample_rate
	generator.buffer_length = 0.5  # 缓冲区长度

## 播放锁定提示音（短促的高音）
func play_lock_sound():
	play_tone(880.0, 0.1, 0.3)  # 880Hz，0.1秒，音量0.3

## 播放解锁提示音（短促的低音）
func play_unlock_sound():
	play_tone(440.0, 0.1, 0.2)  # 440Hz，0.1秒，音量0.2

## 播放切换目标提示音（两个音调）
func play_switch_sound():
	# 先播放一个音，然后播放另一个音
	play_tone(660.0, 0.05, 0.25)
	await get_tree().create_timer(0.05).timeout
	play_tone(880.0, 0.05, 0.25)

## 播放导弹发射音（下降的音调）
func play_missile_launch_sound():
	# 从高音下降到低音
	play_sweep(1200.0, 400.0, 0.3, 0.4)

## 播放爆炸音（噪音 + 低音）
func play_explosion_sound():
	play_noise(0.2, 0.5)
	await get_tree().create_timer(0.1).timeout
	play_tone(150.0, 0.15, 0.3)

## 播放单音调
func play_tone(frequency: float, duration: float, volume: float):
	audio_player.stream = generator
	audio_player.play()
	playback = audio_player.get_stream_playback()
	
	# 计算需要的采样数
	var samples_needed = int(duration * sample_rate)
	
	# 填充缓冲区
	for i in range(samples_needed):
		var t = float(i) / sample_rate
		# 正弦波
		var value = sin(2.0 * PI * frequency * t) * volume
		
		# 添加淡入淡出效果
		var fade = 1.0
		if i < samples_needed * 0.1:
			fade = float(i) / (samples_needed * 0.1)
		elif i > samples_needed * 0.9:
			fade = (samples_needed - float(i)) / (samples_needed * 0.1)
		
		value *= fade
		
		# 推送采样（立体声，左右声道相同）
		playback.push_frame(Vector2(value, value))

## 播放音调扫描（从起始频率到结束频率）
func play_sweep(start_freq: float, end_freq: float, duration: float, volume: float):
	audio_player.stream = generator
	audio_player.play()
	playback = audio_player.get_stream_playback()
	
	var samples_needed = int(duration * sample_rate)
	
	for i in range(samples_needed):
		var t = float(i) / sample_rate
		# 线性插值频率
		var freq = start_freq + (end_freq - start_freq) * t / duration
		var value = sin(2.0 * PI * freq * t) * volume
		
		# 添加淡入淡出
		var fade = 1.0
		if i < samples_needed * 0.1:
			fade = float(i) / (samples_needed * 0.1)
		elif i > samples_needed * 0.9:
			fade = (samples_needed - float(i)) / (samples_needed * 0.1)
		
		value *= fade
		playback.push_frame(Vector2(value, value))

## 播放噪音（用于爆炸等效果）
func play_noise(duration: float, volume: float):
	audio_player.stream = generator
	audio_player.play()
	playback = audio_player.get_stream_playback()
	
	var samples_needed = int(duration * sample_rate)
	
	for i in range(samples_needed):
		# 随机噪音
		var value = randf_range(-1.0, 1.0) * volume
		
		# 添加淡入淡出
		var fade = 1.0
		if i < samples_needed * 0.05:
			fade = float(i) / (samples_needed * 0.05)
		elif i > samples_needed * 0.7:
			fade = (samples_needed - float(i)) / (samples_needed * 0.3)
		
		value *= fade
		playback.push_frame(Vector2(value, value))