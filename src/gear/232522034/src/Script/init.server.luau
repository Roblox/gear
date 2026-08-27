--Made by Luckymaxer
--Updated for R15 avatar by StarWars

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")
Players = game:GetService("Players")
Debris = game:GetService("Debris")

BaseUrl = "http://www.roblox.com/asset/?id="

BasePart = Instance.new("Part")
BasePart.Shape = Enum.PartType.Block
BasePart.Material = Enum.Material.Plastic
BasePart.TopSurface = Enum.SurfaceType.Smooth
BasePart.BottomSurface = Enum.SurfaceType.Smooth
BasePart.FormFactor = Enum.FormFactor.Custom
BasePart.Size = Vector3.new(0.2, 0.2, 0.2)
BasePart.CanCollide = true
BasePart.Locked = true
BasePart.Anchored = false

GrenadeScript = script:WaitForChild("GrenadeScript")
ChargeGui = script:WaitForChild("ChargeGui")

Animations = {
	Throw = {Animation = Tool:WaitForChild("Throw"), FadeTime = nil, Weight = nil, Speed = nil, Duration = 1},
	R15Throw = {Animation = Tool:WaitForChild("R15Throw"), FadeTime = nil, Weight = nil, Speed = nil, Duration = 1}
}

Sounds = {
	Pin = Handle:WaitForChild("Pin"),
	Explode = Handle:WaitForChild("Explode"),
}

TouchDamage = {Min = 10, Max = 10}

ToolEquipped = false
Charging = false

ReloadTime = 5

Rate = (1 / 60)

Grenade = BasePart:Clone()
Grenade.Name = "Grenade"
Grenade.Size = Vector3.new(0.5, 1, 0.5)
GrenadeMesh = Instance.new("SpecialMesh")
GrenadeMesh.MeshType = Enum.MeshType.FileMesh
GrenadeMesh.Scale = Vector3.new(1.5, 1.5, 1.5)
GrenadeMesh.MeshId = (BaseUrl .. "232379763")
GrenadeMesh.TextureId = (BaseUrl .. "232379808")
GrenadeMesh.VertexColor = Vector3.new(1, 1, 1)
GrenadeMesh.Offset = Vector3.new(0, 0, 0)
GrenadeMesh.Parent = Grenade

ServerControl = (Tool:FindFirstChild("ServerControl") or Instance.new("RemoteFunction"))
ServerControl.Name = "ServerControl"
ServerControl.Parent = Tool

ClientControl = (Tool:FindFirstChild("ClientControl") or Instance.new("RemoteFunction"))
ClientControl.Name = "ClientControl"
ClientControl.Parent = Tool

Handle.Transparency = 0
Tool.Enabled = true

function Charge(PlayerGui)
	local Full
	if PlayerGui then
		ChargeGuiClone = ChargeGui:Clone()
		Full = ChargeGuiClone.Bar.Full
		ChargeGuiClone.Parent = PlayerGui
	end
	local NewSize
	while Charging do
		local ChargeRate = 0.04
		for i = 1, (1 / ChargeRate) do
			if not Charging or not CheckIfAlive() then
				break
			end
			NewSize = -(ChargeRate * i)
			if Full and Full.Parent then
				Full.Size = UDim2.new(1, 0, NewSize, 0)
				for i, v in pairs(Full:GetChildren()) do
					if v:IsA("ImageLabel") then
						local ChargePercent = GetPercentage(0, -1, Clamp(NewSize, -1, 0))
						local ChargeColor = ((ChargePercent <= 50 and Color3.new(0, 1, 0)) or (ChargePercent <= 90 and Color3.new(1, 1, 0)) or Color3.new(1, 0, 0))
						v.ImageColor3 = ChargeColor
					end
				end
			end
			wait(Rate)
		end
		for i = 1, (1 / ChargeRate) do
			if not Charging or not CheckIfAlive() then
				break
			end
			NewSize = (-1 + (ChargeRate * i))
			if Full and Full.Parent then
				Full.Size = UDim2.new(1, 0, NewSize, 0)
				for i, v in pairs(Full:GetChildren()) do
					if v:IsA("ImageLabel") then
						local ChargePercent = GetPercentage(0, -1, Clamp(NewSize, -1, 0))
						local ChargeColor = ((ChargePercent <= 25 and Color3.new(0, 1, 0)) or (ChargePercent <= 75 and Color3.new(1, 1, 0)) or Color3.new(1, 0, 0))
						v.ImageColor3 = ChargeColor
					end
				end
			end
			wait(Rate)
		end
	end
	Charging = false
	return NewSize
end

function Reload()
	if Tool.Enabled then
		return
	end
	wait(ReloadTime)
	Handle.Transparency = 0
	Tool.Enabled = true
end

function CheckIfAlive()
	return (((Player and Player.Parent and Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0) and true) or false)
end

function Equipped()
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	if not CheckIfAlive() then
		return
	end
	ToolEquipped = true
end

function Unequipped()
	if ChargeGuiClone and ChargeGuiClone.Parent then
		ChargeGuiClone:Destroy()
	end
	for i, v in pairs({ToolUnequipped}) do
		if v then
			v:disconnect()
		end
	end
	Spawn(Reload)
	ToolEquipped = false
end

function InvokeClient(Mode, Value)
	local ClientReturn = nil
	pcall(function()
		ClientReturn = ClientControl:InvokeClient(Player, Mode, Value)
	end)
	return ClientReturn
end

function Clamp(Number, Min, Max)
	return math.max(math.min(Max, Number), Min)
end

function GetPercentage(Start, End, Number)
	return (((Number - Start) / (End - Start)) * 100)
end

function Round(Number, RoundDecimal)
	local WholeNumber, Decimal = math.modf(Number)
	return ((Decimal >= RoundDecimal and math.ceil(Number)) or (Decimal < RoundDecimal and math.floor(Number)))
end

ServerControl.OnServerInvoke = (function(player, Mode, Value)
	if player ~= Player or not ToolEquipped or not CheckIfAlive() or not Value then
		return
	end
	if Mode == "MouseClick" then
		local Down = Value.Down
		if Down and not Charging and Tool.Enabled then
			Tool.Enabled = false
			Charging = true
			local PlayerGui = Player:FindFirstChild("PlayerGui")
			local ChargePercent = Charge(PlayerGui)
			local ChargePercent = GetPercentage(0, -1, Clamp(ChargePercent, -1, 0))
			local PercentToDecimal = (ChargePercent * 0.01)
			if ChargeGuiClone and ChargeGuiClone.Parent then
				ChargeGuiClone:Destroy()
			end
			local CurrentlyEquipped = true
			if ToolUnequipped then
				ToolUnequipped:disconnect()
			end
			ToolUnequipped = Tool.Unequipped:connect(function()
				CurrentlyEquipped = false
			end)
			Sounds.Pin:Play()
			local Animation = Animations.Throw
			if Humanoid and Humanoid.RigType == Enum.HumanoidRigType.R15 then
				Animation = Animations.R15Throw
			end
			InvokeClient("PlayAnimation", Animation)
			wait(Animation.Duration)
			if CurrentlyEquipped then
				local StartPosition = Handle.Position
				local TargetPosition = InvokeClient("MousePosition").Position
				local Direction = CFrame.new(StartPosition, TargetPosition)
				local Speed = (75 * PercentToDecimal)
				Handle.Transparency = 1
				local GrenadeClone = Grenade:Clone()
				Debris:AddItem(GrenadeClone, 15)
				GrenadeClone.CFrame = Handle.CFrame
				GrenadeClone.Parent = game:GetService("Workspace")
				GrenadeClone.Velocity = (Direction.lookVector * Speed) + Vector3.new(0, 50, 0)
				local Creator = Instance.new("ObjectValue")
				Creator.Name = "Creator"
				Creator.Value = Player
				Creator.Parent = GrenadeClone
				local Explode = Sounds.Explode:Clone()
				Explode.Parent = GrenadeClone
				local GrenadeScriptClone = GrenadeScript:Clone()
				GrenadeScriptClone.Disabled = false
				GrenadeScriptClone.Parent = GrenadeClone
			end
			Spawn(Reload)
		elseif not Down and Charging then
			Charging = false
			Spawn(Reload)
		end
	end
end)

Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)