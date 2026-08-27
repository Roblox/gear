-- Waits for the child of the specified parent
local function WaitForChild(parent, childName)
	while not parent:FindFirstChild(childName) do parent.ChildAdded:wait() end
	return parent[childName]
end

local Tool = script.Parent

local Animations = {}
local MyHumanoid
local MyCharacter


local function PlayAnimation(animationName)
	if Animations[animationName] then
		Animations[animationName]:Play()
	else
		print("Can't find animation:" , animationName)
	end
end

local function StopAnimation(animationName)
	if Animations[animationName] then
		Animations[animationName]:Stop()
	end
end

local function ConnectAnimationToValueChange(valueName, animationName)
	return WaitForChild(Tool, valueName).Changed:connect(
		function (value)
			--if value then
				PlayAnimation(animationName)
			--else
			--	StopAnimation('SlashAnim')
			--end
		end)
end

function OnEquipped(mouse)
	MyCharacter = Tool.Parent
	MyHumanoid = WaitForChild(MyCharacter, 'Humanoid')
	if MyHumanoid then
		Animations['IdleAnim'] = MyHumanoid:LoadAnimation(WaitForChild(Tool, 'BowWalk'))
		Animations['ShootAnim'] = MyHumanoid:LoadAnimation(WaitForChild(Tool, 'ArrowAnim'))
	end
	wait()
	if Tool:IsDescendantOf(Workspace) then
		PlayAnimation('IdleAnim')
	end
end

function OnUnequipped()
	StopAnimation('ShootAnim')
	StopAnimation('IdleAnim')
end



Tool.Equipped:connect(OnEquipped)
Tool.Unequipped:connect(OnUnequipped)

ConnectAnimationToValueChange('PlayShoot', 'ShootAnim')
