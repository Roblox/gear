local vCharacter = script.Parent
local myTorso = vCharacter:FindFirstChild("Torso")
local myHumanoid = vCharacter:FindFirstChild("Humanoid")
print(myTorso)

local thorn
local thornWeld 

local duration = 3.5

if myTorso and myHumanoid then
	myHumanoid.WalkSpeed = 0
	thorn = Instance.new("Part")
	thorn.FormFactor = 3
	thorn.Shape = "Block"
	thorn.Size = Vector3.new(2, 4, 2)
	thorn.CanCollide = true
	thorn.Position = myTorso.Position
	thorn.Parent = vCharacter	

	thornMesh = Instance.new("SpecialMesh")
	thornMesh.MeshId = "http://www.roblox.com/asset/?id=54653968"
	thornMesh.TextureId = "http://www.roblox.com/asset/?id=54654008"
	thornMesh.Scale = Vector3.new(1.0, 1.0, 0.8)
	thornMesh.Parent = thorn

	thornWeld = Instance.new("Weld")
	thornWeld.Parent = myTorso
	thornWeld.Part0 = myTorso
	thornWeld.Part1 = thorn
	thornWeld.C1 = CFrame.new(Vector3.new(0, 0, 0))		

	print("THORN CREATED")	
		
	myTorso.Anchored = true	
end

print(duration)
while duration > 0 do 
	duration = duration - 0.5	
	wait(0.5)
end

if thorn then thorn:Remove() end
if thornWeld then thornWeld:Remove() end
if myTorso then myTorso.Anchored = false end
if myHumanoid then myHumanoid.WalkSpeed = 16 end

wait(2.0)
script:Remove()
