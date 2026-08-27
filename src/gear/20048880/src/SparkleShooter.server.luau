local debris = game:GetService("Debris")

Tool = script.Parent

local colors = {Color3.new(1,0,0), Color3.new(0,1,0), Color3.new(0,0,1), Color3.new(1,.5,0), Color3.new(0,.5,1)}


function fire()
	
	 for j=1,20 do

		local p = Instance.new("Part")
		p.Size = Vector3.new(1,1,1)
		--p.Transparency = 1
		p.Reflectance = 1
		p.Position = Tool.Handle.Position + (Tool.Handle.CFrame.lookVector * 5) + (Tool.Handle.CFrame.lookVector * math.random() * 5)
		p.Velocity =  (Vector3.new(math.random() - .5, math.random() - .5, math.random() - .5) + ( (Tool.Handle.CFrame.lookVector * 5)).unit * math.random(20,120))

		
		local s = Instance.new("Sparkles")
		s.Color = colors[math.random(1, #colors)]
		s.Parent = p

		local f = Instance.new("BodyForce")
		f.force = Vector3.new(0,98,0)
		f.Parent = p

		p.Parent = game.Workspace

		--print(p.Position.x, p.Position.y, p.Position.z)

		local debris = game:GetService("Debris")
		debris:AddItem(p, 5)

		wait(.1)
	end
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

	Tool.Handle.SparkSound.Looped = true
	Tool.Handle.SparkSound:Play()


	fire()
	Tool.Handle.SparkSound:Stop()
	wait(3)

	Tool.Enabled = true
end


script.Parent.Activated:connect(onActivated)