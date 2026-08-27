-------- OMG HAX

r = game:service("RunService")


local damage = 0


local slash_damage = 0


sword = script.Parent.Handle
Tool = script.Parent



function attack()
	local anim = Instance.new("StringValue")
	anim.Name = "toolanim"
	anim.Value = "Slash"
	anim.Parent = Tool
end


function swordUp()
	Tool.GripForward = Vector3.new(-1,0,0)
	Tool.GripRight = Vector3.new(0,1,0)
	Tool.GripUp = Vector3.new(0,0,1)
end

function swordOut()
	Tool.GripForward = Vector3.new(0,0,1)
	Tool.GripRight = Vector3.new(0,-1,0)
	Tool.GripUp = Vector3.new(-1,0,0)
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

	wait(1)

	Tool.Enabled = true
end


function onEquipped()
	print("Running Delete")
end


script.Parent.Activated:connect(onActivated)
script.Parent.Equipped:connect(onEquipped)

