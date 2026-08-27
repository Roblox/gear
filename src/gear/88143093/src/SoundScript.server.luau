--SolarCrane
function waitForChild(parent, childName)
	local child = parent:findFirstChild(childName)
	if child then return child end
   while true do
		child = parent.ChildAdded:wait()
		if child.Name==childName then return child end
   end
end

local Tool = script.Parent


local Launch = waitForChild(Tool, 'Launch')

local PostShot = waitForChild(Tool, 'PostShot')


local PoweringUp = waitForChild(Tool, 'PoweringUp')



function ChargeSoundLogic(value, sound)
		print('Charge Changed Event ' .. value)
		if value == 0 then -- this means it was just fired
			if Launch then
				Launch:Play()
				wait(0.2)
				PostShot:Play()
			end
		elseif value < 20 then
			if sound then --and sound.IsPlaying then
				sound:Stop()
				print('Charge Up Stopped ' .. value)
			end
		else
			if sound then -- and sound.IsPaused then
				sound:Play()
				sound.Volume = value / 100
				print('Charge Up Playing ' .. value)
			end
		end
end


function onUnequipped()
	if PostShot then
		PostShot:Stop()
	end
	if PoweringUp then
		PoweringUp:Stop()
	end
	if Launch then
		Launch:Stop()
	end
end

Tool.Unequipped:connect(onUnequipped)

Tool:FindFirstChild('Charge').Changed:connect(
	function(value)
		ChargeSoundLogic(value, PoweringUp)
	end
)
