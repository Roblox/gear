--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

Slash = Tool:WaitForChild("Slash")
Swing = Tool:WaitForChild("Swing")
HoldOut = Tool:WaitForChild("HoldOut")

SlashSound = Handle:WaitForChild("SlashSound")
HitSound = Handle:WaitForChild("HitSound")
SwingSound = Handle:WaitForChild("SwingSound")

Players = game:GetService("Players")
Debris = game:GetService("Debris")
RunService = game:GetService("RunService")

Equipped = false
AttackReady = true
SwingReady = true

BaseDamage = 0
SlashDamage = 15
SwingDamage = 30

Damage = BaseDamage

ReloadTime = 1

Last_Attack = 0

Grips = {
	Slash = CFrame.new(0, 1.75, 0, 0, 0, 1, 0.00042643919, -0.999999881, 0, 0.999999881, 0.00042643919, 0),
	Hold = CFrame.new(0, 1.5, 0, 0, 0, 1, 0.999999762, -0.000818330271, 0, 0.000818330387, 0.999999642, -0)
}

NunchuckSwirl = Handle:Clone()
NunchuckSwirl.Size = Vector3.new(3, 3,0.2)
NunchuckSwirl.Mesh.Scale = Vector3.new(1.5, 1.5, 2)
NunchuckSwirl.Mesh.MeshId = "http://www.roblox.com/asset/?id=159710546"
NunchuckSwirl.Mesh.TextureId = "http://www.roblox.com/asset/?id=159710634"

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

function Blow(Hit)
	if Hit and Hit.Parent and Handle.Transparency < 1 then
		local character, humanoid = FindCharacterAncestor(Hit.Parent)
		if character and character ~= Character and humanoid and humanoid.Health > 0 and Humanoid.Health > 0 then
			local right_arm = Character:FindFirstChild("Right Arm")
			if right_arm then
				local joint = right_arm:FindFirstChild("RightGrip")
				if joint and (joint.Part0 == Handle or joint.Part1 == Handle) then
					UntagHumanoid(humanoid)
					TagHumanoid(humanoid, Player)
					humanoid:TakeDamage(Damage)
					HitSound:Play()
				end
			end
		end
	end
end

function Attack()
	Spawn(function()
		AttackReady = false
		Damage = SlashDamage
		Tool.Grip = Grips.Slash
		SlashAnim = Humanoid:LoadAnimation(Slash)
		if SlashAnim then
			SlashSound:Play()
			SlashAnim:Play()
		end
		wait(ReloadTime)
		SlashSound:Stop()
		Damage = BaseDamage
		Tool.Grip = Grips.Hold
		AttackReady = true
	end)
end

function DoubleClick()
	Spawn(function()
		SwingReady = false
		AttackReady = false
		Handle.Transparency = 1
		SwingAnim = Humanoid:LoadAnimation(Swing)
		local LeftArm = Character:FindFirstChild("Left Arm")
		local RightArm = Character:FindFirstChild("Right Arm")
		local NunchuckSwirls = {}
		if LeftArm then
			LeftNunchuckSwirl = NunchuckSwirl:Clone()
			LeftGrip = Instance.new("Weld")
			LeftGrip.Part0 = LeftArm
			LeftGrip.Part1 = LeftNunchuckSwirl
			LeftGrip.C0 = CFrame.new(0, -1, 0, 1, 0, -0, 0, 0, 1, 0, -1, -0)
			LeftGrip.C1 = CFrame.new(0, 0, -0.300000012, -0, 1, 0, 1, 0, 0, 0, 0, -1)
			LeftGrip.Parent = LeftNunchuckSwirl
			table.insert(NunchuckSwirls, LeftNunchuckSwirl)
			Debris:AddItem(LeftNunchuckSwirl, 5)
			LeftNunchuckSwirl.Parent = Character
		end
		if RightArm then
			RightNunchuckSwirl = NunchuckSwirl:Clone()
			RightGrip = Instance.new("Weld")
			RightGrip.Part0 = RightArm
			RightGrip.Part1 = RightNunchuckSwirl
			RightGrip.C0 = CFrame.new(0, -1, 0, 1, 0, -0, 0, 0, 1, 0, -1, -0)
			RightGrip.C1 = CFrame.new(0, 0, -0.300000012, -0, 1, 0, 1, 0, 0, 0, 0, -1)
			RightGrip.Parent = RightNunchuckSwirl
			table.insert(NunchuckSwirls, RightNunchuckSwirl)
			Debris:AddItem(RightNunchuckSwirl, 5)
			RightNunchuckSwirl.Parent = Character
		end
		for i, v in pairs(NunchuckSwirls) do
			if v and v.Parent then
				v.Touched:connect(function(Hit)
					if Hit and Hit.Parent then
						local character, humanoid = FindCharacterAncestor(Hit.Parent)
						if character and character ~= Character and humanoid and humanoid.Health > 0 and Humanoid.Health > 0 then
							UntagHumanoid(humanoid)
							TagHumanoid(humanoid, Player)
							humanoid:TakeDamage(SwingDamage)
							HitSound:Play()
						end
					end
				end)
			end
		end
		Spawn(function()
			while RightGrip and RightGrip.Parent do
				RightGrip.C1 = RightGrip.C1 * CFrame.Angles(0, 0, 1)
				wait()
			end
		end)
		Spawn(function()
			while LeftGrip and LeftGrip.Parent do
				LeftGrip.C1 = LeftGrip.C1 * CFrame.Angles(0, 0, -1)
				wait()
			end
		end)
		SwingSound:Play()
		if SwingAnim then
			SwingAnim:Play()
		end
		wait(1.5)
		if LeftNunchuckSwirl and LeftNunchuckSwirl.Parent then
			LeftNunchuckSwirl:Destroy()
		end
		if RightNunchuckSwirl and RightNunchuckSwirl.Parent then
			RightNunchuckSwirl:Destroy()
		end
		if SwingAnim then
			SwingAnim:Stop()
		end
		SwingSound:Stop()
		Handle.Transparency = 0
		AttackReady = true
		SwingReady = true
	end)
end

function Activated()
	if Tool.Enabled and SwingReady then
		Tool.Enabled = false
		local Time = RunService.Stepped:wait()
		if (Time - Last_Attack) < 0.2 then
			DoubleClick()
		elseif AttackReady then
			Attack()
		end
		Last_Attack = Time
		Tool.Enabled = true
	end
end

function Equipped(Mouse)
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	Tool.Grip = Grips.Hold
	Damage = BaseDamage
	if not Character or not Humanoid then
		return
	end
	HoldOutAnim = Humanoid:LoadAnimation(HoldOut)
	if HoldOutAnim then
		HoldOutAnim:Play()
	end
	Equipped = true
	if not Tool.Enabled then
		wait(ReloadTime)
		Tool.Enabled = true
	end
end

function Unequipped()
	Equipped = false
	SpecialActive = false
	Handle.Transparency = 0
	SwingSound:Stop()
	if SlashAnim then
		SlashAnim:Stop()
	end
	if SwingAnim then
		SwingAnim:Stop()
	end
	if HoldOutAnim then
		HoldOutAnim:Stop()
	end
	if LeftNunchuckSwirl and LeftNunchuckSwirl.Parent then
		LeftNunchuckSwirl:Destroy()
	end
	if RightNunchuckSwirl and RightNunchuckSwirl.Parent then
		RightNunchuckSwirl:Destroy()
	end
end

Handle.Touched:connect(Blow)

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)