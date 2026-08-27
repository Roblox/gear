wait()
--get references to important objects
local Player = game:GetService("Players").LocalPlayer
local Tool = script.Parent
local Remote = Tool:WaitForChild("Remote")

local animationTracks = {}

--this function plays an animation on demand
--inefficient, but prevents edge cases with dropping the weapon
function playAnimation(animationName, speed)
	local animation = Tool:FindFirstChild(animationName)
	if animation and Tool.Parent and Tool.Parent:FindFirstChild("Humanoid") then
		local human = Tool.Parent.Humanoid
		local track = human:LoadAnimation(animation)
		
		if animationTracks[animationName] then
			animationTracks[animationName]:Stop()
		end
		track:Play(nil, nil, speed)
		animationTracks[animationName] = track
	end
end

-- stops all animations to prevent the from being stuck
function stopAnimations()
	for name, track in next, animationTracks do
		track:Stop()
	end
	
	animationTracks = {}
end

--hook up the remote
Remote.OnClientEvent:connect(function(func, ...)
	local args = {...}
	
	if func == "PlayAnimation" then
		playAnimation(args[1], args[2])
	end
end)

-- stops all animations once the sword is unequipped
Tool.Unequipped:connect(stopAnimations)