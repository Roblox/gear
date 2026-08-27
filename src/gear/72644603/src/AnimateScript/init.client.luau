while script:FindFirstChild("OtherFiveAnim") == nil do 
	wait()
end 

local character = script.Parent 
local humanoid = character:FindFirstChild("Humanoid") 

if humanoid then 
	fiveAnim = humanoid:LoadAnimation(script.OtherFiveAnim) 
	if fiveAnim then fiveAnim:Play() end 
end 

wait(1.5)
if fiveAnim then fiveAnim:Stop() end 
script:Remove() 
