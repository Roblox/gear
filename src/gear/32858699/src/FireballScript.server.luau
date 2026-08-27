local fireball = script.Parent
local debris = game:GetService("Debris")

local ember = Instance.new("Part")
ember.Transparency = 1
ember.Shape = 0
ember.formFactor = 0
ember.Size = Vector3.new(0,0,0)
ember.TopSurface = 0
ember.BottomSurface = 0
ember.Locked = true

local emberFire = Instance.new("Fire")
emberFire.Color = Color3.new(1,160/255,51/255)
emberFire.Size = 2
emberFire.Parent = ember

local force = Instance.new("BodyForce")
force.force = Vector3.new(0,90,0)
force.Parent = ember

function makeEmbers()

	for i = 1, 5 do
		local er = ember:clone()
		er.Position = fireball.Position
		er.Velocity = Vector3.new(math.random(-20,20),math.random(10,25),math.random(-20,20))
		er.Parent = game.Workspace
		debris:AddItem(er,2)
	end

end

local touching = false

fireball.Touched:connect(function(part)
	
	local human = part.Parent:FindFirstChild("Humanoid")
	if human ~= nil and touching == false then
		script.Parent = human.Parent
		touching = true
		makeEmbers()
		local fire = fireball.Fire:clone()
		fireball.Fire:remove()
		fire.Parent = part
		debris:AddItem(fire, 10)
		fireball:remove()
		for i = 1, 100 do
			if fire.Enabled == true then human:TakeDamage(0.59) end
			wait(0.1)
		end
		script:remove()
		touching = false
	end

end)

