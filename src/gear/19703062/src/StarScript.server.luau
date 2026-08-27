arrow = script.Parent
local debris = game:service("Debris")

local HitSound = Instance.new("Sound")
HitSound.SoundId = "http://www.roblox.com/asset/?id=19321040"
HitSound.Parent = arrow
HitSound.Volume = 1

function onTouched(hit)

	connection:disconnect()

	if hit.Name == "XMAS" then
		HitSound:Play()
		base = hit.Parent:findFirstChild("XMASBase")
		if base~=nil then 
			local weld = Instance.new("Weld")
			local star = Instance.new("Part")
			star.Size = Vector3.new(1,2,1)
			star.Shape = 1
			star.BrickColor = BrickColor.Red()
			star.Parent = game.Workspace

			arrow.Mesh.Parent = star

			weld.Part0 = base
			weld.Part1 = star
			weld.C0 = CFrame.new(0,0,0)
			weld.C1 = CFrame.new(0,-11.5,0)
			weld.Parent = game.Workspace

			debris:AddItem(star, 300)
			
		end
		arrow.Parent = nil
	else
		debris:AddItem(arrow, 30)
	end

	
	
end


connection = arrow.Touched:connect(onTouched)