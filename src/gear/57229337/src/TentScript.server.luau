-- Open tent asset IDs:
-- Mesh: 56824172
-- Texture: 56824061

local Tool = script.Parent
local Bag = Tool.Handle

local vCharacter
local myTorso

Tool.Enabled = true 

local tent = Instance.new("Part")
tent.FormFactor = 3
tent.Size = Vector3.new(7, 7, 7)
tent.Shape = "Block"
tent.CanCollide = false
tent.Anchored = true
tent.Name = "Tent"

local tentMesh = Instance.new("SpecialMesh")
tentMesh.MeshId = "http://www.roblox.com/asset/?id=56824172"
tentMesh.TextureId = "http://www.roblox.com/asset/?id=56824061"
tentMesh.Parent = tent
tentMesh.Scale = Vector3.new(7, 7, 7)

local cloneTent
local cloneTent2

function onActivated()
	if Tool.Enabled == false then 
		return 	
	end
	print("Ohai")
	print(cloneTent)
	print(cloneTent2)
	if cloneTent or cloneTent2 then 
		return
	end
	print("Hi")
	Tool.Enabled = false

	vCharacter = Tool.Parent
	myTorso = vCharacter:FindFirstChild("Torso")
	if myTorso == nil then
		return
	end

	Bag.Transparency = 1.0
	
	cloneTent = tent:Clone()
	cloneTent.CFrame = (myTorso.CFrame + ((myTorso.CFrame.lookVector * 12.0) + Vector3.new(0, 2, 0))) * CFrame.Angles(-math.pi/2, 0, math.pi)
	cloneTent.Parent = game.Workspace

	cloneTent2 = tent:Clone()
	cloneTent2.CFrame = (myTorso.CFrame + ((myTorso.CFrame.lookVector * 12.0) + Vector3.new(0, 2, 0))) * CFrame.Angles(math.pi/2, 0, -math.pi)
	cloneTent2.Parent = game.Workspace
	cloneTent2.Mesh.Scale = Vector3.new(-7, -7, -7)
	
	wait(2.0)
	Tool.Enabled = true
end

function onEquipped()
end

function onUnequipped()
	if cloneTent then print("1") cloneTent:Remove() cloneTent = nil end
	if cloneTent2 then print("2") cloneTent2:Remove() cloneTent2 = nil end
	if Bag then Bag.Transparency = 0.0 end
end

Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)
Tool.Activated:connect(onActivated)