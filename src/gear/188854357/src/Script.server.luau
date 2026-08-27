--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

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

Animations = {
	LeftSlash = {Animation = Tool:WaitForChild("LeftSlash"), FadeTime = nil, Weight = nil, Speed = 2, Duration = 0.6},
	RightSlash = {Animation = Tool:WaitForChild("RightSlash"), FadeTime = nil, Weight = nil, Speed = 2, Duration = 0.6},
	DoubleSlash = {Animation = Tool:WaitForChild("DoubleSlash"), FadeTime = nil, Weight = nil, Speed = 1.5, Duration = 0.75},
	Block = {Animation = Tool:WaitForChild("Block"), FadeTime = nil, Weight = nil, Speed = nil, Duration = nil},
}

Sounds = {
	Slash = Handle:WaitForChild("Slash")
}

Damage = {
	Hit = 0,
	Slash = 15,
	DoubleSlash = 30
}

ToolEquipped = false

Blocking = false

Clicks = 0
FirstClick = false
DoubleClickReload = 3
DoubleClickTick = 0

DisplayModel = Tool:FindFirstChild("DisplayModel")
if DisplayModel then
	DisplayModel:Destroy()
end

for i, v in pairs(Tool:GetChildren()) do
	if (v:IsA("BasePart") and v ~= Handle) then
		v:Destroy()
	end
end

ServerControl = (Tool:FindFirstChild("ServerControl") or Instance.new("RemoteFunction"))
ServerControl.Name = "ServerControl"
ServerControl.Parent = Tool

ClientControl = (Tool:FindFirstChild("ClientControl") or Instance.new("RemoteFunction"))
ClientControl.Name = "ClientControl"
ClientControl.Parent = Tool

Handle.Transparency = 0
Tool.Enabled = true

ServerControl.OnServerInvoke = (function(player, Mode, Value)
	if player == Player then
		if Mode == "MouseClick" and Value.Down then
			Activated()
		elseif Mode == "KeyPress" then
			local Key = Value.Key
			local ByteKey = string.byte(Key)
			local Down = Value.Down
			if ByteKey == 48 then
				local Animation = Animations.Block
				if Blocking ~= Down then
					Blocking = Down
					if Blocking then
						if HealthChanged then
							HealthChanged:disconnect()
						end
						local OldHealth = Humanoid.Health
						HealthChanged = Humanoid.HealthChanged:connect(function()
							Spawn(function()
								local NewHealth = Humanoid.Health
								if NewHealth < OldHealth then
									local HealthChange = (OldHealth - NewHealth)
									local PercentIncrease = (HealthChange * 0.25) --25% of the health lost
									Humanoid.Health = (NewHealth + PercentIncrease)
								end
								OldHealth = Humanoid.Health
							end)
						end)
						Humanoid.WalkSpeed = 8
						InvokeClient("PlayAnimation", Animation)
					else
						Humanoid.WalkSpeed = 24
						InvokeClient("StopAnimation", Animation)
					end
				end
			end
		end
	end
end)

function InvokeClient(Mode, Value)
	local ClientReturn = nil
	pcall(function()
		ClientReturn = ClientControl:InvokeClient(Player, Mode, Value)
	end)
	return ClientReturn
end

function RayCast(Position, Direction, MaxDistance, IgnoreList)
	return game:GetService("Workspace"):FindPartOnRayWithIgnoreList(Ray.new(Position, Direction.unit * (MaxDistance or 999.999)), IgnoreList) 
end

function TagHumanoid(humanoid, player)
	local Creator_Tag = Instance.new("ObjectValue")
	Creator_Tag.Name = "creator"
	Creator_Tag.Value = player
	Debris:AddItem(Creator_Tag, 2)
	Creator_Tag.Parent = humanoid
end

function UntagHumanoid(humanoid)
	for i, v in pairs(humanoid:GetChildren()) do
		if v:IsA("ObjectValue") and v.Name == "creator" then
			v:Destroy()
		end
	end
end

function CheckTableForInstance(Table, Instance)
	for i, v in pairs(Table) do
		if v == Instance then
			return true
		end
	end
	return false
end

function Activated()
	if not Tool.Enabled or not ToolEquipped or Blocking then
		return
	end
	Clicks = (Clicks + 1)
	if not FirstClick then
		FirstClick = true
		local CurrentlyEquipped = true
		ToolUnequipped = Tool.Unequipped:connect(function()
			CurrentlyEquipped = false
		end)
		wait(0.15)
		if ToolUnequipped then
			ToolUnequipped:disconnect()
		end
		if not CurrentlyEquipped then
			return
		end
		if (not (LeftClaw and LeftClaw.Parent) and not (RightClaw and RightClaw.Parent)) then
			return
		end
		Tool.Enabled = false
		local SingleClickAnims = {}
		local DoubleClickAnims = {}
		for i, v in pairs({LeftClaw, RightClaw}) do
			if v and v.Parent then
				if v == LeftClaw then
					table.insert(SingleClickAnims, Animations.LeftSlash)
				elseif v == RightClaw then
					table.insert(SingleClickAnims, Animations.RightSlash)
				end
			end
		end
		if ((LeftClaw and LeftClaw.Parent) and (RightClaw and RightClaw.Parent)) then
			table.insert(DoubleClickAnims, Animations.DoubleSlash)
		end
		Sounds.Slash:Play()
		local VerifiedClicks = (
			((Clicks < 2 or #DoubleClickAnims == 0 or (tick() - DoubleClickTick) <= DoubleClickReload) and 1)
			or Clicks
		)
		AnimationChosen = ((VerifiedClicks < 2 and SingleClickAnims[math.random(1, #SingleClickAnims)]) or DoubleClickAnims[math.random(1, #DoubleClickAnims)])
		if VerifiedClicks > 1 then
			DoubleClickTick = tick()
			Humanoid.WalkSpeed = 8
		end
		local ClawConnections = {}
		local CharactersHit = {}
		for i, v in pairs({LeftClaw, RightClaw}) do
			if v and v.Parent then
				local ClawTouched = v.Touched:connect(function(Hit)		
					if not Hit or not Hit.Parent then
						return
					end
					local character = Hit.Parent
					if character:IsA("Hat") or character:IsA("Tool") then
						character = character.Parent
					end
					if character == Character or CheckTableForInstance(CharactersHit, character) then
						return
					end
					local humanoid = character:FindFirstChild("Humanoid")
					if not humanoid or humanoid.Health == 0 then
						return
					end
					local DamageAmount = 0
					if AnimationChosen == Animations.DoubleSlash then
						DamageAmount = Damage.DoubleSlash
					elseif ((AnimationChosen == Animations.LeftSlash and v == LeftClaw) or (AnimationChosen == Animations.RightSlash and v == RightClaw)) then
						DamageAmount = Damage.Slash
					end
					table.insert(CharactersHit, character)
					UntagHumanoid(humanoid)
					TagHumanoid(humanoid, Player)
					humanoid:TakeDamage(DamageAmount)
				end)
				table.insert(ClawConnections, ClawTouched)
			end
		end
		Delay(1, function()
			for i, v in pairs(ClawConnections) do
				if v then
					v:disconnect()
				end
			end
		end)
		InvokeClient("PlayAnimation", AnimationChosen)
		wait(AnimationChosen.Duration)
		if CurrentlyEquipped then
			--InvokeClient("StopAnimation", AnimationChosen)
			Humanoid.WalkSpeed = 24
		end
		AnimationChosen = nil
		FirstClick = false
		Clicks = 0
		Tool.Enabled = true
	end
end

function EquipClaws()
	local Claw = BasePart:Clone()
	Claw.Name = "Claw"
	Claw.Transparency = 0
	Claw.Size = Vector3.new(0.5, 1.75, 1)
	Claw.CanCollide = false
	Claw.Velocity = Vector3.new(0, 0, 0)
	Claw.RotVelocity = Vector3.new(0, 0, 0)
	local Mesh = Instance.new("SpecialMesh")
	Mesh.TextureId = "http://www.roblox.com/asset?id=188808993"
	Mesh.MeshType = Enum.MeshType.FileMesh
	Mesh.Scale = Vector3.new(3, 3, 3)
	Mesh.Parent = Claw
	local LeftArm = Character:FindFirstChild("Left Arm")
	local RightArm = Character:FindFirstChild("Right Arm")
	if LeftArm then
		LeftClaw = Claw:Clone()
		LeftClaw.Name = "LeftClaw"
		LeftClaw.Mesh.MeshId = "http://www.roblox.com/asset?id=188808919"
		local Weld = Instance.new("Weld")
		Weld.Part0 = LeftArm
		Weld.Part1 = LeftClaw
		Weld.C0 = CFrame.new(0, -1, 0, 1, 0, -0, 0, 0, 1, 0, -1, -0)
		Weld.C1 = CFrame.new(0.25, 0.2, -0.05, 1, 0, 0, 0, -0.000177887006, 0.99999994, 0, -1, -0.000177886992)
		Weld.Parent = LeftClaw
		LeftClaw.Parent = Tool
		InvokeClient("SetLocalTransparencyModifier", {Object = LeftArm, Transparency = 0})
	end
	if RightArm then
		RightClaw = Claw:Clone()
		RightClaw.Name = "RightClaw"
		RightClaw.Mesh.MeshId = "http://www.roblox.com/asset?id=188808952"
		local Weld = Instance.new("Weld")
		Weld.Part0 = RightArm
		Weld.Part1 = RightClaw
		Weld.C0 = CFrame.new(0, -1, 0, 1, 0, -0, 0, 0, 1, 0, -1, -0)
		Weld.C1 = CFrame.new(-0.25, 0.2, -0.05, 1, 0, 0, 0, -0.000177887006, 0.99999994, 0, -1, -0.000177886992)
		Weld.Parent = RightClaw
		RightClaw.Parent = Tool
		InvokeClient("SetLocalTransparencyModifier", {Object = RightArm, Transparency = 0})
	end
	for i, v in pairs({LeftClaw, RightClaw}) do
		if v and v.Parent then
			v.Touched:connect(function(Hit)
				if not Hit or not Hit.Parent then
					return
				end
				local character = Hit.Parent
				local humanoid = character:FindFirstChild("Humanoid")
				if not humanoid or humanoid.Health == 0 then
					return
				end
				if not AnimationChosen or ((AnimationChosen == Animations.LeftSlash and v ~= LeftClaw) or (AnimationChosen == Animations.RightSlash and v ~= RightClaw)) then
					UntagHumanoid(humanoid)
					TagHumanoid(humanoid, Player)
					humanoid:TakeDamage(Damage.Hit)
				end
			end)
		end
	end
end

function CheckIfAlive()
	return (Player and Player.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0)
end

function Equipped()
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	Torso = Character:FindFirstChild("Torso")
	if not CheckIfAlive() then
		return
	end
	for i, v in pairs(Tool:GetChildren()) do
		if (v:IsA("BasePart") and v ~= Handle) then
			v:Destroy()
		end
	end
	for i, v in pairs(Animations) do
		if v and v.Animation then
			InvokeClient("Preload", v.Animation.AnimationId)
		end
	end
	Handle.Transparency = 1
	Spawn(function()
		EquipClaws()
	end)
	Humanoid.WalkSpeed = 24
	ToolEquipped = true
end

function Unequipped()
	Clicks = 0
	FirstClick = false
	Blocking = false
	for i, v in pairs({LeftClaw, RightClaw}) do
		if v and v.Parent then
			v:Destroy()
		end
	end
	for i, v in pairs(Tool:GetChildren()) do
		if v:IsA("BasePart") and v ~= Handle then
			v:Destroy()
		end
	end
	for i, v in pairs({HealthChanged, ToolUnequipped}) do
		if v then
			v:disconnect()
		end
	end
	Handle.Transparency = 0
	for i, v in pairs(Animations) do
		InvokeClient("StopAnimation", v)
	end
	Humanoid.WalkSpeed = 16
	ToolEquipped = false
end

Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)