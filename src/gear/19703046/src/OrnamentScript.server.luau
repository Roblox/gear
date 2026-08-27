arrow = script.Parent
local debris = game:service("Debris")
local HitSound = Instance.new("Sound")
HitSound.SoundId = "http://www.roblox.com/asset/?id=19344667"
HitSound.Parent = arrow
HitSound.Volume = .7


function stick(hit)
	-- joint myself to the thing i hit

	local weld = Instance.new("Weld")

	weld.Part0 = arrow
	weld.Part1 = hit

	-- correction term to account for average skew between physics update and heartbeat
	local HitPos = arrow.Position --+ (-arrow.Velocity * (1/60)) --+ (arrow.CFrame.lookVector * .5)

	local CJ = CFrame.new(HitPos)
	local C0 = arrow.CFrame:inverse() *CJ
	local C1 = hit.CFrame:inverse() * CJ
	
	weld.C0 = C0
	weld.C1 = C1

	weld.Parent = game.Workspace

end


function onTouched(hit)

	connection:disconnect()

	if hit.Name == "XMAS" then
		HitSound:Play()
		stick(hit)
		debris:AddItem(arrow, 300)
	else
		debris:AddItem(arrow, 30)
	end
	
end


connection = arrow.Touched:connect(onTouched)