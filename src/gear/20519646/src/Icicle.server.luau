debris = game:GetService("Debris")
ball = script.Parent
damage = 10

local blues = {23,107,102,11,45,135}

--removedLength = 8
function onTouched(hit)
	if hit.Parent == nil then return end
	humanoid = hit.Parent:findFirstChild("Humanoid")
	print(humanoid)
	if(ball.Name=="Icicle") then
		-- make a splat
		for i=1,3 do
			local s = Instance.new("Part")
			s.Name = "Shard"
			s.Shape = 1 -- block
			s.formFactor = 2 -- plate
			s.Size = Vector3.new(1,.4,1)
			s.BrickColor = BrickColor.new(blues[math.random(#blues)])
			s.Material = Enum.Material.Ice
			local v = Vector3.new(math.random(-1,1), math.random(0,1), math.random(-1,1))
			s.Velocity = 50 * v
			s.CFrame = CFrame.new(ball.Position + v, v)
			local new_script = script:clone()
			new_script.Disabled = false
			new_script.Parent = s
			s.Parent = game.Workspace

			local tag = ball:findFirstChild("creator")
			if tag~= nil then
				local new_tag = tag:clone()
				new_tag.Parent = s
			end

			debris:AddItem(s, 2)  ---NICK I THINK THIS IS IT

			if humanoid ~= nil then
				tagHumanoid(humanoid)
				humanoid:TakeDamage(damage)
				wait(2)
				untagHumanoid(humanoid)
			end

			connection:disconnect()
			ball.Parent = nil
		end

	else
		if humanoid ~= nil then
				tagHumanoid(humanoid)
				humanoid:TakeDamage(10)
				wait(2)
				untagHumanoid(humanoid)
				ball.Parent = nil
		end
		--removedLength = 2
		connection:disconnect()
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
			tag.Parent = nil
		end
	end
end

connection = ball.Touched:connect(onTouched)

wait(8)
--if ball.Parent~=nil then
ball.Parent = nil
--end 