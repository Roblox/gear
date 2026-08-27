Tool = script.Parent
local bomb = nil
local debris = game:GetService("Debris")

function plant(pos)

	Tool.Handle.Sound:Play()
   
	local vCharacter = Tool.Parent
	local vPlayer = game.Players:playerFromCharacter(vCharacter)

	local spawnPos = vCharacter.PrimaryPart.Position

	bomb = Tool.Handle:clone()
	bomb.Locked = true
	bomb.Transparency = 0
	bomb.CanCollide = true
	bomb.Name = "WhoopeeCushion"
	bomb.Position = pos

	local creator_tag = Instance.new("ObjectValue")
	creator_tag.Value = vPlayer
	creator_tag.Name = "creator"
	creator_tag.Parent = bomb

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
	Tool.Handle.Sound:Stop()

	wait(10)

	Tool.Handle.Transparency = 0
	Tool.Enabled = true
end


script.Parent.Activated:connect(onActivated)