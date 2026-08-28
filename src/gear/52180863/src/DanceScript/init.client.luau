local vCharacter = script.Parent
local myHumanoid = vCharacter:findFirstChild("Humanoid")

local danceAnim

anim = script:findFirstChild("FluteDance")

while anim == nil do 
	anim = script:FindFirstChild("FluteDance")
	wait()
end

print("Found Anim")

if myHumanoid then 
	print("Playing Anim")
	wait(1.0)
	danceAnim = myHumanoid:LoadAnimation(script.FluteDance)
	if danceAnim then danceAnim:Play() end
end

wait(3.25)

print("Removing Script")

script:Remove() 

