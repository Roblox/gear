arrow = script.Parent


debris = game:GetService("Debris")



local HitSound = Instance.new("Sound")
HitSound.SoundId = "http://www.roblox.com/asset/?id=25605551"
HitSound.Parent = arrow
HitSound.Volume = 1

function Snowface(h)
	
	local torso = h.Parent:FindFirstChild("Torso")
	
	if torso ~= nil then
		
		local iceCube = Instance.new("Part")

		local smoke = Instance.new("Smoke")
		smoke.Parent = iceCube

		iceCube.Name = "Ice Cube"
		iceCube.Velocity = arrow.Velocity
		iceCube.Position = torso.Position
		iceCube.Size = Vector3.new(torso.Size.x + 4, torso.Size.y + 4, torso.Size.z + 4)
		iceCube.BrickColor = BrickColor.new("Pastel light blue")
		iceCube.Material = Enum.Material.Plastic
		iceCube.TopSurface = 0
		iceCube.BottomSurface = 0
		iceCube.Transparency = 0.35
		iceCube.Reflectance = 0.5
		iceCube.Shape = 1
		iceCube.Locked = true
		iceCube.CanCollide = true
		iceCube.Anchored = true
		iceCube.Parent = game.Workspace

		weld = Instance.new("Weld")
		weld.Part0 = iceCube
		weld.Part1 = torso
		weld.Parent = game.Workspace

		wait(3)
		iceCube:remove()
		weld:remove()
	end
	

end

function Explode()

	local count = 5


	for i=1,count do
		local p = Instance.new("Part")
		p.BrickColor = BrickColor.new("Pastel light blue")
		p.formFactor = 2
		p.Size = Vector3.new(1,.4,1)
		p.Material = Enum.Material.Ice
		p.TopSurface = 0
		p.BottomSurface = 0
		
		p.Velocity = arrow.Velocity * (4 + (math.random() *2))
		p.RotVelocity = Vector3.new(math.random(-20,20), math.random(-20,20), math.random(-20,20))
		p.Position = arrow.Position + (arrow.Velocity * math.random() * .05) + Vector3.new(0,math.random() * 3, 0)
		p.Parent = game.Workspace

		debris:AddItem(p, 60)
	end

end




function onTouched(hit)

	connection:disconnect()

	if hit.Parent ~= nil then
		humanoid = hit.Parent:findFirstChild("Humanoid")
		if humanoid~=nil then
			arrow.Transparency = 1
			HitSound:Play()
			Snowface(humanoid)
		end
	end

	Explode()

	arrow:Remove()

	
end



connection = arrow.Touched:connect(onTouched)

wait(10)

arrow.Parent = nil