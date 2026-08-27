vCharacter = script.Parent

myHumanoid = vCharacter:FindFirstChildOfClass("Humanoid")

myTorso = vCharacter:FindFirstChild("HumanoidRootPart") or vCharacter:FindFirstChild("Torso") or vCharacter:FindFirstChild("UpperTorso")
local TorsoNames = {"Root","Torso"} -- Used for gathering all of the torsos


local duration = script:WaitForChild("Duration",10).Value

local creatortag = script:WaitForChild("creator",10).Value

function TagHumanoid(humanoid, player)
	local Creator_Tag = Instance.new("ObjectValue")
	Creator_Tag.Name = "creator";
	Creator_Tag.Value = player;
	game:GetService("Debris"):AddItem(Creator_Tag, 2)
	Creator_Tag.Parent = humanoid
end
	
function UntagHumanoid(humanoid)
	for _, v in pairs(humanoid:GetChildren()) do
		if v:IsA("ObjectValue") and v.Name == "creator" then
			v:Destroy()
		end
	end
end


if vCharacter and myHumanoid  then
	myHumanoid.WalkSpeed = 0.0
	
	local AnchoredParts  = {}
	for _,v in pairs(vCharacter:GetChildren()) do
		for _,names in pairs(TorsoNames) do
			if v:IsA("BasePart") and string.find(string.lower(v.Name),string.lower(names)) then
				table.insert(AnchoredParts,v)
				v.Anchored = true
			end
		end
	end

	local thorn = Instance.new("Part")
	thorn.FormFactor = 3
	thorn.Shape = "Block"
	thorn.Size = Vector3.new(2, 4, 2)
	thorn.CanCollide = true
	thorn.Position = myTorso.Position
	thorn.Parent = vCharacter     

	local thornMesh = Instance.new("SpecialMesh")
	thornMesh.MeshId = "http://www.roblox.com/asset/?id=54653968"
	thornMesh.TextureId = "http://www.roblox.com/asset/?id=59793260"
	thornMesh.Scale = Vector3.new(1.0, 1.0, 0.8)
	thornMesh.Parent = thorn

	local thornWeld = Instance.new("Weld")
	thornWeld.Parent = myTorso
	thornWeld.Part0 = myTorso
	thornWeld.Part1 = thorn
	thornWeld.C1 = CFrame.new(Vector3.new(0, 0, 0)) 
	
	local Smoke = script:WaitForChild("Smoke")
	Smoke.Parent = thorn
	Smoke.Enabled = true
	
	local Sparkle = Instance.new("Sparkles")
	Sparkle.SparkleColor = Color3.fromRGB(85, 170, 255)
	Sparkle.Parent = thorn
	 
	while duration > 0 do 
		UntagHumanoid(myHumanoid)
		TagHumanoid(myHumanoid,creatortag)
		myHumanoid:TakeDamage(3)
		duration = duration - wait(0.5)
		wait(0.5)
	end

	if thorn then thorn:Destroy() end
	if thornWeld then thornWeld:Destroy() end
	myHumanoid.WalkSpeed = 16
	
	for _,v in pairs(AnchoredParts) do
		if v then 
			v.Anchored = false 
		end
	end
end

wait(2)
script:Destroy() 

