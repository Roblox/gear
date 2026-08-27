--Made by Luckymaxer

Model = script.Parent

Players = game:GetService("Players")
Debris = game:GetService("Debris")

RbxUtility = LoadLibrary("RbxUtility")
Create = RbxUtility.Create

Effects = {}
Removing = false

Values = {}
for i, v in pairs(script:GetChildren()) do
	if string.find(string.lower(v.ClassName), string.lower("Value")) then
		Values[v.Name] = v
	end
end

function EnableTeleport(Portal)
	local TouchedConnection
	local Debounce = false
	TouchedConnection = Portal.Touched:connect(function(Hit)
		if not Hit or not Hit.Parent or #Effects < 2 or Debounce then
			return
		end
		local character = Hit.Parent
		local PortalTag = character:FindFirstChild("PortalDebounce")
		if PortalTag then
			return
		end
		local player = Players:GetPlayerFromCharacter(character)
		if player and player ~= Values.Creator.Value then
			for i, v in pairs(character:GetChildren()) do
				if v:IsA("ForceField") then
					return
				end
			end
		end
		local humanoid = character:FindFirstChild("Humanoid")
		local torso = character:FindFirstChild("Torso")
		if not humanoid or humanoid.Health == 0 then
			return
		end
		Debounce = true
		local Portals = {}
		for i, v in pairs(Effects) do
			if v ~= Portal then
				table.insert(Portals, v)
			end
		end
		local TeleportTag = Create("BoolValue"){
			Name = "PortalDebounce",
			Value = true,
		}
		Debris:AddItem(TeleportTag, 2)
		TeleportTag.Parent = character
		local PortalSelected = Portals[math.random(1, #Portals)]
		torso.CFrame = (PortalSelected.CFrame * CFrame.new(0, ((torso.Size.Y * 2) + (Portal.Size.Y / 2)), 0))
		wait(0.5)
		Debounce = false
	end)
	return TouchedConnection
end

function RemoveModel()
	if Removing then
		return
	end
	local Parts = {}
	for i, v in pairs(Model:GetChildren()) do
		if v:IsA("BasePart") then
			table.insert(Parts, v)
		end
	end
	if #Parts == 0 then
		Removing = true
		Model.Name = ""
		Debris:AddItem(Model, 0.5)
	end
end

if not Values.Creator then
	RemoveModel()
	return
end

Model.ChildAdded:connect(function(Child)
	if Child.Name == "Effect" then
		if #Effects >= 5 then
			local EffectNumber = 1
			local CurrentEffect = Effects[EffectNumber]
			if CurrentEffect then
				if CurrentEffect.Parent then
					CurrentEffect:Destroy()
				end
			end
			table.remove(Effects, 1)
		end
		table.insert(Effects, Child)
		EnableTeleport(Child)
	end
end)

Model.ChildRemoved:connect(function(Child)
	for i, v in pairs(Effects) do
		if v == Child then
			table.remove(Effects, i)
			break
		end
	end
	RemoveModel()
end)

wait(1)

RemoveModel()