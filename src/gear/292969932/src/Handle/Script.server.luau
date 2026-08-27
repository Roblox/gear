local master
local mode = "follow"
local bg
local bp
local evolved = false
local jump = Vector3.new(0,0,0)

function Command(msg)
	msg = msg:lower()
	if msg == "stay" then
		mode = "stay"
	elseif msg == "follow" then
		mode = "follow"
	elseif msg == "evolve" then
		Evolve()
	elseif msg == "jump" then
		jump = Vector3.new(0,2,0)
		bp.maxForce = Vector3.new(999999,999999,999999)
		wait(1)
		jump = Vector3.new(0,0,0)
		bp.maxForce = Vector3.new(999999,0,999999)
	end
end

function Init()
	wait(3)
	game:GetService("Chat"):Chat(script.Parent,"Hi, I'm Rukiryo's Cat!")
	wait(2)
	game:GetService("Chat"):Chat(script.Parent,"Say follow to make me follow, and stay to make me stay!")
	wait(3)
	game:GetService("Chat"):Chat(script.Parent,"There's a secret word to make me evolve. I wonder what it is?")
	while wait(0.2) and master ~= nil and master.Parent ~= nil and master.Character ~= nil and master.Character.Parent ~= nil do
		if mode == "follow" then
			bg.cframe = CFrame.new(script.Parent.Position, Vector3.new(master.Character.HumanoidRootPart.Position.X, script.Parent.Position.Y, master.Character.HumanoidRootPart.Position.Z))
			local vecBetween = (master.Character.HumanoidRootPart.Position - script.Parent.Position)
			local desired = script.Parent.Position + (vecBetween - vecBetween.unit * 10)
			bp.position = desired + jump
		end
	end
	script.Parent:Destroy()
end

function Evolve()
	if evolved then return end
	evolved = true
	mode = "stay"
	script.Parent.ParticleEmitter.Color = ColorSequence.new(Color3.new(1,0,0))
	script.Parent.ParticleEmitter.VelocitySpread = 100
	script.Parent.ParticleEmitter.Rate = 300
	script.Parent.ParticleEmitter.Speed = NumberRange.new(5)
	script.Parent.ParticleEmitter.Enabled = true
	wait(5)
	script.Parent.Mesh.VertexColor = Vector3.new(1, 0.3, 0.3)
	script.Parent.Mesh.Scale = Vector3.new(10, 10, 10)
	script.Parent.Size = Vector3.new(11,11,11)
	script.Parent.ParticleEmitter.Enabled = false
	wait(4)
	mode = "follow"
end

script.Parent.RemoteEvent.OnServerEvent:connect(function(player, args)
	if args[1] == "drop" then
		master = player
		local pos = script.Parent.Position
		local char = player.Character
		char["Right Arm"].RightGrip:Destroy()
		script.Parent.Parent = player.Character
		script.Parent.CanCollide = true
		script.Parent.CFrame = CFrame.new(pos)
		player.Character.RukiryoCat:Destroy()
		wait(2)
		script.Parent.ParticleEmitter.Enabled = true
		wait(4)
		script.Parent.Size = Vector3.new(6,6,6)
		script.Parent.Mesh.Scale = Vector3.new(5,5,5)
		script.Parent.ParticleEmitter.Enabled = false
		bg = Instance.new("BodyGyro",script.Parent)
		bp = Instance.new("BodyPosition", script.Parent)
		bp.maxForce = Vector3.new(999999,0,999999)
		bp.P = 3000
		bp.position = script.Parent.Position
		bg.maxTorque = Vector3.new(0.1,0.1,0.1)
		bg.cframe = CFrame.new(script.Parent.Position, Vector3.new(master.Character.HumanoidRootPart.Position.X, script.Parent.Position.Y, master.Character.HumanoidRootPart.Position.Z))
		player.Chatted:connect(function(msg) Command(msg) end)
		Init()
	end
end)