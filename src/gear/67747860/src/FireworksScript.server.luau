local Tool = script.Parent
local Rocket = Tool.Handle

local vCharacter

function plant(pos)	
   
	local vCharacter = Tool.Parent
	local vPlayer = game.Players:playerFromCharacter(vCharacter)

	local spawnPos = vCharacter.PrimaryPart.Position

	local bomb = Tool.Handle:Clone()
	bomb.CanCollide = true
	bomb.Transparency = 0
	bomb.Position = pos
	bomb.Name = "Shell"
	bomb.Locked = true

	local creator_tag = Instance.new("ObjectValue")
	creator_tag.Value = vPlayer
	creator_tag.Name = "creator"
	creator_tag.Parent = bomb

	bomb.Parent = game.Workspace
	local newScript = Tool.BlastScript:clone()
	newScript.Disabled = false
	newScript.Parent = bomb
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
	wait(5)
	Tool.Handle.Transparency = 0
	Tool.Enabled = true
end


Tool.Activated:connect(onActivated)