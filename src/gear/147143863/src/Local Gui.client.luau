--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")
FireShield = Tool:WaitForChild("FireShield")
Special = Tool:WaitForChild("Special")
Fire = Handle:WaitForChild("Fire")
Equip = Tool:WaitForChild("Equip")
ArmsUp = Tool:WaitForChild("ArmsUp")
Anims = {"LeftSlash", "LeftSwingFast", "RightSlash", "RightSwingFast"}

Debris = game:GetService("Debris")

SpecialRunning = false

-- Returns a character ancestor and its Humanoid, or nil
function FindCharacterAncestor(Parent)
	if Parent and Parent ~= game:GetService("Workspace") then
		local humanoid = Parent:FindFirstChild("Humanoid")
		if humanoid then
			return Parent, humanoid
		else
			return FindCharacterAncestor(Parent.Parent)
		end
	end
	return nil
end

function RayCast(Position, Direction, MaxDistance, IgnoreList)
	return game:GetService("Workspace"):FindPartOnRayWithIgnoreList(Ray.new(Position, Direction.unit * (MaxDistance or 999.999)), IgnoreList) 
end

function DestroyItem(Parent)
	for i, v in pairs(Parent:GetChildren()) do
		if v:IsA("BaseScript") or v:IsA("Fire") or v:IsA("Smoke") or v:IsA("Decal") or v:IsA("Texture") then
			v:Destroy()
		elseif v:IsA("SpecialMesh") then
			v.TextureId = ""
		elseif v:IsA("DataModelMesh") then
			local BrickColor = BrickColor.new("Really black")
			local Color = BrickColor.Color
			local r, g, b = Color.r, Color.g, Color.b
			v.VertexColor = Vector3.new(r, g, b)
		elseif v:IsA("BasePart") then
			v.BrickColor = BrickColor.new("Really black")
			v.Material = Enum.Material.CorrodedMetal
			v:BreakJoints()
		end
		DestroyItem(v)
	end
end

function CreateFirePillar(Position)
	local FirePillar = Instance.new("Model")
	FirePillar.Name = "FirePillar"
	Debris:AddItem(FirePillar, 30)
	FirePillar.Parent = Character
	for i = 1, 25 do
		local Part = Instance.new("Part")
		Part.Name = "FlamePart"
		Part.Anchored = true
		Part.CanCollide = false
		Part.TopSurface = Enum.SurfaceType.Smooth
		Part.BottomSurface = Enum.SurfaceType.Smooth
		Part.FormFactor = Enum.FormFactor.Custom
		Part.Size = Vector3.new(2, 2, 2)
		Part.Transparency = 1
		local FireClone = Fire:Clone()
		FireClone.Parent = Part
		Part.Touched:connect(function(Hit)
			if Hit and Hit.Parent and Hit.Parent ~= Character then
				local character, humanoid = FindCharacterAncestor(Hit)
				if character == Character or humanoid == Humanoid then
					return
				end
				if not Hit:FindFirstChild(Fire.Name) then
					local FireClone = Fire:Clone()
					Debris:AddItem(FireClone, 10)
					FireClone.Parent = Part
				end
				local Item = Hit.Parent
				if Item:IsA("Tool") or Item:IsA("Hat") and Item ~= Tool then
					DestroyItem(Item)
				end
				local humanoid = Hit.Parent:FindFirstChild("Humanoid")
				if humanoid and humanoid.Parent and humanoid.Health > 0 and humanoid ~= Humanoid then
					humanoid:TakeDamage(20)
				end
			end
		end)
		Part.Parent = FirePillar
		Part.CFrame = CFrame.new(Position) + Vector3.new(0, (Part.Size.y * i), 0)
	end
	return FirePillar
end

function Equipped(Mouse)
	Mouse.Icon = "rbxasset://textures\\GunCursor.png"
	Character = Tool.Parent
	Humanoid = Character:FindFirstChild("Humanoid")
	Torso = Character:FindFirstChild("Torso")
	EquipTime = tick()
	EquipAnim = Humanoid:LoadAnimation(Tool.Equip)
	EquipAnim:Play(nil, nil, 0.7)
	Mouse.Button1Down:connect(function()
		if Tool.Enabled and (tick() - EquipTime) > 1.7 and not SpecialRunning then
			if (Special.Value and (LastClick and ((tick() - LastClick) <= 0.3))) then
				Special.Value = false
				local TorsoPos = Torso.CFrame
				for i = 1, 100 do
					local Position = TorsoPos + TorsoPos.lookVector * (i + 4)
					local Hit, Pos = RayCast(Position.p, Vector3.new(0, -1, 0), 6, {Character})
					if Hit then
						local Part = Instance.new("Part")
						Part.Name = "FlamePart"
						Part.Anchored = true
						Part.CanCollide = false
						Part.TopSurface = Enum.SurfaceType.Smooth
						Part.BottomSurface = Enum.SurfaceType.Smooth
						Part.FormFactor = Enum.FormFactor.Custom
						Part.Size = Vector3.new(2, 2, 2)
						Part.Transparency = 1
						local FireClone = Fire:Clone()
						FireClone.Parent = Part
						Debris:AddItem(Part, 10)
						Part.Touched:connect(function(Hit)
							if Hit and Hit.Parent then
								local humanoid = Hit.Parent:FindFirstChild("Humanoid")
								if humanoid and humanoid.Parent and humanoid.Health > 0 and humanoid ~= Humanoid then
									humanoid:TakeDamage(10)
								end
							end
						end)
						Part.Parent = Character
						Part.CFrame = CFrame.new(Pos)
					end
				end
			end
			Tool.Enabled = false
			Mouse.Icon = "rbxasset://textures\\GunWaitCursor.png"
			local TempAnims = {}
			for i, v in pairs(Anims) do
				if v ~= LastAnim then
					table.insert(TempAnims, v)
				end
			end
			NewAnim = TempAnims[math.random(1, #TempAnims)]
			LastAnim = NewAnim
			local Anim = Tool:FindFirstChild(NewAnim)
			local AnimTrack = Humanoid:LoadAnimation(Anim)
			AnimTrack:Play()
			wait(0.5)
			Mouse.Icon = "rbxasset://textures\\GunCursor.png"
			LastClick = tick()
			Tool.Enabled = true
		end
	end)
	Mouse.KeyDown:connect(function(Key)
		Key = Key:lower()
		if Key == "q" and FireShield.Value and (tick() - EquipTime) > 1.7 and not SpecialRunning then
			SpecialRunning = true
			local ArmsUpAnim = Humanoid:LoadAnimation(ArmsUp)
			ArmsUpAnim:Play()
			wait(5)
			ArmsUpAnim:Stop()
			FireShield.Value = false
			local NumberOfFires = 48
			local Increment = ((math.pi * 2)/ NumberOfFires)
			local TorsoPos = Torso.Position - Vector3.new(0, (Torso.Size.y * 2), 0)
			local TorsoNormal = Torso.CFrame.lookVector
			Denom = (math.abs(TorsoNormal.x) + math.abs(TorsoNormal.z))
			PosX = (15 * (TorsoNormal.x / Denom))
			PosZ = (15 * (TorsoNormal.z / Denom))
			local Pos = Vector3.new(TorsoPos.x + PosX, TorsoPos.y, TorsoPos.z + PosZ)
			for i = 1, NumberOfFires do
				local Angle = (Increment * i)
				CreateFirePillar(Pos)
				Pos = Vector3.new(((Pos.x - TorsoPos.x) * math.cos(Angle)) - ((Pos.z - TorsoPos.z) * math.sin(Angle)) + TorsoPos.x, TorsoPos.y,((Pos.x - TorsoPos.x) * math.sin(Angle)) + ((Pos.z - TorsoPos.z) * math.cos(Angle)) + TorsoPos.z)
			end
			SpecialRunning = false
		end
	end)
end

function Unequipped()
	if EquipAnim then
		EquipAnim:Stop()
	end
	if ArmsUpAnim then
		ArmsUpAnim:Stop()
	end
end

Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)