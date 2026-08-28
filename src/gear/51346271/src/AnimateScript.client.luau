local Tool = script.Parent
local Blowgun = Tool.Handle

local blowAnim
local vCharacter


local Animatons = {
	Blow = Tool:WaitForChild("Blow");
	R15Blow = Tool:WaitForChild("R15Blow");
}

function onActivated()
	vCharacter = Tool.Parent
	myHumanoid = vCharacter:FindFirstChild("Humanoid")		
	if myHumanoid == nil then 
		return
	end

	blowAnim = myHumanoid:LoadAnimation(Animatons.Blow)
	if myHumanoid and myHumanoid.RigType == Enum.HumanoidRigType.R15 then
		blowAnim = myHumanoid:LoadAnimation(Animatons.R15Blow)
	end
	
	if blowAnim then blowAnim:Play() end	
	
end

function onEquipped()
end

function onUnequipped()
	if blowAnim then blowAnim:Stop() end	
end

Tool.Activated:connect(onActivated)
Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)