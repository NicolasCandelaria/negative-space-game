extends RefCounted

## Calls the Dialogue autoload by node path so scripts parse without the global identifier.


static func say(tree: SceneTree, text: String) -> void:
	if tree == null:
		return
	var dlg := tree.root.get_node_or_null("Dialogue")
	if dlg:
		dlg.call("say", text)
