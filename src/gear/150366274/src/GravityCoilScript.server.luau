--Made by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")
CoilSound = Handle:WaitForChild("CoilSound")

EqualizingForce = (236 / 1.2) -- amount of force required to levitate a mass
Gravity = 0.85 -- things float at > 1

GhostEffect = nil
MassCon1 = nil
MassCon2 = nil

function GetTotalMass(root)
	local force = 0
	
	for _, obj in pairs(root:GetChildren()) do
		if obj:IsA("BasePart") then
			force = force + obj:GetMass() * EqualizingForce * Gravity
		end
		force = force + GetTotalMass(obj)
	end
	
	return force
end

function OnMassChanged(child, character)
	if GhostEffect and GhostEffect.Parent then
		GhostEffect.force = Vector3.new(0, GetTotalMass(Character), 0)
	end
end

function UpdateGhostState(Unequipped)
	if Unequipped then
		GhostEffect:Destroy()
		GhostEffect = nil
		MassCon1:disconnect()
		MassCon2:disconnect()
	else
		if not GhostEffect then
			GhostEffect = Instance.new("BodyForce")
			GhostEffect.Name = "GravityCoilEffect"
			GhostEffect.force = Vector3.new(0, GetTotalMass(Character), 0)
			GhostEffect.Parent = Head
			MassCon1 = Character.ChildAdded:connect(function(Child)
				OnMassChanged(Child, Character)
			end)
			MassCon2 = Character.ChildRemoved:connect(function(Child)
				OnMassChanged(Child, Character)
			end)
		end
	end
end

function OnEquipped()
	Character = Tool.Parent
	Head = Character:FindFirstChild("Head")
	if not Head or not Head.Parent then
		return
	end
	CoilSound:Play()
	UpdateGhostState(false)
end

function OnUnequipped()
	UpdateGhostState(true)
end

Tool.Equipped:connect(OnEquipped)
Tool.Unequipped:connect(OnUnequipped)