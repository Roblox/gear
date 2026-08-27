local Tool = script.Parent 
local RHead = Tool.Handle

local WalkAnim
local RapidFireAnim 

local function fuse(key)
	-- Need to add animation 
	key = key:lower() 
	if key == "q" then 
		local rFire = Tool:FindFirstChild("RapidFire")
		if rFire and rFire.Value == false and vHumanoid then 
			RapidFireAnim = vHumanoid:LoadAnimation(Tool.RapidFireAnim)
			RapidFireAnim:Play() 
			wait(0.2)
			rFire.Value = true 
			wait(1.2)
			RapidFireAnim:Stop()
		end  
	end 
end 

local function onEquipped(mouse)
	vCharacter = Tool.Parent 
	vHumanoid = vCharacter:FindFirstChild("Humanoid")
	if mouse then
		mouse.KeyDown:connect(fuse) 
	end 
	if vHumanoid then
		WalkAnim = vHumanoid:LoadAnimation(Tool.WalkAnim) 
		WalkAnim:Play() 
	end 
end 

local function onUnequipped()
	if WalkAnim then WalkAnim:Stop() end 
	if RapidFireAnim then RapidFireAnim:Stop() end 
end  

Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)
