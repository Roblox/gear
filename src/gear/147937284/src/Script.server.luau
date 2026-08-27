--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

DanceRadius = 50

function Activated()
	if Tool.Enabled then
		Tool.Enabled = false
		local Increase = 0.1
		local MaxSize = 6
		local DiscoBall = Handle:Clone()
		Handle.Transparency = 1
		DiscoBall.Name = "DiscoBall"
		DiscoBall.CanCollide = false
		local Light = Instance.new("PointLight")
		Light.Range = DanceRadius
		Light.Brightness = 25
		Light.Shadows = true
		Light.Enabled = false
		Light.Name = "Light"
		Light.Parent = DiscoBall
		local CurrentSize = DiscoBall.Size
		DiscoBall.Size = Vector3.new(MaxSize, MaxSize, MaxSize)
		DiscoBall.CanCollide = false
		DiscoBall.Anchored = true
		DiscoBall.Locked = true
		Debris:AddItem(DiscoBall, 30)
		DiscoBall.Parent = game:GetService("Workspace")
		DiscoBall.CFrame = Handle.CFrame
		DiscoBall.CFrame = CFrame.new(DiscoBall.Position)
		for i = Increase, (MaxSize - CurrentSize.Y) + Increase, Increase do
			DiscoBall.Mesh.Scale = DiscoBall.Mesh.Scale + Vector3.new(Increase, Increase, Increase)
			DiscoBall.CFrame = DiscoBall.CFrame + Vector3.new(0, Increase * 3, 0)
			wait(0.01)
		end
		DiscoBall.CanCollide = true
		DiscoBall.DiscoBallScript.Disabled = false
		Light.Enabled = true
		wait(15)
		Handle.Transparency = 0
		Tool.Enabled = true
	end
end

Tool.Activated:connect(Activated)