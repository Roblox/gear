local CharacterRef = script:WaitForChild("CharacterRef",10).Value
local PhaseSound = CharacterRef:FindFirstChild("PhaseIn",true)


local Services = {
	SoundService = (game:FindService("SoundService") or game:GetService("SoundService")),
}

--[[for _,parts in pairs(CharacterRef:GetDescendants()) do
	if parts:IsA("BasePart") then
		parts.Anchored = true
		parts.CanCollide = false
		parts.Transparency = .5
		parts.Color = Color3.new(1,1,1)
		if parts:IsA("UnionOperation") then
			parts.UsePartColor = true
		end
		if parts.Name == "HumanoidRootPart" then
			CharacterRef.PrimaryPart = parts
		end
	elseif parts:IsA("SpecialMesh") then
		parts.TextureId = ""
	elseif parts:IsA("JointInstance") or parts:IsA("Humanoid") then
		parts:Destroy()
	end
end]]
	
CharacterRef.Parent = workspace.CurrentCamera
if PhaseSound then
	Services.SoundService:PlayLocalSound(PhaseSound)
end


