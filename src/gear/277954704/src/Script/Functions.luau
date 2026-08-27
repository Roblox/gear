--Made by Luckymaxer

Players = game:GetService("Players")
Debris = game:GetService("Debris")

RbxUtility = LoadLibrary("RbxUtility")
Create = RbxUtility.Create

BaseUrl = "http://www.roblox.com/asset/?id="

Functions = {
	
	GetVector = (function(cframe, Direction)
		local px, py, pz, xx, yx, zx, xy, yy, zy, xz, yz, zz = cframe:components()
		
		local Position = Vector3.new(px, py, pz)
		local Right = Vector3.new(xx, xy, xz)
		local Top = Vector3.new(yx, yy, yz)
		local Back = Vector3.new(zx, zy, zz)
		
		return (
			(Direction == Enum.NormalId.Top and Top) or
			(Direction == Enum.NormalId.Back and Back) or
			(Direction == Enum.NormalId.Right and Right)
		)
	end),
	
	CFrameFromTopBack = (function(at, top, back)
		local Right = top:Cross(back)
		return CFrame.new(
			at.x, at.y, at.z,
			Right.x, top.x, back.x,
			Right.y, top.y, back.y,
			Right.z, top.z, back.z
		)
	end),
	
	CreateTank = (function(Player)
		local Body = Create("Part"){
			Name = "Torso",
			Transparency = 1,
			Shape = Enum.PartType.Block,
			FormFactor = Enum.FormFactor.Custom,
			Material = Enum.Material.Plastic,
			TopSurface = Enum.SurfaceType.Smooth,
			BottomSurface = Enum.SurfaceType.Smooth,
			Size = Vector3.new(1.75, 1, 2.5),
			CanCollide = true,
			Locked = true,
			Create("SpecialMesh"){
				Scale = Vector3.new(1, 1, 1),
				MeshId = (BaseUrl .. "272605197"),
				TextureId = (BaseUrl .. "272605241"),
			},
			Create("BodyGyro"){
				maxTorque = Vector3.new(math.huge, math.huge, math.huge),
				cframe = CFrame.new(0, 0, 0),
			},
			Create("Sound"){
				Name = "Fire",
				SoundId = (BaseUrl .. "81116734"),
				Pitch = 1,
				Volume = 0.5,
				Looped = false,
			},
			Create("Sound"){
				Name = "Idle",
				SoundId = (BaseUrl .. "82229695"),
				Pitch = 0.6,
				Volume = 0.2,
				Looped = true,
			},
			Create("Sound"){
				Name = "Start",
				SoundId = (BaseUrl .. "82229695"),
				Pitch = 0.8,
				Volume = 1.0,
			},
			Create("Sound"){
				Name = "Drive",
				SoundId = (BaseUrl .. "82229584"),
				Pitch = 1.5,
				Volume = 1.0,
				Looped = true,
			},
		}
		
		local BodyGyro = Body:FindFirstChild("BodyGyro")
		local Sounds = {
			Fire = Body:FindFirstChild("Fire"),
			Idle = Body:FindFirstChild("Idle"),
			Start = Body:FindFirstChild("Start"),
			Drive = Body:FindFirstChild("Drive"),
		}
		
		local Turret = Create("Part"){
			Name = "Head",
			Shape = Enum.PartType.Block,
			FormFactor = Enum.FormFactor.Custom,
			Material = Enum.Material.Plastic,
			TopSurface = Enum.SurfaceType.Smooth,
			BottomSurface = Enum.SurfaceType.Smooth,
			Size = Vector3.new(0.75, 0.5, 2.25),
			CanCollide = false,
			Locked = true,
			Transparency = 1,
			Create("SpecialMesh"){
				Scale = Vector3.new(1, 1, 1),
				MeshId = (BaseUrl .. "273775095"),
				TextureId = (BaseUrl .. "272605241"),
			},
		}
		
		local BodyPart = Body:Clone()
		BodyPart.Name = "Part"
		BodyPart.Transparency = 0
		BodyPart.Size = Vector3.new(0.2, 0.2, 0.2)
		BodyPart.CanCollide = false
		for i, v in pairs(BodyPart:GetChildren()) do
			if not v:IsA("DataModelMesh") then
				v:Destroy()
			end
		end
		local BodyPartWeld = Create("Weld"){
			Part0 = Body,
			Part1 = BodyPart,
			C0 = (CFrame.new(0, 0, -0.9) * CFrame.Angles((math.pi / 2), 0, 0)),
			Parent = BodyPart,
		}
		
		local TurretPart = Turret:Clone()
		TurretPart.Name = "Part"
		TurretPart.Transparency = 0
		TurretPart.Size = Vector3.new(0.2, 0.2, 0.2)
		TurretPart.CanCollide = false
		local TurretPartWeld = Create("Weld"){
			Part0 = Turret,
			Part1 = TurretPart,
			C0 = (CFrame.new(-0.25, -1, 0) * CFrame.Angles((math.pi / 2), 0, 0)),
			C1 = CFrame.new(-0.25, 0, 1.25),
			Parent = TurretPart,
		}
		
		local Wheels = {
			{C0 = CFrame.new(-0.85, -0.2, 0.85), C1 = CFrame.new(0, 0, 0)},
			{C0 = CFrame.new(-0.85, -0.2, 0), C1 = CFrame.new(0, 0, 0)},
			{C0 = CFrame.new(-0.85, -0.2, -0.85), C1 = CFrame.new(0, 0, 0)},
			{C0 = (CFrame.new(0.85, -0.2, 0.85) * CFrame.Angles(0, 0, 0)), C1 = (CFrame.new(0, 0, 0) * CFrame.Angles(0, -math.pi, 0))},
			{C0 = (CFrame.new(0.85, -0.2, 0) * CFrame.Angles(0, 0, 0)), C1 = (CFrame.new(0, 0, 0) * CFrame.Angles(0, -math.pi, 0))},
			{C0 = (CFrame.new(0.85, -0.2, -0.85) * CFrame.Angles(0, 0, 0)), C1 = (CFrame.new(0, 0, 0) * CFrame.Angles(0, -math.pi, 0))},
		}
		
		local WheelParts = {}
		for i, v in pairs(Wheels) do
			local Wheel = Create("Part"){
				Name = "Wheel",
				Shape = Enum.PartType.Block,
				FormFactor = Enum.FormFactor.Custom,
				Material = Enum.Material.Plastic,
				TopSurface = Enum.SurfaceType.Smooth,
				BottomSurface = Enum.SurfaceType.Smooth,
				Size = Vector3.new(0.2, 0.2, 0.2),
				CanCollide = false,
				Create("SpecialMesh"){
					Scale = Vector3.new(1, 1, 1),
					MeshId = (BaseUrl .. "273788737"),
					TextureId = (BaseUrl .. "272605241"),
				},
			}
			local Motor = Create("Motor6D"){
				Part0 = BodyPart,
				Part1 = Wheel,
				C0 = (v.C0 * CFrame.Angles(0, (math.pi / 2), 0)),
				C1 = (v.C1 * CFrame.Angles(0, -(math.pi / 2), 0)),
				Parent = Wheel,
			}
			table.insert(WheelParts, {Part = Wheel, Motor = Motor})
		end
		
		local Humanoid = Create("Humanoid"){
			PlatformStand = true,
		}
		
		local TurretAttach = Create("Weld"){
			Name = "Neck",
			Parent = Body,
			Part0 = Body,
			Part1 = Turret,
			C0 = CFrame.new(0, 0.65, -0.25),
			C1 = CFrame.new(0, 0.5, 0),
		}
		
		local Model = Create("Model"){
			Name = "Tank",
		}
		
		local Creator = Create("ObjectValue"){
			Name = "Creator",
			Value = Player,
			Parent = Model,
		}
		
		Body.Parent = Model
		Turret.Parent = Model
		BodyPart.Parent = Model
		TurretPart.Parent = Model
		Humanoid.Parent = Model
			
		for i, v in pairs(WheelParts) do
			v.Part.Parent = Model
		end
		
		Humanoid.MaxHealth = 500
		Humanoid.Health = Humanoid.MaxHealth
	
		return {
			Model = Model,
			Body = Body,
			Wheels = WheelParts,
			BodyGyro = BodyGyro,
			Sounds = Sounds,
			Turret = Turret,
			TurretAttach = TurretAttach,
			Humanoid = Humanoid,
		}
		
	end),
	
	DoCastDown = (function(Tank, Offset, Dir)
		Dir = (Dir or Vector3.new(0, -1, 0))
		local CastFrom = ((Tank.Body.CFrame * Offset).p - Dir * 2.5)
		local ray = Ray.new(CastFrom, Dir * 999)
		local Part, at = game:GetService("Workspace"):FindPartOnRay(ray, Tank.Model)
		if Part and (not Part.CanCollide or Part.Transparency == 1) then
			local Parts = {Tank.Body, Tank.Turret}
			while Part and (not Part.CanCollide or Part.Transparency == 1) do
				Parts[#Parts + 1] = Part
				Part, at = game:GetService("Workspace"):FindPartOnRayWithIgnoreList(ray, Parts)
			end
		end
		return Part, at, ((CastFrom - at).magnitude - 2.5)
	end),
	
	Decay = (function(Number)
		return (1 - math.sqrt(1 - Number))
	end),
	
	Clamp = (function(n, min, max)
		return math.max(math.min(max, n), min)
	end),
	
	Sign = (function(n)
		return (((n >= 0) and 1) or -1)
	end),

}

return Functions