--Made by Luckymaxer

wait()

Humanoid = script.Parent

Players = game:GetService("Players")
Debris = game:GetService("Debris")
StarterGui = game:GetService("StarterGui")

Character = Humanoid.Parent
Player = Players:GetPlayerFromCharacter(Character)

Animations = {
	Faint = script:FindFirstChild("Faint"),
	Unconscious = script:FindFirstChild("Unconscious")
}

ScreenFog = script:FindFirstChild("ScreenFog")

Unconscious = true

function DestroyScript()
	Unconscious = false
	if Face and Face.Parent and OriginalFace then
		Face.Texture = OriginalFace
	end
	if UnconsciousAnim then
		UnconsciousAnim:Stop()
	end
	if Humanoid and Humanoid.Parent then
		Humanoid.WalkSpeed = 16
	end
	if PlayerGui and ScreenFog and ScreenFogFrame then
		Debris:AddItem(ScreenFog, 2)
		Spawn(function()
			for i = 1, ((1 - 0.2) * 50) do
				ScreenFogFrame.Transparency = (ScreenFogFrame.Transparency + 0.02)
				wait(0.01)
			end
			ScreenFogFrame.Transparency = 1
		end)
		ScreenFog.Parent = PlayerGui
	end
	Debris:AddItem(ScreenFog, 3)
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, true)
	Debris:AddItem(script, 2)
end

if not Player or not ScreenFog or not Animations.Faint or not Animations.Unconscious then
	DestroyScript()
	return
end

BlackoutScript = game:GetService("Workspace"):FindFirstChild(Player.Name .. "BlackoutScript")

if not BlackoutScript then
	DestroyScript()
	return
end

ScreenFog = ScreenFog:Clone()
ScreenFogFrame = ScreenFog:FindFirstChild("Frame")

PlayerGui = Player:FindFirstChild("PlayerGui")
if PlayerGui and ScreenFog and ScreenFogFrame then
	Spawn(function()
		ScreenFogFrame.Transparency = 1
		for i = 1, ((1 - 0.1) * 100) do
			ScreenFogFrame.Transparency = (ScreenFogFrame.Transparency - 0.01)
			wait(0.01)
		end
		ScreenFogFrame.Transparency = 0.1
	end)
	ScreenFog.Parent = PlayerGui
end

UnequipTools = Character.ChildAdded:connect(function(Child)
	Delay(0, function()
		if Unconscious then
			Humanoid:UnequipTools()
		end
	end)
end)

Head = Character:FindFirstChild("Head")
if Head then
	Face = Head:FindFirstChild("face")
	OriginalFace = Face.Texture
	Face.Texture = "http://www.roblox.com/asset/?id=15395252"
end

Humanoid.Changed:connect(function(Property)
	if Property == "Jump" then
		Humanoid.Jump = false
	end
end)

Humanoid.WalkSpeed = 0

Humanoid:UnequipTools()
StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)

FaintAnim = Humanoid:LoadAnimation(Animations.Faint)
if FaintAnim then
	FaintAnim:Play()
	wait(1)
	UnconsciousAnim = Humanoid:LoadAnimation(Animations.Unconscious)
	if UnconsciousAnim then
		UnconsciousAnim:Play()
	end
end

BlackoutScript.Changed:connect(function(Property)
	if Property == "Parent" and not BlackoutScript.Parent then
		DestroyScript()
	end
end)