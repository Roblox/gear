--Made by Stickmasterluke


sp = script.Parent


local speedboostscript = sp:WaitForChild("SpeedBoostScript")

function Equipped()
	if sp.Parent:FindFirstChild("SpeedBoostScript") == nil then
		local s = speedboostscript:clone()
		local tooltag = Instance.new("ObjectValue")
		tooltag.Name = "ToolTag"
		tooltag.Value = sp
		tooltag.Parent = s
		s.Parent = sp.Parent
		s.Disabled = false
		local sound = sp.Handle:FindFirstChild("CoilSound")
		if sound ~= nil then
			sound:Play()
		end
	end
end

sp.Equipped:connect(Equipped)