local Tool = script.Parent
local Handle = Tool:FindFirstChild'Handle'

script.PlaySound.Event:connect(function(name, length, part)
	part = part or Handle
	
	local sound = script[name]:Clone()
	sound.Parent = part
	sound:Play()
	
	delay(length or 5, function() sound:Destroy() end)
end)

Tool.Equipped:connect(function()
	script.PlaySound:Fire('Equip')
end)