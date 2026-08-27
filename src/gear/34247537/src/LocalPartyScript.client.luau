local Tool = script.Parent
local torso = nil
local partyRadius = 50
local mouseCon = nil
local gui = nil
local player = nil
local firstTime = true

local sound = Instance.new("Sound")
sound.SoundId = "http://www.roblox.com/asset/?id=33810432"
sound.Looped = true

local debris = game:GetService("Debris")

function onEquippedLocal(mouse)
	torso = Tool.Parent:FindFirstChild("Torso")
	gui = Tool.PartyGui:clone()
	player = game.Players:GetPlayerFromCharacter(Tool.Parent)
	mouseCon = mouse.Button1Down:connect(onActivated)
end

function onUnequippedLocal()
	mouseCon:disconnect()
	gui:remove()
end

Tool.Equipped:connect(onEquippedLocal)
Tool.Unequipped:connect(onUnequippedLocal)


function findClosePlayers()

	local players = game.Players:GetChildren()
	local closePlayers = {}
	for i = 1, #players do
		if (players[i].Character.Torso.Position - torso.Position).magnitude < partyRadius then
			table.insert(closePlayers, players[i].Character)
		end
	end

	return closePlayers

end

local enabled = false
function onActivated()

	if enabled then return end
	enabled = true

	local fire = Instance.new("Fire")
	fire.Heat = 25
	fire.Size = 2
	fire.Color = Color3.new(1,153/255,51/255)
	fire.Parent = Tool.Handle

	wait(2)

	local noGo = false
	local part = Instance.new("Part")
	part.Size = Vector3.new(20,13.6,20)
	part.Transparency = 1
	part.CanCollide = false
	part.Position = Vector3.new( torso.Position.x,torso.Position.y + 10, torso.Position.z)
	local bodyForce = Instance.new("BodyForce")
	bodyForce.force = Vector3.new(0,1200000,0)
	bodyForce.Parent = part
	part.Touched:connect(function()
		noGo = true
	end)
	part.Parent = game.Workspace
	wait(0.1)
	part:remove()

	fire:remove()

	if noGo then
		if player then
			gui.Parent = player.PlayerGui
		end
		Tool.Handle.Fail:Play()
		wait(3)
		gui.Parent = nil
		enabled = false
		return
	end

	local explosion = Instance.new("Explosion")
	explosion.BlastPressure = 0
	explosion.BlastRadius = 15
	explosion.Position = torso.Position
	explosion.Parent = game.Workspace

	local explosionSound = Instance.new("Sound")
	explosionSound.SoundId = "rbxasset://sounds\\Rocket shot.wav"
	explosionSound.Parent = Tool.Handle
	explosionSound:Play()
	debris:AddItem(explosionSound,2)

	local partyPeople = findClosePlayers()
	for i = 1, #partyPeople do
		local scripter = Tool.DanceScript:clone()
		scripter.Parent = partyPeople[i]
		local animator = Tool.partyanim:clone()
		animator.Parent = partyPeople[i]
		scripter.Disabled = false
	end


	--This call will cause a "wait" until the data comes back
	local root = game:GetService("InsertService"):LoadAsset(33743813)

	local instances = root:GetChildren()
	if #instances == 0 then
		root:Remove()
		return
	end
	
	root = root:FindFirstChild("DanceFloor")
	root.Parent = game.Workspace
	local children = root:GetChildren()
	debris:AddItem(root,18)

	for i = 1, #children do
		if children[i].className == "Part" or children[i].className == "TrussPart" then
			children[i].CanCollide = false
			if children[i].BrickColor == BrickColor.new("Really black") then
				for j = 1, 5 do
					local sparkles = Instance.new("Sparkles")
					if i == 1 then sparkles.SparkleColor = Color3.new(1,51/255,154/255)
					elseif j == 2 then sparkles.SparkleColor = Color3.new(51/255,205/255,51/255)
					elseif j == 3 then sparkles.SparkleColor = Color3.new(1,1,0)
					elseif j == 4 then sparkles.SparkleColor = Color3.new(0,51/255,205/255)
					elseif j == 5 then sparkles.SparkleColor = Color3.new(1,0,0) 
						sound.Parent = children[i]
						-- ensures music plays on first try
						if firstTime then wait(1) end
						sound:Play()
						firstTime = false
					end
					sparkles.Parent = children[i]
				end
			end
		end
	end

	
	root:MoveTo(Vector3.new(torso.Position.x,torso.Position.y,torso.Position.z))

	local bodyPos = Instance.new("BodyPosition")
	bodyPos.position = Vector3.new(torso.Position.x, torso.Position.y + 10, torso.Position.z)
	bodyPos.P = 10000
	bodyPos.D = bodyPos.D
	bodyPos.maxForce = Vector3.new(bodyPos.P,bodyPos.P,bodyPos.P)
	bodyPos.Parent = torso

	wait(1.5)

	bodyPos:remove()

	for i = 1, #children do
		if children[i].className == "Part" or children[i].className == "TrussPart" then
			children[i].CanCollide = true
		end
	end


	wait(20)
	if sound then sound:Stop() end
	enabled = false

end

