--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")
local GLib = require(206209239)

Players = game:GetService("Players")
Debris = game:GetService("Debris")
RunService = game:GetService("RunService")
InsertService = game:GetService("InsertService")

SlashSound = Handle:WaitForChild("SlashSound")

LeftSlash = Tool:WaitForChild("LeftSlash")
RightSlash = Tool:WaitForChild("RightSlash")
Strike = Tool:WaitForChild("Strike")
Idle = Tool:WaitForChild'Idle'
Walk = Tool:WaitForChild'Walk'

NewAnimate = script:WaitForChild("NewAnimate")

Base_Damage = 8
Slash_Damage = 15
Strike_Damage = 20

ExtraDamage = 15

Damage = Base_Damage

CrownId = 166896278
CrownModel = InsertService:LoadAsset(CrownId)
Crown = CrownModel:GetChildren()[1]
CrownName = Crown.Name
CrownHandle = Crown:FindFirstChild("Handle")
CrownMesh = CrownHandle:FindFirstChild("Mesh")

AttackReady = true
StrikeReady = true

Last_Attack = 0

function FindCharacterAncestor(Parent)
	if Parent and Parent ~= game:GetService("Workspace") then
		local humanoid = Parent:FindFirstChild("Humanoid")
		if humanoid then
			return Parent, humanoid
		else
			return FindCharacterAncestor(Parent.Parent)
		end
	end
	return nil
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

function CheckForCrown()
	for i, v in pairs(Character:GetChildren()) do
		if v:IsA("Hat") then
			local handle = v:FindFirstChild("Handle")
			if handle then
				local mesh = handle:FindFirstChild("Mesh")
				if mesh and mesh.MeshId == CrownMesh.MeshId and mesh.TextureId == CrownMesh.TextureId then
					return true
				end
			end
		end
	end
	return false
end

function Blow(Hit)
	if Hit and Hit.Parent then
		local character = Hit.Parent
		local humanoid = character:FindFirstChild("Humanoid")
		if Humanoid and Humanoid ~= humanoid and humanoid and Humanoid.Health > 0 and humanoid.Health > 0 then
			local Right_Arm = Character:FindFirstChild("Right Arm")
			if Right_Arm then
				local Joint = Right_Arm:FindFirstChild("RightGrip")
				if (Joint and (Joint.Part0 == Handle or Joint.Part1 == Handle)) and GLib.IsTeammate(GLib.GetPlayerFromPart(Tool), GLib.GetPlayerFromPart(humanoid))~=true then
					UntagHumanoid(humanoid)
					TagHumanoid(humanoid, Player)
					humanoid:TakeDamage((Damage + ((CheckForCrown() and ExtraDamage) or 0)))
					print((Damage + ((CheckForCrown() and ExtraDamage) or 0)))
				end
			end
		end
	end
end

function CreateFakeHandle()
	LeftSword = Handle:Clone()
	LeftSword.Name = "FakeHandle"
	LeftSword.CanCollide = false
	
	LeftSwordWeld = Instance.new("ManualWeld")
	LeftSwordWeld.Part1 = LeftSword
	LeftSwordWeld.C0 = CFrame.new(0, -1, 0, 1, 0, -0, 0, 0, 1, 0, -1, -0)
	LeftSwordWeld.C1 = Tool.Grip
	
	local LeftArm = Character:FindFirstChild("Left Arm")
	LeftSwordWeld.Part0 = LeftArm
	LeftSword.Parent = Tool
	LeftSwordWeld.Parent = LeftSword
	
	LeftSword.Touched:connect(Blow)	
end

function Attack()
	Spawn(function()
		AttackReady = false
		Damage = Slash_Damage
		RandomSlashAnim = math.random(1, 2)
		CurrentAnim = Humanoid:LoadAnimation((RandomSlashAnim == 1 and LeftSlash) or RightSlash)
		SlashAnim = CurrentAnim
		if SlashAnim then
			SlashAnim:Play()
		end
		wait(0.5)
		if SlashAnim then
			SlashAnim:Stop()
		end
		Damage = Base_Damage
		AttackReady = true
	end)
end

function DoubleClick()
	Spawn(function()
		StrikeReady = false
		AttackReady = false
		Damage = Strike_Damage
		--NewAnimateClone.Disabled = true
		CurrentAnim = Humanoid:LoadAnimation(Strike)
		if CurrentAnim then
			CurrentAnim:Play()
		end
		wait(1)
		if CurrentAnim then
			CurrentAnim:Stop()
		end
		--NewAnimateClone.Disabled = false
		Damage = Base_Damage
		AttackReady = true
		StrikeReady = true
	end)
end

function Activated()
	if Tool.Enabled and StrikeReady then
		Tool.Enabled = false
		local Time = RunService.Stepped:wait()
		if (Time - Last_Attack) < 0.2 then
			DoubleClick()
		elseif AttackReady then
			Attack()
		end
		SlashSound:Play()
		Last_Attack = Time
		Tool.Enabled = true
	end
end

local IdleTrack, WalkTrack, WalkCon
function Equipped()
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	Torso = Character:FindFirstChild("Torso")
	if not Humanoid or Humanoid.Health == 0 or not Torso then
		return
	end
	IdleTrack = Humanoid:LoadAnimation(Idle)
	IdleTrack:Play()
	WalkTrack = Humanoid:LoadAnimation(Walk)
	WalkCon = Humanoid.Running:connect(function(speed)
		if speed > 0.001 then
			WalkTrack:Play()
		else
			WalkTrack:Stop()
		end
	end)
	if Humanoid:GetState() == Enum.HumanoidStateType.Running then
		WalkTrack:Play()
	end
	
	wait()
	
	local FakeHandle = Tool:FindFirstChild("FakeHandle")
	if FakeHandle then
		FakeHandle:Destroy()
	end

	CreateFakeHandle()
	--[[
	OldAnimate = Character:FindFirstChild("Animate")
	if OldAnimate then
		OldAnimate.Disabled = true
	end
	
	NewAnimateClone = NewAnimate:Clone()
	NewAnimateClone.Disabled = false
	NewAnimateClone.Parent = Character
	--]]
end

function Unequipped()
	if IdleTrack then IdleTrack:Stop() end
	if WalkTrack then WalkTrack:Stop() end
	if WalkCon then WalkCon:disconnect() WalkCon=nil end
	
	StrikeReady = true
	LeftSword:Destroy()
	if CurrentAnim then
		CurrentAnim:Stop()
	end
	--[[
	if NewAnimateClone and NewAnimateClone.Parent then
		NewAnimateClone.Stop.Value = true
	end
	if OldAnimate and OldAnimate.Parent then
		OldAnimate.Disabled = false
	end
	--]]
end

Handle.Touched:connect(Blow)

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)
