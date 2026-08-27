--Made by Luckymaxer
--Updated for R15 avatars by StarWars

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
R15 = false

BlackOutScript = script:WaitForChild("BlackOutScript")

Animations = {
	Equip = {Animation = Tool:WaitForChild("Equip"), FadeTime = nil, Weight = nil, Speed = nil, Duration = nil},
	LeftSlash = {Animation = Tool:WaitForChild("LeftSlash"), FadeTime = nil, Weight = nil, Speed = 8, Duration = 0.25},
	RightSlash = {Animation = Tool:WaitForChild("RightSlash"), FadeTime = nil, Weight = nil, Speed = 8, Duration = 0.25},
	ClawSlash = {Animation = Tool:WaitForChild("ClawSlash"), FadeTime = nil, Weight = nil, Speed = 8, Duration = 0.25},
	R15Equip = {Animation = Tool:WaitForChild("R15Equip"), FadeTime = nil, Weight = nil, Speed = nil, Duration = nil},
	R15LeftSlash = {Animation = Tool:WaitForChild("R15LeftSlash"), FadeTime = nil, Weight = nil, Speed = 1, Duration = .6},
	R15RightSlash = {Animation = Tool:WaitForChild("R15RightSlash"), FadeTime = nil, Weight = nil, Speed = 1, Duration = .6},
	R15ClawSlash = {Animation = Tool:WaitForChild("R15ClawSlash"), FadeTime = nil, Weight = nil, Speed = 1, Duration = .6}	
}

Sounds = {
	Swing1 = Handle:WaitForChild("Swing1"),
	Swing2 = Handle:WaitForChild("Swing2"),
	Swing3 = Handle:WaitForChild("Swing3"),
	Swing4 = Handle:WaitForChild("Swing4"),
	Hit = Handle:WaitForChild("Hit"),
}

Damage = {
	Hit = 5,
	Slash = 15,
	Crush = 40
}

ToolEquipped = false

Clicks = 0
FirstClick = false

DisplayModel = Tool:FindFirstChild("DisplayModel")
if DisplayModel then
	DisplayModel:Destroy()
end

for i, v in pairs(Tool:GetChildren()) do
	if v:IsA("BasePart") and v ~= Handle then
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
	if not Tool.Enabled or not ToolEquipped then
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
		local SlashSounds = {Sounds.Swing1, Sounds.Swing2, Sounds.Swing3, Sounds.Swing4}
		for i, v in pairs({LeftClaw, RightClaw}) do
			if v and v.Parent then
				if v == LeftClaw then
					if Humanoid and Humanoid.RigType == Enum.HumanoidRigType.R15 then
						table.insert(SingleClickAnims, Animations.R15LeftSlash)
					else
						table.insert(SingleClickAnims, Animations.LeftSlash)
					end
				elseif v == RightClaw then
					if Humanoid and Humanoid.RigType == Enum.HumanoidRigType.R15 then
						table.insert(SingleClickAnims, Animations.R15RightSlash)
					else
						table.insert(SingleClickAnims, Animations.RightSlash)
					end				
				end
			end
		end
		if ((LeftClaw and LeftClaw.Parent) and (RightClaw and RightClaw.Parent)) then
			table.insert(DoubleClickAnims, R15 and Animations.R15ClawSlash or Animations.ClawSlash)
		end
		SlashSounds[math.random(1, #SlashSounds)]:Play()
		AnimationChosen = (((Clicks < 2 or #DoubleClickAnims == 0) and SingleClickAnims[math.random(1, #SingleClickAnims)]) or DoubleClickAnims[math.random(1, #DoubleClickAnims)])
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
					if AnimationChosen == Animations.ClawSlash or AnimationChosen == Animations.R15ClawSlash then
						local LeftClawHit, LeftClawPos = RayCast(LeftClaw.Position, (LeftClaw.CFrame * CFrame.Angles(0, (math.pi / 2), 0)).lookVector, (LeftClaw.Size.X * 2), {Character})
						local RightClawHit, RightClawPos = RayCast(RightClaw.Position, (RightClaw.CFrame * CFrame.Angles(0, -(math.pi / 2), 0)).lookVector, (RightClaw.Size.X * 2), {Character})
						if ((LeftClawHit and LeftClawHit.Parent) and (RightClawHit and RightClawHit.Parent)) then
							local LeftHit = LeftClawHit.Parent
							local RightHit = RightClawHit.Parent
							LeftHit = (((LeftHit:IsA("Hat") or LeftHit:IsA("Tool")) and LeftHit.Parent) or LeftHit)
							RightHit = (((RightHit:IsA("Hat") or RightHit:IsA("Tool")) and RightHit.Parent) or RightHit)
							if LeftHit == character and RightHit == character then
								if LeftHit.Parent and LeftHit == character and RightHit.Parent and RightHit == character then
									DamageAmount = Damage.Crush
								end
							end
						end
					elseif ((AnimationChosen == Animations.LeftSlash and v == LeftClaw) or (AnimationChosen == Animations.RightSlash and v == RightClaw)) or
						((AnimationChosen == Animations.R15LeftSlash and v == LeftClaw) or (AnimationChosen == Animations.R15RightSlash and v == RightClaw)) then
						DamageAmount = Damage.Slash
					end
					Sounds.Hit:Play()
					table.insert(CharactersHit, character)
					UntagHumanoid(humanoid)
					TagHumanoid(humanoid, Player)
					humanoid:TakeDamage(DamageAmount)
					if DamageAmount == Damage.Crush then
						local player = Players:GetPlayerFromCharacter(character)
						if player and not character:FindFirstChild(BlackOutScript.Name) then
							local BackOutScriptClone = BlackOutScript:Clone()
							BackOutScriptClone.Disabled = false
							Debris:AddItem(BackOutScriptClone, 15)
							BackOutScriptClone.Parent = character
						end
					end
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
	Claw.Size = Vector3.new(1.25, 1.85, 1.25)
	Claw.CanCollide = false
	local Mesh = Instance.new("SpecialMesh")
	Mesh.TextureId = "http://www.roblox.com/asset?id=185943428"
	Mesh.MeshType = Enum.MeshType.FileMesh
	Mesh.Scale = Vector3.new(1.25, 1.25, 1.25)
	Mesh.Parent = Claw
	local LeftArm = Character:FindFirstChild("Left Arm") or Character:FindFirstChild("LeftHand")
	local RightArm = Character:FindFirstChild("Right Arm") or Character:FindFirstChild("RightHand")
	if LeftArm then
		LeftClaw = Claw:Clone()
		LeftClaw.Name = "LeftClaw"
		LeftClaw.Mesh.MeshId = "http://www.roblox.com/asset?id=185943376"
		local Weld = Instance.new("Weld")
		Weld.Part0 = LeftArm
		Weld.Part1 = LeftClaw
		Weld.C0 = CFrame.new(0, LeftArm.Name == "LeftHand" and 0 or -1, 0, 1, 0, -0, 0, 0, 1, 0, -1, -0)
		Weld.C1 = CFrame.new(0, 0.6, 0, -1, 8.9011528e-006, 0, 0, 0, 0.99999994, 8.9011528e-006, 1, -0) * CFrame.Angles(0, 0, math.pi)
		Weld.Parent = LeftClaw
		LeftClaw.Parent = Tool
	end
	if RightArm then
		RightClaw = Claw:Clone()
		RightClaw.Name = "RightClaw"
		RightClaw.Mesh.MeshId = "http://www.roblox.com/asset?id=185943338"
		local Weld = Instance.new("Weld")
		Weld.Part0 = RightArm
		Weld.Part1 = RightClaw
		Weld.C0 = CFrame.new(0, RightArm.Name == "RightHand" and 0 or -1, 0, 1, 0, -0, 0, 0, 1, 0, -1, -0)
		Weld.C1 = CFrame.new(0, 0.6, 0, -1, 8.9011528e-006, 0, 0, 0, 0.99999994, 8.9011528e-006, 1, -0) * CFrame.Angles(0, 0, math.pi)
		Weld.Parent = RightClaw
		RightClaw.Parent = Tool
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
				if not AnimationChosen or ((AnimationChosen == Animations.LeftSlash and v ~= LeftClaw) or (AnimationChosen == Animations.RightSlash and v ~= RightClaw)) or
					((AnimationChosen == Animations.R15LeftSlash and v ~= LeftClaw) or (AnimationChosen == Animations.R15RightSlash and v ~= RightClaw)) then
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
	Torso = Character:FindFirstChild("Torso") or Character:FindFirstChild("UpperTorso")
	if not CheckIfAlive() then
		return
	end
	for i, v in pairs(Tool:GetChildren()) do
		if v:IsA("BasePart") and v ~= Handle then
			v:Destroy()
		end
	end
	local CurrentlyEquipped = true
	EquippedToolUnequipped = Tool.Unequipped:connect(function()
		CurrentlyEquipped = false
	end)
	if EquippedToolUnequipped then
		EquippedToolUnequipped:disconnect()
	end
	if not CurrentlyEquipped then
		return
	end
	for i, v in pairs(Animations) do
		if v and v.Animation then
			InvokeClient("Preload", v.Animation.AnimationId)
		end
	end
	if Humanoid and Humanoid.RigType == Enum.HumanoidRigType.R15 then
		R15 = true
		InvokeClient("PlayAnimation", Animations.R15Equip)
	else
		InvokeClient("PlayAnimation", Animations.Equip)
	end
	Handle.Transparency = 1
	Spawn(function()
		EquipClaws()
	end)
	ToolEquipped = true
end

function Unequipped()
	Clicks = 0
	FirstClick = false
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
	for i, v in pairs({EquippedToolUnequipped, ToolUnequipped}) do
		if v then
			v:disconnect()
		end
	end
	Handle.Transparency = 0
	for i, v in pairs(Animations) do
		InvokeClient("StopAnimation", v)
	end
	ToolEquipped = false
end

Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)