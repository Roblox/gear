-- // Created by StarWars
local Debris = game:GetService("Debris")

local GearService = require(1075123174)

local tool = script.Parent
local gear = GearService:BindGear(tool)
gear:SetupRemoteFunctions()
gear:SetupLocalScript("MouseIcon")

local RELOAD_TIME = 2
local DAMAGE = 10
local MAX_FORCE = 50

function FireStar(start, direction)
	local newPart = Instance.new("Part")
	newPart.Size = Vector3.new(0.139, 1.316, 1.266)
	local mesh = Instance.new("SpecialMesh")
	mesh.MeshType = Enum.MeshType.FileMesh
	mesh.TextureId = "rbxassetid://2477749911"
	mesh.MeshId = "rbxassetid://2477749482"
	mesh.Parent = newPart
	
	local attachment = Instance.new("Attachment")
	attachment.Parent = newPart
	
	newPart.CanCollide = false
	 
	local vectorForce = Instance.new("VectorForce")
	vectorForce.RelativeTo = Enum.ActuatorRelativeTo.World
	vectorForce.Attachment0 = attachment
	vectorForce.ApplyAtCenterOfMass = true
	vectorForce.Force = (direction * MAX_FORCE) + Vector3.new(0, workspace.Gravity * newPart:GetMass() * 0.9, 0)
	vectorForce.Parent = newPart
	
	local torque = Instance.new("Torque")
	torque.RelativeTo = Enum.ActuatorRelativeTo.Attachment0
	torque.Attachment0 = attachment
	torque.Torque = Vector3.new(10, 0, 0)
	torque.Parent = newPart
	
	
	newPart.CFrame = CFrame.new(start, start + direction)
	newPart.Touched:Connect(function(hit)
		if hit:IsDescendantOf(gear.Character) or not hit.Parent then return end
		
		local parentTo = hit.Parent
		if parentTo:IsA("Accessory") or parentTo:IsA("Tool") then
			parentTo.Parent = parentTo.Parent
		end
		
		local humanoid = parentTo:FindFirstChildOfClass("Humanoid")
		if humanoid and humanoid.Health > 0 then
			humanoid:TakeDamage(DAMAGE)
		end
		
		newPart:Destroy()
	end)
	
	tool.Handle.Fire:Play()
	Debris:AddItem(newPart, 30)
	newPart.Parent = workspace
	newPart:SetNetworkOwner(gear.Player)
end

tool.Activated:Connect(function()
	if tool.Enabled and gear:IsPlayerAlive() then
		tool.Enabled = false
		
		local mouseData
		pcall(function()
			mouseData = gear.ClientControls:InvokeClient(gear.Player, "GetMouseData")
		end)
		
		if mouseData then
			local direction = (mouseData.Position - gear.RootPart.CFrame.p).Unit
			FireStar(gear.RootPart.CFrame.p, direction)
		end
		
		wait(RELOAD_TIME)
		tool.Enabled = true
	end
end)