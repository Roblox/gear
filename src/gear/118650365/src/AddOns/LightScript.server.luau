--Rescripted by Luckymaxer
--Stickmasterluke

Part = script.Parent

RunService = game:GetService("RunService")

Light = (Part:FindFirstChild("Light") or Instance.new("PointLight"))
Light.Name = "Light"
Light.Parent = Part

Colors = {
	Color3.new(1, 0, 0),
	Color3.new(1, 1, 0),
	Color3.new(0, 1, 0),
	Color3.new(0, 0, 1),
}

RunService.Stepped:connect(function()
	if Part.Velocity.magnitude > 2 then
		local BrightnessPercent = math.min(((Part.Velocity.magnitude - 2) / 40), 1)
		local CurrentColor = Colors[math.floor((tick() % #Colors) + 1)]
		local NextColor = Colors[math.floor(((tick() + 1) % #Colors) + 1)]
		local ColorPercent = (tick() % 1)
		Light.Brightness = (4 * BrightnessPercent)
		Light.Range = (4 + (BrightnessPercent * 8))
		Light.Color = Color3.new(
			(CurrentColor.r + (NextColor.r - CurrentColor.r) * ColorPercent),
			(CurrentColor.g + (NextColor.g - CurrentColor.g) * ColorPercent),
			(CurrentColor.b + (NextColor.b - CurrentColor.b) * ColorPercent)
		)
		Light.Enabled = true
	else
		Light.Enabled = false
	end
end)