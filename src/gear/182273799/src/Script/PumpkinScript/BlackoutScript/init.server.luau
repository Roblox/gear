--Made by Luckymaxer

Debris = game:GetService("Debris")

ClientScript = script:FindFirstChild("ClientScript")
FixBackpack = script:FindFirstChild("FixBackpack")

Creator = script:FindFirstChild("Creator")
UnconsciousDuration = script:FindFirstChild("UnconsciousDuration")

function DestroyScript()
	local FixBackpackClone = FixBackpack:Clone()
	FixBackpackClone.Disabled = false
	if Player then
		local Backpack = Player:FindFirstChild("Backpack")
		if Backpack then
			FixBackpackClone.Parent = Backpack
		end
	elseif Character then
		FixBackpackClone.Parent = Character
	end
	Debris:AddItem(script, 2)
end

if not Creator or not UnconsciousDuration then
	DestroyScript()
	return
end

if not ClientScript or not FixBackpack or not Creator.Value or not Creator.Value.Parent or not Creator.Value:IsA("Player") or UnconsciousDuration.Value <= 0 then
	DestroyScript()
	return
end


ClientScript = ClientScript:Clone()
FixBackpack = FixBackpack:Clone()
Player = Creator.Value

Character = Player.Character
if not Character then
	DestroyScript()
	return
end

Humanoid = Character:FindFirstChild("Humanoid")
if not Humanoid or Humanoid.Health == 0 then
	return
end

Humanoid.Died:connect(function()
	DestroyScript()
end)

Player.Changed:connect(function(Property)
	if Property == "Character" and not Player.Character then
		DestroyScript()
	end
end)

ServerConnectionObject = Instance.new("ObjectValue")
ServerConnectionObject.Name = "ServerConnection"
ServerConnectionObject.Parent = script

ServerConnection = Instance.new("ObjectValue")
ServerConnection.Name = "ServerScript"
ServerConnection.Value = ServerConnectionObject
ServerConnection.Parent = ClientScript

ClientScriptClone = ClientScript:Clone()
ClientScriptClone.Disabled = false
ClientScriptClone.Parent = Humanoid

Spawn(function()
	while true do
		wait(1)
		UnconsciousDuration.Value = (UnconsciousDuration.Value - 1)
		if UnconsciousDuration.Value <= 0 then
			DestroyScript()
			break
		end
	end
end)