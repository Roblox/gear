--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")
Mesh = Handle:WaitForChild("Mesh")

ToolDisplays = {
	Normal = {
		Grip = CFrame.new(0, -0.75, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
		MeshScale = Vector3.new(0.25, 0.25, 0.25)
	},
	Display = {
		Grip = CFrame.new(1.5, 2.54999995, -1.5, 1, 0, 0, 0, 1, 0, 0, 0, 1),
		MeshScale = Vector3.new(3, 3, 3)
	}
}

Tool.Grip = ToolDisplays.Normal.Grip
Mesh.Scale = ToolDisplays.Normal.MeshScale