local tool = script.Parent
local handle = tool.Handle
local remote = script.Parent.Remote
local spawns = remote.Spawn
local meshes = script.Parent.Meshes:GetChildren()
local balligator
local last = 0

RemoverScript = script:WaitForChild("RemoverScript")

local spawning = false

function Colorize(ball)
	if ball:FindFirstChild("Mesh") then
		ball.Mesh:Destroy()
	end
	meshes[math.random(1,#meshes)]:clone().Parent = ball
end

function SpawnGator(player)
	local target = player.Character
	local torso = target:FindFirstChild("HumanoidRootPart")
	if not torso then return end
	
	local gator = handle:clone()
	gator.CanCollide = true
	gator.Transparency = 0
	handle.Transparency = 1
	gator.Velocity = torso.CFrame.lookVector*10 + Vector3.new(0,100,0)
	
	local model = Instance.new("Model")
	model.Name = "Balligator"
	model.Parent = player.Character
	gator.Parent = model
	
	local RemoverScriptCopy = RemoverScript:Clone()
	local ToolValue = Instance.new("ObjectValue")
	ToolValue.Name = "Tool"
	ToolValue.Value = tool
	ToolValue.Parent = model
	local Creator = Instance.new("ObjectValue")
	Creator.Name = "Creator"
	Creator.Value = player
	Creator.Parent = model
	RemoverScriptCopy.Disabled = false
	RemoverScriptCopy.Parent = model
	
	wait(1/2)
	
	local ball = Instance.new("Part")
	ball.Size = Vector3.new(2,2,2)
	ball.Shape = "Ball"
	Colorize(ball)
	ball.BrickColor = BrickColor.new("Neon orange")
	ball.CFrame = CFrame.new(gator.Position - Vector3.new(0,1.2,0))
	local bv = Instance.new("BodyVelocity")
	bv.maxForce = Vector3.new(4000,0,4000)
	bv.velocity = Vector3.new()
	bv.Parent = ball
	local sound = Instance.new("Sound")
	sound.SoundId = "rbxassetid://277504165"
	sound.Parent = ball
	
	local bg = Instance.new("BodyGyro")
	bg.maxTorque = Vector3.new(40000,40000,40000)
	bg.Parent = gator
	local bp = Instance.new("BodyPosition")
	bp.maxForce = Vector3.new(400000,400000,400000)
	bp.D = 100
	bp.Parent = gator

	ball.Parent = model
	local last = 0
	
	ball:SetNetworkOwner(player)
	gator:SetNetworkOwner(player)
return model end

tool.Unequipped:connect(function()
	if balligator then
		balligator:Destroy()
	end
	handle.Transparency = 0
end)

function spawns.OnServerInvoke(player)
	if not spawning then
		spawning = true
		if balligator then
			balligator:Destroy()
		end
		balligator = SpawnGator(player)
		spawning = false
	end
return balligator end