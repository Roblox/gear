--Made by Luckymaxer
--[[
	Fixed by ArceusInator
	- Works in FE
--]]

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

local GLib = require(206209239)
GLib.Script.Parent = Tool

Players = game:GetService("Players")
Debris = game:GetService("Debris")

Sounds = {
	Handle:WaitForChild("Midas1"),
	Handle:WaitForChild("Midas2"),
	Handle:WaitForChild("Midas3")
}

ReloadTime = 2

PrimaryColor = "Pastel Blue"
SecondaryColor = "Sand blue"

Part = Instance.new("Part")
Part.Name = "Part"
Part.BrickColor = BrickColor.new("Pastel Blue")
Part.Material = Enum.Material.Granite
Part.TopSurface = Enum.SurfaceType.Smooth
Part.BottomSurface = Enum.SurfaceType.Smooth
Part.Shape = Enum.PartType.Block
Part.FormFactor = Enum.FormFactor.Custom
Part.Size = Vector3.new(1, 0.4, 1)

TextureId = 136803121

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

function GetRandomSound()
	local Sound = Sounds[math.random(1, #Sounds)]
	if not Sound.IsPlaying then
		return Sound
	else
		GetRandomSound()
	end
end

function MakeColorShavings(Position)
	for i = 1, 3 do
		local PartClone = Part:Clone()
		local a = (math.random() * 6.28)
		local d = Vector3.new(math.cos(a), 0, math.sin(a)).unit
		PartClone.Velocity = (d * 25)
		PartClone.RotVelocity = d
		Debris:AddItem(PartClone, 60)
		PartClone.Parent = game:GetService("Workspace")
		PartClone.CFrame = Position + Vector3.new(0, (math.random() * 3), 0) + (d * 2)
	end
end

function Blow(Hit)
	if Hit and Hit.Parent then
		local character, humanoid = FindCharacterAncestor(Hit.Parent)
		if not character or character ~= Character  and Humanoid and Humanoid.Health > 0 and RightArm then
			local RightGrip = RightArm:FindFirstChild("RightGrip")
			if RightGrip and (RightGrip.Part0 == Handle or RightGrip.Part1 == Handle) then
				if Hit:GetMass() < (Handle:GetMass() * 10) and (character or not Hit.Locked) then
					Hit.BrickColor = Part.BrickColor
					Hit.Material = Part.Material
					for i, v in pairs(Hit:GetChildren()) do
						if v:IsA("SpecialMesh") then
							if v.MeshType == Enum.MeshType.FileMesh then
								v.TextureId = "http://www.roblox.com/asset/?id=" .. TextureId
							else
								Hit.BrickColor = BrickColor.new(SecondaryColor)
							end
						end
					end
					if character then
						for i, v in pairs(character:GetChildren()) do
							if v:IsA("BodyColors") or v:IsA("Clothing") then
								v:Destroy()
							elseif v:IsA("CharacterMesh") and v.BodyPart.Name == string.gsub(Hit.Name, " ", "") then
								v.BaseTextureId = TextureId
								v.OverlayTextureId = TextureId
							end
						end
					end
				end
			end
		end
	end
end

function Activated()
	local Character, Player, Humanoid = GLib.GetCharacter(Tool)
	local Torso = Humanoid.Torso
	
	if Player and Humanoid and Humanoid.Health > 0 and Torso then
		MakeColorShavings(Torso.CFrame + (Torso.CFrame.lookVector * 3))
	end
end

function Equipped()
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	Torso = Character:FindFirstChild("Torso")
	RightArm = Character:FindFirstChild("Right Arm")
	if not Player or not Humanoid or Humanoid.Health == 0 or not Torso or not RightArm then
		return
	end
	if not Tool.Enabled then
		wait(ReloadTime)
		Tool.Enabled = true
	end
end

function Unequipped()
end

Handle.Touched:connect(Blow)

-- Tool.Activated:connect(Activated)
Tool:WaitForChild'ActivatedRemote'.OnServerEvent:connect(function(client)
	if client.Character == Tool.Parent then
		Activated()
	end
end)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)