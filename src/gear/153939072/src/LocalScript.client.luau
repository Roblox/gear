--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

PlaySound = Tool:WaitForChild("PlaySound")

HitGroundSound = Handle:WaitForChild("HitGround")
JumpDownSound = Handle:WaitForChild("JumpDown")
SlashSound = Handle:WaitForChild("Slash")

JumpUp = Tool:WaitForChild("JumpUp")
JumpDown = Tool:WaitForChild("JumpDown")
LeftSlash = Tool:WaitForChild("LeftSlash")
RightSlash = Tool:WaitForChild("RightSlash")

Equip = false
Active = false
SlashCoolDown = false
JumpCoolDown = false
OriginalWalkSpeed = 0
LastClick = 0
Clicks = 0
HitGround = false
HitParts = {}
PlayersUpHit = {}

HandleTouchedConnection = nil

function RayCast(Position, Direction, MaxDistance, IgnoreList)
	return game:GetService("Workspace"):FindPartOnRayWithIgnoreList(Ray.new(Position, Direction.unit * (MaxDistance or 999.999)), IgnoreList) 
end

function CheckTable(Table, Object)
	for i, v in pairs(Table) do
		if v == Object then
			return true
		end
	end
	return false
end

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

function PartsHit(Parts)
	for i, v in pairs(Parts) do
		if v:IsA("BasePart") then
			local PartHit
			PartHit = v.Touched:connect(function(Hit)
				if Hit and Hit.Parent then
					HitGround = true
					for i, v in pairs(Parts) do
					end
				end
			end)
			table.insert(HitParts, PartHit)
		end
	end
end

function JumpUpTouchEnabled()
	HandleTouchedConnection = Handle.Touched:connect(function(Hit)
		if Hit and Hit.Parent then
			local character, humanoid = FindCharacterAncestor(Hit.Parent)
			if character and character ~= Character and humanoid and humanoid ~= Humanoid and humanoid.Health > 0 and Humanoid.Health > 0 and not CheckTable(PlayersUpHit, character) then
				local torso = character:FindFirstChild("Torso")
				if  torso then
					table.insert(PlayersUpHit, character)
					UntagHumanoid(humanoid)
					TagHumanoid(humanoid, Player)
					humanoid:TakeDamage(20)
					torso.Velocity = Vector3.new(0, 148, 0)
				end
			end
		end
	end)
	return HandleTouchedConnection
end

function JumpDownTouchEnabled()
	HandleTouchedConnection = Handle.Touched:connect(function(Hit)
		if Hit and Hit.Parent then
			local character, humanoid = FindCharacterAncestor(Hit.Parent)
			if character and character ~= Character and humanoid and humanoid ~= Humanoid and humanoid.Health > 0 and Humanoid.Health > 0 and CheckTable(PlayersUpHit, character) then
				local torso = character:FindFirstChild("Torso")
				if  torso then
					for i, v in pairs(PlayersUpHit) do
						if v == character then
							table.remove(PlayersUpHit, i)
						end
					end
					UntagHumanoid(humanoid)
					TagHumanoid(humanoid, Player)
					humanoid:TakeDamage(40)
					torso.Velocity = Vector3.new(0, -5, 0)
				end
			end
		end
	end)
	return HandleTouchedConnection
end

function Attack()
	Active = true
	Spawn(function()
		if (not SlashCoolDown and (not SlashAnim or SlashAnim.KeyframeReached)) then
			SlashCoolDown = true
			local PossibleAnims = {RightSlash, LeftSlash}
			local ChosenAnim = PossibleAnims[math.random(1, #PossibleAnims)]
			SlashAnim = Humanoid:LoadAnimation(ChosenAnim)
			SlashAnim:Play()
			PlaySound.Value = SlashSound.Name
			HandleTouchedConnection = Handle.Touched:connect(function(Hit)
				if Hit and Hit.Parent then
					local character, humanoid = FindCharacterAncestor(Hit.Parent)
					if character and character ~= Character and humanoid and humanoid ~= Humanoid and humanoid.Health > 0 and Humanoid.Health > 0 then
						UntagHumanoid(humanoid)
						TagHumanoid(humanoid, Player)
						humanoid:TakeDamage(5)
					end
				end
			end)
			Delay(0.5, function()
				if HandleTouchedConnection then
					HandleTouchedConnection:disconnect()
				end
			end)
			wait(0.5)
			SlashCoolDown = false
		end
	end)
	Active = false
end

function DoubleClick() --Idea suggested by nintendocpu/Bayshicpu
	if Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Torso and Torso.Parent then
		JumpCoolDown = true
		Active = true
		JumpUpAnim = Humanoid:LoadAnimation(JumpUp)
		JumpDownAnim = Humanoid:LoadAnimation(JumpDown)		
		
		OriginalWalkSpeed = Humanoid.WalkSpeed
		Humanoid.WalkSpeed = 0
		
		JumpUpAnim:Play(0, 1, 8)
		Humanoid.Jump = true
		Torso.Velocity = Vector3.new(0, 150, 0)
		
		JumpTouchedConnection = JumpUpTouchEnabled()
		
		Delay(1.5, function()
			if JumpTouchedConnection then
				JumpTouchedConnection:disconnect()
			end
		end)

		while Torso.Velocity.Y > 0 do
			wait()
		end
		
		if Equip then
			if JumpTouchedConnection then
				JumpTouchedConnection:disconnect()
			end
	
			JumpTouchedConnection = JumpDownTouchEnabled()
	
			Delay(1, function()
				if JumpTouchedConnection then
					JumpTouchedConnection:disconnect()
				end
			end)
	
			JumpUpAnim:Stop()
			JumpDownAnim:Play(0, 1, 10)
			PlaySound.Value = JumpDownSound.Name
			Torso.Velocity = Torso.Velocity - Vector3.new(0, 10, 0)
			
			RightLeg = Character:FindFirstChild("Right Leg")
			LeftLeg = Character:FindFirstChild("Left Leg")
			PartsHit({RightLeg, LeftLeg})
			while not HitGround do
				wait()
			end
			HitGround = false
			for i, v in pairs(HitParts) do
				if v then
					v:disconnect()
				end
			end
			HitParts = {}
			PlayersUpHit = {}
			JumpDownAnim:Stop()
			PlaySound.Value = HitGroundSound.Name
			Humanoid.WalkSpeed = OriginalWalkSpeed
			Active = false
		end
		wait(2)
		JumpCoolDown = false
	end
end

function Activated()
	if not Active then
		local Tick = tick()
		if HandleTouchedConnection then
			HandleTouchedConnection:disconnect()
		end
		if LastClick == 0 or (Tick - LastClick) <= 0.25 and not JumpCoolDown then
			LastClick = Tick
			Clicks = Clicks + 1
			if Clicks >= 2 then
				LastClick = 0
				Clicks = 0
				local Hit, Pos = RayCast(Torso.Position, Vector3.new(0, -1, 0), (Torso.Size * 2), {Character})
				if Hit and Hit.Parent then
					if SlashAnim then
						SlashAnim:Stop()
					end
					DoubleClick()
				end
			else
				Attack()
			end
		else
			Attack()
			Clicks = 1
			LastClick = Tick
		end
	end
end

function Equipped(Mouse)
	Equip = true
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	Torso = Character:FindFirstChild("Torso")
	if not Player or not Humanoid or not Torso then
		return
	end
	StartingWalkSpeed = Humanoid.WalkSpeed
	Humanoid.WalkSpeed = 32
end

function Unequipped()
	Equip = false
	Active = false
	Humanoid.WalkSpeed = StartingWalkSpeed
	if HandleTouchedConnection then
		HandleTouchedConnection:disconnect()
	end
	if JumpTouchedConnection then
		JumpTouchedConnection:disconnect()
	end
	if SlashAnim then
		SlashAnim:Stop()
	end
	if JumpUpAnim then
		JumpUpAnim:Stop()
	end
	if JumpDownAnim then
		JumpDownAnim:Stop()
	end
	for i, v in pairs(HitParts) do
		if v then
			v:disconnect()
		end
	end
	HitParts = {}
	PlayersUpHit = {}
end

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)