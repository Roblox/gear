-------- OMG HAX
debris = game:GetService("Debris")
r = game:service("RunService")




sword = script.Parent.Handle
Tool = script.Parent


local sounds = {Tool.Handle.Midas1, Tool.Handle.Midas2, Tool.Handle.Midas3}



function goldEffect(pos)

	local count = 5


	for i=1,count do
		local p = Instance.new("Part")
		p.BrickColor = BrickColor.new("Bright yellow")
		p.formFactor = 2
		p.Size = Vector3.new(1,.4,1)
		p.Material = Enum.Material.Ice
		p.TopSurface = 0
		p.BottomSurface = 0
		
		local a = math.random() * 6.28
		local d = Vector3.new(math.cos(a), 0, math.sin(a)).unit
		p.Velocity = d * 25
		p.RotVelocity = d
		p.Position = pos + Vector3.new(0, math.random() * 3, 0) + (d * 2)
		p.Parent = game.Workspace

		debris:AddItem(p, 60)
	end

end


function blow(hit)
	
	local vCharacter = Tool.Parent
	local hum = vCharacter:findFirstChild("Humanoid") -- non-nil if tool held by a character

	

	if hum ~= nil then
		-- final check, make sure sword is in-hand
		local right_arm = vCharacter:FindFirstChild("Right Arm")
		if (right_arm ~= nil) then
			local joint = right_arm:FindFirstChild("RightGrip")
			if (joint ~= nil and (joint.Part0 == sword or joint.Part1 == sword)) then
				if (hit.Locked == false) then
					hit.BrickColor = BrickColor.new("Bright yellow")
					hit.Material = Enum.Material.Ice

					local i = math.random(3)
					if (sounds[i].IsPlaying == false) then
						sounds[i]:Play()
					end
				end
			end
		end


	end
end





function attack()
	local anim = Instance.new("StringValue")
	anim.Name = "toolanim"
	anim.Value = "Slash"
	anim.Parent = Tool
end





Tool.Enabled = true

function onActivated()

	if not Tool.Enabled then
		return
	end

	Tool.Enabled = false

	local character = Tool.Parent;
	local humanoid = character.Humanoid
	if humanoid == nil then
		print("Humanoid not found")
		return 
	end

	
	
	attack()
	wait(.2)
	goldEffect(character.Torso.Position + (character.Torso.CFrame.lookVector * 3))

	wait(1)

	Tool.Enabled = true
end





script.Parent.Activated:connect(onActivated)



connection = sword.Touched:connect(blow)


