extends Object


static func get_files_in_dir_recursive(path: String, pattern: String) -> Array:
	var files = []
	var dir := DirAccess.open(path)

	if not dir:
		return files

	dir.list_dir_begin()

	var file_name = dir.get_next()

	while file_name != "":
		var file_path = path + "/" + file_name
		if dir.current_is_dir():
			files.append_array(get_files_in_dir_recursive(file_path, pattern))
		elif file_name.matchn(pattern):
			files.append(file_path)

		file_name = dir.get_next()

	return files
