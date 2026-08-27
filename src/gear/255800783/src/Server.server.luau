local Tool = script.Parent
local Remote = Tool:WaitForChild("Remote")
local Handle = Tool:WaitForChild("Handle")

local FriendlyFire = false

local AttackPower = 1
local AttackDamage = 22.5
local AtackRechargeTime = 1.75
local AttackRecharge = 1/AtackRechargeTime
local AttackSpeed = 256

local Equipped = false
local Heartbeat = game:GetService("RunService").Heartbeat

local Knives = {}

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

function getKnife()
	local knife = Handle:clone()
	knife.Transparency = 0
	knife.Hit.Pitch = math.random(90, 110)/100
	
	local lift = Instance.new("BodyForce")
	lift.force = Vector3.new(0, 196.2, 0) * knife:GetMass() * 0.8
	lift.Parent = knife
	
	local proj = Tool.Projectile:Clone()
	proj.Disabled = false
	proj.Parent = knife
	
	return knife
end

function equippedLoop()
	while Equipped do
		local dt = Heartbeat:wait()
		
		if AttackPower < 1 then
			AttackPower = AttackPower + dt * AttackRecharge
			if AttackPower > 1 then
				AttackPower = 1
			end
		end
		
		Handle.Fire.Enabled = AttackPower >= 1
		Handle.Transparency = 1 - AttackPower
	end
end

function changeMesh()
	local mesh = Handle.Mesh
	if mesh.MeshId == "rbxassetid://252793741" then
		mesh.MeshId = "rbxassetid://252793785"
	elseif mesh.MeshId == "rbxassetid://252793785" then
		mesh.MeshId = "rbxassetid://252793817"
	else
		mesh.MeshId = "rbxassetid://252793741"
	end
end

function onLeftDown(mousePos)
	local knife = getKnife()
	knife.CFrame = CFrame.new(Handle.Position, mousePos)
	knife.Velocity = knife.CFrame.lookVector * AttackSpeed * AttackPower
	local damage = AttackDamage * AttackPower
	local touched
	touched = knife.Touched:connect(function(part)
		if part:IsDescendantOf(Tool.Parent) then return end
		if contains(Knives, part) then return end
		
		touched:disconnect()
		
		if part.Parent and part.Parent:FindFirstChild("Humanoid") then
			local human = part.Parent.Humanoid
			if checkTeams(human) then
				tagHuman(human)
				human:TakeDamage(damage)
				knife.Hit:Play()
			end
		end
		
		knife.Projectile:Destroy()
		
		local w = Instance.new("Weld")
		w.Part0 = part
		w.Part1 = knife
		w.C0 = part.CFrame:toObjectSpace(knife.CFrame)
		w.Parent = w.Part0
	end)
	table.insert(Knives, knife)
	knife.Parent = workspace
	
	game:GetService("Debris"):AddItem(knife, 3.5)
	delay(2, function()
		knife.Transparency = 1
		knife.Fire.Enabled = false
	end)
	
	Remote:FireClient(getPlayer(), "PlayAnimation", "Throw")	
	
	Handle.Throw.Pitch = 0.8 + 0.4 * AttackPower
	Handle.Throw:Play()
	
	AttackPower = 0
	
	changeMesh()
end

function onRemote(player, func, ...)
	if player ~= getPlayer() then return end
	
	if func == "LeftDown" then
		onLeftDown(...)
	end
end

function onEquip()
	Equipped = true
	equippedLoop()
end

function onUnequip()
	Equipped = false
end

Remote.OnServerEvent:connect(onRemote)
Tool.Equipped:connect(onEquip)
Tool.Unequipped:connect(onUnequip)

changeMesh()
