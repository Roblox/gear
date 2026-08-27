local Tool = script.Parent
local Staff = Tool.Handle

local vCharacter
local myHumanoid

local animate

local slamAnim
local swingAnim

function onEquipped(mouse)
	vCharacter = Tool.Parent
	myHumanoid = vCharacter:FindFirstChild("Humanoid")
	if mouse then 
		mouse.KeyDown:connect(function(key) 
			if key:lower() == "q" and myHumanoid then 
				animate = Tool:FindFirstChild("Animate")
				swingAnim = myHumanoid:LoadAnimation(Tool.SwingAnim)				
				if swingAnim then swingAnim:Play() end
				wait(1.0)				
			end
		end)
	end
end

function onUnequipped()
	if slamAnim then slamAnim:Stop() end
	if swingAnim then swingAnim:Stop() end
end

Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)

animate = Tool:FindFirstChild("Animate")
while animate == nil do 
	animate = Tool:FindFirstChild("Animate")
	wait()
end

animate.Changed:connect(function()
	animate = Tool:FindFirstChild("Animate")
	if animate and animate.Value == 1 and myHumanoid then 
		slamAnim = myHumanoid:LoadAnimation(Tool.SlamAnim)		
		if slamAnim then slamAnim:Play() end
		myHumanoid.Jump = true
		wait(2.2)	
		animate.Value = 0
	end
end)
