local fire = script.Parent
local debris = game:GetService("Debris")

local ice = Instance.new("Part")
ice.Transparency = 0.5
ice.BrickColor = BrickColor.new("Bright blue")
ice.TopSurface = 0
ice.BottomSurface = 0
ice.Reflectance = 0.75
ice.CanCollide = false

local smoke = Instance.new("Smoke")
smoke.Size = 1
smoke.RiseVelocity = -1
smoke.Opacity = 0.1
smoke.Parent = ice

function onTouched(part)

	if string.find(fire.Name,part.Parent.Name) ~= nil then return end
	if part.Parent:FindFirstChild("Humanoid") then
		if part:FindFirstChild(fire.Name) == nil then
			burn = script.Icer:clone()
			burn.Parent = part.Parent
			burn.Disabled = false
			ice.Size = Vector3.new(part.Size.x + 1,part.Size.y + 1,part.Size.z + 1)
			ice.Parent = game.Workspace
			local weld = Instance.new("Weld")
			weld.Part0 = ice
			weld.Parent = ice
			weld.Part1 = part
			print(part.Name)
			debris:AddItem(ice,12)
		end
	end

end

fire.Touched:connect(onTouched)

