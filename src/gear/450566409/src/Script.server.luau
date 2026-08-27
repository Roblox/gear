--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

DisplayModel = Tool:FindFirstChild("DisplayModel")
if DisplayModel then
	DisplayModel:Destroy()
end