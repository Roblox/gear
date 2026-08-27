tool = script.Parent
local player = game.Players.LocalPlayer

wait()
local remote = script.Parent:WaitForChild("Remote")
local spawn = remote.Spawn
local last = 0

local model, gator, ball

function Jump(ball)
	ball.Velocity = Vector3.new(ball.Velocity.x, math.random(25,32), ball.Velocity.z)
	last = game.Workspace.DistributedGameTime
	if ball:FindFirstChild("Sound") then
		ball.Sound:Play()
	end
end

tool.Equipped:connect(function(mouse)
	mouse.Button1Down:connect(function()
		model = spawn:InvokeServer()
		gator, ball = model:WaitForChild("Handle"), model:WaitForChild("Part")
		local close = false
		while model and model.Parent == player.Character do
			local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
			if not rootPart then break end
			gator.BodyPosition.position = ball.Position + Vector3.new(0,1.15,0)
			--gator.Position = ball.Position + Vector3.new(0,1.15,0)
			local ang = math.atan2(ball.Velocity.x, ball.Velocity.z)
			gator.BodyGyro.cframe = CFrame.Angles(0,ang + math.pi,0)
			local rel = (rootPart.Position - ball.Position)
			if 6 > rel.magnitude then
				close = true
			end
			if 3 < rel.magnitude and rel.magnitude < 7 and close then
				ball.BodyVelocity.velocity = Vector3.new(rel.z, 0, -1*rel.x).unit*3
			else
				close = false
				ball.BodyVelocity.velocity = rel.unit*math.min(rel.magnitude*1.5 - 6, 17)
			end
			wait()
			if math.random(1,100) == 1 and (game.Workspace.DistributedGameTime - last) > 1 then
				Jump(ball)
			end
		end
	end)
end)