--Rescripted by Luckymaxer
--Made by Stickmasterluke
--// Fixed for R15 avatars by StarWars
-- Fixed for mobile support by Luke, again

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")
Mesh = Handle:WaitForChild("Mesh")

local Cloud

Players = game:GetService("Players")
Debris = game:GetService("Debris")

BasePart = Instance.new("Part")
BasePart.Shape = Enum.PartType.Block
BasePart.Material = Enum.Material.Plastic
BasePart.TopSurface = Enum.SurfaceType.Smooth
BasePart.BottomSurface = Enum.SurfaceType.Smooth
BasePart.FormFactor = Enum.FormFactor.Custom
BasePart.Anchored = false
BasePart.Locked = true
BasePart.CanCollide = true

Sounds = {
	Wind = Handle:WaitForChild("Wind")
}

BaseScale = Vector3.new(3, 3, 3)

Rate = (1 / 60)

Flying = false
ToolEquipped = false

ServerControl = (Tool:FindFirstChild("ServerControl") or Instance.new("RemoteFunction"))
ServerControl.Name = "ServerControl"
ServerControl.Parent = Tool

ClientControl = (Tool:FindFirstChild("ClientControl") or Instance.new("RemoteFunction"))
ClientControl.Name = "ClientControl"
ClientControl.Parent = Tool

Mesh.Scale = BaseScale
Handle.Transparency = 0
Tool.Enabled = true

function RemoveFlyStuff()
	for i, v in pairs(Tool:GetChildren()) do
		if v:IsA("BasePart") and v.Name == "EffectCloud" then
			v:Destroy()
		end
		for i, v in pairs(Sounds) do
			v:Stop()
		end
	end
end

function CheckIfAlive()
	return (((Player and Player.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Torso and Torso.Parent) and true) or false)
end

function Equipped()
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	Torso = Character:FindFirstChild("HumanoidRootPart")
	if not CheckIfAlive() then
		return
	end
	spawn(function()
		Handle.Transparency = 0
		RemoveFlyStuff()
	end)
	Flying = false
	ToolEquipped = true
end

function Unequipped()
	Handle.Transparency = 0
	RemoveFlyStuff()
	Flying = false
	ToolEquipped = false
end

function OnServerInvoke(player, mode, value)
	if player ~= Player or not value or not CheckIfAlive() or not ToolEquipped then
		return
	end
	print(mode)
	if mode == "Fly" then
		local Fly = value.Flying
		Flying = Fly
		if Cloud and Cloud.Parent then
			Cloud:Destroy()
		end
		Handle.Transparency = ((Flying and 1) or 0)
		if Flying then
			Cloud = Handle:Clone()
			Cloud.Name = "EffectCloud"
			Cloud.Transparency = 0
			Cloud.CanCollide = false
			--[[local Wind = Cloud:FindFirstChildOfClass("Sound")
			if Wind then
				Wind:Play()
			end]]
			local Smoke = Cloud:FindFirstChild("Smoke")
			if Smoke then
				Smoke.Enabled = true
			end
			local Weld = Instance.new("Weld")
			Weld.Part0 = Torso
			Weld.Part1 = Cloud
			Weld.C0 = (CFrame.new(1, -4, 0) * CFrame.Angles(0, (math.pi / 2), 0))
			Weld.C1 = CFrame.new(0, 0, 0)
			Weld.Parent = Cloud
			Cloud.Parent = Tool
			return Cloud
		end
	elseif mode == "SetSound" then

		if Sounds.Wind then
			--print("Changing Sound")
			Sounds.Wind.Pitch = ((value * 2) + 1)
			Sounds.Wind.Volume = (value + 0.1)
		end
		
	elseif mode == "SetMesh" then
		local CloudMesh = Cloud:FindFirstChildOfClass("SpecialMesh")
		if Cloud and CloudMesh then
			print("Changing Mesh")
			CloudMesh.Scale = Vector3.new(4, 4, (4 + (value * 4)))
		end
		
	elseif mode == "ToggleSound" then
		local Sound = Sounds.Wind
		local Playing = value
		if not Sound then
			return
		end
		if Playing then
			Sound:Play()
		else
			Sound:Stop()
		end
	end
end

function InvokeClient(Mode, Value)
	local ClientReturn = nil
	pcall(function()
		ClientReturn = ClientControl:InvokeClient(Player, Mode, Value)
	end)
	return ClientReturn
end

for i, v in pairs(Tool:GetChildren()) do
	if v:IsA("BasePart") and v ~= Handle then
		v:Destroy()
	end
end

ServerControl.OnServerInvoke = OnServerInvoke

Tool.Equipped:Connect(Equipped)
Tool.Unequipped:Connect(Unequipped)