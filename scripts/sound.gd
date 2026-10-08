extends Node
## Tiny original synthesized sounds; no external audio files or runtime services.
var enabled: bool = true

func play(kind: String = "tap") -> void:
	if not enabled or DisplayServer.get_name() == "headless":
		return
	var frequencies: Array = [660.0]
	if kind == "merge": frequencies = [523.25, 659.25, 783.99]
	if kind == "reward": frequencies = [659.25, 783.99, 1046.5]
	if kind == "cook": frequencies = [440.0, 587.33]
	var samples := PackedByteArray()
	var rate: int = 22050
	for frequency in frequencies:
		var count: int = int(rate * 0.075)
		for i in count:
			var t: float = float(i) / rate
			var envelope: float = sin(PI * float(i) / count) * 0.12
			var value: int = int(sin(TAU * float(frequency) * t) * envelope * 32767)
			samples.append(value & 255)
			samples.append((value >> 8) & 255)
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = rate
	stream.data = samples
	var player := AudioStreamPlayer.new()
	player.stream = stream
	add_child(player)
	player.finished.connect(player.queue_free)
	player.play()
