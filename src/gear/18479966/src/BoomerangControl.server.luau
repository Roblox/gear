local bodyp = script.Parent.BodyPosition
local arrow = script.Parent
local connection = nil
local damage = 65 --whoa

local sound = script.Parent.FlyingSound
sound.Looped = true
sound:Play()

function OnTouch(hit)
	bodyp:Remove()
	connection:disconnect()
	sound:Stop()


	humanoid = hit.Parent:findFirstChild("Humanoid")
	if humanoid~=nil then
		tagHumanoid(humanoid)

			humanoid:TakeDamage(damage)

		wait(1)
		untagHumanoid(humanoid)
	end
	
end

function tagHumanoid(humanoid)
	-- todo: make tag expire
	local tag = arrow:findFirstChild("creator")
	if tag ~= nil then
		local new_tag = tag:clone()
		new_tag.Parent = humanoid
		
	end
end


function untagHumanoid(humanoid)
	if humanoid ~= nil then
		local tag = humanoid:findFirstChild("creator")
		if tag ~= nil then
			
			tag.Parent = nil
		end
	end
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
script.Parent.RotVelocity = Vector3.new(0,20,0)

while (true) do
	wait(.1)
	if (script.Parent.Position - bodyp.position).magnitude < 10 then
		bodyp:Remove()
		break
	end
end

sound:Stop()
wait(10)
script.Parent:Remove()