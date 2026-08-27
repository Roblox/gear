--Pararocket

--local function waitForChild(parent, child)
--	while parent:FindFirstChild(child) == nil do 
--		wait()
--	end 
--	return parent[child] 
--end 

local Debris = game.Debris

local Tool = script.Parent

local Player 
local Character
local Torso
local RightArm
local RightGrip 


local FlightTime = 5
local DropPlayerTime = FlightTime - 1
local ReloadTime = 10
local RocketThrust = 2

function Launch()	
	Tool.Handle.Transparency = 1
	local Rocket = Tool.Handle:Clone()
	Rocket.Transparency = 0
	Rocket.Name = "Rocket"
	Rocket.Parent = game.Workspace
	Rocket.Size = Vector3.new(3.35, 6.78, 3.53)
	
	
	local TorsoWeld = Instance.new("Weld")
	TorsoWeld.Part0 = Torso
	TorsoWeld.Part1 = Rocket
	TorsoWeld.Parent = Rocket
	TorsoWeld.C1 = CFrame.Angles(0, math.pi/2, 0) * CFrame.new(0, -1.4, 1.6) 
	
	local CharacterTag = Instance.new("ObjectValue")
	CharacterTag.Name = "AttachedPlayer"
	CharacterTag.Value = Character
	CharacterTag.Parent = Rocket

	local RocketScript = Tool.RocketThrust:Clone()
	RocketScript.Parent = Rocket
	RocketScript.Disabled = false

	Debris:AddItem(Rocket, FlightTime + 3)

end


Tool.Enabled = true	
function onActivate()
	if not Tool.Enabled then return end
	Tool.Enabled = false

	
	Launch()

	wait(ReloadTime)
	Tool.Handle.Transparency = 0
	Tool.Enabled = true

end
Tool.Activated:connect(onActivate)

local function onEquip()
	Character = Tool.Parent 
	Torso = Character:FindFirstChild("Torso") or Character:FindFirstChild("UpperTorso")
	RightArm = Character:FindFirstChild("Right Arm") or Character:FindFirstChild("RightHand")
--	RightGrip = RightArm:FindFirstChild("RightGrip") or RightArm:FindFirstChild("RightWrist")
--	RightGrip.Part0 = Torso 
--	RightGrip.Part1 = Tool.Handle 
--	RightGrip.C1 = CFrame.new(1.59999979, -2.20000029, 0, -4.37113883e-008, -1, -4.37113883e-008, 0, -4.37113883e-008, 1, -1, 4.37113883e-008, 1.91068547e-015)
	delay(.1, function()
		if Character:FindFirstChild("Backpack") ~= nil then return end
		local Backpack = Instance.new("Part")
		Backpack.Position = Torso.Position
		Backpack.CanCollide = false
		Backpack.Parent = Torso
		Backpack.Transparency = 0
		Backpack.Name = "Backpack"

		local Mesh = Instance.new("SpecialMesh")
		Mesh.MeshId = "http://www.roblox.com/asset/?id=85027479"
		Mesh.TextureId = "http://www.roblox.com/asset/?id=85027535"
		Mesh.Parent = Backpack
		
		
		if(Torso:FindFirstChild("BackpackWeld") == nil) then
			local BackpackWeld = Instance.new("Weld")
			BackpackWeld.Part0 = Torso
			BackpackWeld.Part1 = Backpack
			BackpackWeld.Parent = Torso
			BackpackWeld.Name = "BackpackWeld"
			BackpackWeld.C1 = CFrame.new(0, 0, -1)
		end
	end)
	
	
end

Tool.Equipped:connect(onEquip)

function onUnequip()
	Torso = Character:FindFirstChild("Torso") or Character:FindFirstChild("UpperTorso")
	
	local Backpack = Torso:FindFirstChild("Backpack")
	print("Backpack: ", Backpack)
	
	if Backpack ~= nil then 
		print("Taketh away")
		Backpack:Destroy() 
	end

end
Tool.Unequipped:connect(onUnequip)
