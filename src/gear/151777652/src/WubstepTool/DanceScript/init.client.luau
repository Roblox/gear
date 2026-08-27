--Just dance like you never had a chance

--I'd rhyme, but I dont have the time

--this is getting silly, so orange.

while script:FindFirstChild('DanceAnim') == nil do wait() end 

local Character = script.Parent  
local Humanoid = Character:FindFirstChild('Humanoid') 
Humanoid.WalkSpeed = 0.0 
local DanceAnim = Humanoid:LoadAnimation(script.DanceAnim)
DanceAnim:Play() 

--Song lasts 8 seconds
wait(8.0)
DanceAnim:Stop() 
Humanoid.WalkSpeed = 16.0

wait(4.0)
script:Destroy() 
