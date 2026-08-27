local Barrel = script.Parent
local force = Barrel:FindFirstChild("BodyForce")
local touching = false
local con = nil
local particles = 8

function killBarrel()

	Barrel.Roll.Looped = false
	Barrel.Roll:Stop()
	Barrel:remove()

end

local debris = game:GetService("Debris")
Delay(15,killBarrel)

local plank = Instance.new("Part")
plank.Name = "Plank"
plank.Material = 512 -- wood
plank.BrickColor = BrickColor.new("Reddish brown")
plank.Shape = 1
plank.formFactor = 2
plank.Size = Vector3.new(1,0.4,4)
plank.BottomSurface = 0
plank.TopSurface = 0

function onTouched(part)

	if touching then
		return
	end
	
	touching = true

	local human = part.Parent:FindFirstChild("Humanoid")
	if human ~= nil and Barrel.Velocity.magnitude > 20 then

		human:TakeDamage(25)
		human.Jump = true

		local angularVelo = Instance.new("BodyAngularVelocity")
		angularVelo.P = 500000
		angularVelo.angularvelocity = Vector3.new(math.random(-5,5),22,math.random(-5,5))
		angularVelo.maxTorque = Vector3.new(angularVelo.P,angularVelo.P,angularVelo.P)
		local Torso = human.Parent:FindFirstChild("Torso") or human.Parent:FindFirstChild("UpperTorso")
		if not Torso then touching = false return end
		angularVelo.Parent = Torso
		debris:AddItem(angularVelo, 1)

		local force = Instance.new("BodyForce")
		force.force = Barrel.Velocity * 50
		force.Parent = Torso
		debris:AddItem(force, 0.5)
		Barrel.GameOver:Play()
		con:disconnect()

		for i = 1, particles do
		
			local clone = plank:Clone()
			clone.Position = Barrel.Position
			clone.Parent = game.Workspace
			debris:AddItem(clone, 5)

		end
		killBarrel()
	end

	touching = false

end

con = Barrel.Touched:connect(onTouched)

wait(1)
while true do
	if force.Parent ~= nil then
		force.force = force.force * 0.5
	end
	wait(1)
	force.force = force.force * 2
	wait(3)
end
