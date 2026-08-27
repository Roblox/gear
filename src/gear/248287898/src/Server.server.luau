local Tool = script.Parent
local Remote = Tool:WaitForChild("Remote")
local Handle = Tool:WaitForChild("Handle")

local FriendlyFire = false

local DanceScene = nil

local Player
local Humanoid

--returns the wielding player of this tool
function getPlayer()
	local char = Tool.Parent
	return game:GetService("Players"):GetPlayerFromCharacter(char)
end

--helpfully checks a table for a specific value
function contains(t, v)
	for _, val in pairs(t) do
		if val == v then
			return true
		end
	end
	return false
end

--tags a human for the ROBLOX KO system
function tagHuman(human)
	local tag = Instance.new("ObjectValue")
	tag.Value = getPlayer()
	tag.Name = "creator"
	tag.Parent = human
	game:GetService("Debris"):AddItem(tag)
end

--used by checkTeams
function sameTeam(otherHuman)
	local player = getPlayer()
	local otherPlayer = game:GetService("Players"):GetPlayerFromCharacter(otherHuman.Parent)
	if player and otherPlayer then
		if player == otherPlayer then
			return true
		end
		if otherPlayer.Neutral then
			return false
		end
		return player.TeamColor == otherPlayer.TeamColor
	end
	return false
end

--use this to determine if you want this human to be harmed or not, returns boolean
function checkTeams(otherHuman)
	return not (sameTeam(otherHuman) and not FriendlyFire)
end

function createDiscoBall(danceScene)
	local discoBall = Handle:Clone()
	discoBall.Name = "DiscoBall"
	discoBall.Anchored = true
	discoBall.CanCollide = false
	discoBall.Transparency = 0	
	discoBall.CFrame = CFrame.new(0, 14, 0)
	discoBall.Mesh.Scale = Vector3.new(1, 1, 1) * 2.5
	discoBall.Parent = danceScene
	
	danceScene.PrimaryPart = discoBall
	
	spawn(function()
		local rotSpeed = math.pi
		while DanceScene ~= nil do
			discoBall.CFrame = discoBall.CFrame * CFrame.Angles(0, rotSpeed * wait(), 0)
		end
	end)
end

function createDanceFloor(danceScene)
	local tile = Instance.new("Part")
	tile.Anchored = true
	tile.CanCollide = false
	tile.Material = "SmoothPlastic"
	
	local tiles = {}
	local tileSize = 3
	local floorSize = 6
	local offset = -floorSize/2
	for tx = 0, floorSize do
		for tz = 0, floorSize do
			local x = (tx + offset) * tileSize
			local z = (tz + offset) * tileSize
			local pos = Vector3.new(x, 0, z)
			local newTile = tile:Clone()
			newTile.Size = Vector3.new(tileSize, 0.2, tileSize)
			newTile.CFrame = CFrame.new(pos)
			newTile.Parent = danceScene
			table.insert(tiles, newTile)
		end
	end
	
	spawn(function()
		local tileSwitchTime = 0.25
		while DanceScene ~= nil do
			for _, tile in pairs(tiles) do
				tile.BrickColor = BrickColor.palette(math.random(0, 63))
			end
			wait(tileSwitchTime)
		end
	end)
end

function getRoot()
	local char = Tool.Parent
	if char then
		return char:FindFirstChild("HumanoidRootPart")
	end
end

function createDanceScene()
	DanceScene = Instance.new("Model")
	createDiscoBall(DanceScene)
	createDanceFloor(DanceScene)
	
	local root = getRoot()
	if root then
		local offset = Humanoid.HipHeight > 0 and Humanoid.HipHeight*1.5 + 0.2 or 3
		local pos = root.Position + Vector3.new(0, DanceScene.DiscoBall.Position.Y - offset, 0)
		DanceScene:SetPrimaryPartCFrame(CFrame.new(pos))
		DanceScene.Parent = workspace
	end
end

function destroyDanceScene()
	if DanceScene then
		DanceScene:Destroy()
		DanceScene = nil
	end
end

function hideHandle()
	Handle.Transparency = 1
end

function getHuman()
	local char = Tool.Parent
	if char then
		return char:FindFirstChild("Humanoid")
	end
end

function disableMovement()
	local human = getHuman()
	if human then
		local normalHumanWalkSpeed = 16
		human.WalkSpeed = human.WalkSpeed - normalHumanWalkSpeed
		
		spawn(function()
			while DanceScene ~= nil do
				wait()
			end
			human.WalkSpeed = human.WalkSpeed + normalHumanWalkSpeed
		end)
	end
end

function onEquip()
	Player = getPlayer()
	Humanoid = Tool.Parent:FindFirstChildOfClass("Humanoid")
	createDanceScene()
	hideHandle()
	disableMovement()
	if Humanoid then
		if Humanoid.RigType == Enum.HumanoidRigType.R15 then
			Remote:FireClient(getPlayer(), "PlayAnimation", "R15Dance")
		else
			Remote:FireClient(getPlayer(), "PlayAnimation", "Dance")
		end
	end
	
end

function onUnequip()
	destroyDanceScene()
	if Humanoid then
		if Humanoid.RigType == Enum.HumanoidRigType.R15 then
			Remote:FireClient(getPlayer(), "StopAnimation", "R15Dance")
		else
			Remote:FireClient(getPlayer(), "StopAnimation", "Dance")
		end
	end	
end

Tool.Equipped:connect(onEquip)
Tool.Unequipped:connect(onUnequip)