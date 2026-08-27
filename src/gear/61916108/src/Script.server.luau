local Tool = script.Parent
local Gun = Tool.Handle 

local vCharacter
local myTorso
local myHumanoid

local gunSound

game:GetService("ContentProvider"):Preload("http://www.roblox.com/asset/?id=61844654")
game:GetService("ContentProvider"):Preload("http://www.roblox.com/asset/?id=61910181")

local mouseDown = false

local shard = Instance.new("Part")
shard.FormFactor = 3
shard.Size = Vector3.new(1.2, 2.5, 1.2)
shard.CanCollide = false

local shardMesh = Instance.new("SpecialMesh")
shardMesh.MeshId = "http://www.roblox.com/asset/?id=61910181"
shardMesh.TextureId = "http://www.roblox.com/asset/?id=61838880"
shardMesh.Scale = Vector3.new(2.5, 2.5, 2.5)
shardMesh.Parent = shard

local firePart = Instance.new("Part")
firePart.FormFactor = 3
firePart.Size = Vector3.new(0.2, 0.2, 0.2)
firePart.Transparency = 0.9
firePart.CanCollide = false

local fire = Instance.new("Fire")
fire.Color = Color3.new(0.1, 0.1, 0.9)
fire.SecondaryColor = Color3.new(0.8, 0.1, 0.9)
fire.Size = 1.0
fire.Heat = 0.1
fire.Parent = firePart

local shardClone
local shardWeld

local shardFire

function chargeShards()
	local countTimer = 1
	local rotationSpeedUp = 1
	local theta
	
	if vCharacter == nil or myTorso == nil then return end
	shardFire = Tool:FindFirstChild("ShardFire")
	if not shardFire then return end
	if shardFire.Value == 1 then return end	

	mouseDown = true

	shardClone = shard:Clone()
	shardClone.Parent = vCharacter
	shardClone.Name = "Shards"
	
	shardWeld = Instance.new("Weld")
	shardWeld.Part0 = Gun
	shardWeld.Part1 = shardClone
	shardWeld.Name = "ShardWeld"
	shardWeld.Parent = shardClone		
	shardWeld.C1 = CFrame.new(Vector3.new(0, -2, 0.5)) 
	local initCFrame = shardWeld.C1

	local weldC = Tool:FindFirstChild("WeldC")
	if weldC then weldC.Value = initCFrame end

	print(initCFrame)
	print(shardWeld.C1)
	
	while mouseDown == true do 
		if shardWeld then 
			if countTimer%10 == 0 then 
				if rotationSpeedUp  < 8 then 
					rotationSpeedUp =  rotationSpeedUp + 1
					if rotationSpeedUp == 8 then 
						local f = firePart:Clone()
						f.Name = "FirePart"
						f.Parent = shardClone
		
						local w = Instance.new("Weld")
						w.Part0 = shardClone
						w.Part1 = f
						w.Parent = shardClone
					end
				end				
			end	
			theta = countTimer%6 * math.pi/3 * rotationSpeedUp/8
			shardWeld.C1 = initCFrame * CFrame.Angles(0, theta, 0)
			countTimer = countTimer + 1
		end		
		wait()
	end
end

function releaseShards(hit)
	if mouseDown then 
		shardFire = Tool:FindFirstChild("ShardFire")
		shardFire.pos.Value = hit.p
		if shardFire and shardFire.Value == 0 then shardFire.Value = 1 end
		mouseDown = false 
	end	
end

function onEquipped(mouse)
	Gun.Mesh.MeshId = "http://www.roblox.com/asset/?id=61844654"
	vCharacter = Tool.Parent
	myTorso = vCharacter:FindFirstChild("Torso") or vCharacter:FindFirstChild("UpperTorso")
	myHumanoid = vCharacter:FindFirstChild("Humanoid")
end

function onUnequipped()
	if gunSound then gunSound:Stop() end
	Gun.Mesh.MeshId = "http://www.roblox.com/asset/?id=61838856"
end

Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)

Tool.Mouse1Down.OnServerEvent:connect(function(client, hit) if client.Character == Tool.Parent then chargeShards(hit) end end)
Tool.Mouse1Up.OnServerEvent:connect(function(client, hit) if client.Character == Tool.Parent then releaseShards(hit) end end)