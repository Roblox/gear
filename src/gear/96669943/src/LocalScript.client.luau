local animations = {}
local savedHumanoid = nil

local tool = script.Parent
local uis = game:GetService'UserInputService'
local localplayer = game:GetService'Players'.LocalPlayer
local mouse = localplayer:GetMouse()

--
--
function clearAnimations()
	for i, track in next, animations do
		track:Stop()
	end
	animations = {}
	savedHumanoid = nil
end

--
--

tool.Animate.OnClientEvent:connect(function(name, action, ...)
	local humanoid = tool.Parent:FindFirstChild'Humanoid'
	
	if humanoid then
		if savedHumanoid ~= humanoid then
			clearAnimations()
			savedHumanoid = humanoid
		end
		
		local track = animations[name]
		if track == nil then
			track = humanoid:LoadAnimation(tool:WaitForChild(name))
			animations[name] = track
		end
		
		if action == 'Play' then
			track:Play(...)
		elseif action == 'Stop' then
			track:Stop(...)
		elseif action == 'AdjSpeed' then
			track:AdjustSpeed(...)
		end
	end
end)

function onInput(input)
	if tool.Parent == localplayer.Character then
		local down = input.UserInputState == Enum.UserInputState.Begin
		
		if input.UserInputType == Enum.UserInputType.MouseButton2 then
			tool.Input:FireServer('Mouse2', down, mouse.Hit)
		elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
			tool.Input:FireServer('Mouse1', down)
		end
	end
end

--
--

tool.Unequipped:connect(clearAnimations)
uis.InputBegan:connect(onInput)
uis.InputEnded:connect(onInput)