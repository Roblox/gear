local Player = script.Parent
local transparencyFader = 0.1
local playerStuff = Player:GetDescendants()

local meshArray = {}
local face = nil
local decals = {}

for i = 1,10 do
	meshArray[i] = {0,0}
end

-- various meshes to transform into
meshArray[1] = {"http://www.roblox.com/asset/?id=24102128","http://www.roblox.com/asset/?id=24102113"}
meshArray[2] = {"http://www.roblox.com/asset/?id=15089001","http://www.roblox.com/asset/?id=15088976"}
meshArray[3] = {"http://www.roblox.com/asset/?id=11641931","http://www.roblox.com/asset/?id=11641912"}
meshArray[4] = {"http://www.roblox.com/asset/?id=1290033","http://www.roblox.com/asset/?id=1290030"}
meshArray[5] = {"http://www.roblox.com/asset/?id=14846869","http://www.roblox.com/asset/?id=14846834"}
meshArray[6] = {"http://www.roblox.com/asset/?id=16190555","http://www.roblox.com/asset/?id=16285875"}
meshArray[7] = {"http://www.roblox.com/asset/?id=1082816","http://www.roblox.com/asset/?id=28775189"}
meshArray[8] = {"http://www.roblox.com/asset/?id=1029586","http://www.roblox.com/asset/?id=1029588"}
meshArray[9] = {"http://www.roblox.com/asset/?id=19380188","http://www.roblox.com/asset/?id=19380153"}
meshArray[10] = {"http://www.roblox.com/asset/?id=25646277","http://www.roblox.com/asset/?id=26415302"}

for j = 1,10 do
	for i = 1, #playerStuff do
		local thing = playerStuff[i]
		if playerStuff[i]:IsA("BasePart") then
			playerStuff[i].Transparency = playerStuff[i].Transparency + transparencyFader
			if thing:FindFirstChildOfClass("Decal") then
				thing:FindFirstChildOfClass("Decal").Transparency = thing:FindFirstChildOfClass("Decal").Transparency + transparencyFader
			end
		elseif playerStuff[i]:IsA("Accoutrement") then
			playerStuff[i].Handle.Transparency = playerStuff[i].Handle.Transparency + transparencyFader
		elseif playerStuff[i]:IsA("Tool") then
			playerStuff[i].Handle.Transparency = playerStuff[i].Handle.Transparency + transparencyFader
		end

	end
	wait()
end

local torso = Player:FindFirstChild("Torso") or Player:FindFirstChild("UpperTorso")
local rightLeg = Player:FindFirstChild("Right Leg") or Player:FindFirstChild("RightUpperLeg")

local part = Instance.new("Part")
part.Position = rightLeg.Position

local meshToUse = math.random(1,10)
specialMesh = Instance.new("SpecialMesh")
specialMesh.MeshId = meshArray[meshToUse][1]
specialMesh.TextureId = meshArray[meshToUse][2]
specialMesh.Parent = part

part.Parent = Player
part.Name = "Transmorph"

local weld = nil

if rightLeg then
	weld = Instance.new("Weld")
	weld.Parent = part
	weld.Part0 = part
	weld.Part1 = torso
	if meshToUse == 2 then
		weld.C0 = CFrame.new(0,0,1.8) * CFrame.Angles(math.pi/2,math.pi/2,0)
	elseif meshToUse == 3 then
		weld.C0 = CFrame.new(0,2,0)
	elseif meshToUse == 7 then
		weld.C0 = CFrame.new(0,0,2.5) * CFrame.Angles(math.pi/2,0,0)
	elseif meshToUse == 10 then
		weld.C0 = CFrame.new(0,1,0) * CFrame.Angles(0,math.pi/2,0)
	else
		weld.C0 = CFrame.new(0,2.5,0)
	end
end

wait(15)

part.Parent = nil
part:Destroy()
function recursive(root,class,func)
	for i,v in pairs(root:GetDescendants()) do
		if v:IsA(class) and v.Name~='HumanoidRootPart' then
			func(v)
		end
		recursive(v,class,func)
	end
end

for i=1,0,-0.1 do --Count backwards ftw
	wait()
	recursive(Player,"BasePart",function(c) c.Transparency=i end)
	recursive(Player,"Decal",function(c) c.Transparency=i end)
end

script:Destroy()

