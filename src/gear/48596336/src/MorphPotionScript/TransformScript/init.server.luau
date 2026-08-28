--Transform into someone else for X amount of seconds!
--Scripted by TakeoHonorable

local Character,CharacterHumanoid,Target = script.Parent,script.Parent:FindFirstChildOfClass("Humanoid"),script:FindFirstChild("Target")

if not Character or not Character:FindFirstChildOfClass("Humanoid") or not Target or not Target.Value then script:Destroy() end

local TargetHumanoid = Target.Value:FindFirstChildOfClass("Humanoid")

if not TargetHumanoid then script:Destroy() end

local MyDesc,TargetDesc = Character:FindFirstChildWhichIsA("HumanoidDescription",true),Target.Value:FindFirstChildWhichIsA("HumanoidDescription",true)

if not MyDesc or not TargetDesc then script:Destroy() end

local Sounds = {
	Reset = script:WaitForChild("MorphResetSound"),	
}

CharacterHumanoid:ApplyDescription(TargetDesc)

delay(20,function()
	CharacterHumanoid:ApplyDescription(MyDesc)
	Sounds.Reset.Parent = Character:FindFirstChild("Torso") or Character:FindFirstChild("UpperTorso")
	Sounds.Reset:Play()
	game:GetService("Debris"):AddItem(Sounds.Reset,Sounds.Reset.TimeLength+1)
	script:Destroy()
end)