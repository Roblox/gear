local player = script.Parent
local animFile = player:FindFirstChild("partyanim")

local anim = player.Humanoid:LoadAnimation(animFile)

anim:Play()

wait(15)

anim:Stop()
animFile:remove()
anim:remove()
script:remove()