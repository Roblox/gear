local Tool = script.Parent
local debris = game:GetService("Debris")
local player = nil

Fire = Tool.Handle:WaitForChild("Fire")
Tool.Handle:WaitForChild("PointLight")
Tool.Handle:WaitForChild("Light")
Tool:WaitForChild("FireScript")

Fire.Enabled = false

Tool.Equipped:connect(function()
	player = Tool.Parent
end)

Tool.Handle.Touched:connect(function(part)

	if Tool.Handle.Fire.Enabled == false then
		return
	end
	local children = part:GetChildren()
	for i = 1, #children do
		if children[i].className == "Fire" then
			return
		end
	end
	if part.Parent == player then
		return
	end

	if part.Material ==  Enum.Material.Wood then
		local fire = Tool.Handle.Fire:clone()
		fire.Parent = part
		local light=Tool.Handle.PointLight:clone()
		light.Parent=part
		
		local fireScript = Tool.FireScript:clone()
		fireScript.Parent = part
		fireScript.Disabled = false

		debris:AddItem(fire,35)
		debris:AddItem(light,35)
	end

end)

Tool.Activated:connect(function()
	Tool.Handle.Fire.Enabled = not Tool.Handle.Fire.Enabled
	Tool.Handle.PointLight.Enabled = not Tool.Handle.PointLight.Enabled
	Tool.Handle.Light:Play()
end)
