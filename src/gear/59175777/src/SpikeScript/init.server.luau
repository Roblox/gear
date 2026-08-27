function waitForChild(parent, childName)
	while not parent:FindFirstChild(childName) do
		parent.ChildAdded:wait()
	end
	return parent[childName]
end

local vCharacter = script.Parent
local myHumanoid = vCharacter:FindFirstChild("Humanoid")
local myTorso = vCharacter:FindFirstChild("Torso")
local myHead = vCharacter:FindFirstChild("Head")
local myRightArm = vCharacter:FindFirstChild("Right Arm")
local myLeftArm = vCharacter:FindFirstChild("Left Arm")
local myRightLeg = vCharacter:FindFirstChild("Right Leg")
local myLeftLeg = vCharacter:FindFirstChild("Left Leg")

local vPlayer = game.Players:GetPlayerFromCharacter(vCharacter)

local key = waitForChild(script, "Key")

local spikeDamage = 15

local debris = game:GetService("Debris")

local spike = Instance.new("Part")
spike.FormFactor = 3
spike.Size = Vector3.new(0.2, 5.5, 0.2)
spike.Shape = "Block"
spike.Name = "Spike"
spike.CanCollide = false

local spikeMesh = Instance.new("SpecialMesh")
spikeMesh.MeshId = "http://www.roblox.com/asset/?id=59092052"
spikeMesh.TextureId = "http://www.roblox.com/asset/?id=59091614"
spikeMesh.Parent = spike

local spikeClones = {}

local LeftSpike
local RightSpike

local removingSpikes = false

function poke(hit)
	if hit and hit.Parent then 
		local humanoid = hit.Parent:FindFirstChild("Humanoid")		
		if humanoid ~= nil and myHumanoid ~= nil and myHumanoid ~= humanoid then
			tagHumanoid(humanoid, vPlayer)
			humanoid:TakeDamage(spikeDamage)
		end
	end
end

function tagHumanoid(humanoid, player)
	if humanoid and player then 
		creator = Instance.new("ObjectValue")
		creator.Name = "creator"
		creator.Value = player
		creator.Parent = humanoid 
		debris:AddItem(creator, 1)
	end
end

function weldSpikes(WeldParts, C1s)
	local NewSpikes = {}
	local LeftWeld
	local RightWeld
	local Welds = {}

	for i = 1, 2 do
		if WeldParts[i] then
			NewSpikes[i] = spike:Clone()
			NewSpikes[i].Parent = vCharacter
			table.insert(spikeClones, NewSpikes[i])
			
			local NewWeld = Instance.new("Weld")
			NewWeld.Part0 = WeldParts[i]
			NewWeld.Part1 = NewSpikes[i]
			NewWeld.C1 = C1s[i]
			NewWeld.Parent = WeldParts[i]
			Welds[i] = NewWeld

			NewSpikes[i].Touched:connect(poke)
		end
	end

	local LeftMesh
	local RightMesh
	local Meshes = {LeftMesh, RightMesh}
	
	for j = 1, 10 do
		for i = 1, 2 do
			if NewSpikes[i] then 
				Meshes[i] = NewSpikes[i]:FindFirstChild("Mesh")
				if Meshes[i] then Meshes[i].Scale = Vector3.new(1, 1 + (j * 0.5), 1) end
				if Welds[i] then Welds[i].C1 = Welds[i].C1 - Vector3.new(0, 0.3, 0) end
			end
		end
		wait(0.15)
	end
end
	

	

function spikeyDestruction()
	if removingSpikes then return end
	if myHumanoid then
		if key then 
			if #spikeClones >= 4 then 
				removingSpikes = true
				for i = 1, #spikeClones do
					if spikeClones[i] then
						spikeClones[i]:Remove()
					end
					wait(0.1)
				end
				removingSpikes = false
				spikeClones = {}
			end			
			if key.Value == "q" then
				weldSpikes({myLeftArm, myRightArm}, {CFrame.Angles(0, 0, -math.pi/2), CFrame.Angles(0, 0, math.pi/2)})
			elseif key.Value == "e" then
				weldSpikes({myLeftLeg, myRightLeg}, {CFrame.Angles(math.pi/2, -math.pi/6, 0), CFrame.Angles(math.pi/2, math.pi/6, 0)})
			elseif key.Value == "z" then
				weldSpikes({myTorso, myTorso}, {CFrame.new(0.5, 0, 0.3) * CFrame.Angles(math.pi/2, -math.pi/6, 0), CFrame.new(-0.5, 0, 0.3) * CFrame.Angles(math.pi/2, math.pi/6, 0)})
			elseif key.Value == "c" then
				weldSpikes({myTorso, myTorso}, {CFrame.new(0.5, 0, 0.3) * CFrame.Angles(-math.pi/2, math.pi/6, 0), CFrame.new(-0.5, 0, 0.3) * CFrame.Angles(-math.pi/2, -math.pi/6, 0)})
			else 
				-- do nothing 
			end		
		end
	end
end

if key then local connection = key.Changed:connect(spikeyDestruction) end

spikeyDestruction()


wait(30.0)
if connection then connection:disconnect() end
for i = 1, #spikeClones do
	if spikeClones[i] then
		spikeClones[i]:Remove()
	end
end
script:Remove() 