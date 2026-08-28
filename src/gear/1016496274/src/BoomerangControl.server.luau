local bodyp = script.Parent.BodyPosition
local connection = nil


local sound = script.Parent.FlyingSound
sound.Looped = true
sound:Play()


function OnTouch(hit)
	bodyp:Remove()
	connection:disconnect()
	sound:Stop()
end


connection = script.Parent.Touched:connect(OnTouch)


while(true) do
	wait(.1)
	if (script.Parent.Position - bodyp.position).magnitude < 10 then
		
		-- get tosser
		local creator_tag = script.Parent:FindFirstChild("creator")
		if creator_tag == nil then
			bodyp:Remove()
		else
			local char = creator_tag.Value.Character
			if char == nil then
				bodyp:Remove()
			else
				bodyp.position = char.Head.Position
			end
		end
	
		break
	end
end

wait(.5)
script.Parent.RotVelocity = Vector3.new(0,10,0)

while (true) do
	wait(.1)
	if (script.Parent.Position - bodyp.position).magnitude < 5 then
		bodyp:Remove()
		break
	end
end

sound:Stop()
script:Remove()