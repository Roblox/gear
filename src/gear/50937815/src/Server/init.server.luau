--Rescripted By TakeoHonorable

function Create(ty)
	return function(data)
		local obj = Instance.new(ty)
		for k, v in pairs(data) do
			if type(k) == 'number' then
				v.Parent = obj
			else
				obj[k] = v
			end
		end
		return obj
	end
end

local Tool = script.Parent
Tool.Enabled = true

local Handle = Tool:WaitForChild("Handle",math.huge)

local MouseLoc = Tool:WaitForChild("MouseInput",math.huge)

local BarrelPoints = {
	Barrel1 = Handle:WaitForChild("Barrel1",math.huge),
	Barrel2 = Handle:WaitForChild("Barrel2",math.huge),
	Barrel3 = Handle:WaitForChild("Barrel3",math.huge)
}

local Sounds = {
	Shoot = Handle:WaitForChild("Shoot")
}

local Grips = {
	Reg = Tool:WaitForChild("Reg",math.huge).Value
}
Tool.Grip = Grips.Reg

local Services = {
	Players = (game:FindService("Players") or game:GetService("Players")),
	Debris = (game:FindService("Debris") or game:GetService("Debris")),
	RunService = (game:FindService("RunService") or game:GetService("RunService")),
	ServerScriptService = (game:FindService("ServerScriptService") or game:GetService("ServerScriptService"))
}

local function Wait(para) -- bypasses the latency
	local Initial = tick()
	repeat
		Services.RunService.Heartbeat:Wait()
	until tick()-Initial >= para
end

local ProjPart = Create("Part"){
	Size = Vector3.new(1,1,1)*1.5,
	Transparency = 0.4,
	Shape = Enum.PartType.Ball,
	Material = Enum.Material.Glass,
	Color = Color3.new(1,1,1),
	Locked = true,
	CanCollide = false,
	Name = "Projectile",
	Anchored = false,
	TopSurface = Enum.SurfaceType.Smooth,
	BottomSurface = Enum.SurfaceType.Smooth
}


local Player,Character,Humanoid

function Equipped()
	Character = Tool.Parent
	Player = Services.Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChildOfClass("Humanoid")
end

function Activated()
	if not Player or not Humanoid or Humanoid.Health <= 0 or not Tool.Enabled then return end
	Tool.Enabled = false
	for _,point in pairs(BarrelPoints) do
		if Tool:IsDescendantOf(Character) then
			local Sucess,Pos = pcall(function() return MouseLoc:InvokeClient(Player) end)
			Pos = (Sucess and Pos) or Vector3.new(0,0,0)
			local SpawnPos = point.WorldPosition + (Pos - point.WorldPosition).Unit * 4
			local Proj,ProjScript = ProjPart:Clone(),script:WaitForChild("ProjectileScript",math.huge):Clone()
			
			Proj.Position = SpawnPos
			
			local Velo = Create("BodyVelocity"){
				MaxForce = Vector3.new(1,1,1) * math.huge,
				Velocity = (Pos - point.WorldPosition).Unit * 300,
				Parent = Proj
			}
			
			Proj.Parent = workspace
			ProjScript:WaitForChild("Creator",math.huge).Value = Player
			ProjScript.Parent = Proj
			ProjScript.Disabled = false
			Proj:SetNetworkOwner(nil)
			Services.Debris:AddItem(Proj,1)
			Sounds.Shoot:Play()
			Tool.Grip = Tool.Grip * CFrame.Angles(math.rad(-20),0,0)
			local particle = point:FindFirstChildOfClass("ParticleEmitter")
			if particle then
				particle:Emit(particle.Rate)
			end
			Wait(1/30)
			Tool.Grip = Grips.Reg
		end
	end
	wait(1.5)
	Tool.Enabled = true
end

Tool.Equipped:Connect(Equipped)
Tool.Activated:Connect(Activated)