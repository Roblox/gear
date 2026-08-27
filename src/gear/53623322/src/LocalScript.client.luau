local animations = {}
local savedHumanoid = nil

local tool = script.Parent
local uis = game:GetService'UserInputService'
local localplayer = game:GetService'Players'.LocalPlayer
local mouse = localplayer:GetMouse()

local uis, cas = game:GetService'UserInputService', game:GetService'ContextActionService'

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

local hdc
tool:WaitForChild'Animate'.OnClientEvent:connect(function(name, action, ...)
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
		
		if hdc then hdc:disconnect() end
		hdc = humanoid.Died:connect(function() tool.Parent = nil end)
	end
end)
tool.Unequipped:connect(function()
	if hdc then hdc:disconnect() end
end)

function onInput(input)
	if tool.Parent == localplayer.Character then
		local down = input.UserInputState == Enum.UserInputState.Begin
		
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			tool.Input:FireServer('Mouse1', down)
		elseif input.UserInputType == Enum.UserInputType.Keyboard then
			tool.Input:FireServer('Key', down, input.KeyCode)
		end
	end
end

if uis.TouchEnabled then
	tool.Equipped:connect(function()
		cas:UnbindAction('SorcusSwordOfJudgement_X')
		cas:UnbindAction('SorcusSwordOfJudgement_Z')
		
		cas:BindActionToInputTypes('SorcusSwordOfJudgement_X', function()
			tool.Input:FireServer('Key', true, {Name='x'})
		end, true, '')
		cas:BindActionToInputTypes('SorcusSwordOfJudgement_Z', function()
			tool.Input:FireServer('Key', true, {Name='z'})
		end, true, '')
		
		cas:SetTitle('SorcusSwordOfJudgement_X', 'Call for Judgement')
		cas:SetTitle('SorcusSwordOfJudgement_Z', 'Will of Judgement')
	end)
	
	tool.Unequipped:connect(function()
		cas:UnbindAction('SorcusSwordOfJudgement_X')
		cas:UnbindAction('SorcusSwordOfJudgement_Z')
	end)
end

--
--

tool.Unequipped:connect(clearAnimations)
uis.InputBegan:connect(onInput)
uis.InputEnded:connect(onInput)