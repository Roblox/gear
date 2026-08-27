--Made by Luckymaxer

Humanoid = script.Parent
Character = Humanoid.Parent

Players = game:GetService("Players")
Debris = game:GetService("Debris")

Head = Character:WaitForChild("Head")

Face = Head:FindFirstChild("face")

Texture = 186936495
FaceId = 186936651

FreezeColor = BrickColor.new("Pastel Blue")

Player = Players:GetPlayerFromCharacter(Character)

Duration = script:WaitForChild("Duration").Value

function DestroyScript()
	Debris:AddItem(script, 1)
end

function GetAllObjects(Parent)
	local Objects = {}
	local function GetObjects(Parent)
		for i, v in pairs(Parent:GetChildren()) do
			if v.Parent:IsA("Tool") then
				return
			end
			table.insert(Objects, v)
			GetObjects(v)
		end
	end
	GetObjects(Parent)
	return Objects
end

function BeginFreeze()
	if Player then
		PlayerGui = Player:FindFirstChild("PlayerGui")
		if PlayerGui then
			FreezeGui = PlayerGui:FindFirstChild("FreezeGui")
			if not FreezeGui then
				FreezeGui = Instance.new("ScreenGui")
				FreezeGui.Name = "FreezeGui"
				ImageLabel = Instance.new("ImageLabel")
				ImageLabel.BackgroundTransparency = 1
				ImageLabel.BorderSizePixel = 0
				ImageLabel.ImageTransparency = 0.35
				ImageLabel.Image = "http://www.roblox.com/asset/?id=186936495"
				ImageLabel.Position = UDim2.new(-0.05, 0, -0.05, 0)
				ImageLabel.Size = UDim2.new(1.1, 0, 1.1, 0)
				ImageLabel.Parent = FreezeGui
				FreezeGui.Parent = PlayerGui
			end
		end
	end
	Objects = GetAllObjects(Character)
	for i, v in pairs(Objects) do
		if v:IsA("BasePart") then
			Objects[i] = {Object = v, Parent = v.Parent, BrickColor = v.BrickColor}
			v.BrickColor = FreezeColor
		elseif v:IsA("DataModelMesh") then
			Objects[i] = {Object = v, NewObject = v:Clone(), Parent = v.Parent, VertexColor = v.VertexColor}
			local Color = FreezeColor.Color
			local r, g, b = Color.r, Color.g, Color.b
			v.VertexColor = Vector3.new(r, g, b)
			v.TextureId = ("http://www.roblox.com/asset/?id=" .. Texture)
			if v:IsA("FileMesh") then
				v.TextureId = ("http://www.roblox.com/asset/?id=" .. Texture)
			end
		elseif v:IsA("Clothing") or v:IsA("ShirtGraphic") or v:IsA("Decal") and v.Name ~= "face" then
			Objects[i] = {Object = v, NewObject = v:Clone(), Parent = v.Parent}
			v:Destroy()
		elseif v:IsA("CharacterMesh") then
			Objects[i] = {Object = v, NewObject = v:Clone(), Parent = v.Parent}
			v.BaseTextureId = Texture
			v.OverlayTextureId = Texture
		end
	end
	if Face then
		OriginalFace = Face.Texture
		Face.Texture = ("http://www.roblox.com/asset/?id=" .. FaceId)
	end	
	
	Humanoid.WalkSpeed = -8

	DisableJump = Humanoid.Changed:connect(function(Property)
		if Property == "Jump" then
			Humanoid.Jump = false
		end
	end)
end

function EndFreeze()
	if Humanoid and Humanoid.Parent then
		Humanoid.WalkSpeed = 16
	end
	if DisableJump then
		DisableJump:disconnect()
	end
	if Face and Face.Parent then
		Face.Texture = OriginalFace
	end
	if Objects and #Objects > 0 then
		for i, v in pairs(Objects) do
			if type(v) == "table" and v.Object then
				if v.Object:IsA("BasePart") then
					v.Object.BrickColor = v.BrickColor
				elseif v.Object:IsA("DataModelMesh") or v.Object:IsA("Clothing") or v.Object:IsA("ShirtGraphic") or v.Object:IsA("Decal") or v.Object:IsA("CharacterMesh") then
					if v.Object.Parent then
						v.Object:Destroy()
					end
					if v.Object:IsA("CharacterMesh") then
					end
					v.NewObject.Parent = v.Parent
				end
			end
		end
	end
	if FreezeGui and FreezeGui.Parent then
		FreezeGui:Destroy()
	end
	DestroyScript()
end

BeginFreeze()

wait(Duration)

EndFreeze()