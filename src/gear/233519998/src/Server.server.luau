--Updated for R15 avatar by StarWars

local Tool = script.Parent
local Remote = Tool:WaitForChild("Remote")
local Handle = Tool:WaitForChild("Handle")

local Heartbeat = game:GetService("RunService").Heartbeat
local HeartbeatConnection

local FriendlyFire = false

local AttackRestTimer = 0
local DropAttackTimer = 0
local DamageTimer = 0

local AttackWindow = 0.75
local AttackDamage = 12
local AttackDamaging = false

for i, v in pairs(Tool:GetChildren()) do
	if v:IsA("BasePart") and v ~= Handle then
		v:Destroy()
	end
end

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

function canAttack()
	return AttackRestTimer <= 0 
end

function canDropAttack()
	return DropAttackTimer > 0
end

function onHeartbeat(dt)
	AttackRestTimer = AttackRestTimer - dt
	if AttackRestTimer < 0 then
		AttackRestTimer = 0
	end
	
	DropAttackTimer = DropAttackTimer - dt
	if DropAttackTimer < 0 then
		DropAttackTimer = 0
	end
	
	DamageTimer = DamageTimer - dt
	if DamageTimer < 0 then
		DamageTimer = 0
	end
	
	if characterIsGrounded() then
		DropAttackTimer = 0
	end
end

function playSound(name, pitch)
	pitch = pitch or math.random(90, 110) / 100
	
	local sound = Handle:FindFirstChild(name)
	sound.Pitch = pitch
	sound:Play()
end

function airAttack()
	local root = Tool.Parent:FindFirstChild("HumanoidRootPart")
	local humanoid = Tool.Parent:FindFirstChild("Humanoid")
	if root then
		if canDropAttack() then
			root.Velocity = Vector3.new(0, -160, 0)
			
			spawn(function()
				local t = 0
				while not characterIsGrounded() and t < 2 do
					t = t + Heartbeat:wait()
				end
				
				local e = Instance.new("Explosion")
				e.Position = root.Position - Vector3.new(0, 3, 0)
				e.BlastPressure = 0
				e.Hit:connect(function(part)
					if part:IsDescendantOf(Tool.Parent) then return end
					
					if part.Parent and part.Parent:FindFirstChild("HumanoidRootPart") then
						local root = part.Parent.HumanoidRootPart
						local dir = (root.Position - e.Position).unit
						
						local vel = Instance.new("BodyVelocity")
						vel.velocity = dir * 64
						vel.maxForce = Vector3.new(1e9, 1e9, 1e9)
						vel.Parent = root
						game:GetService("Debris"):AddItem(vel, 0.1)
					end
				end)
				e.Parent = workspace
				
				if humanoid then
					if humanoid.RigType == Enum.HumanoidRigType.R6 then
						Remote:FireClient(getPlayer(), "StopAnimation", "Fall")
					elseif humanoid.RigType == Enum.HumanoidRigType.R15 then
						Remote:FireClient(getPlayer(), "StopAnimation", "R15Fall")
					end
				end
				playSound("Hit")
			end)
			
			DropAttackTimer = 0
			AttackRestTimer = AttackRestTimer + 1
			
			if humanoid then
				if humanoid.RigType == Enum.HumanoidRigType.R6 then
					Remote:FireClient(getPlayer(), "PlayAnimation", "Fall")
				elseif humanoid.RigType == Enum.HumanoidRigType.R15 then
					Remote:FireClient(getPlayer(), "PlayAnimation", "R15Fall")
				end
			end
			playSound("Whoosh")
		else
			root.Velocity = Vector3.new(0, 96, 0)
			
			DropAttackTimer = 2.5
			AttackRestTimer = AttackRestTimer + 0.5
			
			if humanoid then
				if humanoid.RigType == Enum.HumanoidRigType.R6 then
					Remote:FireClient(getPlayer(), "PlayAnimation", "Jump", nil, nil, 2)
				elseif humanoid.RigType == Enum.HumanoidRigType.R15 then
					Remote:FireClient(getPlayer(), "PlayAnimation", "R15Jump", nil, nil, 2)
				end
			end
			playSound("Jump")
		end
	end
end

function groundAttack()
	local humanoid = Tool.Parent:FindFirstChild("Humanoid")
	if humanoid then
		if humanoid.RigType == Enum.HumanoidRigType.R6 then
			Remote:FireClient(getPlayer(), "PlayAnimation", "Swing", nil, nil, math.random(90, 110) / 100)
		elseif humanoid.RigType == Enum.HumanoidRigType.R15 then
			Remote:FireClient(getPlayer(), "PlayAnimation", "R15Swing", nil, nil, math.random(90, 110) / 100)
		end
	end
	playSound("Swing")
	
	AttackRestTimer = AttackRestTimer + 0.25
	DamageTimer = DamageTimer + 0.15
end

function characterIsGrounded()
	local root = Tool.Parent:FindFirstChild("HumanoidRootPart")
	if root then
		local ray = Ray.new(root.Position, Vector3.new(0, -3.5, 0))
		local part, pos = workspace:FindPartOnRay(ray, Tool.Parent)
		return part ~= nil
	end
	return false
end

function onLeftDown()
	if not canAttack() then return end
	
	if characterIsGrounded() then
		groundAttack()
	else
		airAttack()
	end
end

function onHandleTouched(part)
	if DamageTimer <= 0 then return end
	if part:IsDescendantOf(Tool.Parent) then return end
	
	if part.Parent and part.Parent:FindFirstChild("Humanoid") then
		local human = part.Parent.Humanoid
		if checkTeams(human) then
			tagHuman(human)
			human:TakeDamage(AttackDamage)
			DamageTimer = 0
		end
	end
end

function onRemote(player, func, ...)
	if player ~= getPlayer() then return end
	
	if func == "LeftDown" then
		onLeftDown(...)
	end
end

function onEquip()
	HeartbeatConnection = Heartbeat:connect(onHeartbeat)
	Spawn(function()
	local LeftArm = Tool.Parent:FindFirstChild("Left Arm") or Tool.Parent:FindFirstChild("LeftHand") --Fix implemented by Luckymaxer
		if LeftArm then
			FakeHandle = Handle:Clone()
			FakeHandle.Name = "FakeHandle"
			local LeftGrip = Instance.new("Weld")
			LeftGrip.Part0 = LeftArm
			LeftGrip.Part1 = FakeHandle
			LeftGrip.C0 = CFrame.new(0, (LeftArm.Name == "LeftHand" and -0.15) or -1, 0, 1, 0, -0, 0, 0, 1, 0, -1, -0)
			LeftGrip.C1 = Tool.Grip
			LeftGrip.Parent = FakeHandle
			FakeHandle.Touched:connect(onHandleTouched)
			FakeHandle.Parent = Tool
		end
	end)
end

function onUnequip()
	if FakeHandle and FakeHandle.Parent then
		FakeHandle:Destroy()
	end
	if HeartbeatConnection then
		HeartbeatConnection:disconnect()
		HeartbeatConnection = nil
	end
end

Remote.OnServerEvent:connect(onLeftDown)
Tool.Equipped:connect(onEquip)
Tool.Unequipped:connect(onUnequip)
Handle.Touched:connect(onHandleTouched)
