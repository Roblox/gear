local Tool = script.Parent

local Player = game:GetService("Players").LocalPlayer
local Mouse = Player:GetMouse()

local Remote = Tool:WaitForChild("Remote")

local CAS = game:GetService("ContextActionService")
local ActionName = "NeonNinjaThrowingStars"

function onAttack(actionName, inputState, inputObject)
	if inputState == Enum.UserInputState.Begin then
		Remote:FireServer("Attack", Mouse.Hit.p)
	end
end

function onEquipped()
	onUnequipped()
	
	CAS:BindActionToInputTypes(
		ActionName,
		onAttack,
		false,
		Enum.UserInputType.MouseButton1,
		Enum.UserInputType.Touch
	)
end

function onUnequipped()
	CAS:UnbindAction(ActionName)
end

function main()
	Tool.Equipped:connect(onEquipped)
	Tool.Unequipped:connect(onUnequipped)
end

main()