--Made by Luckymaxer

Players = game:GetService("Players")
Debris = game:GetService("Debris")

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")
ThrowChair = Tool:WaitForChild("ThrowChair")

Equipped = false
MouseDown = false

ReloadTime = 1

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

function GetTotalMass(Parent)
	local TotalMass = 0
	local function GetMass(Parent)
		for i, v in pairs(Parent:GetChildren()) do
			GetMass(v)
			if v:IsA("BasePart") then
				TotalMass = TotalMass + v:GetMass()
			end
		end
	end
	GetMass(Parent)
	return TotalMass
end

function TagHumanoid(Humanoid, Player)
	local creator_tag = Instance.new("ObjectValue")
	creator_tag.Name = "creator"
	creator_tag.Value = Player
	Debris:AddItem(creator_tag, 2)
	creator_tag.Parent = Humanoid
	return creator_tag
end

function UntagHumanoid(Humanoid)
	for i, v in pairs(Humanoid:GetChildren()) do
		if v.Name == "creator" then
			v:Destroy()
		end
	end
end

function OnEquipped(Mouse)
	Equipped = true
	Character = Tool.Parent
	Humanoid = Character:WaitForChild("Humanoid")
	Torso = Character:WaitForChild("Torso")
	Player = Players:GetPlayerFromCharacter(Character)
	Handle.Transparency = 0
	if not Tool.Enabled then
		wait(ReloadTime)
		Tool.Enabled = true
	end
	Mouse.Button1Down:connect(function()
		if Tool.Enabled and not ThrowAnim then
			MouseDown = true
			ThrowAnim = Humanoid:LoadAnimation(ThrowChair)
			ThrowAnim:Play()
			BodyAngularVelocity = Instance.new("BodyAngularVelocity")
			BodyAngularVelocity.angularvelocity = Vector3.new(0, 10, 0)
			BodyAngularVelocity.maxTorque = Vector3.new(0, (((GetTotalMass(Character) ^ 2) ^ 2) / 2), 0)
			BodyAngularVelocity.Parent = Torso
			local Velocity = 50
			local MaxVelocity = 200
			while MouseDown do
				wait(0.1)
				Velocity = ((Velocity < MaxVelocity and (Velocity + 5)) or (Velocity >= MaxVelocity and MaxVelocity))
			end
			if Equipped then
				Tool.Enabled = false
				if ThrowAnim then
					ThrowAnim:Stop()
					ThrowAnim = nil
				end
				if BodyAngularVelocity and BodyAngularVelocity.Parent then
					BodyAngularVelocity:Destroy()
				end
				local TorsoCFrame = Torso.CFrame
				local Chair = Handle:Clone()
				Handle.Transparency = 1
				Chair.Name = "Chair"
				Chair.CanCollide = true
				Chair.Locked = true
				Chair.Friction = 1
				Chair.Elasticity = 0
				Chair.Velocity = Torso.CFrame.lookVector * Velocity
				local ChairHit = false
				Chair.Touched:connect(function(Hit)
					if Hit and Hit.Parent and not ChairHit then
						local character, humanoid = FindCharacterAncestor(Hit)
						if character and character.Parent and character ~= Character then
							local torso = character:FindFirstChild("Torso")
							if humanoid and humanoid.Parent and humanoid ~= Humanoid and humanoid.Health > 0 and torso and torso.Parent then
								ChairHit = true
								local PlaySound = Chair:FindFirstChild("PlaySound")
								if PlaySound and PlaySound.Parent then
									PlaySound.Disabled = false
								end
								Chair.Velocity = Vector3.new(0, 0, 0)
								Chair.RotVelocity = Vector3.new(0, 0, 0)
								UntagHumanoid(humanoid)
								TagHumanoid(humanoid, Player)
								local ChairDistance = (Torso.Position - Chair.Position).magnitude
								local Damage = ((ChairDistance >= 100 and 100) or (ChairDistance <= 5 and 15) or ChairDistance)
								humanoid.Sit = true
								torso.Velocity = CFrame.new(TorsoCFrame.p, torso.Position).lookVector * 50
								humanoid:TakeDamage(Damage)
							end
						end
					end
				end)
				Debris:AddItem(Chair, 10)
				Chair.Parent = game:GetService("Workspace")
				Chair.CFrame = Handle.CFrame + Torso.CFrame.lookVector * (Handle.Size.z * 2)
				wait(ReloadTime)
				Handle.Transparency = 0
				Tool.Enabled = true
			end
		end
	end)
	Mouse.Button1Up:connect(function()
		MouseDown = false
	end)
end

function OnUnequipped()
	Equipped = false
	MouseDown = false
	Handle.Transparency = 0
end

Tool.Equipped:connect(OnEquipped)
Tool.Unequipped:connect(OnUnequipped)