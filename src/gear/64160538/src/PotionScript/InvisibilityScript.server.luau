--Rescripted by Luckymaxer

Character = script.Parent
Humanoid = Character:FindFirstChild("Humanoid")

Debris = game:GetService("Debris")

Creator = script:FindFirstChild("Creator")
Tool = script:FindFirstChild("Tool")
Invisible = script:FindFirstChild("Invisible")
Duration = script:FindFirstChild("Duration")

TransparentObjects = {}
Disabled = false

function DestroyScript()
	Disabled = true
	ResetTransparency()
	Debris:AddItem(script, 0.5)
	script:Destroy()
end

function CheckIfAlive()
	return (((Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0) and true) or false)
end

function CheckTableForString(Table, String)
	for i, v in pairs(Table) do
		if string.lower(v) == string.lower(String) then
			return true
		end
	end
	return false
end

function ResetTransparency(Object)
	local PartNames = {"Head", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg"}
	if not Object then
		for i, v in pairs({DescendantAdded, DescendantRemoving}) do
			if v then
				v:disconnect()
			end
		end
		for i, v in pairs(TransparentObjects) do
			v.Object.Transparency = ((CheckTableForString(PartNames, v.Object.Name) and 0) or v.Transparency)
		end
		TransparentObjects = {}
	else
		local Objects = GetAllObjectsWithProperty(Object, "Transparency", "number")
		for i, v in pairs(TransparentObjects) do
			for ii, vv in pairs(Objects) do
				if v.Object == vv then
					v.Object.Transparency = ((CheckTableForString(PartNames, v.Object.Name) and 0) or v.Transparency)
					table.remove(TransparentObjects, i)
					break
				end
			end
		end
	end
end

function GetAllObjectsWithProperty(Parent, Property, Type)
	local Objects = {}
	local function GetObjects(Parent)
		for i, v in pairs(Parent:GetChildren()) do
			local PropertyExists = false
			pcall(function()
				local Property = v[Property]
				if type(Property) == Type then
					PropertyExists = true
				end
			end)
			if PropertyExists then
				table.insert(Objects, v)
			end
			GetObjects(v)
		end
	end
	GetObjects(Parent)
	return Objects
end

function GetTransparentObjects(Parent)
	local Objects = {}
	local IgnoreObjects = {"HumanoidRootPart"}
	for i, v in pairs(GetAllObjectsWithProperty(Parent, "Transparency", "number")) do
		table.insert(Objects, v)
	end
	for i, v in pairs(Objects) do
		if CheckTableForString(IgnoreObjects, v.Name) then
			table.remove(Objects, i)
		end
	end
	return Objects
end

function SetTransparency(Parent, Transparent, Delay, FadeRate)
	local Objects = {}
	local FadeRate = (FadeRate or 0.1)
	if type(Parent) == "table" then
		Objects = Parent
	else
		for i, v in pairs(GetTransparentObjects(Parent)) do
			table.insert(Objects, {Object = v, Transparency = v.Transparency})
		end
	end
	--Spawn(function()
		if Delay then
			local AllAltered = false
			while not AllAltered and CheckIfAlive() do
				local AllCurrentlyAltered = true
				for i, v in pairs(Objects) do
					if ((Transparent and v.Object.Transparency < 1) or (not Transparent and v.Object.Transparency > v.Transparency)) then
						v.Object.Transparency = (v.Object.Transparency + (FadeRate * ((Transparent and 1) or -1)))
						AllCurrentlyAltered = false
					end
				end
				if AllCurrentlyAltered then
					AllAltered = true
				end
				wait()
			end
		end
		if not CheckIfAlive() then
			return
		end
		for i, v in pairs(Objects) do
			if Transparent then
				v.Object.Transparency = 1
			else
				ResetTransparency(v.Object)
			end
		end
	--end)
	return Objects
end

if not CheckIfAlive() or not Creator or not Tool or not Invisible or not Duration then
	DestroyScript()
	return
end

Invisible.Changed:connect(function()
	if Disabled then
		return
	end
	ResetTransparency()
	for i, v in pairs({DescendantAdded, DescendantRemoving}) do
		if v then
			v:disconnect()
		end
	end
	if Invisible.Value then
		Humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
		Humanoid.WalkSpeed = 22
		TransparentObjects = SetTransparency(Character, Invisible.Value, true)
		DescendantAdded = Character.DescendantAdded:connect(function(Child)
			local Objects = SetTransparency(Child, true, false)
			for i, v in pairs(Objects) do
				table.insert(TransparentObjects, v)
			end
		end)
		DescendantRemoving = Character.DescendantRemoving:connect(function(Child)
			ResetTransparency(Child)
		end)
	else
		Humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.Viewer
		Humanoid.WalkSpeed = 16
		SetTransparency(TransparentObjects, false, true, 0.025)
	end
end)

wait(Duration.Value)

SetTransparency(TransparentObjects, false, true, 0.025)

DestroyScript()