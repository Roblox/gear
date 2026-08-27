--Rescripted by TakkeoHonorable
--Color refences to the game: Portal

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

function IsInTable(Table,Value)
	for _,v in pairs(Table) do
		if v == Value then
			return true
		end
	end
	return false
end

local Properties = {
	AssetId = "rbxassetid://",
	PortalSize = 10,--Scale of Portal
}

local Services = {
	Players = (game:FindService("Players") or game:GetService("Players")),
	Debris = (game:FindService("Debris") or game:GetService("Debris")),
	RunService = (game:FindService("RunService") or game:GetService("RunService")),
	ServerScriptService = (game:FindService("ServerScriptService") or game:GetService("ServerScriptService"))
}

local Tool = script.Parent
Tool.Enabled = true

local Handle,MousePos,Remote = Tool:WaitForChild("Handle"),Tool:WaitForChild("MouseLoc"),Tool:WaitForChild("Remote")

local Sounds = {
	Fire = Handle:WaitForChild("Fire"),
	Teleport = script:WaitForChild("Teleport")
}

local Components = {
	Tip = Handle:WaitForChild("Tip")
}

local Portal1,Portal2
local Player,Character,Humanoid 
local Died
function Equipped()
	Character = Tool.Parent
	Humanoid = Character:FindFirstChildOfClass("Humanoid")
	Player = Services.Players:GetPlayerFromCharacter(Character)
	
	if Humanoid then
		Died = Humanoid.Died:Connect(function()
			if Portal1 then
				Portal1:Destroy();Portal1 = nil
			end
			if Portal2 then
				Portal2:Destroy();Portal2 = nil
			end
		end)
	end
end



local Queue = {}

function MakePortal(Missile)
	
	
	local ray = Ray.new(Missile.Position,Missile.CFrame.lookVector*10)
	local hit,pos,nor = workspace:FindPartOnRayWithIgnoreList(ray,{Character})
	if Missile then Missile:Destroy() end
	if not hit then return end
	
	local PortalRing = Create("Part"){
		Locked = true,
		CanCollide = false,
		Anchored = true,
		Material = Enum.Material.Neon,
		TopSurface = Enum.SurfaceType.Smooth,
		BottomSurface = Enum.SurfaceType.Smooth,
		CFrame = CFrame.new(pos,pos+nor)*CFrame.Angles(0,math.rad(90),0),
		Color = (Portal1 and Color3.fromRGB(255,85,0)) or Color3.fromRGB(0,85,255),
		Name = "Portal",
		Size = Vector3.new(.5 ,1 * Properties.PortalSize ,1 * Properties.PortalSize),
		Shape = Enum.PartType.Cylinder,
		Parent = workspace,
	}
	
	local PortalWatch = script:WaitForChild("PortalWatch"):Clone()
	PortalWatch:WaitForChild("Tool").Value = Tool
	PortalWatch:WaitForChild("Creator").Value = Player
	PortalWatch.Parent = PortalRing
	PortalWatch.Disabled = false
	
	local Attachment = Create("Attachment"){
		Position = Vector3.new(1,1,1)*0,
		Name = "Center",
		Parent = PortalRing
	}
	
	local PortalParticle = script:WaitForChild("Effect"):Clone()
	PortalParticle.Parent = PortalRing
	PortalParticle.Color = ColorSequence.new((Portal1 and Color3.fromRGB(255,85,0)) or Color3.fromRGB(0,85,255))
	PortalParticle.Enabled = true
	 
	--[[local PortalRingMesh = Create("SpecialMesh"){
		MeshId = Properties.AssetId .. "3270017",
		TextureId = Properties.AssetId .. "3270066",
		Scale = Vector3.new(1,1,1)*Properties.PortalSize,
		Parent = PortalRing
	}]]
	
	PortalRing.Touched:Connect(function(hit)
		if not hit or not hit.Parent then return end
		local Hum,Torso,FF = hit.Parent:FindFirstChildOfClass("Humanoid"),hit.Parent:FindFirstChild("Torso") or hit.Parent:FindFirstChild("UpperTorso"),hit.Parent:FindFirstChildOfClass("ForceField")
		if not Hum or not Torso or IsInTable(Queue,Hum) or (FF and FF.Parent ~= Character)then return end
		
		local Destination = ((PortalRing == Portal1) and Portal2) or (PortalRing  == Portal2 and Portal1) or nil
		if Destination then
			Torso.CFrame = CFrame.new(Destination.CFrame.p)*(Torso.CFrame-Torso.CFrame.p)
			local SoundClone = Sounds.Teleport:Clone()
			SoundClone.Parent = Destination
			SoundClone:Play()
			coroutine.wrap(function()
				SoundClone.Ended:Wait()
				SoundClone:Destroy();SoundClone = nil
			end)()
		end
		
		coroutine.wrap(function()
			Queue[#Queue + 1] = Hum
			wait(1.5)
			for index,hum in pairs(Queue) do
				if hum == Hum then
					table.remove(Queue,index)
				end
			end
		end)()
	
	end)
	
	return PortalRing
end

function Activated()
	if not Tool.Enabled or Humanoid.Health <= 0 then return end
	Tool.Enabled = false
	local sucess,Pos = pcall(function() return MousePos:InvokeClient(Player) end)
	Pos = (sucess and Pos) or Vector3.new(0,0,0)

	local spawnPos = Components.Tip.WorldPosition + (Pos - Components.Tip.WorldPosition).Unit * 1.5
	
	local Direction = (Pos-Components.Tip.WorldPosition).Unit
	
	local missile = Create("Part"){
		CFrame = CFrame.new(spawnPos, Pos),
		Size = Vector3.new(1,1,3.5),
		Velocity = Direction * 80,
		BrickColor = BrickColor.new(23),
		Locked = true,
		Anchored = false,
		CanCollide = false,
		Shape = Enum.PartType.Block,
		BottomSurface = Enum.SurfaceType.Smooth,
		TopSurface = Enum.SurfaceType.Smooth,
		Name = "Portal",
	}

	local m = script.Mesh:Clone()	
	m.Parent = missile
	
	local Velo = Create("BodyVelocity"){
		MaxForce = Vector3.new(1,1,1) * math.huge,
		Velocity = Direction * 100,
		Parent = missile
	}
	
	missile.Parent = workspace
	missile:SetNetworkOwner(nil)
	
	Services.Debris:AddItem(missile,7)
	local Touch
	Touch = missile.Touched:Connect(function(hit)
		if not hit or not hit.Parent or not hit.CanCollide then return end
		local Hum = hit.Parent:FindFirstChildOfClass("Humanoid")
		if Hum then return end -- Don't connect on characters
		if Touch then Touch:Disconnect();Touch = nil end
		
		if not Portal1 then
			Portal1 = MakePortal(missile)
		elseif not Portal2 then
			Portal2 = MakePortal(missile)
		else -- Replace Portal2
			if Portal2 then
				Portal2:Destroy()
				Portal2 = nil
			end
			Portal2 = MakePortal(missile)
		end
			--print(Portal1,Portal2)
			if Portal1 and Portal2 then --Create Beam from Point A to point B
				--print("Both Portals Found")
				local Path = script:WaitForChild("Beam"):Clone()
				Path.Attachment0 = Portal1:FindFirstChildOfClass("Attachment")
				Path.Attachment1 = Portal2:FindFirstChildOfClass("Attachment")
				Path.Enabled = true
				Path.Parent = Portal2
			end
	end)
		
	Sounds.Fire:Play()
	wait(.25)
	Tool.Enabled = true
end



Tool.Equipped:Connect(Equipped)
Tool.Activated:Connect(Activated)

Remote.OnServerEvent:Connect(function(Client,Key)
	if Client ~= Player or not Key or not Tool.Enabled then return end
	if Key == Enum.KeyCode.X then
		--print("Closing all portals")
		if Portal1 then
			Portal1:Destroy();Portal1 = nil
		end
		if Portal2 then
			Portal2:Destroy();Portal2 = nil
		end
	end
end)