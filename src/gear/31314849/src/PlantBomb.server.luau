bombScript = script.Parent.Bomb
Tool = script.Parent

function plant(pos)
	
	local vCharacter = Tool.Parent
	local vPlayer = game.Players:playerFromCharacter(vCharacter)

	local spawnPos = vCharacter.PrimaryPart.Position

	local bomb = Tool.Handle:clone()

	bomb.CanCollide = true
	bomb.Transparency = 0
	bomb.Position = pos
	bomb.Size = Vector3.new(2,2,2)
	bomb.Name = "FuseBomb"
	bomb.Locked = true

	local spark = Instance.new("Sparkles")
	spark.Name = "Fuse"
	spark.Parent = bomb

	--This call will cause a "wait" until the data comes back
	local monkey = game:GetService("InsertService"):LoadAsset(31044315)

	local instances = monkey:GetChildren()
	if #instances == 0 then
		monkey:Remove()
		return
	end

	monkey = monkey:FindFirstChild("Monkey")

	--Continue the insert process

	monkey.Parent = bomb

	local sound = Instance.new("Sound")
	sound.SoundId = "http://www.roblox.com/asset/?id=31044217"
	sound.Name = "Explosion"
	sound.Parent = bomb

	local creator_tag = Instance.new("ObjectValue")
	creator_tag.Value = vPlayer
	creator_tag.Name = "creator"
	creator_tag.Parent = bomb

	bomb.Parent = game.Workspace

	local new_script = bombScript:clone()
	new_script.Disabled = false
	new_script.Parent = bomb

	local monkeyScript = Tool.MonkeyScript:clone()
	monkeyScript.Parent = bomb

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
	wait(3)
	Tool.Handle.Transparency = 0

	Tool.Enabled = true
end


script.Parent.Activated:connect(onActivated)