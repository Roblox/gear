local Tool = script.Parent 
local Wings = Tool.Handle 

local Character
local Player 

local Torso 
local Humanoid 
local Head 

Tool.Enabled = true 

local JumpConnection 
local HeadConnection

local Debris = Game:GetService('Debris')

local BASE_URL = "http://www.roblox.com"

local RightWing = Instance.new('Part')
RightWing.FormFactor = 3
RightWing.Size = Vector3.new(1, 2, 1)
RightWing.CanCollide = false 
RightWing.Name = 'RightWing'

local Fire = Instance.new('Fire')
Fire.Parent = RightWing
Fire.Color = Color3.new(1, 1, 1)
Fire.Enabled = false 

local RightWingMesh = Instance.new('SpecialMesh')
RightWingMesh.MeshId = BASE_URL .. "/asset/?id=117468194"
RightWingMesh.TextureId = BASE_URL .. "/asset/?id=117468135"
RightWingMesh.Parent = RightWing

local LeftWing = Instance.new('Part')
LeftWing.FormFactor = 3
LeftWing.Size = Vector3.new(1, 3, 1)
LeftWing.Name = 'LeftWing'
LeftWing.CanCollide = false 

local LeftWingMesh = RightWingMesh:Clone()
LeftWingMesh.MeshId = BASE_URL .. "/asset/?id=117468191"
LeftWingMesh.Parent = LeftWing

local LFire = Fire:Clone()
LFire.Parent = LeftWeld

local RightWeld 
local LeftWeld 

local NewBV = nil
local NewBG = nil
local NewBAV = nil
local NewBP = nil

local Flapping = false 
local InDash = false 

local WingDamage = 5

local function LightenUp(hPart, wing, head)
	if hPart and hPart.Parent and wing and wing.Parent then 
		local humanoid = hPart.Parent:FindFirstChild('Humanoid')
		if hPart.Parent:IsA('Hat') and hPart.Parent.Parent then 
			humanoid = hPart.Parent.Parent:FindFirstChild('Humanoid')
		end 
		if humanoid and humanoid ~= Humanoid then 
			humanoid:TakeDamage(WingDamage)
			if wing:FindFirstChild('Fire') and not humanoid.Parent:FindFirstChild('WaspFireScript') then 
				local wScript = Tool:WaitForChild('WaspFireScript'):Clone()
				wScript.Parent = humanoid.Parent 
				wScript.Disabled = false 
			end 
		end 
	end 
end 

local function FlapWings(duration) 
	duration = duration or 1.0 
	Flapping = true 
	local rCFrame = RightWeld.C1 
	local lCFrame = LeftWeld.C1 

	local count = 1
	local anglePerFrame = 0.025

	if LeftWing:FindFirstChild('Fire') then 
		LeftWing.Fire.Enabled = true 
	end 

	if RightWing:FindFirstChild('Fire') then 
		RightWing.Fire.Enabled = true 
	end 

	while duration > 0 do 
		LeftWeld.C1 = LeftWeld.C1 * CFrame.Angles(0, anglePerFrame * (count%6), 0)
		RightWeld.C1 = RightWeld.C1 * CFrame.Angles(0, -anglePerFrame * (count%6), 0)		
		if count%6 == 0 then anglePerFrame = -anglePerFrame end 
		count = count + 1 
		duration = duration - wait() 
		wait()
	end 

	RightWeld.C1 = rCFrame 
	LeftWeld.C1 = lCFrame

	if LeftWing:FindFirstChild('Fire') then 
		LeftWing.Fire.Enabled = false 
	end 

	if RightWing:FindFirstChild('Fire') then 
		RightWing.Fire.Enabled = false 
	end 
	Flapping = false 
end 

local function WaspDash()	

	local target = Humanoid.TargetPoint

	InDash = true 

	Spawn(function()
		FlapWings(5.0)
	end)

	local direction = (target - Torso.Position) * Vector3.new(1, 0, 1)
	if direction.magnitude < .01 then Tool.Enabled = true return end
	direction = direction.unit

	local tPosition = Torso.Position

	NewBG = Instance.new("BodyGyro")
	NewBG.P = 30000
	NewBG.maxTorque = Vector3.new(NewBG.P, NewBG.P, NewBG.P)	
	
	NewBG.cframe = CFrame.new(tPosition, target * Vector3.new(1,0,1) + Vector3.new(0, tPosition.Y, 0) ) * CFrame.Angles(-math.pi/2, 0, 0)
	NewBG.Parent = Torso

	NewBP = Instance.new("BodyPosition")
	NewBP.P = 100000
	NewBP.maxForce = Vector3.new(NewBP.P, NewBP.P, NewBP.P)
	NewBP.position = tPosition + Vector3.new(0, 0.25, 0)
	NewBP.Parent = Torso

	NewBAV = Instance.new("BodyAngularVelocity")
	NewBAV.P = 100000
	NewBAV.maxTorque = Vector3.new(NewBAV.P, NewBAV.P, NewBAV.P)
	
	NewBV = Instance.new("BodyVelocity")
	NewBV.P = 100000
	NewBV.maxForce = Vector3.new(NewBV.P, 0, NewBV.P)
	NewBV.velocity = direction * 100
	
	wait(0.5)
	
	NewBG.maxTorque = Vector3.new(NewBP.P, 0, NewBP.P)
	NewBP.maxForce = Vector3.new(0, NewBP.P, 0)
	NewBV.Parent = Torso	
	
	NewBAV.Parent = Torso
	wait(1.5)	

	if NewBAV ~= nil then NewBAV:Destroy() end
	if NewBP ~= nil then NewBP:Destroy() end
	if NewBV ~= nil then NewBV:Destroy() end

	if NewBG ~= nil then NewBG.cframe = CFrame.new(tPosition, target * Vector3.new(1,0,1) + Vector3.new(0, tPosition.Y, 0) ) end
	if NewBG ~= nil then NewBG.maxTorque = Vector3.new(NewBG.P, NewBG.P, NewBG.P) end
	
	wait(.25)

	if NewBG ~= nil then NewBG:Destroy() end
	InDash = false 
end 

local function OnActivated()
	if not Tool.Enabled  then 
		return 
	end 

	if not Torso or not Humanoid then 
		return 
	end 

	Tool.Enabled = false 

	WaspDash()

	wait(2.5)
	Tool.Enabled = true 
end 

local function OnEquipped()
	Character = Tool.Parent 
	Player = Game.Players:GetPlayerFromCharacter(Character)
	Torso = Character:WaitForChild('Torso')
	Humanoid = Character:WaitForChild('Humanoid')
	Head = Character:WaitForChild('Head')

	Wings.Transparency = 1.0

	JumpConnection = Humanoid.Changed:connect(function(property)
		if property == 'Jump' and Humanoid['Jump'] == true then 
			if Flapping == false then 			
				FlapWings() 
			end 
		end 
	end)

	if RightWeld and LeftWeld then 
		RightWeld.Parent = Torso 
		LeftWeld.Parent = Torso 
		RightWing.Parent = Torso 
		LeftWing.Parent = Torso 
	elseif RightWing.Parent ~= Character then 
		RightWing.Parent = Character 

		RightWeld = Instance.new('Weld')
		RightWeld.Parent = Torso 
		RightWeld.Name = 'RightWingWeld'
		RightWeld.Part0 = Torso 
		RightWeld.Part1 = RightWing		

		LeftWeld = Instance.new('Weld')
		LeftWeld.Parent = Torso 
		LeftWeld.Name = 'LeftWingWeld'
		LeftWeld.Part0 = Torso 
		LeftWeld.Part1 = LeftWing

		LeftWing.Parent = Character 

		LeftWeld.C1 = LeftWeld.C1 + Vector3.new(0.3, 0, 0)
		RightWeld.C1 = RightWeld.C1 + Vector3.new(-0.3, 0, 0)
	end 

	RightWing.Touched:connect(function(hPart)
		LightenUp(hPart, RightWing)
	end)

	LeftWing.Touched:connect(function(hPart)
		LightenUp(hPart, LeftWing)
	end)

	HeadConnection = Head.Touched:connect(function(hPart)		
		if InDash and RightWing then 			
			LightenUp(hPart, RightWing, Head)
		end 
	end) 
end 

local function OnUnequipped()
	Wings.Transparency = 0.0 

	RightWing.Parent = nil 
	LeftWing.Parent = nil 
	RightWeld.Parent = nil 
	LeftWeld.Parent = nil 

	if JumpConnection then 
		JumpConnection:disconnect()
	end 

	if HeadConnection then 
		HeadConnection:disconnect()
	end 
end

Tool.Equipped:connect(OnEquipped)
Tool.Unequipped:connect(OnUnequipped)
Tool.Activated:connect(OnActivated)