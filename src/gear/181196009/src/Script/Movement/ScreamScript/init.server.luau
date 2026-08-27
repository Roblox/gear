--Made by Luckymaxer

Character = script.Parent
Humanoid = Character:FindFirstChild("Humanoid")
Head = Character:FindFirstChild("Head")

Debris = game:GetService("Debris")
InsertService = game:GetService("InsertService")

ScareScript = script:WaitForChild("ScareScript")

Faces = {147144644, 117522793, 34186804, 30395097, 30265169, 21755022, 21635583, 20909103, 17138027, 14812981, 14127194, 7699177}

function DestroyScript()
	if ScareScriptClone and ScareScriptClone.Parent then
		Debris:AddItem(ScareScriptClone, 2)
	end
	Debris:AddItem(script, 2)
end

if not Humanoid then
	DestroyScript()
	return
end

ScareScriptClone = ScareScript:Clone()
ScareScriptClone.Disabled = false

RemoteConnection = Instance.new("RemoteFunction")
RemoteConnection.Name = "RemoteConnection"
RemoteConnection.Parent = ScareScriptClone

RemoteConnection.OnServerInvoke = (function(Player, Mode, Value)
	if Mode == "Destroy" and Value then
		if Face and Face.Parent then
			Face.Texture = OriginalTexture
		end
		DestroyScript()
	end
end)

ScareScriptClone.Parent = Character

if Head then
	Face = Head:FindFirstChild("face")
	OriginalTexture = Face.Texture
	local NewTexture = InsertService:LoadAsset(Faces[math.random(1, #Faces)]):GetChildren()[1].Texture
	Face.Texture = NewTexture
else
	DestroyScript()
end

Delay(15, function()
	DestroyScript()
end)