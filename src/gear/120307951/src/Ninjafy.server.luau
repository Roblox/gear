local TIME_INVISIBLE = 15
local DEFAULT_WALK_SPEED = 16
local NEW_WALK_SPEED = 40

function SetTransparency(instance, transparency)
	if (instance:IsA("BasePart") or instance:IsA("Decal")) and instance.Name~="HumanoidRootPart" then
		instance.Transparency = transparency
	end
	for _, child in pairs(instance:GetChildren()) do
		-- Exception for our case: the tool already makes itself 
		-- visible again, so we should avoid touching tool's transparency
		if not child:IsA("Tool") then
			SetTransparency(child, transparency)
		end
	end
end

if script.Parent then
	SetTransparency(script.Parent, 1.0)
	script.Parent.Humanoid.WalkSpeed = NEW_WALK_SPEED
end
wait(TIME_INVISIBLE)
if script.Parent then
	SetTransparency(script.Parent, 0.0)
	script.Parent.Humanoid.WalkSpeed = DEFAULT_WALK_SPEED
end
script:Destroy()

