-- Unwing this flyer! 

local function WaitForChild(parent, child)
	while not parent:FindFirstChild(child) do 
		parent.ChildAdded:Wait()
	end 
	return parent[child]
end 

local Character = script.Parent 
local Torso = WaitForChild(Character, 'HumanoidRootPart')
local Humanoid = Character:FindFirstChildOfClass("Humanoid")

local RBX_Debris = game:GetService('Debris')

local Wing_List = {['RightWing'] = true, ['LeftWing'] = true}
local cChildren = Character:GetChildren()
for k = 1, #cChildren do
	if cChildren[k]:IsA('BasePart') and Wing_List[cChildren[k].Name] then 
		local wing = cChildren[k]
		wing:BreakJoints() 	
		RBX_Debris:AddItem(wing, 7.5)
	end

	if cChildren[k]:IsA('Tool') then 
		Humanoid:UnequipTools()
		cChildren[k]:Destroy()
	end 
end 

Torso.Anchored = true 

local Thorn_Part = Instance.new('Part')
Thorn_Part.CanCollide = false 
Thorn_Part.Size = Vector3.new(2, 4, 2)
Thorn_Part.CFrame = Torso.CFrame 
Thorn_Part.Anchored = true 
Thorn_Part.Parent = Character 

Thorn_Mesh = Instance.new("SpecialMesh") 
Thorn_Mesh.MeshId = "http://www.roblox.com/asset/?id=54653968" 
Thorn_Mesh.TextureId = "http://www.roblox.com/asset/?id=54654008" 
Thorn_Mesh.Scale = Vector3.new(1.0, 1.0, 0.6) 
Thorn_Mesh.Parent = Thorn_Part
Thorn_Mesh.VertexColor = Vector3.new(0.1, 0.1, 0.9)


local tChildren = Torso:GetChildren()
for i = 1, #tChildren do 
	if tChildren[i] and string.sub(tChildren[i].Name, 1, 6) == 'Flight' then 
		tChildren[i]:Destroy() 
	end 
end 

wait(3.75)
for i,v in pairs(Character:GetDescendants()) do
	if v:IsA("BasePart") and v.Name == "Torso" or v.Name == "HumanoidRootPart" then
		v.Anchored = false
	elseif v:IsA("BodyVelocity") or v:IsA("BodyThrust") or v:IsA("BodyPosition") then
		v:Destroy()
	end
end
Thorn_Part:Destroy()

wait(1)

script:Destroy() 


