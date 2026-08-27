--Updated for R15 avatars by StarWars
local Tool = script.Parent
local Remote = Tool:WaitForChild("Remote")

local CAS = game:GetService("ContextActionService")
local ActionName = "PenguinAttack"

local Player = game:GetService("Players").LocalPlayer
local Mouse = Player:GetMouse()

local HoldAni = Tool:WaitForChild("holdAni")
local R15Sit = Tool:WaitForChild("R15Sit")

local Track

local Controls = Tool:WaitForChild("controlsGui")

Mouse.KeyDown:connect(function(key)
	Remote:FireServer("KeyDown", key)
end)

Mouse.KeyUp:connect(function(key)
	Remote:FireServer("KeyUp", key)
end)

function onAction(actionName, inputState, inputObject)
	if inputState == Enum.UserInputState.Begin then
		Remote:FireServer("Activate", Mouse.Hit.p)
	end
end

function onEquipped()
	--ensure unequip
	onUnequipped()
	
	local Humanoid = Tool.Parent:WaitForChild("Humanoid")	
	
	if Humanoid and Humanoid.RigType == Enum.HumanoidRigType.R15 then
		Track = Humanoid:LoadAnimation(R15Sit)
	else
		Track = Humanoid:LoadAnimation(HoldAni)
	end
	Track:Play()
	
	Controls.Parent = Player.PlayerGui
	
	--bind
	CAS:BindActionToInputTypes(
		ActionName,
		onAction,
		false,
		Enum.UserInputType.MouseButton1,
		Enum.UserInputType.Touch
	)
end

function onUnequipped()
	if Track then
		Track:Stop()
	end
	
	if Controls.Parent ~= Tool then
		Controls.Parent = Tool
	end
	
	--unbind
	CAS:UnbindAction(ActionName)
end

function playAnimation(name, ...)
	local anim = Tool:FindFirstChild(name)
	if anim then
		local human = Tool.Parent:FindFirstChild("Humanoid")
		if human then
			local track = human:LoadAnimation(anim)
			track:Play(...)
		end
	end
end

function onRemote(func, ...)
	if func == "PlayAnimation" then
		playAnimation(...)
	end
end

--connect
Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)
Remote.OnClientEvent:connect(onRemote)