local Tool = script.Parent
local Remote = Tool:WaitForChild("Remote")

local CAS = game:GetService("ContextActionService")
local ActionName = "KorbloxIceHunterBow"

local Player = game:GetService("Players").LocalPlayer
local Mouse = Player:GetMouse()

local Tracks = {}

function onAction(actionName, inputState, inputObject)
	if inputState == Enum.UserInputState.Begin then
		Remote:FireServer("Activate", Mouse.Hit.p)
	end
	
	if inputState == Enum.UserInputState.End then
		Remote:FireServer("Deactivate", Mouse.Hit.p)
	end
end

function onEquipped()
	--ensure unequip
	onUnequipped()
	
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
			Tracks[name] = track
		end
	end
end

function stopAnimation(name)
	if Tracks[name] then
		Tracks[name]:Stop()
		Tracks[name] = nil
	end
end

function onRemote(func, ...)
	if func == "PlayAnimation" then
		playAnimation(...)
	end
	
	if func == "StopAnimation" then
		stopAnimation(...)
	end
end

--connect
Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)
Remote.OnClientEvent:connect(onRemote)