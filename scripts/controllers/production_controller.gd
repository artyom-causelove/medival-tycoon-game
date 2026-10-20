extends Node

var processes: Array[Process] = []

func process(delta: float = 1):
	for i in processes.size():
		var proc = processes[i]
		if proc.is_running() and proc.tick(delta):
			var result: Process.Result = proc.finish()
			MyResourceController.add(result.resource.type, result.count)
			if not proc.fund():
				proc.stop()

func add_process(proc: Process) -> bool:
	var funded = proc.fund()
	if funded:
		processes.append(proc)
	return funded
