local pinata = script.Parent
local theWholeThing = pinata.Parent
local humanoid=theWholeThing:WaitForChild("Humanoid")
local health = 100
local gears = {Sombrero=26673654,Sombrero2=26673654,Poncho=26673669,VaqueroSombrero=53901180,footbag=52180858,taco=15177716,Epicsauce=31314931,waterballoon=29100543,Epicsausegreen=38861951,Bugle=33683368,Guitar=26673760,Maraca=21351465,Tambourine=21392417,teddy=12848902}
geardropchance=.5

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
		if color == 1 then
			pinataPart.BrickColor = BrickColor.new("Bright red")
		elseif color == 2 then
			pinataPart.BrickColor = BrickColor.new("Bright yellow")
		else
			pinataPart.BrickColor = BrickColor.new("Hot pink")
		end
		pinataPart.BottomSurface = 0
		pinataPart.TopSurface = 0
		pinataPart.Material = Enum.Material.Grass
		pinataPart.Position = Vector3.new(pinata.Position.x + math.random(-1,1),pinata.Position.y + math.random(-1,1),pinata.Position.z + math.random(-1,1))
		pinataPart.Parent = workspace
		debris:AddItem(pinataPart,math.random(3,7))
	end
end

local breaking = false
function checkHealth()

--	print(health)
	-- time to break out some gear!
	if health <= 0 then

		if breaking then return end
		breaking = true
		
		local sound=pinata:FindFirstChild("BrokenSound")
		if sound then
			sound:Play()
		end

		delay(0,function()
			local gearInstances = {}
			for _,v in pairs(gears) do
				if math.random()<geardropchance then
					--This call will cause a "wait" until the data comes back --DONT CARE, DELAY'D(coroutine'd) IT
					local root = game:GetService("InsertService"):LoadAsset(v)
		
					local instances = root:GetChildren()
					if #instances == 0 then
						root:Destroy()
						return
					end
		
					root = root:GetChildren()
					root[1].Handle.Position = Vector3.new(pinata.Position.x + math.random(-1,1),pinata.Position.y + math.random(-1,1),pinata.Position.z + math.random(-1,1))
					root[1].Handle.Velocity=Vector3.new(math.random()-.5,math.random()-.5,math.random()-.5)*50
					root[1].Parent=workspace
				end
			end
		end)

		pinata.Transparency = 1
		pinata.CanCollide = false

		pinataPieces()

	

		debris:AddItem(pinata,3)
		wait(3)
		theWholeThing:Destroy()
	end
end


local touching = false
function onTouched(part)
	if touching then return end
	touching = true
	
	if part.CanCollide then
		health = math.max(0,health - math.min(5,math.max(1,part.Velocity.magnitude/8)))
		delay(0,function()
			local light=pinata:FindFirstChild("PointLight")
			if light~=nil then
				light.Range=math.random(12,22)
				light.Color=Color3.new(math.random(2,3)/3,math.random(2,3)/3,math.random(2,3)/3)
			end
		end)
		checkHealth()
		wait(0.1)
	end

	touching = false
end

pinata.Touched:connect(onTouched)

while true do
	humanoid.Health=health
	humanoid.MaxHealth=100
	wait(.5)
end
