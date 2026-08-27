-- Paper sword script, based on existing sword scripts (EelSword and MahjongSword, since they're what I have).

-- No stab attack; that's probably too violent for Town and City. Touch damage is 0, and slash damage,
--   while there, is VERY minimal.
-- Also, you can unfold (or refold) it with the 'x' key.
local TOUCH_DAMAGE = 0
local SLASH_DAMAGE = 0.3
local damage = TOUCH_DAMAGE	-- The current damage, set to one of the above.

local Tool = script.Parent
local Sword = Tool.Handle
local CloneTool = Tool:Clone()

local Paper
local PaperWeld


local slashAnim
local slashSound
local unfoldAnim
local foldAnim
local foldSound
local alreadyUnfolded = false

local myCharacter
local myHumanoid
local myPlayer
local Torso
local RightArm
local LeftArm

local signs = {57197301, 57197341, 57197361}
local signMesh

local INITIAL_MESH_SIZE = Vector3.new(2, 2, 2)
local INITIAL_GRIP_POS = Vector3.new(0, 0, -1.75)

-- Tentative lock
Tool.Enabled = true

function tagHumanoid(humanoid, player)
	if humanoid and player then
		local creatorTag = Instance.new("ObjectValue")
		creatorTag.Name = "creator"
		creatorTag.Parent = humanoid
		creatorTag.Value = player
	end
end

function untagHumanoid(humanoid)
	if humanoid then
		local tag = humanoid:FindFirstChild("creator")
		if tag then
			tag:Remove()
		end
	end
end
	

function blow(hit)
	if not hit or not hit.Parent then return end
	-- Set up local variables for the attacking and hit players
	myCharacter = Tool.Parent
	myHumanoid = myCharacter:FindFirstChild("Humanoid")
	myPlayer = game.Players:GetPlayerFromCharacter(myCharacter)
	local hitHumanoid = hit.Parent:FindFirstChild("Humanoid")

	-- Check to make sure the hit was on someone else.
	if not myHumanoid or not hitHumanoid or myHumanoid == hitHumanoid then return end
	-- And that the attacker still has a right arm.
	RightArm = myCharacter:FindFirstChild("Right Arm")
	if not RightArm then return end
	-- And that he's still holding the sword...
	local RightGrip = RightArm:FindFirstChild("RightGrip")

	if RightGrip and (RightGrip.Part0 == Sword or RightGrip.Part1 == Sword) then
		-- Now we're good to proceed, so: do damage and make (and remove) the leaderboard tag.
		hitHumanoid:TakeDamage(damage)
		tagHumanoid(hitHumanoid, myPlayer)
		wait(1)
		untagHumanoid(hitHumanoid)
	end
end

--displayAndWeldPaper: creates the paper object in front of the player
function displayAndWeldPaper()
	-- Make a new part for the paper...
	Paper = Instance.new("Part")
	Paper.Name = "Paper"
	Paper.FormFactor = 3
	Paper.Size = Vector3.new(1, .2, 1)
	Paper.CanCollide = false	
	Paper.Locked = true
	Paper.BrickColor = BrickColor.new(5)
	Paper.Parent = game.Workspace
	Paper.CFrame = Torso.CFrame + 2 * Torso.CFrame.lookVector	
	
	signMesh = Instance.new("SpecialMesh")
	signMesh.MeshId = "http://www.roblox.com/asset/?id=57196972"
	math.random(tick())
	signMesh.TextureId = "http://www.roblox.com/asset/?id="..signs[math.random(1, 3)]
	signMesh.Scale = Vector3.new(0.25, 0.25, 0.25)
	signMesh.Parent = Paper		
	
	-- And weld it to the character('s torso).
	PaperWeld = Instance.new("Weld")
	PaperWeld.Parent = Paper
	PaperWeld.Part0 = Paper
	PaperWeld.Part1 = Torso
	PaperWeld.C0 = CFrame.new(Vector3.new(0, -0.2, 1.5)) -- N.B. Weld coordinates are apparently measured in the coordinate systems of their component objects!
																	--      So using Torso.CFrame.lookVector didn't work here.

	-- Make a mesh for the paper, so that it actually looks like paper.
	--	local PaperMesh = Instance.new("SpecialMesh")
	--	PaperMesh.Name = "Paper Mesh"
	--PaperMesh.MeshId = "http://www.roblox.com/asset/?id=54002410"		-- But for now, it looks
	--PaperMesh.TextureId = "http://www.roblox.com/asset/?id=53969202" 	-- like a Sword Fish.
	--PaperMesh.Scale = Vector3.new(0, 0, 0)
	--PaperMesh.Parent = Paper
end

-- unfold: turns the sword into a sign with a childlike message on it, supposed to be a piece of paper
--   that is the sword unfolded. Even though the sword is actually made of cardboard :P This function also
--   accomplishes the reverse process, by calling fold() if the sword is already unfolded.
function unfold(key)
	if key:lower() ~= "x" then return end
	if not Tool.Enabled then return end
	Tool.Enabled = false	

	myCharacter = Tool.Parent
	if not myCharacter then return end
	myHumanoid = myCharacter:FindFirstChild("Humanoid")
	if not myHumanoid then return end
	RightArm = myCharacter:FindFirstChild("Right Arm")
	LeftArm = myCharacter:FindFirstChild("Left Arm")
	Torso = myCharacter:FindFirstChild("Torso")
	unfoldAnim = myHumanoid:LoadAnimation(Tool.SwordToPaper)
	if unfoldAnim then unfoldAnim:Play() end

	if alreadyUnfolded then
		fold()
		return
	end

	alreadyUnfolded = true

	foldSound = Tool:FindFirstChild("FoldSound")
	if foldSound then foldSound:Play() end
	wait(0.5)
	-- sword should now be held directly in front of character.
	
	displayAndWeldPaper()
	
	if not RightArm or not LeftArm then return end
	for i = 1, 25 do
		Sword.Mesh.Scale = (25.0 - i) / 25.0 * INITIAL_MESH_SIZE
		Tool.GripPos = INITIAL_GRIP_POS + Vector3.new(0, 0, i/12.5)	
		--PaperMesh.Scale = Vector3.new(i/25.0, i/25.0, i/25.0)
		wait(.02)
	end

	-- And reset the tool.

	Tool.Enabled = true
	
end	

--fold:  refolds paper into a sword after the sword has already been unfolded.
function fold()
	-- We're already guaranteed that tool was enabled (but has been set to disabled).
	-- We're also guaranteed that the player still exists, and that we've tried to access
	-- his arms.
	if not RightArm or not LeftArm then return end

	alreadyUnfolded = false
	foldAnim = myHumanoid:LoadAnimation(Tool.PaperToSword)
	if foldAnim then foldAnim:Play() end

	wait(0.5)	-- For the animation.
	foldSound = Tool:FindFirstChild("FoldSound")
	if foldSound then foldSound:Play() end

	for i = 1, 25 do
		Sword.Mesh.Scale = i / 25.0 * INITIAL_MESH_SIZE
		Tool.GripPos = INITIAL_GRIP_POS + Vector3.new(0, 0, (25.0 - i)/12.5)	
		signMesh.Scale = Vector3.new((25.0 - i)/100.0, (25.0 - i)/100.0, (25.0 - i)/100.0)
		wait(.02)
	end
	if Paper then Paper:Remove() end

	-- Wait for animation to finish
	wait(0.5)

	-- Reset the tool

	Tool.Enabled = true
end
	
function onActivated()
	-- First make sure we're trying to swing a sword, not a piece of paper.
	if alreadyUnfolded then return end

	-- Make some checks: user is still alive, tool is enabled, etc.
	if not Tool.Enabled then return end
	Tool.Enabled = false	-- And make sure the tool isn't enabled for the next few seconds!
	myCharacter = Tool.Parent
	if not myCharacter then return end
	myHumanoid = myCharacter:FindFirstChild("Humanoid")
	if not myHumanoid then return end

	-- If we're good to go forward, then just slash!
	damage = SLASH_DAMAGE
	slashAnim = myHumanoid:LoadAnimation(Tool.Slash)
	if slashAnim then slashAnim:Play() end
	slashSound = Tool:FindFirstChild("CrumpleSound")
	if slashSound then slashSound:Play() end

	-- Wait for animation and sound to finish, then reset everything we just changed.
	wait(1)
	damage = TOUCH_DAMAGE
	Tool.Enabled = true
	
end

function onEquipped(mouse)
	--No unsheath sound; it's a paper sword, for Pete's sake!
	mouse.KeyDown:connect(unfold)

	-- Get rid of Paper...
	if Paper then Paper:Remove() end
	if alreadyUnfolded then
		-- Replace it, and resize the sword, if necessary...
		displayAndWeldPaper()
		Sword.Mesh.Scale = Vector3.new(0, 0, 0)
		Tool.GripPos = INITIAL_GRIP_POS + Vector3.new(0, 0, 2)
	else
		-- or just resize the sword.
		Sword.Mesh.Scale = INITIAL_MESH_SIZE
		Tool.GripPos = INITIAL_GRIP_POS
	end
	
end

function onUnequipped()
	-- Stop sounds and/or animations
	if slashAnim then slashAnim:Stop() end
	if slashSound then slashSound:Stop() end
	if foldAnim then foldAnim:Stop() end
	if unfoldAnim then unfoldAnim:Stop() end
	if foldSound then foldSound:Stop() end


	-- Get rid of Paper and, if necessary, reset the size.
	if Paper then Paper:Remove() end
	if alreadyUnfolded then
		Sword.Mesh.Scale = INITIAL_MESH_SIZE
		Tool.GripPos = INITIAL_GRIP_POS
	end

end

Tool.Activated:connect(onActivated)
Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)

Sword.Touched:connect(blow)

