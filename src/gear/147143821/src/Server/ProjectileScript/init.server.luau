--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")
--Returned = Tool:WaitForChild("Returned")
Target = script:WaitForChild("TargetPos").Value

WhipSound = script:WaitForChild("WhipSound")
ThudSound = Handle:WaitForChild("ThudSound")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

Character = Tool.Parent
Player = Players:GetPlayerFromCharacter(Character)
Humanoid = Character:FindFirstChildOfClass("Humanoid")

DaggerReturning = false
Ctr = 0



Dagger = Handle:Clone()
Dagger.Transparency = 0
Dagger.CFrame = CFrame.new(Handle.CFrame.p,Target)
DaggerPos = Dagger.Position
VelVector = (Target - Dagger.Position)
InitVel = (100 * VelVector.unit)
Dagger.Velocity = InitVel
InitRotVel = (20 * Dagger.CFrame.rightVector)
Dagger.RotVelocity = InitRotVel
Dagger.Name = "BoomerangDaggerProjectile"

Trail = Dagger:WaitForChild("Trail",10)

AntiGrav = Instance.new("BodyForce")
AntiGrav.Force = Vector3.new(0, 196.2 * Dagger:GetMass(), 0)
AntiGrav.Parent = Dagger

Dagger.Parent = workspace

Trail.Enabled = true

Dagger:SetNetworkOwner(nil) --Keep it from being so laggy looking

WhipSound.Parent = Dagger

Tool.Unequipped:Connect(function()
	if ThudSound then
		ThudSound:Stop()
	end
	Dagger:Destroy()
	--Returned.Value = true
	script:Destroy()
end)

function UntagHumanoid(humanoid)
	for _, v in pairs(humanoid:GetChildren()) do
		if v:IsA("ObjectValue") and v.Name == "creator" then
			v:Destroy()
		end
	end
end

function TagHumanoid(humanoid, player)
	local CreatorTag = Instance.new("ObjectValue")
	CreatorTag.Name = "creator"
	CreatorTag.Value = player
	CreatorTag.Parent = humanoid
	Debris:AddItem(CreatorTag, 3)
end

function Blow(Hit)
	if Hit:FindFirstChild("BoomerangDaggerRecentlyHit") then
		return
	else
		local DebounceTag = Instance.new("BoolValue")
		DebounceTag.Name = "BoomerangDaggerRecentlyHit"
		DebounceTag.Parent = Hit
		Debris:AddItem(DebounceTag, 0.3)

		local HitParent = Hit.Parent
		
		if HitParent:IsA("Accessory") then
			HitParent = HitParent.Parent
		end
		
		local HitHumanoid = HitParent:FindFirstChild("Humanoid")
		if HitParent ~= Character and HitHumanoid and HitHumanoid ~= Humanoid then
			UntagHumanoid(HitHumanoid)
			TagHumanoid(HitHumanoid, Player)
			HitHumanoid:TakeDamage(15)
		elseif HitParent == Tool and DaggerReturning then
			Dagger:Destroy()
			wait()
			Dagger = nil
		end
	end
end

function ManageSound()
	if WhipSound then
		WhipSound:Play()
		wait(5/30)
		WhipSound:Play()
		wait(7/30)
		WhipSound:Play()
		wait(10/30)
		WhipSound:Play()
		wait(17/30)
		WhipSound:Play()
		wait(17/30)
		if Dagger then
			WhipSound:Play()
			wait(10/30)
		end
		if Dagger then
			WhipSound:Play()
			wait(7/30)
		end
		while Dagger do
			WhipSound:Play()
			wait(5/30)
		end
	end
end

SoundCo = coroutine.create(ManageSound)
coroutine.resume(SoundCo)

Dagger.Touched:Connect(Blow)

for i = 50, 0, -1 do
	Dagger.Velocity = ((i / 50) * InitVel)
	Dagger.RotVelocity = ((i / 50) * InitRotVel)
	wait()
end

DaggerReturning = true

	

while Handle and Dagger do
	Dagger.Velocity = (2 * Ctr * (Handle.Position - Dagger.Position).unit)
	Dagger.RotVelocity = ((-Ctr / 50) * InitRotVel)
	Ctr = (Ctr + 1)
	wait()
end

Tool.Enabled = true
Handle.Transparency = 0.0
ThudSound = Handle:FindFirstChild("ThudSound")
if ThudSound then
	ThudSound:Play()
end

wait(0.3)
--Returned.Value = true
script:Destroy()