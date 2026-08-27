ball = script.Parent
local owner = ball.creator.Value
local GLib = require(206209239)
damage = 10

HitSound = Instance.new("Sound")
HitSound.Name = "HitSound"
HitSound.SoundId = "http://www.roblox.com/asset/?id=11945266"
HitSound.Parent = ball
HitSound.Volume = 1


firstWeld = false
local reporters = {}
function onTouched(cf, hit)
	if firstWeld == false then
		local char, player, humanoid = GLib.GetCharacter(hit)
		if hit:IsA("Part") and hit.Name ~= "StickyStep" and not GLib.IsTeammate(owner, player) then
			ball.Velocity = Vector3.new(0,0,0)
			ball.RotVelocity = Vector3.new(0,0,0)
			ball.CanCollide = true
			firstWeld = true
			if hit.Anchored then
				ball.Anchored = true
				ball.CFrame = cf
			else
				ball.CFrame = cf
				newWeld = Instance.new("Weld")
				newWeld.Name = "Glue"
				newWeld.Part0 = hit
				newWeld.Part1 = ball
				newWeld.C0 = hit.CFrame:toObjectSpace(cf)
				newWeld.Parent = game.Workspace
			end
	
			HitSound:Play()
			
			for index, sc in next, reporters do sc:Destroy() end
		end
	end
end

for index, player in next, game:GetService'Players':GetPlayers() do
	local sc = script.ContactReporter:Clone()
	sc.Block.Value = ball
	
	sc.Report.OnServerEvent:connect(function(client, cf, hit)
		if hit ~= nil and client == player then
			onTouched(cf, hit)
		end
	end)
	
	sc.Parent = player:FindFirstChild'PlayerGui'
	table.insert(reporters, sc)
	sc.Disabled = false
end

ball.BrickColor = BrickColor.new(1020)
wait(4)
ball.BrickColor = BrickColor.new(0,1,1)
wait(4)
ball.BrickColor = BrickColor.new(1,1,0)
wait(4)
ball.BrickColor = BrickColor.new(1,0,0)
wait(3)



--ball.SparkSound.Looped = false
--ball.SparkSound:Stop()
ball.Parent = nil