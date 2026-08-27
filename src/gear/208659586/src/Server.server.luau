local Tool = script.Parent
local Remote = Tool:WaitForChild("Remote")
local Handle = Tool:WaitForChild("Handle")

local FriendlyFire = false

local AttackPower = 1
local AttackDamage = 22.5
local AtackRechargeTime = 3
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
function TagHumanoid(humanoid, player)
	local Creator_Tag = Instance.new("ObjectValue")
	Creator_Tag.Name = "creator";
	Creator_Tag.Value = player;
	game:GetService("Debris"):AddItem(Creator_Tag, 2)
	Creator_Tag.Parent = humanoid
end
	
function UntagHumanoid(humanoid)
	for _, v in pairs(humanoid:GetChildren()) do
		if v:IsA("ObjectValue") and v.Name == "creator" then
			v:Destroy()
		end
	end
end

--used by checkTeams
function IsTeamMate(Player1, Player2)
	return (Player1 and Player2 and not Player1.Neutral and not Player2.Neutral and Player1.TeamColor == Player2.TeamColor)
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

local Throwing = false

function onLeftDown(mousePos)
	if Throwing then return end
	Throwing = true
	local knife = getKnife()
	knife.CFrame = CFrame.new(Handle.Position, mousePos)
	knife.Velocity = knife.CFrame.lookVector * AttackSpeed * AttackPower
	local damage = AttackDamage * AttackPower
	local touched
	touched = knife.Touched:Connect(function(part)
		if part:IsDescendantOf(Tool.Parent) then return end
		if contains(Knives, part) then return end
		
		local human = part.Parent:FindFirstChildOfClass("Humanoid")
		if part.Parent and human then
			if not IsTeamMate(getPlayer(),game:GetService("Players"):GetPlayerFromCharacter(human.Parent)) then
				UntagHumanoid(human)
				TagHumanoid(human,getPlayer())
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
		
		touched:Disconnect()
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
	wait(1/10)
	Throwing = false
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

Remote.OnServerEvent:Connect(onRemote)
Tool.Equipped:Connect(onEquip)
Tool.Unequipped:Connect(onUnequip)