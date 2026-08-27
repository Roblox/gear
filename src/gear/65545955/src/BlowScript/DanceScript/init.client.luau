local vCharacter = script.Parent

local vPlayer = game.Players:GetPlayerFromCharacter(vCharacter) 
local backpack = nil

if vPlayer then
	backpack = vPlayer:FindFirstChild("Backpack")
end

while script:FindFirstChild("DanceAnim") == nil do 
	wait()
end

while script:FindFirstChild("DanceSound") == nil do 
	wait()
end

local danceSound = script.DanceSound
danceSound:Play()

local myTorso = vCharacter:FindFirstChild("Torso")
local myHumanoid = vCharacter:FindFirstChild("Humanoid") 

local debris = game:GetService("Debris")

if myTorso == nil or myHumanoid == nil then 
	script:Remove()
end

local toolInHand = nil
local backpackItems = {}

myHumanoid.WalkSpeed = 0.0

local children = vCharacter:GetChildren()
for i = 1, #children do 
	if children[i] and children[i].className == "Tool" then 
		toolInHand = children[i]
		toolInHand.Parent = nil
	end
end

if backpack then 
	local bChildren = backpack:GetChildren()
	for j = 1, #bChildren do 
		if bChildren[j] then 
			table.insert(backpackItems, bChildren[j])
			bChildren[j].Parent = nil
		end
	end
end

local danceAnim = myHumanoid:LoadAnimation(script.DanceAnim)
if danceAnim then danceAnim:Play() end

wait(5.5)
if danceSound then danceSound:Stop() end

wait(1.0)
if danceAnim then danceAnim:Stop() end
myHumanoid.WalkSpeed = 16.0
if toolInHand then toolInHand.Parent = backpack end
for a = 1, #backpackItems do 
	if backpackItems[a] then 
		backpackItems[a].Parent = backpack 
	end
end
script:Remove() 