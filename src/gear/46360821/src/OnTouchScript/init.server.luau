-- Search for the Thrown Potion Object in the workspace
-- It was made child of Workspace in the PPScript
thrownPP = script.Parent


if not thrownPP then
	print("Not yet thrown")
	return
end

local connnection = nil 
-- Sound
local HitSound = Instance.new("Sound")
HitSound.Name = "HitSound"
HitSound.SoundId = "http://www.roblox.com/asset?id=46209447"
HitSound.Volume = 1.0

-- If the potion touches a humanoid
function onTouched(hit)
	if hit == nil or hit.Parent == nil then
		return 
	end
	
	local humanoid = hit.Parent:findFirstChild("Humanoid")	
	-- Make sure the potion exists
	-- Copy the PenguinMaker script and all child Objects to the target humanoid
	if thrownPP and hit.Parent:FindFirstChild("PenguinMaker") == nil then	
		if humanoid ~= nil then 
			HitSound.Parent = thrownPP
			HitSound:Play()		
			penguinMaker = script.PenguinMaker
			penguinMaker.Parent = hit.Parent
			penguinMaker.Disabled = false
			connection:disconnect()
			if thrownPP then
				thrownPP:Remove()
			end
		end
	end
end

-- Connect to the touched event!
if thrownPP then
	connection = thrownPP.Touched:connect(onTouched)
end

