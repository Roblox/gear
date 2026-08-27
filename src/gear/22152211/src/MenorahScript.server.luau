-------- OMG HAX

r = game:service("RunService")


Tool = script.Parent

local sparkles = script.Parent.Handle:findFirstChild("Sparkles")

function onEquipped()
	menorahsound = Instance.new("Sound")
	menorahsound.SoundId = "http://www.roblox.com/asset/?id=19095020" 
	menorahsound.Parent = Tool
	menorahsound.Volume = .4

end

function onUnequipped()
	menorahsound:Stop()
end


function onActivated()

	
	--active the sparkes
	if (not sparkles.Enabled) then
		sparkles.Enabled = true		
		menorahsound:Play()
	else
		sparkles.Enabled = false
	end
end

--connecting the equip, unequip, and mouseClick functions
script.Parent.Equipped:connect(onEquipped)
script.Parent.Unequipped:connect(onUnequipped)
script.Parent.Activated:connect(onActivated)




