local Tool = script.Parent
local Bat = Tool.Handle

local myCharacter
local myHumanoid
local Torso

local isBaseballisticObj = Tool.IsBaseballistic	 -- We know isBaseballisticObj ~= nil because we checked for that before enabling this script.
local startPoint
local targetPoint
local targetDir
local targetRay
local partToAttack

local debris = game:service("Debris")

local baseballsRemaining

local resetBaseballNumScript

local Baseball = Instance.new("Part")
Baseball.Name = "Baseball"
Baseball.Size = Vector3.new(20, 20, 20)
Baseball.Shape = Enum.PartType.Ball
Baseball.Material = "Grass"
Baseball.Locked = true

local BaseballMesh = Instance.new("SpecialMesh")
BaseballMesh.MeshId = "http://www.roblox.com/asset/?id=55021861"
BaseballMesh.TextureId = "http://www.roblox.com/asset/?id=55021914"
BaseballMesh.Scale = Vector3.new(85, 85, 85)
BaseballMesh.Parent = Baseball

local RedSparkles = Instance.new("Sparkles")
RedSparkles.SparkleColor = Color3.new(1, 0, 0)
local WhiteSparkles = Instance.new("Sparkles")
WhiteSparkles.SparkleColor = Color3.new(1, 1, 1)

if Bat then
	RedSparkles.Parent = Bat
	WhiteSparkles.Parent = Bat
end

function onActivated()
	-- Standard checks, plus checking to make sure that the user's turned on baseballisticism. Yeah, that's a word now.
	myCharacter = Tool.Parent
	if not myCharacter then return end
	myHumanoid = myCharacter:FindFirstChild("Humanoid")
	Torso = myCharacter:FindFirstChild("Torso")
	if not (myHumanoid and Torso) then return end
	if not isBaseballisticObj.Value then return end
	baseballsRemaining = Tool:FindFirstChild("BaseballsRemaining")
	if not baseballsRemaining then return end
	isBaseballisticObj.Value = false	-- To make sure you can't click multiple times for multiple baseballs

	--Use a ray trace to find the part we want to attack.
	startPoint = Torso.Position
	targetPoint = myHumanoid.TargetPoint
	targetDir = (targetPoint - startPoint).unit
	print (targetDir)
	targetRay = Ray.new(startPoint, 500*targetDir)
	partToAttack, intersectionPoint = game.Workspace:FindPartOnRay(targetRay, myCharacter)

	if partToAttack ~= nil then
		-- Spawn a giant baseball above this part
		local GiantBall = Baseball:Clone()
		GiantBall.Position = partToAttack.Position + Vector3.new(0, 50, 0)
		GiantBall.Name = "Giant Baseball"
		GiantBall.Parent = game.Workspace
		debris:AddItem(GiantBall, 15)
		partToAttack = nil	-- To reset for the next time.
		-- Remove sparkles :(
		RedSparkles.Parent = nil
		WhiteSparkles.Parent = nil
		-- Set the number of balls remaining up to change
		baseballsRemaining.Value = baseballsRemaining.Value - 1
		-- Set everything else back to normal.
		wait()	-- Wait necessary to avoid triggering BaseballBat LS's onActivated event.
					-- However, this only matters in Play Solo; when playing on a server, the delay time between
					--   local and server scripts provides enough of a wait.
		Tool.Enabled = true
		-- And, after a while, remove the script.
		wait(15)
		script:Remove()
	else
		isBaseballisticObj.Value = true	-- So that if we accidentally don't click on something, we can try again.
	end

end

function onUnequipped()
	RedSparkles.Parent = nil
	WhiteSparkles.Parent = nil
	Tool.Enabled = true
	isBaseballisticObj.Value = false
	script:Remove()
end

Tool.Activated:connect(onActivated)
Tool.Unequipped:connect(onUnequipped)
