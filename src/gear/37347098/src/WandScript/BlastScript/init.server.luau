spark = script.Parent

local newtSound = Instance.new("Sound")
newtSound.SoundId = "http://www.roblox.com/asset/?id=35971304"
newtSound.Parent = script.Parent
newtSound.Name = "NewtSound"
newtSound.Volume = 1

function onTouch(hit)
	if spark.Transparency < .2 then return end -- to avoid collisions with creator (unless creator runs into it)
	if hit == nil then return end
	if hit.Parent == nil then return end
	humanoid = hit.Parent:FindFirstChild("Humanoid")
	if humanoid == nil then
		
	else
		-- if this is same as creator, don't newt (for now we just wait 1 second before newt-ing people)
		-- otherwise, time to get our Newt-On :)
		if hit.Parent:FindFirstChild("NewtOnScript") == nil then 
			newNewt = script:FindFirstChild("NewtOnScript")
			if newNewt == nil then return end
			newNewt = newNewt:Clone()
			newNewt.Parent = hit.Parent
			newNewt.Disabled = false
			newtSound:Play()
			spark.Parent = nil
		end
	end
end


spark.Touched:connect(onTouch)
for i = 1,50 do
	spark.Transparency = i/50
	wait(.1)
end
spark.Parent = nil

