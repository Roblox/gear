local debris = game:GetService("Debris")

function onTouched(part)

	local humanoid =  part.Parent:findFirstChild("Humanoid")
	if humanoid ~= nil then
	
		script.Parent.InsertScript.Parent = humanoid.Parent
		local sound = script.Parent.hitSound
		sound.Parent = humanoid.Parent
		sound:Play()
		debris:AddItem(sound,5)
		humanoid.Parent.InsertScript.Disabled = false
		script.Parent:remove()
		
	end

end

script.Parent.Touched:connect(onTouched)
