wait()
--our player is usually a nice thing to have
local Player = game:GetService("Players").LocalPlayer
--the mouse is handy
local Mouse = Player:GetMouse()
--we'll want an easy reference to the tool
local Tool = script.Parent
--this is our way of communicating with the server side of things
local Remote = Tool:WaitForChild("Remote")
--first, acquire our input source
local CAS = game:GetService("ContextActionService")
--we'll use this variable later to uniquely identify our context actions
local ActionName = "LightReflectionSword"

--this function is filtered to by context action service
function onAttack(actionName, inputState, inputObject)
	if inputState == Enum.UserInputState.Begin then
		Remote:FireServer("AttackStarted", Mouse.Hit.p)
	end
	
	if inputState == Enum.UserInputState.End then
		Remote:FireServer("AttackEnded", Mouse.Hit.p)
	end
end

--when the sword is equipped, bind our actions
function onEquipped(mouse)
	--make sure we unequipped
	onUnequipped()
	
	--bind
	--[[
	CAS:BindActionToInputTypes(
		ActionName,
		onAttack,
		false,
		Enum.UserInputType.MouseButton1,
		Enum.UserInputType.Touch
	)--]] -- This is super weird and it crashes mobile.  No idea why we're not using mouse.Button1.  Changed. -ArceusInator
	mouse.Button1Down:connect(function()
		onAttack(ActionName, Enum.UserInputState.Begin)
	end)
	mouse.Button1Up:connect(function()
		onAttack(ActionName, Enum.UserInputState.End)
	end)
end
Tool.Equipped:connect(onEquipped)

--when we unequip, unbind the action
function onUnequipped()
	CAS:UnbindAction(ActionName)
end
Tool.Unequipped:connect(onUnequipped)