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

local IdleAnim = waitForChild(Tool, "IdleAnim")

local SlashAnimations = {
	LoadAnim("SlashAnim"),
	LoadAnim("Slash2Anim"),
	LoadAnim("Slash3Anim"),
	LoadAnim("Slash4Anim"),
}

local SlashAnimationTracks = {}

local BlockAnimations = {
	LoadAnim("Block1Anim"),
	LoadAnim("Block2Anim"),
}

local BlockAnimationTracks = {}

local IdleAnimations = {
	LoadAnim("IdleAnim"),
	LoadAnim("Idle2Anim"),
}

local IdleAnimationTracks = {}

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
function onActivated()
	PlayRandomAnimation(SlashAnimationTracks)
	
end
Tool.Activated:connect(onActivated)

function onKeyPressed(key)
	key = string.byte(key)

	if key == string.byte("e") then
		--do a block
		PlayRandomAnimation(BlockAnimationTracks)
	end
	
	
	

end



function onEquipped(mouse)
	Character = Tool.Parent
	local Humanoid = Character:FindFirstChild("Humanoid")

	for i = 1, #SlashAnimations do
		SlashAnimationTracks[i] = Humanoid:LoadAnimation(SlashAnimations[i])
	end

	for i = 1, #BlockAnimations do
		BlockAnimationTracks[i] = Humanoid:LoadAnimation(BlockAnimations[i])
	end

	for i = 1, #IdleAnimations do
		IdleAnimationTracks[i] = Humanoid:LoadAnimation(IdleAnimations[i])
	end

	PlayRandomAnimation(IdleAnimationTracks)
	
	mouse.KeyDown:connect(onKeyPressed)
end
Tool.Equipped:connect(onEquipped)


function onUnequipped()
	Character = nil
	ClearAnimations(IdleAnimationTracks)
end
Tool.Unequipped:connect(onUnequipped)
