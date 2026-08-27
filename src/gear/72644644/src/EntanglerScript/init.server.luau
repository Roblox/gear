--Rescripted by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")
InsertService = game:GetService("InsertService")

InfoGui = script:WaitForChild("InfoGui")
AIScript = script:WaitForChild("AIScript")

CloneId = 68452456
CloneModel = InsertService:LoadAsset(CloneId)
Clone = CloneModel:GetChildren()[1]:Clone()
if CloneModel and CloneModel.Parent then
	CloneModel:Destroy()
end

CloneValue = Instance.new("ObjectValue")
CloneValue.Changed:connect(function()
	if not InfoGuiClone or not InfoGuiClone.Parent then
		return
	end
	local Frame = InfoGuiClone:FindFirstChild("Frame")
	if not Frame then
		return
	end
	local TextLabel = Frame:FindFirstChild("TextLabel")
	if not TextLabel then
		return
	end
	TextLabel.Text = ((CloneValue.Value and "Press Q/E to swap with your double!") or "Summon your double!")
end)

BasePart = Instance.new("Part")
BasePart.Shape = Enum.PartType.Block
BasePart.Material = Enum.Material.Plastic
BasePart.FormFactor = Enum.FormFactor.Custom
BasePart.TopSurface = Enum.SurfaceType.Smooth
BasePart.BottomSurface = Enum.SurfaceType.Smooth
BasePart.Size = Vector3.new(0.2, 0.2, 0.2)
BasePart.Locked = true
BasePart.CanCollide = true
BasePart.Anchored = false

ShockWave = BasePart:Clone()
ShockWave.Size = Vector3.new(1, 0.2, 1)
ShockWave.Transparency = 1
ShockWave.Anchored = true
ShockWave.CanCollide = false
TopDecal = Instance.new("Decal")
TopDecal.Specular = 20
TopDecal.Face = Enum.NormalId.Top
TopDecal.Texture = "http://www.roblox.com/asset/?version=1&id=72634953"
TopDecal.Parent = ShockWave
BottomDecal = TopDecal:Clone()
BottomDecal.Face = Enum.NormalId.Bottom
BottomDecal.Parent = ShockWave
Mesh = Instance.new("BlockMesh")
Mesh.Parent = ShockWave

Animations = {
	Stab = {Animation = Tool:WaitForChild("Stab"), FadeTime = nil, Weight = nil, Speed = nil, Duration = nil},
	Rage = {Animation = Tool:WaitForChild("Rage"), FadeTime = nil, Weight = nil, Speed = nil, Duration = nil}
}

ShockDamage = 14

CanSwap = true
CanExplode = true
ToolEquipped = false

ServerControl = (Tool:FindFirstChild("ServerControl") or Instance.new("RemoteFunction"))
ServerControl.Name = "ServerControl"
ServerControl.Parent = Tool

ClientControl = (Tool:FindFirstChild("ClientControl") or Instance.new("RemoteFunction"))
ClientControl.Name = "ClientControl"
ClientControl.Parent = Tool

Tool.Enabled = true

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

function IsTeamMate(Player1, Player2)
	return (Player1 and Player2 and not Player1.Neutral and not Player2.Neutral and Player1.TeamColor == Player2.TeamColor)
end

function SpawnClone(character, torso)
	
	if not character then
		return
	end
	
	local humanoid = character:FindFirstChild("Humanoid")
	if not humanoid or humanoid.Health == 0 then
		return
	end

	PlayerClone = Clone:Clone()
	PlayerClone.Name = character.Name
	
	CloneValue.Value = PlayerClone
	
	local ThisClone = PlayerClone
	
	local CloneHumanoid = PlayerClone:FindFirstChild("Humanoid")
	if CloneHumanoid then
		CloneHumanoid.Died:connect(function()
			Debris:AddItem(PlayerClone, 2)
		end)
		PlayerClone.Changed:connect(function(Property)
			if Property == "Parent" and not PlayerClone.Parent then
				if CloneValue.Value == ThisClone then
					CloneValue.Value = nil
				end
			end
		end)
	end
	
	local Target = Instance.new("ObjectValue")
	Target.Name = "Target"
	Target.Value = humanoid
	Target.Parent = PlayerClone
	
	local AIScriptClone = AIScript:Clone()
	AIScriptClone.Disabled = false
	AIScriptClone.Parent = PlayerClone
	
	for i, v in pairs(character:GetChildren()) do
		if v:IsA("BasePart") then
			for ii, vv in pairs(PlayerClone:GetChildren()) do
				if v:IsA("BasePart") and v.Name == vv.Name then
					vv.BrickColor = v.BrickColor
					for iii, vvv in pairs(vv:GetChildren()) do
						if not vvv:IsA("JointInstance") then
							vvv:Destroy()
						end
					end
					for iii, vvv in pairs(v:GetChildren()) do
						if vvv:IsA("FaceInstance") or vvv:IsA("DataModelMesh") then
							local Object = vvv:Clone()
							Object.Parent = vv
						end
					end
				end
			end
		elseif v:IsA("Clothing") or v:IsA("Accoutrement") or v:IsA("CharacterMesh") then
			local Object = v:Clone()
			Object.Parent = PlayerClone
		end
	end	
	
	Debris:AddItem(PlayerClone, 60)
	PlayerClone.Parent = game:GetService("Workspace")
	PlayerClone:MoveTo(Torso.Position + Vector3.new(5, 0, 5))
	
end

function Swap()
	if not PlayerClone or not PlayerClone.Parent or not CheckIfAlive() or not CanSwap then
		return
	end
	local humanoid = PlayerClone:FindFirstChild("Humanoid")
	local torso = PlayerClone:FindFirstChild("Torso")
	if not humanoid or humanoid.Health == 0 or not torso then
		return
	end
	CanSwap = false
	local myCFrame = Torso.CFrame
	local cloneCFrame = torso.CFrame
	Torso.CFrame = CFrame.new(cloneCFrame.p, cloneCFrame.p + cloneCFrame.lookVector)
	torso.CFrame = CFrame.new(myCFrame.p, myCFrame.p + myCFrame.lookVector)
	wait(0.75)
	CanSwap = true
end

function BlastHumanoids(torso)
	if not torso then
		return
	end
	local AOE = Vector3.new(10, 10, 10)	
	local Parts = game:GetService("Workspace"):FindPartsInRegion3WithIgnoreList(Region3.new((torso.Position - AOE), (torso.Position + AOE)), {Character, PlayerClone}, 100)
	for i, v in pairs(Parts) do
		local character = v.Parent
		local player = Players:GetPlayerFromCharacter(character)
		local IgnorePlayer = false
		if player and IsTeamMate(Player, player) then
			IgnorePlayer = true
		end
		if character and not IgnorePlayer then
			local humanoid = character:FindFirstChild("Humanoid")
			local torso = character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Torso")
			if humanoid and humanoid.Health > 0 and torso then
				UntagHumanoid(humanoid)
				TagHumanoid(humanoid, Player)
				humanoid:TakeDamage(ShockDamage)
				humanoid.Sit = true
			end
		end
	end
end

function Explode()
	if not PlayerClone or not PlayerClone.Parent or not CheckIfAlive() or not CanExplode then
		return
	end
	local humanoid = PlayerClone:FindFirstChild("Humanoid")
	local torso = PlayerClone:FindFirstChild("Torso")
	if not humanoid or humanoid.Health == 0 or not torso then
		return
	end
	CanExplode = false
	InvokeClient("PlayAnimation", Animations.Rage)
	wait(0.35)
	local Blasted = false
	Humanoid.WalkSpeed = 0
	humanoid.WalkSpeed = 0
	local ShockWaveDuration = 1
	local ShockWaveTick = tick()
	local ShockWaveClone = ShockWave:Clone()
	local ShockWaveMesh = ShockWaveClone.Mesh
	local ShockWaveClone2 = ShockWave:Clone()
	local ShockWaveMesh2 = ShockWaveClone2.Mesh
	Debris:AddItem(ShockWaveClone, ShockWaveDuration)
	Debris:AddItem(ShockWaveClone2, ShockWaveDuration)
	ShockWaveClone.Parent = game:GetService("Workspace")
	ShockWaveClone2.Parent = game:GetService("Workspace")
	ShockWaveClone.CFrame = Torso.CFrame
	ShockWaveClone2.CFrame = torso.CFrame
	while (tick() - ShockWaveTick) < ShockWaveDuration and ShockWaveClone and ShockWaveClone.Parent do
		ShockWaveMesh.Scale = Vector3.new((ShockWaveMesh.Scale.X + 1.1), 0.2, (ShockWaveMesh.Scale.Z + 1.1))
		ShockWaveMesh2.Scale = Vector3.new((ShockWaveMesh2.Scale.X + 1.1), 0.2, (ShockWaveMesh2.Scale.Z + 1.1))
		ShockWaveClone.CFrame = Torso.CFrame
		ShockWaveClone2.CFrame = torso.CFrame
		if (tick() - ShockWaveTick) < 0.85 and not Blasted then
			Blasted = true 
			BlastHumanoids(torso)
			BlastHumanoids(Torso)
		end
		wait()
	end
	for i, v in pairs({ShockWaveClone, ShockWaveClone2}) do
		if v and v.Parent then
			v:Destroy()
		end
	end
	Humanoid.WalkSpeed = 16
	humanoid.WalkSpeed = 16
	wait(7.5)
	CanExplode = true
end
function CheckIfAlive()
	return (((Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Torso and Torso.Parent and Player and Player.Parent) and true) or false)
end

function Activated()
	if not Tool.Enabled or not CheckIfAlive() or not ToolEquipped then 
		return 
	end
	if PlayerClone and PlayerClone.Parent then
		return
	end
	Tool.Enabled = false
	InvokeClient("PlayAnimation", Animations.Stab)
	wait(0.5)
	SpawnClone(Character, Torso)
	wait(0.5)
	Tool.Enabled = true
end

function Equipped()
	Character = Tool.Parent
	Humanoid = Character:FindFirstChild("Humanoid")
	Torso = Character:FindFirstChild("HumanoidRootPart")
	Player = Players:GetPlayerFromCharacter(Character)
	if not CheckIfAlive() then
		return
	end
	PlayerGui = Player:FindFirstChild("PlayerGui")
	if PlayerGui then
		InfoGuiClone = InfoGui:Clone()
		InfoGuiClone.Frame.TextLabel.Text = "Summon your double!"
		InfoGuiClone.Parent = PlayerGui
	end
	ToolEquipped = true
end

function Unequipped()
	if InfoGuiClone and InfoGuiClone.Parent then
		InfoGuiClone:Destroy()
	end
	ToolEquipped = false
end

function OnServerInvoke(player, mode, value)
	if player == Player and ToolEquipped and value and CheckIfAlive() then
		if mode == "KeyPress" then
			local Down = value.Down
			local Key = value.Key
			local ByteKey = string.byte(Key)
			if (Key == "q" or Key == "e") and Down then
				Swap()
			elseif Key == "x" and Down then
				Explode()
			end
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

ServerControl.OnServerInvoke = OnServerInvoke
Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)