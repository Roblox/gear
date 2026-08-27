local Tool = script.Parent;
debris = game:GetService("Debris")

enabled = true



function MakeABuck(pos)

	--PLAY COIN SOUND
	Tool.Handle.CoinSound:Play()

	for i=1,5 do
		local p = Instance.new("Part")
		p.BrickColor = BrickColor.new(23)
		p.formFactor = 2
		p.Size = Vector3.new(1,.2,1)
		p.TopSurface = 0
		p.BottomSurface = 0
		
		local a = math.random() * 6.28 
		local d = Vector3.new(math.cos(a), 0, math.sin(a)).unit
		p.Velocity = d * 25
		p.RotVelocity = d
		p.Position = pos + Vector3.new(0,2,0) + Vector3.new(0, math.random() * 3, 0) + (d * 2)
		p.Parent = game.Workspace
		Tool.Mesh:Clone().Parent = p

		debris:AddItem(p, 60)
	end

end

function onActivated()
	if not enabled  then
		return
	end

	enabled = false

	local char = Tool.Parent


	MakeABuck(Tool.Handle.Position)

--	char.Torso["Right Shoulder"].MaxVelocity = 0.5
--	char.Torso["Right Shoulder"].DesiredAngle = 3
--	wait(.2)
--	char.Torso["Right Shoulder"].MaxVelocity = 0.5
--	char.Torso["Right Shoulder"].DesiredAngle = 3
--	wait(.2)
--	char.Torso["Right Shoulder"].MaxVelocity = 0.5
--	char.Torso["Right Shoulder"].DesiredAngle = 3
--	wait(.2)
--	char.Torso["Right Shoulder"].MaxVelocity = 0.5
--	char.Torso["Right Shoulder"].DesiredAngle = 3
--	wait(.2)
--
--
--	char.Torso["Right Shoulder"].MaxVelocity = 1

--[[
	Tool.GripForward = Vector3.new(0,-1,0)
	Tool.GripPos = Vector3.new(0,0,2)
	Tool.GripRight = Vector3.new(1,0,0)
	Tool.GripUp = Vector3.new(0,0,-1)
]]--
	enabled = true

end



script.Parent.Activated:connect(onActivated)

