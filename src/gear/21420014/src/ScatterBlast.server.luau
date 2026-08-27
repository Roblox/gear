local Tool = script.Parent;

enabled = true

local spark = Instance.new("Sparkles")
spark.Color = Color3.new(1,0,0)

local fireEvent = Tool:WaitForChild('FireEvent')

function fire(v)

	local vCharacter = Tool.Parent
	local vPlayer = game.Players:playerFromCharacter(vCharacter)

	
	

	local spawnPos = vCharacter.PrimaryPart.Position
	
	local PewPew = Tool.Handle:FindFirstChild("PewPew")

	if (PewPew == nil) then
		PewPew = Instance.new("Sound")
		PewPew.Name = "PewPew"
		PewPew.SoundId = "http://www.roblox.com/asset/?id=13775466"
		PewPew.Parent = Tool.Handle
		PewPew.Volume = 1
		PewPew.Pitch = .7
	end
	

	for dx=-1,1,1 do
		for dy=-1,1,1 do
			if (math.abs(dx) == 0 or math.abs(dy) == 0) then

				local p = Instance.new("Part")
				p.BrickColor = BrickColor.new("Bright red")
				p.formFactor = 2
				p.Size = Vector3.new(1,.4,1)
				p.Material = Enum.Material.Ice
				p.Friction = .05
				p.Elasticity = .9
				p.TopSurface = 0
				p.BottomSurface = 0
				p.Name = "ScatterShot"

				local dv = CFrame.fromEulerAnglesXYZ(dx/4,dy/4,0) * v

				local a = math.random() * 6.28
				local d = Vector3.new(math.cos(a), 0, math.sin(a)).unit
				p.Velocity = dv * 100
				p.RotVelocity = d
				p.Position = spawnPos + (dv * 10)

				local force = Instance.new("BodyForce")
				force.force = Vector3.new(0,30,0)
				force.Parent = p

				local creator_tag = Instance.new("ObjectValue")
				creator_tag.Value = vPlayer
				creator_tag.Name = "creator"
				creator_tag.Parent = p

				local new_script = script.Parent.LaserBlast:clone()
				new_script.Disabled = false
				new_script.Parent = p

				spark:Clone().Parent = p

				p.Parent = game.Workspace
			end
		end
	end

	PewPew:Play()

end



function gunUp()
	Tool.GripForward = Vector3.new(0,.981,-.196)
	Tool.GripRight = Vector3.new(1,0,0)
	Tool.GripUp = Vector3.new(0,.196,.981)
end

function gunOut()
	Tool.GripForward = Vector3.new(0,1,0)
	Tool.GripRight = Vector3.new(1,0,0)
	Tool.GripUp = Vector3.new(0,0,1)
end



function onActivated(targetPos)
	if not enabled  then
		return
	end

	enabled = false


	local character = Tool.Parent;
	local humanoid = character.Humanoid
	if humanoid == nil then
		print("Humanoid not found")
		return 
	end

	local lookAt = (targetPos - character.Head.Position).unit

	local reload = .3
	--if (isTurbo(character)) then
	--	reload = .25
	--	print("turbo")
	--end

	gunUp()
	fire(lookAt)
	wait(reload)
	gunOut()
	wait(reload)

	enabled = true

end

fireEvent.OnServerEvent:connect(function(player, targetPos)
	onActivated(targetPos)
end)

function onEquipped()
	Tool.Handle.EquipSound:play()
end

--script.Parent.Activated:connect(onActivated)
script.Parent.Equipped:connect(onEquipped)
