--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Eat = Tool:WaitForChild("Eat")
IdlePunch = Tool:WaitForChild("IdlePunch")
LeftPunch = Tool:WaitForChild("LeftPunch")
RightPunch = Tool:WaitForChild("RightPunch")

Whack = Handle:WaitForChild("Whack")
Eating = Handle:WaitForChild("Eating")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

Damage = 15

PunchingHams = {}
Arms = {}

Equipped = false
Enabled = false
Active = false
Swinging = false

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

function MakeDeadly(Part)
	Part.Touched:connect(function(Hit)
		if Hit and Hit.Parent and Hit.Parent ~= Character and Swinging then
			local humanoid = Hit.Parent:FindFirstChild("Humanoid")
			if humanoid and humanoid.Health > 0 and Humanoid.Health > 0 then
				Whack:Play()
				local torso = Hit.Parent:FindFirstChild("Torso")
				if torso then
					torso.Velocity = CFrame.new(Part.Position, torso.Position).lookVector * 100
				end
				UntagHumanoid(humanoid)
				TagHumanoid(humanoid, Player)
				humanoid:TakeDamage(Damage)
			end
		end
	end)
end

function Activated()
	if not Humanoid or not Humanoid.Parent or Humanoid.Health == 0 or Active then
		return
	end
	if not Enabled then
		Enabled = true
		Active = true
		EatAnim = Humanoid:LoadAnimation(Eat)
		if EatAnim then
			EatAnim:Play()
		end
		local StillEquipped = true
		ToolUnequippedConnection = Tool.Unequipped:connect(function()
			StillEquipped = false
			ToolUnequippedConnection:disconnect()
		end)
		wait(1.5)
		Eating:Play()
		if Equipped and StillEquipped then
			if EatAnim then
				EatAnim:Stop()
			end
			IdlePunchAnim = Humanoid:LoadAnimation(IdlePunch)
			if IdlePunchAnim then
				IdlePunchAnim:Play()
			end
			LeftArm = Character:FindFirstChild("Left Arm")
			RightArm = Character:FindFirstChild("Right Arm")
			Arms = {LeftArm, RightArm}
			if LeftArm and RightArm then
				Handle.Transparency = 1
				for i, v in pairs(Arms) do
					if v and v.Parent then
						v.Transparency = 1
						local Part = Handle:Clone()
						Part.Name = "PunchingHam"
						Part.Transparency = 0
						Part.Size = v.Size
						Part:FindFirstChild("Mesh").Scale = Vector3.new(1.25, 1.25, 1.25)
						local Weld = Instance.new("Weld")
						Weld.Part0 = Part
						Weld.Part1 = v
						Weld.C0 = Weld.C0 * CFrame.Angles(math.pi / 2, 0, 0)
						Weld.Parent = Part
						table.insert(PunchingHams, Part)
						MakeDeadly(Part)
						Part.Parent = v
					end
				end
			end
		end
		Active = false
	else
		Active = true
		Swinging = true
		local Animations = {LeftPunch, RightPunch}
		local ChosenAnimation = Animations[math.random(1, #Animations)]
		PunchAnim = Humanoid:LoadAnimation(ChosenAnimation)
		PunchAnim:Play()
		wait(1)
		PunchAnim:Stop()
		Swinging = false
		Active = false
	end
end

function Equipped()
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	if not Player or not Humanoid or Humanoid.Health == 0 then
		return
	end
end

function Unequipped()
	Enabled = false
	Active = false
	Handle.Transparency = 0
	for i, v in pairs({EatAnim, IdlePunchAnim, PunchAnim}) do
		if v then
			v:Stop()
		end
	end
	for i, v in pairs(PunchingHams) do
		if v and v.Parent then
			v:Destroy()
		end
	end
	for i, v in pairs(Arms) do
		if v and v.Parent then
			v.Transparency = 0
		end
	end
end

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)