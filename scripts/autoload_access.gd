extends RefCounted

## Resolve autoload singletons by name so GDScript parses without global identifiers.


static func settings(tree: SceneTree) -> Node:
	if tree == null:
		return null
	return tree.root.get_node_or_null("GameSettings")


static func audio(tree: SceneTree) -> Node:
	if tree == null:
		return null
	return tree.root.get_node_or_null("GameAudio")


static func fx(tree: SceneTree) -> Node:
	if tree == null:
		return null
	return tree.root.get_node_or_null("GameFx")
