local Player = game:GetService("Players").LocalPlayer
local Mouse = Player:GetMouse()

local Tool = script.Parent
local Remote = Tool:WaitForChild("Remote")

local CAS = game:GetService("ContextActionService")
local ActionName = "RiotShield"

local WalkTrack

function playAnimation(animationName, fadeTime, weight, speed)
	local anim = Tool:FindFirstChild(animationName)
	if anim ~= nil then
		local char = Player.Character
		if char and char:FindFirstChild("Humanoid") then
			local human = char.Humanoid
			local track = human:LoadAnimation(anim)
			
			track:Play(fadeTime, weight, speed)
		end
	end
end

function onAction(actionName, inputState, inputObject)
	if inputState == Enum.UserInputState.Begin then
		Remote:FireServer("Attack")
	end
end

function toggleWalkTrack(on)
	if on then
		local anim = Tool:WaitForChild("ShieldWalk")
		local char = Player.Character
		if char and char:FindFirstChild("Humanoid") then
			local human = char.Humanoid
			WalkTrack = human:LoadAnimation(anim)
			WalkTrack:Play(1)
		end
	else
		if WalkTrack then
			WalkTrack:Stop()
		end
	end
end

function onEquipped()
	onUnequipped()
	
	CAS:BindActionToInputTypes(
		ActionName,
		onAction,
		false,
		Enum.UserInputType.MouseButton1,
		Enum.UserInputType.Touch
	)
	
	toggleWalkTrack(true)
end

function onUnequipped()
	CAS:UnbindAction(ActionName)
	
	toggleWalkTrack(false)
end

function onRemote(func, ...)
	if func == "PlayAnimation" then
		playAnimation(...)
	end
end

Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)
Remote.OnClientEvent:connect(onRemote)