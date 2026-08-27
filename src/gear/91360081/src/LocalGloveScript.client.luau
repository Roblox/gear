local function waitForChild(parent, child)
	while parent:FindFirstChild(child) == nil do 
		wait()
	end 
	return parent[child] 
end 

local function PlayRandomAnimation(TrackTable)
	TrackTable[math.random(1, #TrackTable)]:Play()
end

local function ClearAnimations(TrackTable)
	for i = 1, #TrackTable do
		TrackTable[i]:Stop()
	end
end

local Tool = script.Parent
local Handle = Tool.Handle
local Character = nil


local function LoadAnim(Name)
	return waitForChild(Tool, Name)
end

local SlashAnimations = {
	--LoadAnim("StaffSlam"),	
}

local SlashAnimationTracks = {}

local IdleAnimations = {
	--LoadAnim("StaffIdle"),

}

local IdleAnimationTracks = {}

local clientMouse = nil

function TagHumanoid(Humanoid, Player)
	if Humanoid ~= nil then 
		creatorTag = Instance.new("ObjectValue")
		creatorTag.Name = "creator"
		creatorTag.Value = Player
		creatorTag.Parent = Humanoid 
		game.Debris:AddItem(creatorTag, 1)
	end
end

local slash = nil
Tool.Enabled = true
function onActivated()
	if not Tool.Enabled then return end
	Tool.Enabled = false	


	local SummonTarget = Instance.new("Vector3Value")
	SummonTarget.Name = "GloveTarget"
	SummonTarget.Value = clientMouse.Hit.p
	SummonTarget.Parent = Tool

	wait(2)
	Tool.Enabled = true	
end
Tool.Activated:connect(onActivated)

function onEquipped(mouse)
	Character = Tool.Parent
	local Humanoid = Character:FindFirstChild("Humanoid")

	
	
	clientMouse = mouse
end
Tool.Equipped:connect(onEquipped)

function onUnequipped()
	Character = nil
	ClearAnimations(IdleAnimationTracks)
end
Tool.Unequipped:connect(onUnequipped)
