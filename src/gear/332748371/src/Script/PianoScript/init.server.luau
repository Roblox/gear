--Made by Luckymaxer

Character = script.Parent
Humanoid = Character:FindFirstChildOfClass("Humanoid")
Torso = Character:FindFirstChild("Torso") or Character:FindFirstChild("UpperTorso")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

Player = Players:GetPlayerFromCharacter(Character)

RbxUtility = LoadLibrary("RbxUtility")
Create = RbxUtility.Create

Creator = script:WaitForChild("Creator")
Model = script:WaitForChild("Model")
Object = script:WaitForChild("Object")
Hit = script:WaitForChild("Hit")
Remove = script:WaitForChild("Remove")

BackpackMonitor = script:WaitForChild("BackpackMonitor")
BackpackDisabler = script:WaitForChild("BackpackDisabler")
DisableScripts = script:WaitForChild("DisableScripts")

AnimationPlaying = false

Animations = {
	FlailingR6 = script:WaitForChild("FlailingR6"),
	FlailingR15 = script:WaitForChild("FlailingR15")
}

function DestroyScript()
	for i, v in pairs({BodyPosition, ToolAdded, ModelChanged, ObjectChanged, HitChanged, RemoveChanged}) do
		if v then
			if tostring(v) == "Connection" then
				v:disconnect()
			elseif v.Parent then
				v:Destroy()
			end
		end
	end
	if FlailAnim then
		FlailAnim:Stop()
	end
	if Humanoid then
		Humanoid.WalkSpeed = 16
		Humanoid.AutoRotate = true
	end
	Debris:AddItem(script, 0.5)
	return
end

if not Humanoid or Humanoid.Health == 0 or not Torso then
	DestroyScript()
	return
end

BodyPosition = Create("BodyPosition"){
	MaxForce = Vector3.new(math.huge, 0, math.huge),
	Position = Torso.Position,
	Parent = Torso
}

ModelChanged = Model.Value.Changed:Connect(function()
	if not Model.Value or not Model.Value.Parent then
		DestroyScript()
		return
	end
end)

ObjectChanged = Object.Value.Changed:Connect(function()
	if not Object.Value or not Object.Value.Parent then
		DestroyScript()
		return
	end
end)

HitChanged = Hit.Changed:Connect(function()
	if Hit.Value and not AnimationPlaying then
		AnimationPlaying = true
		if Player then
			local BackpackMonitorCopy = BackpackMonitor:Clone()
			local Values = {
				{Name = "Creator", Class = "ObjectValue", Value = Player},
				{Name = "Model", Class = "ObjectValue", Value = Model.Value},
			}
			for i, v in pairs(Values) do
				local Value = Create(v.Class){
					Name = v.Name,
					Value = v.Value,
					Parent = BackpackMonitorCopy,
				}
			end
			BackpackMonitorCopy.Disabled = false
			BackpackMonitorCopy.Parent = game:GetService("Workspace")
			Humanoid:UnequipTools()
			ToolAdded = Character.ChildAdded:Connect(function(Child)
				wait()
				if Child:IsA("Tool") then
					Humanoid:UnequipTools()
				end
			end)
			local BackpackDisablerCopy = BackpackDisabler:Clone()
			BackpackDisablerCopy.Disabled = false
			BackpackDisablerCopy.Parent = Character
		end
		AnimationPlaying = true
		FlailAnim = Humanoid:LoadAnimation(Animations["Flailing"..Humanoid.RigType.Name])
		FlailAnim:Play(nil, nil, 2)
	elseif not Hit.Value and AnimationPlaying then
		AnimationPlaying = false
		if FlailAnim then
			FlailAnim:Stop()
		end
	end
end)

RemoveChanged = Remove.Changed:Connect(function()
	if Remove.Value then
		DestroyScript()
		return
	end
end)

for i, v in pairs(DisableScripts:GetChildren()) do
	if v:IsA("BaseScript") then
		local ScriptCopy = v:Clone()
		ScriptCopy.Disabled = false
		ScriptCopy.Parent = script
	end
end

Humanoid.WalkSpeed = 0
Humanoid.AutoRotate = false