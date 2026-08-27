local frameInterval = .35
local numFrames = 11
local reloadTime = numFrames * frameInterval + 1
local currentFrame = 0
local speedUp = 2.5

local frames = {}

local Tool = script.Parent;

local player
local torso
local hum

local running = false

function onActivated()

	if not Tool.Enabled then return end
	Tool.Enabled = false
	running = true

	Tool.Handle.OpenSound:play()
	local curF = currentFrame
	local i = (curF + 1) % numFrames
	while i ~= curF and torso and hum and player do
		torso.Anchored = true
		local f = frames[i]
		if f and torso and hum then
			torso.CFrame = f["TorsoCFrame"]
			hum.Health = f["Health"]
			frames[i] = nil
			Tool.Handle.OpenSound.Volume = 1
			Tool.Handle.OpenSound:play()
			wait(frameInterval / speedUp)
		end
		i = (i + 1) % numFrames
	end
	if torso then torso.Anchored = false torso.Velocity = Vector3.new(0,0,0) end

	running = false


	wait(reloadTime)

	Tool.Enabled = true

end

function onEquipped()
	Tool.Handle.OpenSound:play()
	if player == Tool.Parent then 
		for count = 0, 5 do
			if count <= 5 then
				Tool.Handle.OpenSound.Volume = 1-(count /5)
				Tool.Handle.OpenSound:play()
				count = count+1
				wait(frameInterval)
			end
		end
		return 
	end
	frames = {}
	player = Tool.Parent
	torso = player:FindFirstChild("HumanoidRootPart")
	hum = player:FindFirstChild("Humanoid")
	local count = 0
	while player and torso and torso.Parent and hum and Tool.Parent ~= game.Workspace do
		if running then 
			wait(frameInterval / speedUp)
		else
			if count <= 5 then
				Tool.Handle.OpenSound.Volume = count /5
				Tool.Handle.OpenSound:play()
				count = count+1
			end
			local f = {}
			f["TorsoCFrame"] = torso.CFrame
			f["Health"] = hum.Health
			frames[currentFrame] = f
			wait(frameInterval)
			currentFrame = (currentFrame - 1) % numFrames
		end
	end
	player = nil
	print("unequipped")
end

function onUnequipped()
end

script.Parent.Activated:connect(onActivated)
script.Parent.Equipped:connect(onEquipped)
script.Parent.Unequipped:connect(onUnequipped)
