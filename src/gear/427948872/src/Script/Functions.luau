--Made by Luckymaxer

Players = game:GetService("Players")
Debris = game:GetService("Debris")

RbxUtility = LoadLibrary("RbxUtility")
Create = RbxUtility.Create

Functions = {}

function Functions.CheckTable(Table, Object)
	for i, v in pairs(Table) do
		if v == Object then
			return true
		end
	end
	return false
end

function Functions.FindCharacterAncestor(Parent)
	if Parent and Parent ~= game:GetService("Workspace") then
		local humanoid = Parent:FindFirstChild("Humanoid")
		if humanoid then
			return Parent, humanoid
		else
			return Functions.FindCharacterAncestor(Parent.Parent)
		end
	end
	return nil
end

function Functions.GetAllConnectedParts(Object)
	local Parts = {}
	local function GetConnectedParts(Object)
		for i, v in pairs(Object:GetConnectedParts()) do
			local Ignore = false
			for ii, vv in pairs(Parts) do
				if v == vv then
					Ignore = true
				end
			end
			if not Ignore then
				table.insert(Parts, v)
				GetConnectedParts(v)
			end
		end
	end
	GetConnectedParts(Object)
	return Parts
end

function Functions.CalculateRecursiveMass(RootPart)
	local Mass = 0
	local ConnectedParts = Functions.GetAllConnectedParts(RootPart)
	for i, v in pairs(ConnectedParts) do
		Mass = (Mass + v:GetMass())
	end
	return Mass
end

function Functions.ReflectVector3(Incoming, Normal)
	return (2 * ((-1 * Incoming):Dot(Normal)) * Normal + Incoming)
end

return Functions