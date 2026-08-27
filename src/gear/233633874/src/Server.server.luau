--Updated for R15 avatar by StarWars
local Tool = script.Parent
local Remote = Tool:WaitForChild("Remote")
local Handle = Tool:WaitForChild("Handle")

local FriendlyFire = false

local SlingEmptyMeshData = "rbxassetid://230850530"
local SlingFullMeshData = "rbxassetid://230850577"
local EarthMeshData = "rbxassetid://230850473"
local TextureData = "rbxassetid://230850616"

local AttackAble = true
local AttackReloadTime = 3

local ProjectileSpeed = 128

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

function getEarth()
	local earth = Instance.new("Part")
	earth.CanCollide = false
	earth.FormFactor = "Custom"
	earth.Size = Vector3.new(1, 1, 1)
	earth.TopSurface = "Smooth"
	earth.BottomSurface = "Smooth"
	
	local mesh = Instance.new("SpecialMesh")
	mesh.MeshId = EarthMeshData
	mesh.TextureId = TextureData
	mesh.Parent = earth
	
	local lift = Instance.new("BodyForce")
	lift.force = Vector3.new(0, 196.2, 0) * earth:GetMass() * 0.8
	lift.Parent = earth
	
	return earth
end

function onLeftDown(targetPoint)
	if not AttackAble then return end
	local humanoid = Tool.Parent:FindFirstChild("Humanoid")
		
	AttackAble = false
	delay(AttackReloadTime, function()
		AttackAble = true
		Handle.Mesh.MeshId = SlingFullMeshData
	end)
	
	if humanoid then
		if humanoid.RigType == Enum.HumanoidRigType.R6 then
			Remote:FireClient(getPlayer(), "PlayAnimation", "Throw")
		elseif humanoid.RigType == Enum.HumanoidRigType.R15 then
			Remote:FireClient(getPlayer(), "PlayAnimation", "R15Throw")
		end
	end	
	
	wait(0.2)
	Handle.Mesh.MeshId = SlingEmptyMeshData
	
	local earth = getEarth()
	earth.CFrame = CFrame.new(Handle.Position, targetPoint)
	earth.Velocity = earth.CFrame.lookVector * ProjectileSpeed
	
	earth.Touched:connect(function(part)
		if part:IsDescendantOf(Tool.Parent) then return end
		
		if part.Parent and part.Parent:FindFirstChild("HumanoidRootPart") and part.Parent:FindFirstChild("Humanoid") then
			local spin
			if game.Players:GetPlayerFromCharacter(part.Parent) then
				spin = Tool.SpinClient:Clone()
			else
				spin = Tool.SpinScript:Clone()
			end
			spin.Disabled = false
			spin.Parent = part.Parent
			
			earth:Destroy() --ominous sounding, right?
		end
	end)
	
	earth.Parent = workspace
	game:GetService("Debris"):AddItem(earth)
end

function onRemote(player, func, ...)
	if player ~= getPlayer() then return end
	
	if func == "LeftDown" then
		onLeftDown(...)
	end
end

Remote.OnServerEvent:connect(onRemote)
