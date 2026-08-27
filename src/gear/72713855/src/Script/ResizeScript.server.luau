--Made by Luckymaxer

Character = script.Parent
Humanoid = Character:FindFirstChildOfClass("Humanoid")

Debris = game:GetService("Debris")

ResizeModule = require(201433042)

Duration = script:FindFirstChild("Duration")

local ColorBrick = BrickColor.new

local GigantoFace,GigantoColors = "rbxassetid://21796275",Instance.new("BodyColors")
GigantoColors.HeadColor = ColorBrick("Grime")
GigantoColors.TorsoColor = ColorBrick("Grime")
GigantoColors.RightArmColor = ColorBrick("Grime")
GigantoColors.LeftArmColor = ColorBrick("Grime")
GigantoColors.RightLegColor = ColorBrick("Deep blue")
GigantoColors.LeftLegColor = ColorBrick("Deep blue")

function DestroyScript()
	Debris:AddItem(script, 1)
end

function SetHumanoid(humanoid, MaxHealth, WalkSpeed)
	if not humanoid or not humanoid.Parent or humanoid.Health == 0 then
		return
	end
	local Ratio = (humanoid.Health / humanoid.MaxHealth)
	humanoid.WalkSpeed = WalkSpeed
	humanoid.MaxHealth = MaxHealth
	humanoid.Health = (Ratio * humanoid.MaxHealth)
end

if not Humanoid or not Duration then
	DestroyScript()
	return
end

local ResizeData = ResizeModule.ScaleCharacter(Character, 2, {ScaleTools = true, ScaleHats = true, ScaleBack = {Delay = Duration.Value}})
local OriginalMaxHealth,OriginalBodyColors,OriginalFace = Humanoid.MaxHealth,Character:FindFirstChildOfClass("BodyColors")

local Head = Character:FindFirstChild("Head")

ResizeData.StateChanged.Changed:Connect(function(State)
	if not State then
		--Humanoid.WalkSpeed = 26
		SetHumanoid(Humanoid,OriginalMaxHealth * 5,24)
		if OriginalBodyColors then
			OriginalBodyColors.Parent = nil
		end
		
		if Head then
			local Face = Head:FindFirstChild("face")
			if Face and Face:IsA("Decal") then
				OriginalFace = Face.Texture
				Face.Texture = GigantoFace
			end
		end
		GigantoColors.Parent = Character
	else
		--Humanoid.WalkSpeed = 16
		SetHumanoid(Humanoid,OriginalMaxHealth,16)
		if OriginalBodyColors then
			OriginalBodyColors.Parent = Character
		end
		if Head and OriginalFace then
			local Face = Head:FindFirstChild("face")
			if Face and Face:IsA("Decal") then
				Face.Texture = OriginalFace
			end
		end
		GigantoColors:Destroy()
		DestroyScript()
	end
end)