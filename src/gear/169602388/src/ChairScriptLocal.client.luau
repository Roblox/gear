--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")

KeyControls = Tool:WaitForChild("KeyControls")
CameraControl = Tool:WaitForChild("CameraControl")

Sit = Tool:WaitForChild("SitAnim")

Camera = game:GetService("Workspace").CurrentCamera

CameraControl.OnClientInvoke = (function(player)
	return Camera.CoordinateFrame
end)

function OnKey(Key, Down)
	pcall(function()
		KeyControls:InvokeServer(Key, Down)
	end)
end

function Button1Down()
	pcall(function()
		KeyControls:InvokeServer("Button1Down", Humanoid.TargetPoint)
	end)
end

function Equipped(Mouse)
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	if not Player then
		return
	end
	Mouse.Button1Down:connect(function()
		Button1Down()
	end)
	Mouse.KeyDown:connect(function(Key)
		OnKey(Key, true)
	end)
	Mouse.KeyUp:connect(function(Key)
		OnKey(Key, false)
	end)
	Humanoid.PlatformStand = true
	SitAnim = Humanoid:LoadAnimation(Sit)
	if SitAnim then
		SitAnim:Play()
	end
end

function Unequipped()
	Player = nil
	Humanoid.PlatformStand = false
	if SitAnim then
		SitAnim:Stop()
	end
end

Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)