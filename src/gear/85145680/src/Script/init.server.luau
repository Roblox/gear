-- // Rescripted by StarWars

local Tool = script.Parent

local Rocket = require(script.Rocket)

local Character = nil
local Humanoid = nil
local Torso = nil

local RELOAD_TIME = 10

function OnEquipped()
	Character = Tool.Parent
	Humanoid = Character:FindFirstChildOfClass("Humanoid")
	Torso = Character:FindFirstChild("Torso") or Character:FindFirstChild("UpperTorso")
	
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

function OnUnEquipped()
	local Backpack = Torso:FindFirstChild("Backpack")
	if Backpack then
		Backpack:Destroy()
	end	
	
	Character = nil
	Humanoid = nil
	Torso = nil
end

function OnActivate()
	if not Tool.Enabled then return end
	if not Character then return end
	Tool.Enabled = false	
	
	local NewRocket = Rocket.new(Tool, Character)
	Tool.Handle.Transparency = 1
	NewRocket:Launch()
	NewRocket:DropPlayer()
	
	wait(RELOAD_TIME)
	Tool.Handle.Transparency = 0
	Tool.Enabled = true
end

Tool.Activated:Connect(OnActivate)
Tool.Equipped:Connect(OnEquipped)
Tool.Unequipped:Connect(OnUnEquipped)