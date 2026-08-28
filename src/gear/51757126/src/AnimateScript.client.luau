local Tool = script.Parent 
local Bracer = Tool.Handle 

local dualAnim 

local vCharacter 

function onActivatedLocal() 
	while Tool.Enabled == false do wait() end 
	vCharacter = Tool.Parent 

	myHumanoid = vCharacter:FindFirstChild("Humanoid") 
	if myHumanoid == nil then 
		 return 
	end 

	dualAnim = myHumanoid:LoadAnimation(Tool.BracerBash) 
	if dualAnim then dualAnim:Play() end     
end 

function onEquippedLocal() 
end 

function onUnequippedLocal() 
     if dualAnim then dualAnim:Stop() end 
end 

Tool.Activated:connect(onActivatedLocal) 
Tool.Equipped:connect(onEquippedLocal) 
Tool.Unequipped:connect(onUnequippedLocal) 

