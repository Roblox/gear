local Player = game:GetService("Players").LocalPlayer
local Mouse = Player:GetMouse()

local Tool = script.Parent
local Remote = Tool:WaitForChild("Remote")

local CAS = game:GetService("ContextActionService")
local ActionName = "SteampunkBow"

function onAction(actionName, inputState, inputObject)
	if inputState == Enum.UserInputState.Begin then
		Remote:FireServer("Start")
	end
	
	if inputState == Enum.UserInputState.End then
		Remote:FireServer("End", Mouse.Hit.p)
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

--connect
Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)