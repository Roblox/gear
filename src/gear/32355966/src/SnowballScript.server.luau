arrow = script.Parent

local prevVelocity = 0
local particles = {}

debris = game:GetService("Debris")

function Snowface(h,hit)
	
	local torso = h.Parent:FindFirstChild("Torso") or h.Parent:FindFirstChild("UpperTorso")
	
	if torso ~= nil then
		
		local bodyVelo = Instance.new("BodyVelocity")
		print(prevVelocity)
		bodyVelo.velocity = prevVelocity
		bodyVelo.P = 20000
		bodyVelo.maxForce = Vector3.new(bodyVelo.P,bodyVelo.P,bodyVelo.P)
		bodyVelo.Parent = hit
		debris:AddItem(bodyVelo, 1.5)

	end
	
end


function Explode()

	local count = 5

	for i=1,count do
		local p = Instance.new("Part")
		p.BrickColor = BrickColor.new("Bright green")
		p.Name = "Green particle"
		p.formFactor = 0
		p.Transparency = 0.8
		p.Shape = 0
		p.Size = Vector3.new(1,1,1)
		p.TopSurface = 0
		p.BottomSurface = 0

		local fire = Instance.new("Fire")
		fire.Name = "Fire"
		fire.Color = Color3.new(51/255,205/255,51/255)
		fire.SecondaryColor = Color3.new(0,102/255,0)
		fire.Heat = 9
		fire.Size = 3
		fire.Parent = p
	
		p.Velocity = (-arrow.Velocity/2) * (4 + (math.random() *2))
		p.Position = arrow.Position + (arrow.Velocity * math.random() * .05) + Vector3.new(0,math.random() * 3, 0)
		p.Parent = workspace

		local force = Instance.new("BodyForce")
		force.force = Vector3.new(0,p:GetMass() * workspace.Gravity,0)
		force.Parent = p

		table.insert(particles,p)
	end

	delay(2,killParticles)

end

function killParticles()

	for i = 1, #particles do
		particles[i].Transparency = 1
		particles[i].Fire.Enabled = false
		debris:AddItem(particles[i],3)
	end
	local particles = {}

end


function onTouched(hit)

	connection:disconnect()

	if hit.Parent ~= nil then
		humanoid = hit.Parent:FindFirstChildOfClass("Humanoid")
		if humanoid~=nil then
			arrow.Transparency = 1
			arrow.Fire.Enabled = false
			Snowface(humanoid, hit)
		end
	end

	Explode()

	wait(5)
	arrow:Destroy()

	
end



connection = arrow.Touched:connect(onTouched)

debris:AddItem(arrow,60)

while true do
	prevVelocity = arrow.Velocity
	wait(0.1)
end
