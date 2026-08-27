--Made by Luckymaxer

Gui = script.Parent
ImageFrame = Gui:WaitForChild("ImageFrame")
Image = ImageFrame:WaitForChild("Image")
Astronaut = Image:WaitForChild("Astronaut")
HelpText = Gui:WaitForChild("HelpText")

RunService = game:GetService("RunService")
Debris = game:GetService("Debris")

BaseUrl = "http://www.roblox.com/asset/?id="

Tool = Gui:WaitForChild("Tool").Value

PlayerGui = Gui.Parent
Player = PlayerGui.Parent
Mouse = Player:GetMouse()
Character = Player.Character
Head = Character:WaitForChild("Head")

Destroying = false

function DestroyScript()
	if Destroying then
		return
	end
	for i, v in pairs({HelpText, ImageFrame}) do
		v.Visible = false
	end
	Mouse.Icon = ""
	Debris:AddItem(Gui, 0.5)
	Destroying = true
end

if not Tool then
	DestroyScript()
	return
end

Astronaut.Rotation = 0

RunService.Stepped:connect(function()
	local Camera = game:GetService("Workspace").CurrentCamera
	local Distance = (Camera.CoordinateFrame.p - Head.Position).Magnitude
	if Distance <= 1.5 then
		ImageFrame.Visible = true
		HelpText.Visible = false
		Mouse.Icon = (BaseUrl .. "187746799")
	else
		ImageFrame.Visible = false
		HelpText.Visible = true
		Mouse.Icon = ""
	end
	Astronaut.Rotation = (Astronaut.Rotation + 0.1)
end)

Tool.Changed:connect(function(Property)
	if Property == "Parent" then
		DestroyScript()
	end
end)