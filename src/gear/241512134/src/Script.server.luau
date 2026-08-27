--Made by Luckymaxer

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

Animations = {
	LeftSlash = {Animation = Tool:WaitForChild("LeftSlash"), FadeTime = nil, Weight = nil, Speed = 1.2, Duration = 0.75, Damage = {Min = 18, Max = 33}},
	RightSlash = {Animation = Tool:WaitForChild("RightSlash"), FadeTime = nil, Weight = nil, Speed = 1.2, Duration = 0.75, Damage = {Min = 18, Max = 33}},
	Spin = {Animation = Tool:WaitForChild("Spin"), FadeTime = nil, Weight = nil, Speed = 1},
}

Sounds = {
	Slash = Handle:WaitForChild("Slash"),
	Unsheath = Handle:WaitForChild("Unsheath"),
	Spin = Handle:WaitForChild("Spin"),
}

Special = {
	Enabled = true,
	Active = false,
	Reloading = false,
	Duration = 15,
	ReloadTime = 25,
	Damage = {Min = 6, Max = 22},
}

TouchDamage = {Min = 6, Max = 8}

ToolEquipped = false

Rate = (1 / 60)

ServerControl = (Tool:FindFirstChild("ServerControl") or Instance.new("RemoteFunction"))
ServerControl.Name = "ServerControl"
ServerControl.Parent = Tool

ClientControl = (Tool:FindFirstChild("ClientControl") or Instance.new("RemoteFunction"))
ClientControl.Name = "ClientControl"
ClientControl.Parent = Tool

Tool.Enabled = true

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

function IsTeamMate(Player1, Player2)
	return (Player1 and Player2 and not Player1.Neutral and not Player2.Neutral and Player1.TeamColor == Player2.TeamColor)
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

function Blow(Hit)
	if not Hit or not Hit.Parent or not CheckIfAlive() then
		return
	end
	
	local character = Hit.Parent
	
	local player = Players:GetPlayerFromCharacter(character)
	if player and (IsTeamMate(Player, player) or player == Player) then
		return
	end
	
	local humanoid = character:FindFirstChild("Humanoid")
	if character == Character or not humanoid or humanoid.Health == 0 then
		return
	end
	
	local RightArm = Character:FindFirstChild("Right Arm")
	if not RightArm then
		return
	end
	local RightGrip = RightArm:FindFirstChild("RightGrip")
	if not RightGrip or (RightGrip.Part0 ~= RightArm and RightGrip.Part1 ~= RightArm) then
		return
	end
	
	UntagHumanoid(humanoid)
	TagHumanoid(humanoid, Player)
	
	local DamageValue = ((CurrentAnimation and CurrentAnimation.Damage) or TouchDamage)
	local FinalizedDamage = math.random(DamageValue.Min, DamageValue.Max)
	
	humanoid:TakeDamage(FinalizedDamage)
	
end

function Attack(PossibleAnims, PossibleSounds)
	if PossibleAnims and #PossibleAnims > 0 then
		if PossibleSounds and #PossibleSounds > 0 then
			PossibleSounds[math.random(1, #PossibleSounds)]:Play()
		end 
		CurrentAnimation = PossibleAnims[math.random(1, #PossibleAnims)]
		InvokeClient("PlayAnimation", CurrentAnimation)
		if CurrentAnimation.Duration and CurrentAnimation.Duration > 0 then
			wait(CurrentAnimation.Duration)
			InvokeClient("StopAnimation", CurrentAnimation)
			CurrentAnimation = nil
		end
	end
end

function GetTotalParts(MaxParts, PossibleParts, Parts)
	if MaxParts < PossibleParts then
		return MaxParts
	elseif Parts >= MaxParts then
		return 0
	elseif MaxParts >= PossibleParts then
		local PartCount = (MaxParts - PossibleParts)
		if Parts <= MaxParts then
			PartCount = (MaxParts - Parts)
			if PartCount > PossibleParts then
				return PossibleParts
			else
				return PartCount
			end
		elseif PartCount >= PossibleParts then
			return PossibleParts
		else
			return PartCount
		end
	end
end

function GetParts(Region, MaxParts, Ignore)
	local Parts = {}
	local RerunFailed = false
	while #Parts < MaxParts and not RerunFailed do
		local Region = Region
		local PossibleParts = GetTotalParts(MaxParts, 100, #Parts)
		local PartsNearby = game:GetService("Workspace"):FindPartsInRegion3WithIgnoreList(Region, Ignore, PossibleParts)
		if #PartsNearby == 0 then
			RerunFailed = true
		else
			for i, v in pairs(PartsNearby) do
				table.insert(Parts, v)
				table.insert(Ignore, v)
			end
		end
	end
	return Parts
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
	if not ToolEquipped or not Tool.Enabled or not CheckIfAlive() then
		return
	end
	Tool.Enabled = false
	local AttackAnims = {Animations.LeftSlash, Animations.RightSlash}
	local AttackSounds = {Sounds.Slash}
	Attack(AttackAnims, AttackSounds)
	Tool.Enabled = true
end

function CheckIfAlive()
	return (((Player and Player.Parent and Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Torso and Torso.Parent) and true) or false)
end

local colors = {
	BrickColor.new("Brown"),
	BrickColor.new("Reddish brown"),
	BrickColor.new("Sand red"),
}

function Equipped()
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	Torso = Character:FindFirstChild("Torso")
	if not CheckIfAlive() then
		return
	end
	Sounds.Unsheath:Play()
	ToolEquipped = true
	
	local root = Character:FindFirstChild("HumanoidRootPart")
	if root then
		while ToolEquipped do
			local part, pos, normal = workspace:FindPartOnRay(Ray.new(root.Position, Vector3.new(0, -64, 0)), Character)
			
			local firePath = BasePart:Clone()
			firePath.Material = Enum.Material.Slate
			firePath.Anchored = true
			firePath.Size = Vector3.new(2 + math.random(), 0.2 + math.random() * 0.2, 2 + math.random())
			firePath.CFrame = CFrame.new(pos, pos+normal) * CFrame.Angles(-math.pi/2, math.pi * 2 * math.random(), 0) * CFrame.Angles(-0.1 + math.random() * 0.2, 0, -0.1 + math.random() * 0.2)
			firePath.BrickColor = colors[math.random(1, #colors)]
			firePath.Touched:connect(function(part)
				if part:IsDescendantOf(Character) then return end
				
				if part.Parent and part.Parent:FindFirstChild("Humanoid") then
					local player = game.Players:GetPlayerFromCharacter(part.Parent)
					if player and IsTeamMate(Player, player) then
						return
					end
					
					local human = part.Parent.Humanoid
					human.Sit = true
				end
			end)
			firePath.Parent = Character
			game:GetService("Debris"):AddItem(firePath, 0.75)
			
			wait(0.1)
		end
	end
end

function Unequipped()
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

Handle.Touched:connect(Blow)

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)