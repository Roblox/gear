local Player = game:GetService("Players").LocalPlayer
while not Player.Character do wait() end
local Character = Player.Character
local Human = Character:WaitForChild("Humanoid")

local CAS = game:GetService("ContextActionService")
local ActionName = "GiantAngelicSword"

local Tool = script.Parent
local Remote = Tool:WaitForChild("Remote")

local Animations = {
	Hold = Tool:WaitForChild("Hold"),
	Slam = Tool:WaitForChild("Slam"),
	SwingRightToLeft = Tool:WaitForChild("SwingRightToLeft"),
	SwingLeftToRight = Tool:WaitForChild("SwingLeftToRight"),
}
local HoldTrack

function playAnimation(name, fade, weight, speed)
	if Animations[name] then
		local track = Human:LoadAnimation(Animations[name])
		track:Play(fade, weight, speed)
	end
end

function onAction(actionName, inputState, inputObject)
	if inputState == Enum.UserInputState.Begin then
		Remote:FireServer("Attack")
	end
end

function onEquipped()
	--ensure unequip
	onUnequipped()
	
	--animate
	HoldTrack = Human:LoadAnimation(Animations.Hold)
	HoldTrack:Play(0.5)
	
	--bind actions
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
	
	--stop animation
	if HoldTrack then
		HoldTrack:Stop()
	end
end

function onRemote(func, ...)
	if func == "PlayAnimation" then
		playAnimation(...)
	end
end

--set up events
Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)
Remote.OnClientEvent:connect(onRemote)