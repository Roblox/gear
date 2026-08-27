-- Waits for the child of the specified parent
local function WaitForChild(parent, childName)
	while not parent:FindFirstChild(childName) do parent.ChildAdded:wait() end
	return parent[childName]
end

local Tool = script.Parent

local Animations = {}
local MyHumanoid
local MyCharacter



local StartAnim = WaitForChild(script, 'Start')
local StopAnim = WaitForChild(script, 'Stop')


function PlayAnimation(animationName, speed)
	speed = speed or 1
	if Animations[animationName] then
		Animations[animationName]:Play(0.1, 1, speed)
	else
		print("Can't find animation:" , animationName)
	end
end

function StopAnimation(animationName)
	if Animations[animationName] then
		Animations[animationName]:Stop()
	end
end

function ConnectAnimationToValueChange(valueName, animationName)
	return WaitForChild(Tool, valueName).Changed:connect(
		function (value)
				PlayAnimation(animationName)
		end)
end

function LoadAnimation(animationObject)
	if MyHumanoid then
		Animations[animationObject.Name] = MyHumanoid:LoadAnimation(animationObject)
	else
		print("Tried to load an anim without a humanoid")
	end
end


function OnEquipped(mouse)
	MyCharacter = Tool.Parent
	MyHumanoid = WaitForChild(MyCharacter, 'Humanoid')
	
	Tool.ChildAdded:connect(function (child) if child:IsA('Animation') then LoadAnimation(animationObject) end end)
	for _, child in pairs(Tool:GetChildren()) do
		if child:IsA('Animation') then
			LoadAnimation(child)
		end
	end
end

function OnUnequipped()
	for name, animTrack in pairs(Animations) do
		StopAnimation(name);
	end
end

StartAnim.OnInvoke = PlayAnimation
StopAnim.OnInvoke = StopAnimation

Tool.Equipped:connect(OnEquipped)
Tool.Unequipped:connect(OnUnequipped)

