Tool = script.Parent
local bomb = nil
local debris = game:GetService("Debris")

function plant(pos)

	Tool.Handle.Sound:Play()
   
	local vCharacter = Tool.Parent
	local vPlayer = game.Players:playerFromCharacter(vCharacter)

	local spawnPos = vCharacter.PrimaryPart.Position

	bomb = Instance.new("Part")
	bomb.Locked = true
	bomb.Size = Vector3.new(1,2,1)
	bomb.Name = "BananaPeel"
	bomb.Position = pos

	local mesh = Tool.Handle.Mesh:clone()
	mesh.Parent = bomb

	local creator_tag = Instance.new("ObjectValue")
	creator_tag.Value = vPlayer
	creator_tag.Name = "creator"
	creator_tag.Parent = bomb

	local slip = Tool.SlipSound:clone()
	slip.Parent = bomb
	slip.Name = "SlipSound"

	local script = Tool.BananaScript:clone()
	script.Parent = bomb
	script.Disabled = false

	bomb.Parent = game.Workspace

	debris:AddItem(bomb, 120)

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

	local targetPos = humanoid.TargetPoint

	Tool.Handle.Transparency = 1
	plant(Tool.Handle.Position)

	wait(10)

	Tool.Handle.Transparency = 0
	Tool.Enabled = true
end


script.Parent.Activated:connect(onActivated)