--get references to important objects
local Player = game:GetService("Players").LocalPlayer
local Tool = script.Parent
local Remote = Tool:WaitForChild("Remote")

--this function plays an animation on demand
--inefficient, but prevents edge cases with dropping the weapon
function playAnimation(animationName)
	local animation = Tool:FindFirstChild(animationName)
	if animation and Tool.Parent and Tool.Parent:FindFirstChild("Humanoid") then
		local human = Tool.Parent.Humanoid
		local track = human:LoadAnimation(animation)
		track:Play()
	end
end

--hook up the remote
Remote.OnClientEvent:connect(function(func, ...)
	local args = {...}
	
	if func == "PlayAnimation" then
		playAnimation(args[1])
	end
end)