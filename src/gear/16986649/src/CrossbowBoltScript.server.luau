debris = game:GetService("Debris")
bolt = script.Parent
damage = 33

local GLib = require(206209239)

debris:AddItem(bolt, 20)

function stick(hit)
	-- joint myself to the thing i hit

	local weld = Instance.new("Weld")

	weld.Part0 = bolt
	weld.Part1 = hit


	local HitPos = bolt.Position + (bolt.Velocity.unit * 3)   -- + (arrow.CFrame.lookVector * 1)

	local CJ = CFrame.new(HitPos)
	local C0 = bolt.CFrame:inverse() *CJ
	local C1 = hit.CFrame:inverse() * CJ
	
	weld.C0 = C0
	weld.C1 = C1

	weld.Parent = bolt

end

function onTouched(hit)

	bolt.BodyGyro:remove()
	bolt.BodyForce:remove()

	stick(hit)

	bolt.HitSound:Play()

	local humanoid = hit.Parent:findFirstChild("Humanoid")
	local isTeammate = GLib.IsTeammate(GLib.GetPlayerFromPart(humanoid), bolt.creator.Value)


	if humanoid ~= nil and not isTeammate then
		tagHumanoid(humanoid)
		humanoid.Health = humanoid.Health - damage
	end
	connection:disconnect()
end

function tagHumanoid(humanoid)
	-- todo: make tag expire
	local tag = bolt:findFirstChild("creator")
	if tag ~= nil then
		local new_tag = tag:clone()
		new_tag.Parent = humanoid
		debris:AddItem(new_tag,1)
	end
end



connection = bolt.Touched:connect(onTouched)

for i=1,100 do
	wait(.1 * i)
	if (bolt:FindFirstChild("BodyGyro") ~= nil) then
		bolt.BodyGyro.cframe = CFrame.new(Vector3.new(0,0,0), -bolt.Velocity.unit)
	end
end


