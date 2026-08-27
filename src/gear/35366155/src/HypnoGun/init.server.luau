--Updated for R15 avatars by StarWars

local Tool = script.Parent;

Tool.Enabled = true

function hypnoBeam(lookAt)
	local vCharacter = Tool.Parent
	local vPlayer = game.Players:playerFromCharacter(vCharacter)
	local hypnoSphere = Instance.new("Part")
	newDecal = Tool.HypnoTex:Clone()
	newDecal.Parent = hypnoSphere
	newDecal.Face = 0
	newDecal = Tool.HypnoTex:Clone()
	newDecal.Parent = hypnoSphere
	newDecal.Face = 1
	newDecal = Tool.HypnoTex:Clone()
	newDecal.Parent = hypnoSphere
	newDecal.Face = 2
	newDecal = Tool.HypnoTex:Clone()
	newDecal.Parent = hypnoSphere
	newDecal.Face = 3
	newDecal = Tool.HypnoTex:Clone()
	newDecal.Parent = hypnoSphere
	newDecal.Face = 4
	newDecal = Tool.HypnoTex:Clone()
	newDecal.Parent = hypnoSphere
	newDecal.Face = 5
	
	hypnoSphere.BackSurface = 0
	hypnoSphere.BottomSurface = 0
	hypnoSphere.FrontSurface = 0
	hypnoSphere.LeftSurface = 0
	hypnoSphere.TopSurface = 0
	hypnoSphere.RightSurface = 0

	hypnoSphere.Shape = 0
	hypnoSphere.Size = Vector3.new(4,4,4)
	local RigthArm = vCharacter:FindFirstChild("Right Arm") or vCharacter:FindFirstChild("RightHand")
	hypnoSphere.CFrame = CFrame.new(RigthArm.Position)
	hypnoSphere.CanCollide = false
	newBP = Instance.new("BodyPosition")
	newBP.position = vCharacter.Head.Position + lookAt*20
	newBP.Parent = hypnoSphere
	m = hypnoSphere:GetMass()
	newBP.maxForce = Vector3.new(m*10,m*250,m*10)
	hypnoSphere.Parent = game.Workspace
	hypnoScript = script.HypnoScript:Clone()
	hypnoScript.Parent = hypnoSphere
	hypnoScript.Disabled = false

	local creator_tag = Instance.new("ObjectValue")
	creator_tag.Value = vPlayer
	creator_tag.Name = "creator"
	creator_tag.Parent = hypnoSphere

	hypnoScript.Disabled = false
end


function gunUp()
	Tool.GripForward = Vector3.new(0,.196,-.981)
	Tool.GripUp = Vector3.new(0,.981,-.196)
end

function gunOut()
	Tool.GripForward = Vector3.new(0,0,-1)
	Tool.GripUp = Vector3.new(0,1,0)
end


function onActivated()
	if not Tool.Enabled  then
		return
	end

	Tool.Enabled = false


	local character = Tool.Parent;
	local humanoid = character.Humanoid
	if humanoid == nil then
		print("Humanoid not found")
		return 
	end

	local targetPos = humanoid.TargetPoint
	local lookAt = (targetPos - character.Head.Position).unit


	hypster = Tool.Parent:FindFirstChild("HypnoSound")
	if hypster == nil then
		hypster = Instance.new("Sound")
		hypster.Name = "HypnoSound"
		hypster.Volume = .8
		hypster.SoundId = "http://www.roblox.com/asset/?id=35275837"
		hypster.Parent = Tool.Parent
	end

	hypster2 = Tool.Parent:FindFirstChild("HypnoSound2")
	if hypster2 == nil then
		hypster2 = Instance.new("Sound")
		hypster2.Name = "HypnoSound2"
		hypster2.Volume = .8
		hypster2.SoundId = "http://www.roblox.com/asset/?id=35275883"
		hypster2.Parent = Tool.Parent
	end
	
	hypster:Play()
	hypster2:Play()

	gunUp()
	hypnoBeam(lookAt)
	wait(.75)
	gunOut()
	wait(2.75)
	hypster2:Stop()
	Tool.Enabled = true
end

script.Parent.Activated:connect(onActivated)

