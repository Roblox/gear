--Rescripted by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

PickUpScript = script:WaitForChild("PickUpScript")
CallScript = script:WaitForChild("CallScript")

BaseUrl = "http://www.roblox.com/asset/?id="

Grips = {
	Unequipped = CFrame.new(0, 0.5, 0.6, 1, 0, 0, 0, 1, 0, 0, 0, 1),
	Equipped = CFrame.new(0, 0.5, 0.7, 1, 0, 0, 0, 1, 0, 0, 0, 1),
}

Animations = {
	Shake = {Animation = Tool:WaitForChild("Shake"), FadeTime = 0.1, Weight = 1, Speed = 1},
}

Sounds = {
	Shake = Handle:WaitForChild("Shake"),
}

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

BaseCoin = BasePart:Clone()
BaseCoin.Name = "Coin"
BaseCoin.Size = Vector3.new(1, 0.4, 1)
BaseCoin.BrickColor = BrickColor.new("Dark green")
CoinMesh = Instance.new("SpecialMesh")
CoinMesh.MeshType = Enum.MeshType.FileMesh
CoinMesh.MeshId = (BaseUrl .. "19059116")
CoinMesh.TextureId = (BaseUrl .. "19059111")
CoinMesh.Scale = Vector3.new(1, 1, 1)
CoinMesh.Offset = Vector3.new(0, 0, 0)
CoinMesh.VertexColor = Vector3.new(1, 1, 1)
CoinMesh.Parent = BaseCoin
PickUpSound = Instance.new("Sound")
PickUpSound.Name = "PickUpSound"
PickUpSound.Volume = 1
PickUpSound.Pitch = 1
PickUpSound.SoundId = (BaseUrl .. "97688233")
PickUpSound.Parent = BaseCoin

MaxDistance = 25
GearTakenPerUse = 8
TakeRate = 0.2
ReloadTime = 15

ToolActive = false
ToolEquipped = false

ServerControl = (Tool:FindFirstChild("ServerControl") or Instance.new("RemoteFunction"))
ServerControl.Name = "ServerControl"
ServerControl.Parent = Tool

ClientControl = (Tool:FindFirstChild("ClientControl") or Instance.new("RemoteFunction"))
ClientControl.Name = "ClientControl"
ClientControl.Parent = Tool

Tool.Grip = Grips.Unequipped
Tool.Enabled = true

function IsTeamMate(Player1, Player2)
	return (Player1 and Player2 and not Player1.Neutral and not Player2.Neutral and Player1.TeamColor == Player2.TeamColor)
end

function GetNearbyPlayers(Origin, MaxDistance)
	local NearbyPlayers = {}
	for i, v in pairs(Players:GetPlayers()) do
		if v ~= Player and not IsTeamMate(Player, v) then
			local character = v.Character
			if character and character.Parent then
				local ForceFieldFound = false
				for ii, vv in pairs(character:GetChildren()) do
					if vv:IsA("ForceField") then
						ForceFieldFound = true
					end
				end
				if not ForceFieldFound then
					local humanoid = character:FindFirstChild("Humanoid")
					local torso = character:FindFirstChild("Torso")
					if humanoid and humanoid.Health > 0 and torso then
						local Distance = (torso.Position - Origin).magnitude
						if Distance <= MaxDistance then
							table.insert(NearbyPlayers, v)
						end
					end
				end
			end
		end
	end
	return NearbyPlayers
end

function DropGear(character, gear)
	local torso = character:FindFirstChild("Torso")
	if not torso then
		return
	end
	local handle = gear:FindFirstChild("Handle")
	if not handle then
		return
	end
	local FakeHandle = handle:Clone()
	FakeHandle.CanCollide = false
	FakeHandle.Name = gear.Name
	Debris:AddItem(FakeHandle, 3)
	FakeHandle.CFrame = torso.CFrame
	FakeHandle.Parent = game:GetService("Workspace")
	Debris:AddItem(gear, 0)
	gear:Destroy()
	local Velocity = Instance.new("RocketPropulsion")
	Velocity.Target = Handle
	Velocity.Parent = FakeHandle
	Velocity:Fire()
end

function SpawnCash()
	ToolActive = true
	local CurrentlyEquipped = true
	if ToolUnequipped then
		ToolUnequipped:disconnect()
	end
	ToolUnequipped = Tool.Unequipped:connect(function()
		CurrentlyEquipped = false
	end)
	Spawn(function()
		InvokeClient("PlayAnimation", Animations.Shake)
	end)
	Sounds.Shake:Play()
	Spawn(function()
		local Direction = Torso.CFrame.lookVector
		for i = 0, 10, 1 do
			if ToolEquipped and CurrentlyEquipped and CheckIfAlive() then
				local Coin = BaseCoin:Clone()
				local Creator = Instance.new("ObjectValue")
				Creator.Name = "Creator"
				Creator.Value = Player
				Creator.Parent = Coin
				local PickUpScriptCopy = PickUpScript:Clone()
				PickUpScriptCopy.Disabled = false
				PickUpScriptCopy.Parent = Coin
				Coin.CFrame= Torso.CFrame + (Direction * 5) + Vector3.new(((math.random() * 30) - 15), 20, ((math.random() * 30) - 15))
				Debris:AddItem(Coin, 10)
				Coin.Parent = game:GetService("Workspace")
				wait(0.5)
			end
		end
	end)
	local PlayersNearby = GetNearbyPlayers(Torso.Position, MaxDistance)
	for Take = 1, GearTakenPerUse do
		if ToolEquipped and CurrentlyEquipped and CheckIfAlive() then
			for i, v in pairs(PlayersNearby) do
				if v:IsA("Player") and not IsTeamMate(Player, v) then
					local Backpack = v:FindFirstChild("Backpack")
					local character = v.Character
					local humanoid = character:FindFirstChild("Humanoid")
					if Backpack and character and character.Parent and humanoid and humanoid.Health > 0 then
						if Take == 1 then
							local CallScriptClone = CallScript:Clone()
							local LaughTime = Instance.new("NumberValue")
							LaughTime.Name = "LaughTime"
							LaughTime.Value = (GearTakenPerUse * TakeRate)
							LaughTime.Parent = CallScriptClone
							CallScriptClone.Disabled = false
							CallScriptClone.Parent = character
						end
						local Gear = {}
						for ii, vv in pairs({Backpack, character}) do
							for iii, vvv in pairs(vv:GetChildren()) do
								if vvv:IsA("Tool") then
									table.insert(Gear, vvv)
								end
							end
						end
						if #Gear > 0 then
							local GearTaken = Gear[math.random(1, #Gear)]
							if GearTaken.Parent == character then
								humanoid:UnequipTools()
							end
							DropGear(character, GearTaken)
						end
					end
				end
			end
			wait(TakeRate)
		end
	end
	if ToolUnequipped then
		ToolUnequipped:disconnect()
	end
	ToolActive = false
end

function Activated()
	if not Tool.Enabled or not ToolEquipped or ToolActive or not CheckIfAlive() then
		return
	end
	Tool.Enabled = false
	SpawnCash()
	wait(ReloadTime)
	Tool.Enabled = true
end

function CheckIfAlive()
	return (((Player and Player.Parent and Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Torso and Torso.Parent) and true) or false)
end

function Equipped()
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	Torso = Character:FindFirstChild("Torso")
	if not CheckIfAlive() then
		return
	end
	Tool.Grip = Grips.Equipped
	ToolEquipped = true
end

function Unequipped()
	for i, v in pairs(Sounds) do
		if v and v.Parent then
			v:Stop()
		end
	end
	Tool.Grip = Grips.Unequipped
	ToolEquipped = false
end

function InvokeClient(Mode, Value)
	local ClientReturn = nil
	pcall(function()
		ClientReturn = ClientControl:InvokeClient(Player, Mode, Value)
	end)
	return ClientReturn
end

ServerControl.OnServerInvoke = (function(player, Mode, Value)
	if player ~= Player or not ToolEquipped or not CheckIfAlive() or not Mode or not Value then
		return
	end
end)

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)