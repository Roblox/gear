
local Creator = script:WaitForChild("Creator",5)

local Tool = script:WaitForChild("Tool",5).Value

local PeriFormation = script:WaitForChild("PeriFormation",5):GetChildren()

if not Creator then script:Destroy() return end

local Humanoid,Root = Creator.Value.Character:FindFirstChildOfClass("Humanoid"),Creator.Value.Character:WaitForChild("HumanoidRootPart",5)

if not Humanoid or not Root then script:Destroy() return end

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

local Services = {
	Players = (game:FindService("Players") or game:GetService("Players")),
	TweenService = (game:FindService("TweenService") or game:GetService("TweenService")),
	RunService = (game:FindService("RunService") or game:GetService("RunService")),
	Debris = (game:FindService("Debris") or game:GetService("Debris")),
	TweenService = (game:FindService("TweenService") or game:GetService("TweenService"))
}

local Properties = {
BaseUrl = "rbxassetid://"
}

local Deleteables = {}

local Periastron = Create("Part"){
	Locked = true,
	CanCollide = false,
	Anchored = true,
	Size = Vector3.new(1, 0.6, 5.2)*10,
	Material = Enum.Material.Neon,
	Color = Color3.new(1,1,1)
}

local PeriastronMesh = Create("SpecialMesh"){
	MeshType = Enum.MeshType.FileMesh,
	MeshId = Properties.BaseUrl.."80557857",
	Scale = Vector3.new(1,1,1)*10,
	Parent = Periastron
}

--[[local Surfaces = {"Front","Back","Left","Right","Top","Bottom"}

local BeamLighting = Create("SurfaceLight"){
	Color = Color3.fromRGB(1, 1, 1),
	Angle = 180,
	Enabled = true,
	Range = 100,
	Shadows = false
}

local SurfaceLights = {}]]

local rad = math.rad

local info = TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.In, 0, false, 0)

local Charging = true

local Animation = script:WaitForChild("Animations",5):WaitForChild(Humanoid.RigType.Name,10):WaitForChild("Release")



function IsTeamMate(Player1, Player2)
	return (Player1 and Player2 and not Player1.Neutral and not Player2.Neutral and Player1.TeamColor == Player2.TeamColor)
end

function TagHumanoid(humanoid, player)
	local Creator_Tag = Instance.new("ObjectValue")
	Creator_Tag.Name = "creator"
	Creator_Tag.Value = player
	Services.Debris:AddItem(Creator_Tag, 2)
	Creator_Tag.Parent = humanoid
end

function UntagHumanoid(humanoid)
	for i, v in pairs(humanoid:GetChildren()) do
		if v:IsA("ObjectValue") and v.Name == "creator" then
			v:Destroy()
		end
	end
end


local ReleaseAnim = Humanoid:LoadAnimation(Animation)
		ReleaseAnim:Play(nil,nil,2)
		local RainPeri = Periastron:Clone();RainPeri.Name = "RainbowPeriastron";RainPeri.Size = RainPeri.Size/10
		RainPeri:FindFirstChildOfClass("SpecialMesh").TextureId = Properties.BaseUrl .."157345185"
		RainPeri.CanCollide = false
		RainPeri.CFrame = CFrame.new(Tool:WaitForChild("Handle",5).CFrame.p)*CFrame.Angles(rad(90),0,0);RainPeri.Parent = workspace
		RainPeri.Anchored = true
		
		local Loc = Root.CFrame.p+Vector3.new(0,55,0)
		local Orientation = Loc + (Creator.Value.Character.PrimaryPart.CFrame.lookVector*-2)
		local PartSizeTween = Services.TweenService:Create(RainPeri,info,{Size = RainPeri.Size,CFrame = CFrame.new(Loc,Orientation)})
		local MeshSizeTween = Services.TweenService:Create(RainPeri:FindFirstChildOfClass("SpecialMesh"),info,{Scale = Vector3.new(1,1,1)*10})
		MeshSizeTween:Play()
		PartSizeTween:Play()PartSizeTween.Completed:Wait()
		local PeriRangers = {} --GO GO PERI RANGERS!!!!
		local FormationModel = Create("Model"){
			Name = "PeriRangers",
			Parent = workspace
		}
		Humanoid.Died:Connect(function()--remove the Giant Peri Formation if you happen to die
			FormationModel:Destroy()
			RainPeri:Destroy()
			for _,deletable in pairs(Deleteables) do
				deletable:Destroy()
			end
			script:Destroy()
			return
		end)
		local CenterPiece = Create("Part"){
			Anchored = true,
			CanCollide = false,
			Transparency = 1,
			Size = Vector3.new(1,1,1)*2,
			CFrame = RainPeri.CFrame*CFrame.new(0,0,-RainPeri.Size.z/2),
			Parent = FormationModel
		}
		FormationModel.PrimaryPart = CenterPiece 
		local spin = 0
		local amount = 10
		spawn(function()
			repeat
				RainPeri.CFrame = CFrame.new(Loc,Loc + (Root.CFrame.lookVector*-2))
				FormationModel:SetPrimaryPartCFrame((RainPeri.CFrame*CFrame.new(0,0,-RainPeri.Size.z/2))*CFrame.Angles(0,0,rad(spin)))
				Services.RunService.Stepped:Wait()
				spin = spin+amount
			until not Charging or not FormationModel or not FormationModel.PrimaryPart
		end)
		RainPeri.Touched:Connect(function(hit)--Spinning blades also kill!
			local Hum = hit.Parent:FindFirstChildOfClass("Humanoid")
			if not Hum then return end
			if Hum == Humanoid or IsTeamMate(Creator.Value,Services.Players:GetPlayerFromCharacter(Hum.Parent)) then return end
			UntagHumanoid(Hum)
			TagHumanoid(Hum,Creator.Value)
			Hum:TakeDamage(Hum.Health)
		end)
		for _,Val in pairs(PeriFormation) do
			local PeriClone = RainPeri:Clone();
			--[[for i,v in pairs(PeriClone:GetChildren()) do
				v:Destroy()
			end]]
			PeriClone.Size = PeriClone.Size*10
			local Mesh = PeriClone:FindFirstChildOfClass("SpecialMesh")
			PeriClone.Color = Val.Value
			Mesh.TextureId = Val.Name;
			--Mesh.Scale = Mesh.Scale*10
			PeriClone.Name = "Periastron";
			PeriClone.Parent = FormationModel
			PeriRangers[#PeriRangers+1] = PeriClone
			PeriClone.Touched:Connect(function(hit)--Spinning blades also kill!
				local Hum = hit.Parent:FindFirstChildOfClass("Humanoid")
			if not Hum or Hum == Humanoid or IsTeamMate(Creator.Value,Services.Players:GetPlayerFromCharacter(Hum.Parent)) then return end
				Hum:TakeDamage(Hum.Health)
			end)
		end
		for i,v in pairs(PeriRangers) do
		local pos = (RainPeri.CFrame*CFrame.Angles(rad(90),i*rad(360/#PeriRangers),0))
			v.Anchored = true
			v.CFrame = pos*CFrame.new(0,-v.Size.Z/2,v.Size.Z/2)
		end
		local ChargeSound = script:WaitForChild("ChargeSound",5)
		ChargeSound.Parent = CenterPiece
		ChargeSound:Play()
		local Seed = Random.new(tick())
		local alottedTime = tick()

		--[[workspace.DescendantRemoving:Connect(function(d)
			if d == Tool then
			FormationModel:Destroy()
			RainPeri:Destroy()
			end
		end)]]
		spawn(function()
			repeat
			wait(Seed:NextNumber(.05,.2))
			local Index = Seed:NextInteger(1,#PeriRangers)
			local Energy = Create("Part"){
				Material = Enum.Material.Neon,
				CanCollide = false,
				Size = Vector3.new(1,1,1)*Seed:NextInteger(3,10),
				CFrame = (RainPeri.CFrame*CFrame.Angles(rad(Seed:NextInteger(0,360)),rad(Seed:NextInteger(0,360)),rad(Seed:NextInteger(0,360))))*CFrame.new(0,0,Seed:NextInteger(20,50)),
				Color = (PeriRangers[Index] and PeriRangers[Index].Color) or Color3.new(Seed:NextNumber(0,1),Seed:NextNumber(0,1),Seed:NextNumber(0,1)),
				Shape = Enum.PartType.Ball,
				Transparency = 0.5,
				Parent = workspace,
			}
			Deleteables[#Deleteables+1] = Energy
			Energy:SetNetworkOwner(nil)-- So it wouldn't be so laggy looking :P
			local Aim = Create("RocketPropulsion"){
				Target = RainPeri,
				TargetRadius = 4,
				MaxThrust = 10^5,
				TurnD = 10,
				TurnP = 100,
				MaxSpeed = 100,
				CartoonFactor = .8,
				Parent = Energy	
			}
			Aim:Fire()
			spawn(function()
				Aim.ReachedTarget:Wait()
				Energy:Destroy()
			end)
			delay(2,function()--safety catch
				Energy:Destroy()
			end)
			until tick()-alottedTime >= ChargeSound.TimeLength-(.15*#PeriFormation)
			
			Charging = false
			spawn(function()
				repeat
				FormationModel:SetPrimaryPartCFrame(FormationModel.PrimaryPart.CFrame*CFrame.Angles(0,0,rad(amount)))
				Services.RunService.Stepped:Wait()
				until not FormationModel or not FormationModel.PrimaryPart
			end)
	
			ChargeSound:Stop()
			wait(1)
		--warn("FIRE!!!!!")
		
		local RainBeamEnd = Create("Part"){
			Material = Enum.Material.Neon,
			Anchored = true,
			CanCollide = false,
			Transparency = .2,
			Size = Vector3.new(1,1,1)*150,
			CFrame = (RainPeri.CFrame*CFrame.Angles(0,rad(90),0))*CFrame.new((-150/3)+(RainPeri.Size.Z/2),0,0),
			Shape = Enum.PartType.Ball,
			Parent = workspace
		}
		local RainBeam = Create("Part"){
			Material = Enum.Material.Neon,
			Anchored = true,
			CanCollide = false,
			Transparency = .2,
			Size = Vector3.new(0,150,150),
			CFrame = RainBeamEnd.CFrame * CFrame.new(0,0,0),
			Shape = Enum.PartType.Cylinder,
			Parent = workspace
		}
		
		--[[for _,surfaces in pairs(Surfaces) do
			local Lighting = BeamLighting:Clone()
			Lighting.Face = Enum.NormalId[surfaces]
			Lighting.Parent = RainBeamEnd
			SurfaceLights[#SurfaceLights+1]=Lighting
		end
		for _,surfaces in pairs(Surfaces) do
			local Lighting = BeamLighting:Clone()
			Lighting.Face = Enum.NormalId[surfaces]
			Lighting.Parent = RainBeam
			SurfaceLights[#SurfaceLights+1]=Lighting
		end]]
		
		Deleteables[#Deleteables+1]=RainBeamEnd
		Deleteables[#Deleteables+1]=RainBeam
		RainBeam.Touched:Connect(function(hit)
			if not hit or not hit.Parent then return end
			local Hum = hit.Parent:FindFirstChildOfClass("Humanoid")
			local ForceField = hit.Parent:FindFirstChildOfClass("ForceField")
			if not Hum or ForceField then return end
			if Hum == Humanoid or IsTeamMate(Creator.Value,Services.Players:GetPlayerFromCharacter(Hum.Parent)) then return end
			UntagHumanoid(Hum)
			TagHumanoid(Hum,Creator.Value)
			Hum:TakeDamage(Hum.Health)
			hit:Destroy()
		end)
		RainBeamEnd.Touched:Connect(function(hit)
			if not hit or not hit.Parent then return end
			local Hum = hit.Parent:FindFirstChildOfClass("Humanoid")
			local ForceField = hit.Parent:FindFirstChildOfClass("ForceField")
			if not Hum or ForceField then return end
			if Hum == Humanoid or IsTeamMate(Creator.Value,Services.Players:GetPlayerFromCharacter(Hum.Parent)) then return end
			UntagHumanoid(Hum)
			TagHumanoid(Hum,Creator.Value)
			Hum:TakeDamage(Hum.Health)
			hit:Destroy()
		end)
		spawn(function()
			
			
			while RainBeam and RainBeamEnd do
				--RainBeamEnd.Color = PeriRangers[Seed:NextInteger(1,#PeriRangers)].Color
				--RainBeam.Color = RainBeamEnd.Color
				for _,PeriProperty in pairs(PeriFormation) do
					if PeriProperty.Value then
						local Tween = Services.TweenService:Create(RainBeam,TweenInfo.new(.5, Enum.EasingStyle.Linear, Enum.EasingDirection.In, 0, false, 0),{Color = PeriProperty.Value})
						local Tween2 = Services.TweenService:Create(RainBeamEnd,TweenInfo.new(.5, Enum.EasingStyle.Linear, Enum.EasingDirection.In, 0, false, 0),{Color = PeriProperty.Value})
						
						--[[for _,lights in pairs(SurfaceLights) do
							for _,PeriProperty in pairs(PeriFormation) do
								if PeriProperty.Value then
									local LightTween = Services.TweenService:Create(lights,TweenInfo.new(.5, Enum.EasingStyle.Linear, Enum.EasingDirection.In, 0, false, 0),{Color = PeriProperty.Value})
									LightTween:Play()	
								end
							end
						end]]
						
						Tween:Play();Tween2:Play()
						Tween2.Completed:Wait()
					end
				end
				Services.RunService.Stepped:Wait()
			end
		end)
		local FireSound = script:WaitForChild("FireSound",5)
		FireSound.Parent = CenterPiece
		local LoopSound = script:WaitForChild("LoopSound",5)
		LoopSound.Parent = CenterPiece
		FireSound:Play()
		LoopSound:Play()
		--[[local Velo = Create("BodyVelocity"){
			Velocity = -RainPeri.CFrame.lookVector*100,
			MaxForce = Vector3.new(1,1,1)*math.huge,
			Parent = RainBeam,
		}]]
		local BeamInfo = TweenInfo.new(5, Enum.EasingStyle.Linear, Enum.EasingDirection.In, 0, false, 0)
		local SizeTween = Services.TweenService:Create(RainBeam,BeamInfo,{Size = Vector3.new(500,RainBeam.Size.Y,RainBeam.Size.Z),CFrame = (RainBeamEnd.CFrame*CFrame.new(-500/2,0,0))})
		SizeTween:Play();SizeTween.Completed:Wait()
		--RainBeam.Anchored = false
		local CoolDownSound = Create("Sound"){
			SoundId = "rbxassetid://1899277236",
			Volume = 2,
			Looped = false,
			Parent = CenterPiece
		}
		local AlphaTween = Services.TweenService:Create(RainBeam,TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.In, 0, false, 0),{Transparency = 1})
		AlphaTween:Play()
		local AlphaTween2 = Services.TweenService:Create(RainBeamEnd,TweenInfo.new(1, Enum.EasingStyle.Linear, Enum.EasingDirection.In, 0, false, 0),{Transparency = 1})
		AlphaTween2:Play();
		AlphaTween2.Completed:Wait()
		FireSound:Destroy()
		LoopSound:Destroy()
		CoolDownSound:Play()
		spawn(function()
			repeat
			amount = math.clamp(amount-0.05,0,10)
			Services.RunService.Stepped:Wait()
			until not FormationModel
		end)
		RainBeamEnd:Destroy()
		RainBeam:Destroy()
		CoolDownSound.Ended:Wait()
		delay(1,function()
			RainPeri:Destroy()
			FormationModel:Destroy()
			script:Destroy()
		end)
		
		end)
		