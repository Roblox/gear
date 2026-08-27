--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")
RunService = game:GetService("RunService")

RbxUtility = LoadLibrary("RbxUtility")
Create = RbxUtility.Create

FreezeScript = script:WaitForChild("FreezeScript")
BlizzardGui = script:WaitForChild("BlizzardGui")

BaseUrl = "http://www.roblox.com/asset/?id="

Gravity = 196.20

Rate = (1 / 60)

Damage = {
	Touch = {Min = 5, Max = 8},
	Hit = {Min = 12, Max = 15},
}

BasePart = Create("Part"){
	Material = Enum.Material.Plastic,
	Shape = Enum.PartType.Block,
	TopSurface = Enum.SurfaceType.Smooth,
	BottomSurface = Enum.SurfaceType.Smooth,
	FormFactor = Enum.FormFactor.Custom,
	Size = Vector3.new(0.2, 0.2, 0.2),
	CanCollide = true,
	Locked = true,
}

Sounds = {
	Unsheath = Handle:WaitForChild("Unsheath"),
	Slash = Handle:WaitForChild("Slash"),
	Solidify = Handle:WaitForChild("Solidify"),
	IceShatter = Handle:WaitForChild("IceShatter")
}

Animations = {
	LeftSlash = {Animation = Tool:WaitForChild("LeftSlash"), FadeTime = nil, Weight = nil, Speed = 1.25, Duration = 0.5},
	RightSlash = {Animation = Tool:WaitForChild("RightSlash"), FadeTime = nil, Weight = nil, Speed = 1.25, Duration = 0.5},
	Swing = {Animation = Tool:WaitForChild("Swing"), FadeTime = nil, Weight = nil, Speed = 0.8, Duration = 0.5},
	Idle = {Animation = Tool:WaitForChild("Idle"), FadeTime = nil, Weight = nil, Speed = 1, Duration = nil},
}

BaseIce = BasePart:Clone()
BaseIce.Name = "Ice"
BaseIce.BrickColor = BrickColor.new("Bright blue")
BaseIce.Material = Enum.Material.Ice
BaseIce.Transparency = 0.25
for i, v in pairs({"Top", "Bottom", "Front", "Back", "Left", "Right"}) do
	pcall(function()
		BaseIce[(v .. "Surface")] = Enum.SurfaceType.SmoothNoOutlines
	end)
end

HitDebounce = false
ToolEquipped = false

ServerControl = (Tool:FindFirstChild("ServerControl") or Create("RemoteFunction"){
	Name = "ServerControl",
	Parent = Tool,
})

ClientControl = (Tool:FindFirstChild("ClientControl") or Create("RemoteFunction"){
	Name = "ClientControl",
	Parent = Tool,
})

Handle.Transparency = 0
Tool.Enabled = true

function IsTeamMate(Player1, Player2)
	return (Player1 and Player2 and not Player1.Neutral and not Player2.Neutral and Player1.TeamColor == Player2.TeamColor)
end

function TagHumanoid(humanoid, player)
	local Creator_Tag = Create("ObjectValue"){
		Name = "creator",
		Value = player,
	}
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

function Attack(PossibleAnims)
	if not CheckIfAlive() or not ToolEquipped then
		return
	end
	if PossibleAnims and #PossibleAnims > 0 then
		local Animation = PossibleAnims[math.random(1, #PossibleAnims)]
		CurrentAnimation = Animation
		local AttackAnimation = CurrentAnimation
		Spawn(function()
			InvokeClient("PlayAnimation", CurrentAnimation)
		end)
		wait(Animation.Duration)
		CurrentAnimation = nil
	end
end

function CheckTableForString(Table, String)
	for i, v in pairs(Table) do
		if string.lower(v) == string.lower(String) then
			return true
		end
	end
	return false
end

function Blow(Hit)
	if not Hit or not Hit.Parent or not CheckIfAlive() or not ToolEquipped or HitDebounce then
		return
	end
	local RightArm = Character:FindFirstChild("Right Arm")
	if not RightArm then
		return
	end
	local RightGrip = RightArm:FindFirstChild("RightGrip")
	if not RightGrip or (RightGrip.Part0 ~= Handle and RightGrip.Part1 ~= Handle) then
		return
	end
	local character = Hit.Parent
	if character == Character then
		return
	end
	local humanoid = character:FindFirstChild("Humanoid")
	if not humanoid or humanoid.Health == 0 then
		return
	end
	local torso = character:FindFirstChild("Torso")
	if not torso then
		return
	end
	local player = Players:GetPlayerFromCharacter(character)
	if player and (player == Player or IsTeamMate(Player, player)) then
		return
	end
	HitDebounce = true
	local PossibleDamage = ((CurrentAnimation and Damage.Hit) or Damage.Touch)
	local DamageValue = math.random(PossibleDamage.Min, PossibleDamage.Max)
	local HealthAfter = (humanoid.Health - DamageValue)
	UntagHumanoid(humanoid)
	TagHumanoid(humanoid, Player)
	humanoid:TakeDamage(DamageValue)
	if HealthAfter > 0 then
		local IceChance = math.random(1, 5)
		if IceChance == 1 and not character:FindFirstChild("IceBlock") then
			local torso = character:FindFirstChild("Torso")
			if torso then
				local CharacterSize = character:GetModelSize()
				local CharacterCFrame = character:GetModelCFrame()
				local Ice = BaseIce:Clone()
				Ice.Name = "IceBlock"
				Ice.CanCollide = true
				Ice.Size = (CharacterSize + Vector3.new(0.125, 0.5, 2))
				Ice.CFrame = CharacterCFrame
				local Sound = Sounds.Solidify:Clone()
				Sound.Pitch = (math.random(5, 25) * 0.1)
				Sound.Parent = Ice
				local Weld = Create("Weld"){
					Part0 = torso,
					Part1 = Ice,
					C0 = torso.CFrame:inverse(),
					C1 = Ice.CFrame:inverse(),
					Parent = Ice,
				}
				Debris:AddItem(Ice, 15)
				local FreezeScriptCopy = FreezeScript:Clone()
				FreezeScriptCopy.Parent = character
				local Object = Create("ObjectValue"){
					Name = "Object",
					Value = Ice,
					Parent = FreezeScriptCopy,
				}
				Ice.Parent = character
				FreezeScriptCopy.Disabled = false
				Sound:Play()
			end
		end
	elseif CurrentAnimation == Animations.Swing then
		local Ice = character:FindFirstChild("IceBlock")
		if Ice then
			for i, v in pairs(character:GetChildren()) do
				if v:IsA("ForceField") then
					return
				end
			end
			local Sound = Sounds.IceShatter:Clone()
			Sound.Parent = Ice
			Sound:Play()
			UntagHumanoid(humanoid)
			TagHumanoid(humanoid, Player)
			humanoid:TakeDamage(math.huge)
		end
	end
	wait(0.25)
	HitDebounce = false
end

function CoolNearby(Radius)
	local function CoolPlayers()
		for i, v in pairs(Players:GetChildren()) do
			if v:IsA("Player") and v ~= Player and not IsTeamMate(Player, v) and v.Character then
				local character = v.Character
				local humanoid = character:FindFirstChild("Humanoid")
				local torso = character:FindFirstChild("Torso")
				if humanoid and humanoid.Health > 0 and torso then
					local DistanceApart = (Handle.Position - torso.Position).Magnitude
					if DistanceApart <= Radius then
						local PlayerGui = v:FindFirstChild("PlayerGui")
						if PlayerGui then
							local Gui = PlayerGui:FindFirstChild(BlizzardGui.Name)
							if Gui then
								local Timer = Gui:FindFirstChild("Timer")
								if Timer then
									Timer.Value = tick()
								end
							end
							if not Gui then
								Gui = BlizzardGui:Clone()
								local Timer = Gui:FindFirstChild("Timer")
								if Timer then
									Timer.Value = tick()
								end
								for i, v in pairs(Gui:GetChildren()) do
									if v:IsA("BaseScript") then
										v.Disabled = false
									end
								end
								Gui.Parent = PlayerGui
							end
						end
					end
				end
			end
		end
	end
	RunService.Stepped:connect(function()
		if ToolEquipped and CheckIfAlive() then
			CoolPlayers()
		end
	end)
end

function CheckIfAlive()
	return (((Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Torso and Torso.Parent and Player and Player.Parent) and true) or false)
end

function Activated()
	if not Tool.Enabled or not ToolEquipped then
		return
	end
	Tool.Enabled = false
	Sounds.Slash:Play()
	local AttackAnims = {Animations.LeftSlash, Animations.RightSlash, Animations.Swing}
	Attack(AttackAnims)
	Tool.Enabled = true
end

function Equipped(Mouse)
	Character = Tool.Parent
	Humanoid = Character:FindFirstChild("Humanoid")
	Torso = Character:FindFirstChild("Torso")
	Player = Players:GetPlayerFromCharacter(Character)
	if not CheckIfAlive() then
		return
	end
	Sounds.Unsheath:Play()
	Spawn(function()
		InvokeClient("PlayAnimation", Animations.Idle)
	end)
	ToolEquipped = true
end

function Unequipped()
	ToolEquipped = false
end

function OnServerInvoke(player, mode, value)
	if player ~= Player or not ToolEquipped or not value or not CheckIfAlive() then
		return
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

Handle.Touched:connect(Blow)

Spawn(function()
	CoolNearby(10)
end)

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)