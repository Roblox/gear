--Updated for R15 avatars by StarWars
local Tool = script.Parent
local Remote = Tool:WaitForChild("Remote")
local Handle = Tool:WaitForChild("Handle")
local Human
local JumpConnection
local HB = game:GetService("RunService").Heartbeat
local DB = game:GetService("Debris")

local AttackAble = true
local AttackRestTime = 2/3
local AttackDamaging = false
local AttackStartUp = 0.2
local AttackWindow = 1
local AttackDamage = 25

local JumpAble = true
local JumpRestTime = 5
local JumpDamage = 10

function onEquipped()
	onUnequipped()
	
	Human = Tool.Parent:WaitForChild("Humanoid")
	JumpConnection = Human.Jumping:connect(onJump)
end

function onUnequipped()
	if JumpConnection then
		JumpConnection:disconnect()
	end
end

function bladeTrail(duration)
	spawn(function()
		local fadeTime = 0.5
		local t = 0
		while t < duration do
			t = t + wait(0.075)
			local blade = Handle:clone()
			blade.Anchored = true
			blade.CanCollide = false
			blade.Parent = workspace
			DB:AddItem(blade, fadeTime)
			HB:connect(function(dt)
				blade.Transparency = blade.Transparency + (dt / fadeTime)
			end)
			local touched
			touched = blade.Touched:connect(function(part)
				if part:IsDescendantOf(Tool.Parent) then return end
				
				if part.Parent and part.Parent:FindFirstChild("Humanoid") then
					local human = part.Parent.Humanoid
					tagHuman(human)
					human:TakeDamage(JumpDamage)
					touched:disconnect()
					
					blade.Anchored = false
					local w = Instance.new("Weld")
					w.Part0 = part
					w.Part1 = blade
					w.C0 = part.CFrame:toObjectSpace(blade.CFrame)
					w.Parent = w.Part0
					
					Handle.Hit:Play()
				end
			end)
		end
	end)
end

function onJump()
	if not JumpAble then return end
	
	JumpAble = false
	delay(JumpRestTime, function()
		JumpAble = true
	end)
	
	local duration = 1.5
	local jumpAssist = Instance.new("BodyVelocity")
	jumpAssist.maxForce = Vector3.new(0, math.huge, 0)
	jumpAssist.velocity = Vector3.new(0, 1.5, 0)
	jumpAssist.Parent = Handle
	DB:AddItem(jumpAssist, duration)
	bladeTrail(duration)
	if Human then
		Remote:FireClient(getPlayer(), "LoopAnimation", "R15Spin", duration, 0.5, 0, nil, 1.5)
	else
		Remote:FireClient(getPlayer(), "LoopAnimation", "Spin", duration, 0.5, 0, nil, 1.5)
	end
	local soundTime = 0.25
	for t = 1, duration/soundTime do
		Handle["Clash"..math.random(1, 3)]:Play()
		wait(soundTime)
	end
end

function tagHuman(human)
	local val = Instance.new("ObjectValue")
	val.Name = "creator"
	val.Value = getPlayer()
	val.Parent = human
	game:GetService("Debris"):AddItem(val, 1)
end

function onTouched(part)
	if not AttackDamaging then return end
	
	if part.Parent and part.Parent:FindFirstChild("Humanoid") then
		local human = part.Parent.Humanoid
		tagHuman(human)
		human:TakeDamage(AttackDamage)
		Handle.Hit:Play()
		AttackDamaging = false
	end
end

function activate()
	if not AttackAble then return end
	
	AttackAble = false
	delay(AttackRestTime, function()
		AttackAble = true
	end)
	
	delay(AttackStartUp, function()
		AttackDamaging = true
		delay(AttackWindow, function()
			AttackDamaging = false
		end)
	end)
	
	if Human then
		Remote:FireClient(getPlayer(), "PlayAnimation", "R15HackAndSlash1")
	else
		Remote:FireClient(getPlayer(), "PlayAnimation", "HackAndSlash1")
	end
	
	Handle.Attack.Pitch = math.random(170, 180)/100
	Handle.Attack:Play()
end

function getPlayer()
	return game:GetService("Players"):GetPlayerFromCharacter(Tool.Parent)
end

function onRemote(player, func, ...)
	if player ~= getPlayer() then return end
	
	if func == "Activate" then
		activate()
	end
end

Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)
Remote.OnServerEvent:connect(onRemote)
Handle.Touched:connect(onTouched)