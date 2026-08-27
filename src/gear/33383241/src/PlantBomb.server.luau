Tool = script.Parent
local planting = true
local bomb = nil

local sound = Instance.new("Sound")
sound.SoundId = "http://www.roblox.com/asset/?id=28517063"
sound.Looped = true

local explosion = Instance.new("Sound")
explosion.SoundId = "http://www.roblox.com/asset/?id=28518734"
explosion.Volume = 0.01
explosion:Play()
explosion.Volume = 0.5

function plant(pos)
	
	Tool.Handle.Plant:Play()
   
	local vCharacter = Tool.Parent
	local vHumanoid = vCharacter:FindFirstChild'Humanoid'
	if not vHumanoid or vHumanoid:IsA'Humanoid'==false or vHumanoid.Health<=0 then return end
	local vPlayer = game.Players:playerFromCharacter(vCharacter)

	local spawnPos = vCharacter.PrimaryPart.Position

	bomb = Instance.new("Part")
	bomb.Locked = true
	bomb.formFactor = 2
	bomb.Size = Vector3.new(1,0.4,1)
	bomb.Name = "Mine"
	bomb.Position = pos

	sound.Parent = bomb
	sound:Play()

	explosion:Stop()

	local mesh = Instance.new("SpecialMesh")
	mesh.MeshId = "http://www.roblox.com/asset/?id=28511843"
	mesh.TextureId = "http://www.roblox.com/asset/?id=28512114"
	mesh.Parent = bomb

	local creator_tag = Instance.new("ObjectValue")
	creator_tag.Value = vPlayer
	creator_tag.Name = "creator"
	creator_tag.Parent = bomb

	local script = Tool.BombBlink:clone()
	script.Parent = bomb
	script.Disabled = false

	bomb.Parent = game.Workspace
	bomb.Touched:connect(function(part)
		if part ~= Tool.Handle and part.Parent:FindFirstChild("Humanoid") == nil then
			bomb.Anchored = true
			bomb.CanCollide = false
		end
	end)

	game:GetService'Debris':AddItem(bomb, 60)
end

function blowUp()
	local vCharacter = Tool.Parent
	local vHumanoid = vCharacter:FindFirstChild'Humanoid'
	if not vHumanoid or vHumanoid:IsA'Humanoid'==false or vHumanoid.Health<=0 then return end

	local e = Instance.new("Explosion")
	e.BlastPressure = 12000
	e.BlastRadius = 12
	e.Parent = game.Workspace
	e.Position = bomb.Position
	sound:Stop()
	explosion.Parent = e
	explosion:Play()
	bomb:remove()
	
	bomb = nil
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
	planting = bomb==nil or bomb~=nil and bomb.Parent==nil

	if planting then
		plant(Tool.Handle.Position)
	else
		blowUp()
	end

	Tool.Enabled = true
end


script.Parent.Activated:connect(onActivated)