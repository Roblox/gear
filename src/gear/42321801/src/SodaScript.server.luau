local Tool = script.Parent;

enabled = true

function onActivated()
	if not enabled  then
		return
	end

	enabled = false

	Tool.Handle.DrinkSound:Play()
	
	-- smmmmmmmokin' (or it'd just be "Chocolate")
	local newSmoke = Instance.new("Smoke")
	newSmoke.RiseVelocity = 2
	newSmoke.Opacity = .5
	newSmoke.Size = .1
	newSmoke.Parent = Tool.SmokePart

	wait(1)

	-- hot chocolate will slowly thaw out anything frozen (with a FrostyValue NumberValue tag)
	local h = Tool.Parent:FindFirstChild("Humanoid")
	if (h ~= nil) then
		local frostyValue = Tool.Parent:FindFirstChild("FrostyValue")
		if frostyValue ~= nil then
			if frostyValue.Value > 0 then frostyValue.Value = frostyValue.Value - 1 end
		end
	end

	wait(7)
	newSmoke:remove()
	enabled = true

end


function onEquip()
	-- weld gets broken on unequip :( ...  so rebuild it as necessary :)
	local smokeWeld = Tool.SmokePart:FindFirstChild("SmokeWeld")
	if smokeWeld == nil then
		smokeWeld = Instance.new("Weld")
	end
		smokeWeld.Part0 = Tool.Handle
		smokeWeld.Part1 = Tool.SmokePart
		smokeWeld.Name = "SmokeWeld"
		smokeWeld.C1  = CFrame.Angles(-math.pi/2,0,0)
		smokeWeld.Parent = Tool.SmokePart
end


script.Parent.Equipped:connect(onEquip)
script.Parent.Activated:connect(onActivated)
