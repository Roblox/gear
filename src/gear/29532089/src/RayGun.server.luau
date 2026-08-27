local Tool = script.Parent
local enabled = true
local humanoid = nil
local equipped = false

local debris = game:GetService("Debris")

local reloadSound = Instance.new("Sound")
reloadSound.Name = "reloadSound"
reloadSound.SoundId = "http://www.roblox.com/asset/?id=25299064"
reloadSound.Parent = Tool.Handle
reloadSound.Volume = 2

local pbLeft = 4

local targetPart = Instance.new("Part")
targetPart.CanCollide = false
targetPart.Anchored = true
targetPart.formFactor = 2
targetPart.Transparency = 1
targetPart.Size = Vector3.new(3,0.4,3)

local decal = Instance.new("Decal")
decal.Texture = "http://www.roblox.com/asset/?id=29466325"
decal.Face = 1
decal.Parent = targetPart

local lastX = 0
local lastY = 0

function fire(v, targetPos)

	local vCharacter = Tool.Parent
	local vPlayer = game.Players:playerFromCharacter(vCharacter)

	local missile = Instance.new("Part")
	missile.Locked = true
	missile.Shape = 1
	missile.formFactor = 0
	missile.Size = Vector3.new(1,1,1)
	missile.CFrame = CFrame.new(missile.Position,v)

	local mesh = Instance.new("SpecialMesh")
	mesh.MeshId = "http://www.roblox.com/asset/?id=29456855"
	mesh.TextureId = "http://www.roblox.com/asset/?id=29456894"
	mesh.Scale = Vector3.new(1.6,1.6,1.6)
	mesh.Parent = missile

	local spawnPos = vCharacter.PrimaryPart.Position
	
	local PewPew = Tool.Handle:FindFirstChild("PewPew")

	if (PewPew == nil) then
		PewPew = Instance.new("Sound")
		PewPew.Name = "PewPew"
		PewPew.SoundId = "http://www.roblox.com/asset/?id=29504625"
		PewPew.Parent = Tool.Handle
		PewPew.Pitch = .85
		PewPew.Volume = 1
	end
	

	spawnPos  = spawnPos + (v * 10)

	
	missile.Position = spawnPos
	missile.BottomSurface = 0
	missile.Elasticity = 0.2
	missile.TopSurface = 0
	missile.Name = "PBJar"

	local bodyPos = Instance.new("BodyPosition")
	bodyPos.position = targetPos
	bodyPos.P = 200
	bodyPos.D = 100
	bodyPos.maxForce = Vector3.new(bodyPos.P,0,bodyPos.P)
	bodyPos.Parent = missile

	debris:AddItem(bodyPos,1.5)

	local force = Instance.new("BodyForce")
	force.Name = "BulletFloat"
	force.force = Vector3.new(0,720,0)
	force.Parent = missile

	debris:AddItem(force, 0.2)

	local creator_tag = Instance.new("ObjectValue")
	creator_tag.Value = vPlayer
	creator_tag.Name = "creator"
	creator_tag.Parent = missile
	
	local new_script = script.Parent.LaserBlast:clone()
	new_script.Disabled = false
	new_script.Parent = missile

	local pbScript = script.Parent.SlowWalkerScript:clone()
	pbScript.Parent = missile

	local inserter = script.Parent.InsertScript:clone()
	inserter.Parent = missile

	missile.Parent = game.Workspace

	PewPew:Play()

	pbLeft = pbLeft - 1

	if pbLeft == 3 then
		Tool.Handle.Mesh.MeshId = "http://www.roblox.com/asset/?id=29458281"
	elseif pbLeft == 2 then
		Tool.Handle.Mesh.MeshId = "http://www.roblox.com/asset/?id=29458298"
	elseif pbLeft == 1 then
		Tool.Handle.Mesh.MeshId = "http://www.roblox.com/asset/?id=29458313"
	elseif pbLeft == 0 then
		Tool.Handle.Mesh.MeshId = "http://www.roblox.com/asset/?id=29458345"
		reloadingGui()
		Tool.Handle.Mesh.MeshId = "http://www.roblox.com/asset/?id=29456213"
		pbLeft = 4
	end

end

function reloadingGui()

	if humanoid == nil then
		humanoid = script.Parent.Parent:FindFirstChild("Humanoid")
	end
	local reloader = Tool.ReloadingGui:clone()
	local player = game.Players:GetPlayerFromCharacter(humanoid.Parent)
	reloader.Parent = player.PlayerGui
	debris:AddItem(reloader,10)

	for i = 1, 100 do
		wait(0.05)
		if equipped then
			reloader.Frame.Visible = true
		else
			reloader.Frame.Visible = false
		end
		reloader.Frame.Size = UDim2.new(0,reloader.Frame.Size.X.Offset - 3,0,40)
	end

	if reloader ~= nil then
		reloader.Parent = nil
		reloader:remove()
	end

end


function gunUp()

end

function gunOut()

end

function isTurbo(character)
	return character:FindFirstChild("BoltHelm") ~= nil
end


function onActivated()
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

	local targetPos = humanoid.TargetPoint
	local lookAt = (targetPos - character.Head.Position).unit

	local reload = .1

	gunUp()
	fire(lookAt, targetPos)

	wait(reload)
	gunOut()
	wait(reload)

	enabled = true

end

function onEquipped()
	humanoid = Tool.Parent:FindFirstChild("Humanoid")

	-- load in meshes for faster switching
	for pbLeft = 4, 0, -1 do
		if pbLeft == 3 then
			Tool.Handle.Mesh.MeshId = "http://www.roblox.com/asset/?id=29458281"
		elseif pbLeft == 2 then
			Tool.Handle.Mesh.MeshId = "http://www.roblox.com/asset/?id=29458298"
		elseif pbLeft == 1 then
			Tool.Handle.Mesh.MeshId = "http://www.roblox.com/asset/?id=29458313"
		elseif pbLeft == 0 then
			Tool.Handle.Mesh.MeshId = "http://www.roblox.com/asset/?id=29458345"
			wait(0.1)
			Tool.Handle.Mesh.MeshId = "http://www.roblox.com/asset/?id=29456213"
			pbLeft = 4
		end
		wait()
	end
	
	equipped = true
	checkLaunchPos()
end

function onUnequipped()

	equipped = false
	targetPart.Parent = nil

end

function checkLaunchPos()

	targetPart.Parent = game.Workspace
	while equipped do
		if lastX ~= Tool.X.Value and lastY ~= Tool.Y.Value then
			targetPart.Position = humanoid.TargetPoint
		end
		lastX = Tool.X.Value
		lastY = Tool.Y.Value
		wait()
	end

end

script.Parent.Activated:connect(onActivated)
script.Parent.Unequipped:connect(onUnequipped)
script.Parent.Equipped:connect(onEquipped)
