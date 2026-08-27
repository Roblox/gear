local Tool = script.Parent;

local DeltaTime = 1/60
local Speed = 20

Tool.Enabled = true
function onActivated()
	if not Tool.Enabled  then
		return
	end
	Tool.Enabled = false
	
	Tool.Handle.Noisemaker:Play()

	rattle = Tool.Handle:clone()
	rattle.Anchored = true
	rattle.CanCollide = false
	rattle.Parent = game.Workspace
	
	--location = Instance.new("BodyPosition")
	--location.position = Tool.Handle.Position  --rattle.Position
	--location.Parent = rattle

	Tool.Handle.Transparency = 1
	rattle.Transparency = 0

	local startTime = time()
	local angle = 0
	
	while rattle do
		if time() - startTime > 5 then break end
		local x, _, z = Tool.Handle.CFrame:toEulerAnglesXYZ()
		rattle.CFrame = CFrame.new(Tool.Handle.Position) * CFrame.Angles(x, angle, z)
		angle = (angle + 1) % 360
		wait(DeltaTime)
	end

	--if location~=nil then location:Remove() end
	if rattle then rattle:Destroy() end
	Tool.Handle.Transparency = 0

	wait(2)
	Tool.Enabled = true

end

function onEquipped()
	Tool.Handle.Transparency = 0
end

function onUnequipped()
	--if location~= nil then location:Remove() end
	if rattle then rattle:Destroy() end
end

script.Parent.Activated:connect(onActivated)
script.Parent.Equipped:connect(onEquipped)
script.Parent.Unequipped:connect(onUnequipped)
