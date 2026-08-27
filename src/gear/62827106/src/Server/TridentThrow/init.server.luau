
local Self = script

local Creator,Velocity = Self:WaitForChild("Creator"),Self:WaitForChild("Direction")

local Cframe,Angles,pi,wrap,Pairs,Instant,huge = CFrame.new,CFrame.Angles,math.pi,coroutine.wrap,pairs,Instance.new,math.huge

local Trident = Self.Parent

local Hit = false

local Gyro = Instant("BodyGyro")

local Velo = Instant("BodyVelocity")

local R = (game:FindService("RunService") or game:GetService("RunService"))

local Players = (game:FindService("Players") or game:GetService("Players"))

local Debris = (game:FindService("Debris") or game:GetService("Debris"))

local Sounds = {
	HumanoidHit = Self:WaitForChild("HumanoidHit"),
	Throw = Self:WaitForChild("Throw"),
	Clash = Self:WaitForChild("Clash")
}

Sounds.Throw.Parent = Trident
Sounds.Throw:Play()

Velo.MaxForce = Vector3.new(1,1,1) * huge
Velo.Velocity = Velocity.Value
Velo.Parent = Trident

Gyro.MaxTorque = Vector3.new(1,1,1) * huge
Gyro.D = 10^3
Gyro.CFrame = Trident.CFrame
Gyro.Parent = Trident

function IsTeamMate(Player1, Player2)
	return (Player1 and Player2 and not Player1.Neutral and not Player2.Neutral and Player1.TeamColor == Player2.TeamColor)
end

function TagHumanoid(humanoid, player)
	local Creator_Tag = Instant("ObjectValue")
	Creator_Tag.Name = "creator"
	Creator_Tag.Value = player
	Debris:AddItem(Creator_Tag, 2)
	Creator_Tag.Parent = humanoid
end

function UntagHumanoid(humanoid)
	for i, v in Pairs(humanoid:GetChildren()) do
		if v:IsA("ObjectValue") and v.Name == "creator" then
			v:Destroy()
		end
	end
end

wrap(function()
	repeat
		
		Gyro.CFrame = Cframe(Trident.Position , Trident.Velocity) * Angles(pi,0,0)
		
		R.Heartbeat:Wait()
	
	until Trident.Anchored

end)

delay(20,function()
	
	if not Hit and Trident then
		
		Trident:Destroy()
	
	end

end)

local Touch

Touch = Trident.Touched:Connect(function(hit)
	if Hit or not hit or not hit.Parent or not hit.CanCollide then return end
	
	if hit:FindFirstAncestorWhichIsA("Tool") or hit:FindFirstAncestorWhichIsA("Accoutrement") or hit:IsDescendantOf(Creator.Value) then return end
	
	local Hum, FF = hit.Parent:FindFirstChildOfClass("Humanoid"), hit.Parent:FindFirstChildOfClass("ForceField")
	
	--if Hum == CreatorHumanoid.Value then return end
	
	Hit = true
	
	if Touch then
		Touch:Disconnect()
	end
	
	Sounds.Clash.Parent = Trident
	Sounds.Clash:Play()
	
	Debris:AddItem(Trident,10)
	
	if Velo then
		Velo:Destroy();Velo = nil
	end
	
	if Gyro then
		Gyro:Destroy();Gyro = nil
	end
	
	--print(hit.Name)
	
	local cframe = Trident.CFrame
	
	local Attach = Instant("WeldConstraint")
	
	Attach.Part0 = Trident
	Attach.Part1 = hit
	
	Attach.Parent = Trident
	
	
	if Players:GetPlayerFromCharacter(hit.Parent) == Players:GetPlayerFromCharacter(Creator.Value) or IsTeamMate(Players:GetPlayerFromCharacter(Creator.Value),Players:GetPlayerFromCharacter(hit.Parent)) then return end
	
	if not Hum or Hum.Health <= 0 or FF then return end
	
	Sounds.HumanoidHit.Parent = Trident
	Sounds.HumanoidHit:Play()
	
	UntagHumanoid(Hum)
	TagHumanoid(Hum,Players:GetPlayerFromCharacter(Creator.Value))
	Hum:TakeDamage(Hum.MaxHealth)
	
	if Hum.Health <= 0 then
		--Skelify them!
		
		local Skelify = Self:WaitForChild("Skelify"):Clone()
		
		Skelify.Parent = Hum.Parent
		
		Skelify.Disabled = false
		
	end
	
	
	
end)