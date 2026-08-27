local Debris = game:GetService("Debris")

local ball = script.Parent
local damage = 15

function onTouched(hit)
	local humanoid = hit.Parent:findFirstChild("Humanoid")

	if humanoid ~= nil then
		tagHumanoid(humanoid)
		humanoid:TakeDamage(damage)
		wait(1)
		untagHumanoid(humanoid)
	end
end

function tagHumanoid(humanoid)
	-- todo: make tag expire
	local tag = ball:findFirstChild("creator")
	if tag ~= nil then
		local new_tag = tag:clone()
		new_tag.Parent = humanoid
	end
end


function untagHumanoid(humanoid)
	if humanoid ~= nil then
		local tag = humanoid:findFirstChild("creator")
		if tag ~= nil then
			tag:Destroy()
		end
	end
end

connection = ball.Touched:connect(onTouched)

Debris:AddItem(ball, 10)