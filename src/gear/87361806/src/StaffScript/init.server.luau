--Gallaron's Abysal Carnesphere!
local Workspace = game.Workspace
local Debris = game.Debris

local function waitForChild(parent, child)
	while parent:FindFirstChild(child) == nil do 
		wait()
	end 
	return parent[child] 
end 

local Tool = script.Parent
local Character = nil
local Torso = nil
local Summon = waitForChild(script, "Summon")

local MeteorID = 86374494
local Meteor = game:GetService("InsertService"):LoadAsset(MeteorID):GetChildren()[1]


local MeteorLifeTime = 7
local StaffCooldownTime = 8

function SummonMeteor()
	
	Summon:Play()
	wait(1)
	local ChaosMeteor = Meteor:Clone()
	ChaosMeteor.Name = "Meteor"
	local chilluns = ChaosMeteor:GetChildren()
	local angx, angy, angz = Torso.CFrame:toEulerAnglesXYZ()
	for i = 1, #chilluns do
		chilluns[i].CFrame = CFrame.Angles(angx, angy, angz) + (Torso.Position + (Torso.CFrame.lookVector * 5) + Vector3.new(0, 100, 0))
	end
	ChaosMeteor.Parent = Workspace

	local RockScript = Tool.MeteorScript:Clone()
	RockScript.Parent = ChaosMeteor
	RockScript.Disabled = false

	local Owner = Instance.new("ObjectValue")
	Owner.Name = "Owner"
	Owner.Value = Character
	Owner.Parent = RockScript
	
	
	Debris:AddItem(ChaosMeteor, MeteorLifeTime)

end


Tool.Enabled = true
function onActivated()
	if not Tool.Enabled then return end
	Tool.Enabled = false

	SummonMeteor()

	wait(StaffCooldownTime)
	
	Tool.Enabled = true

end
Tool.Activated:connect(onActivated)


function onEquipped()
	Character = Tool.Parent
	Torso = Character:FindFirstChild("Torso") or Character:FindFirstChild("UpperTorso")

end
Tool.Equipped:connect(onEquipped)


function onUnequipped()
	Character = nil
	Torso = nil
end

Tool.Unequipped:connect(onUnequipped)

