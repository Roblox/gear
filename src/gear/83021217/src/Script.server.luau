local Debris = game:GetService("Debris")

local Tool = script.Parent
local Handle = Tool.Handle

local Sound = Handle:FindFirstChild("Sound")

local GetMousePosition = Instance.new("RemoteFunction")
GetMousePosition.Name = "GetMousePosition"
GetMousePosition.Parent = Tool

local Player = nil
local Character = nil
local Humanoid = nil
local Torso = nil

local LastUse = Tool:FindFirstChild("LastUse")

local COOLDOWN_TIME = 3
local DAMAGE = 55
local POWER = 150

local SharkIds = {82821384,82843647,82821384,82843712}

function CreateShark()
	local Part = Instance.new("Part")
	Part.Name = "Shark"
	Part.BrickColor = BrickColor.White()
	Part.CanCollide = false
	Part.TopSurface = Enum.SurfaceType.Smooth
	Part.BottomSurface = Enum.SurfaceType.Smooth
	
	local Mesh = Instance.new("SpecialMesh")
	Mesh.Name = "Mesh"
	Mesh.MeshId = "rbxassetid://" .. SharkIds[1]
	Mesh.TextureId = "rbxassetid://" .. 82844051
	Mesh.Scale = Vector3.new(2.5, 2.5, 2.5)
	Mesh.Parent = Part
	
	Part.Size = Vector3.new(0.5, 1.1, 3.5)
	
	return Part
end

function OnActivate()
	if not Tool.Enabled then return end
	if not Player then return end
	if not Character then return end
	if not Torso then return end
	if not Humanoid then return end
	if Humanoid.Health <= 0 then return end
	Tool.Enabled = false
	
	local CDamage = 0
	if Sound then
		Sound:Play()
	end
	local NewShark = CreateShark()
	local MousePosition = GetMousePosition:InvokeClient(Player)
	local ThrowVector = (MousePosition - Handle.Position).Unit
	NewShark.CFrame = CFrame.new(Handle.Position, Handle.Position + ThrowVector) * CFrame.new(0, 0, 2)
	NewShark.Velocity = (ThrowVector * POWER) + Vector3.new(0, 20, 0)	
	NewShark.Touched:Connect(function(hit)
		if hit and NewShark and not NewShark:FindFirstChild("Bite") then
			if hit.Parent ~= Character and hit.Name ~= "Handle" and hit.Name ~= "Effect" and hit.Name ~= "Shark" then
				local HitHumanoid = hit.Parent:FindFirstChildOfClass("Humanoid")
				local HitTorso = hit.Parent:FindFirstChild("Torso") or hit.Parent:FindFirstChild("UpperTorso")
				if HitHumanoid and HitTorso and Humanoid.Health > 0 then
					local BiteWeld = Instance.new("Weld")
					BiteWeld.Part0 = hit
					BiteWeld.Part1 = NewShark
					BiteWeld.Name = "Bite"
					BiteWeld.C0 = CFrame.new(0, 0, 0) * CFrame.Angles(math.pi * 2 * math.random(), math.pi * 2 * math.random(), math.pi * 2 * math.random())
					BiteWeld.C1 = CFrame.new(0, 0, -1.5) * CFrame.Angles(0, 0, 0)
					BiteWeld.Parent = NewShark
					
					for i, v in ipairs(Humanoid:GetChildren()) do
						if v.Name == "creator" then
							v:Destroy()
						end
					end
					
					local NewCreator = Instance.new("ObjectValue")
					NewCreator.Name = "creator"
					NewCreator.Value = Player
					Debris:AddItem(NewCreator, 15)
					NewCreator.Parent = HitHumanoid
					HitHumanoid:TakeDamage(20)
					NewShark.Parent = hit.Parent
					CDamage = 20
				else
					NewShark:Destroy()
				end
			end
		end
	end)
	
	Debris:AddItem(NewShark, 15)
	NewShark.Parent = workspace
	spawn(function()
		local Tail = 0
		while NewShark and NewShark.Parent ~= nil and NewShark:IsDescendantOf(workspace) and NewShark:FindFirstChild("Mesh") do
			Tail = Tail + 1
			NewShark.Mesh.MeshId = "rbxassetid://" .. SharkIds[(Tail % (#SharkIds)) + 1]
			local BiteWeld = NewShark:FindFirstChild("Bite")
			if BiteWeld and Tail%4 == 1 then
				if BiteWeld.Part0 then
					local BitingHumanoid = BiteWeld.Part0.Parent:FindFirstChildOfClass("Humanoid")
					if BitingHumanoid then
						BitingHumanoid:TakeDamage(2)
						CDamage = CDamage + 2
					end
				end
			end
			wait(0.1)
			if CDamage > DAMAGE then
				NewShark:Destroy()
			end
		end 
	end)
	
	LastUse.Value = tick()
	wait(COOLDOWN_TIME)	
	Tool.Enabled = true
end

function OnEquipped()
	Character = Tool.Parent
	Player = game.Players:GetPlayerFromCharacter(Character)
	Torso = Character:FindFirstChild("Torso") or Character:FindFirstChild("UpperTorso")
	Humanoid = Character:FindFirstChildOfClass("Humanoid")
end

function OnUnequipped()
	Player = nil
	Character = nil
	Torso = nil
	Humanoid = nil
end

Tool.Activated:Connect(OnActivate)
Tool.Equipped:Connect(OnEquipped)
Tool.Unequipped:Connect(OnEquipped)