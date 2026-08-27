local pinata = script.Parent
local theWholeThing = pinata.Parent
local health = 100
local gears = {29100543, 10472779, 34399428, 20056642, 25695001, 16214845, 20056642, 12848902} --Fix implemented by Luckymaxer

local debris = game:GetService("Debris")

local scale = 1
local increment = 0.1
while scale < 1.6 do
	pinata.Mesh.Scale = Vector3.new(scale,scale,scale)
	scale = scale + increment
	wait()
end

function pinataPieces()

	for i = 1, 20 do

		local pinataPart = Instance.new("Part")
		pinataPart.Name = "Pinata Piece"
		pinataPart.formFactor  = 2
		pinataPart.Size = Vector3.new(1,0.4,1)
		local color = math.random(1,3)
		if color == 1 then pinataPart.BrickColor = BrickColor.new("Bright red")
		elseif color == 2 then pinataPart.BrickColor = BrickColor.new("Bright yellow")
		else pinataPart.BrickColor = BrickColor.new("Bright orange") end
		pinataPart.BottomSurface = 0
		pinataPart.TopSurface = 0
		pinataPart.Material = Enum.Material.Grass
		pinataPart.Position = Vector3.new(pinata.Position.x + math.random(-1,1),pinata.Position.y + math.random(-1,1),pinata.Position.z + math.random(-1,1))
		pinataPart.Parent = game.Workspace
		debris:AddItem(pinataPart,4)

	end

end

local breaking = false
function checkHealth()

	print(health)
	-- time to break out some gear!
	if health <= 0 then

		if breaking then return end
		breaking = true

		local gearInstances = {}

		for i = 1, #gears do
			--This call will cause a "wait" until the data comes back
			local root = game:GetService("InsertService"):LoadAsset(gears[i])

			local instances = root:GetChildren()
			if #instances == 0 then
				root:Remove()
				return
			end

			root = root:GetChildren()
			root[1].Handle.Position = Vector3.new(pinata.Position.x + math.random(-1,1),pinata.Position.y + math.random(-1,1),pinata.Position.z + math.random(-1,1))
			table.insert(gearInstances,root[1])

		end

		pinata.Transparency = 1
		pinata.CanCollide = false

		local co = coroutine.create(pinataPieces)
		coroutine.resume(co)

		for i = 1, #gearInstances do
			gearInstances[i].Parent = game.Workspace
		end
		
		pinata.BrokenSound:Play()

		theWholeThing:remove()
		breaking = false

	end

end


local touching = false
function onTouched(part)
	if touching then return end
	touching = true
	
	if part.CanCollide then
		health = health - part.Velocity.magnitude/50
		checkHealth()
		wait(0.1)
	end

	touching = false
end

pinata.Touched:connect(onTouched)
