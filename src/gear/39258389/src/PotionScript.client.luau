local Tool = script.Parent;

local ripSound = Instance.new("Sound")
ripSound.SoundId = "http://www.roblox.com/asset/?id=38212101"
ripSound.Volume = 1
ripSound.Parent = Tool.Handle

local rightWeld = nil
local leftWeld = nil
	

enabled = true

local vCharacter = Tool.Parent
local humanoid = nil
while vCharacter == nil or vCharacter.Name == "Backpack" or humanoid == nil do
		vCharacter = Tool.Parent
		if vCharacter ~= nil then humanoid = vCharacter:FindFirstChild("Humanoid") end
		wait(1)
end

local ripper = humanoid:LoadAnimation(Tool.bookrip)
local holder = humanoid:LoadAnimation(Tool.holdbook)
local carrier = humanoid:LoadAnimation(Tool.tornbookhold)
local bookFit = humanoid:LoadAnimation(Tool.bookfit)

function onActivated()
	if not enabled then
		return
	end
	enabled = false
	if ripSound ~= nil then ripSound:Play() end
	holder:Stop()
	Tool.DanceObject.Value = ripper
	ripper:Play()
	--Tool.Handle.RipSound:Play()
	wait(.20)
	--Tool.Handle.RipSound:Stop()
	--ripper:Stop()
	--Tool.GripPos = Vector3.new(0.2, 1.8, -0.3)
	Tool.GripPos = Vector3.new(0.2,.7,-.3)
	rippedBook = Tool.Handle:Clone()
	rippedBook.CanCollide = false
	rippedBook.Mesh.MeshId = "http://www.roblox.com/asset/?id=39080763"  -- A: 39080763, B: 39080837, OnePiece: 38161161
	rippedBook.Mesh.TextureId = "http://www.roblox.com/asset/?id=38161734"
	Tool.GripPos = Vector3.new(0.2, 2.7, -0.3)
	rippedBook.Transparency = 0
	rippedBook.Parent = game.Workspace
	rightArm = vCharacter:FindFirstChild("Right Arm")
	leftArm = vCharacter:FindFirstChild("Left Arm")

	rippedBookB = Tool.Handle:Clone()
	rippedBookB.CanCollide = false
	rippedBookB.Mesh.MeshId = "http://www.roblox.com/asset/?id=39080837"  -- A: 39080763, B: 39080837, OnePiece: 38161161
	rippedBookB.Mesh.TextureId = "http://www.roblox.com/asset/?id=38161734"
	rippedBookB.Transparency = 0
	Tool.GripPos = Vector3.new(0.2, 1.2, -0.3)
	rippedBookB.Parent = game.Workspace

	if rightArm ~= nil then
		rightWeld = Instance.new("Weld")
		rightWeld.Part0 = rippedBook
		rightWeld.Part1 = rightArm
		--rightWeld.C1 = rippedBook.CFrame:inverse()*rightArm.CFrame
		rightWeld.C1 = rightArm.CFrame:inverse()*rippedBook.CFrame
		rightWeld.Parent = rightArm
	end

	if leftArm ~= nil then
		leftWeld = Instance.new("Weld")
		leftWeld.Part0 = rippedBookB
		leftWeld.Part1 = leftArm
		--leftWeld.C1 = rippedBookB.CFrame:inverse()*leftArm.CFrame
		leftWeld.C1 = leftArm.CFrame:inverse()*rippedBookB.CFrame
		leftWeld.Parent = leftArm
	end

	Tool.Handle.Transparency = 1
	--Tool.DanceObject.Value = carrier
	--carrier:Play()
	Tool.DanceObject.Value = bookFit
	bookFit:Play()
	ripper:Stop()
	wait(2.4)

	if rightWeld ~= nil and rightWeld.Parent ~= nil then
		rightWeld.Parent = nil
	end
	if leftWeld ~= nil and leftWeld.Parent ~= nil then
		leftWeld.Parent = nil
	end

	rippedBook.CanCollide = true
	rippedBookB.CanCollide = true

	wait(4)

	rippedBook.Parent = nil
	rippedBookB.Parent = nil
	Tool.Handle.Transparency = 0
	--carrier:Stop()
	bookFit:Stop()
	Tool.DanceObject.Value = holder
	holder:Play()
	enabled = true
end

function onEquipped()
	-- no sound here
	Tool.Handle.Transparency = 0
	Tool.DanceObject.Value = holder
	holder:Play()
end

function onUnequipped()
	Tool.Handle.Transparency = 0
	print("primary unequip")
	--if ripSound ~= nil then ripSound:Stop() end

	if rightWeld ~= nil and rightWeld.Parent ~= nil then
		rightWeld.Parent = nil
	end
	if leftWeld ~= nil and leftWeld.Parent ~= nil then
		leftWeld.Parent = nil
	end


	carrier:Stop()
	holder:Stop()
	ripper:Stop()
	bookFit:Stop()
	if Tool.DanceObject.Value ~= nil then
		Tool.DanceObject.Value:Stop()
	end
end

Tool.Activated:connect(onActivated)
Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)
