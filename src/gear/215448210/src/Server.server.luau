local Tool = script.Parent
local Remote = Tool:WaitForChild("Remote")
local Handle = Tool:WaitForChild("Handle")

local AssetId = 215399493
local InsertService = game:GetService("InsertService")

local GriffinEvent

local FriendlyFire = false

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

function onLeftDown(targetPosition)
	if GriffinEvent then
		GriffinEvent:Fire("Attack", targetPosition)
	end
end

function onRemote(player, func, ...)
	if player ~= getPlayer() then return end
	
	if func == "LeftDown" then
		onLeftDown(...)
	end
end

function onEquip()
	if Handle.Transparency == 0 then
		local Griffin = InsertService:LoadAsset(AssetId):GetChildren()[1]
		Griffin.Parent = workspace
		Griffin:MakeJoints()
		Griffin:MoveTo(Handle.Position)
		
		local Owner = Instance.new("ObjectValue")
		Owner.Value = game.Players:GetPlayerFromCharacter(Tool.Parent)
		Owner.Name = "Owner"
		Owner.Parent = Griffin
		
		GriffinEvent = Griffin.Event
		
		Handle.Transparency = 1
		
		while wait(1) do
			if not Griffin.Parent then
				Tool:Destroy()
			end
		end
	end
end

Tool.Equipped:connect(onEquip)
Remote.OnServerEvent:connect(onRemote)