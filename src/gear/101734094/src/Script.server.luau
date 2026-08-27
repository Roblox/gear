function WaitForChild(parent, child)
	while not parent:FindFirstChild(child) do parent.ChildAdded:wait() end
	return parent[child]
end


local Tool = script.Parent
local birdPrototypeContainer = game:GetService("InsertService"):LoadAsset(101713896)
local birdPrototype = birdPrototypeContainer:GetChildren()[1]

local MAX_NUM_BIRDS = 5
local birds = {}
local numBirds = 0
local myCharacter
local myTorso

local Handle = WaitForChild(Tool, "Handle")
local SmallHorn = WaitForChild(Handle, "SmallHorn")
local BigHorn = WaitForChild(Handle, "BigHorn")

local SkeletonBirdDuration = 1*60

--			Create'Sound'{
--				Name = 'CawSound';
--				SoundId = 'http://www.roblox.com/asset/?id=96100733';
--				Volume = 1;
--				Pitch = math.random(80,120)/100;
--			};


function removeDeadBirds()
	for birdRef, bird in pairs(birds) do
		if not bird or not bird.Parent then
			birds[birdRef] = nil
			birdRef.Parent = nil
			numBirds = numBirds - 1
		end
	end
end

function spawnBird(torsoPosition)
	local newBird = birdPrototype:Clone()

	local newBirdTorso = WaitForChild(newBird, "Torso")
	local ownerRef = WaitForChild(newBirdTorso, "OwnerRef")
	ownerRef.Value = myCharacter

	local newBirdTag = Instance.new("ObjectValue")
	newBirdTag.Name = "SkeletonBirdRefObject"
	newBirdTag.Value = newBird
	birds[newBirdTag] = newBird
	newBirdTag.Parent = myCharacter

	local angle = math.pi * 2 * numBirds / (MAX_NUM_BIRDS + 1)
	local spawnPosition = torsoPosition + 200*(Vector3.new(math.sin(angle), 1, math.cos(angle)))
	newBird:TranslateBy(spawnPosition - newBird:GetModelCFrame().p)

	newBird.Parent = workspace
	numBirds = numBirds + 1
	game:GetService("Debris"):AddItem(newBird, SkeletonBirdDuration)
end

local debounce = false
function onActivated()
	if not myTorso or debounce then return end
	debounce = true
	Tool.Enabled = false
	removeDeadBirds()

	local addedBird = false

	if numBirds < MAX_NUM_BIRDS then BigHorn.Volume = 1 SmallHorn.Volume = 0 else SmallHorn.Volume = 1 BigHorn.Volume = 0 end

	while numBirds < MAX_NUM_BIRDS do
		spawnBird(myTorso.CFrame.p)
		wait(1)
		addedBird = true
	end

	local myHumanoid = nil
	if myCharacter then myHumanoid = myCharacter:FindFirstChild("Humanoid") end

	if not myHumanoid or addedBird then debounce = false Tool.Enabled = true return end
	wait(.5)
	for birdRef, bird in pairs(birds) do
		local birdTorso = bird:FindFirstChild("Torso")
		if birdTorso then
			local birdTarget = birdTorso:FindFirstChild("TargetPoint")
			if birdTarget then birdTarget.Value = myHumanoid.TargetPoint end
		end
	end

	wait(1.5)
	Tool.Enabled = true
	debounce = false
end

function onEquipped()
	myCharacter = Tool.Parent
	if not myCharacter or not myCharacter.Parent then myTorso = nil return end

	myTorso = myCharacter:FindFirstChild("Torso")
end


Tool.Activated:connect(onActivated)
Tool.Equipped:connect(onEquipped)
