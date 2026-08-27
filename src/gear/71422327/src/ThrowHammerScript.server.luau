local Tool = script.Parent 
local Hammer = Tool.Handle

local vCharacter 
local myTorso
local myHumanoid 

local damage = 13

local throwHammer 

local debris = game:GetService("Debris")

local hammerClone 

function tagHumanoid(humanoid, player)
	if humanoid then 
		local creatorTag = Instance.new("ObjectValue")
		creatorTag.Name = "creator"
		creatorTag.Value = player 
		creatorTag.Parent = humanoid 
		debris:AddItem(creatorTag, 1)
	end 
end 

function blow(hit)
	if hit and hit.Parent then
		local humanoid 	
		humanoid = hit.Parent:FindFirstChild("Humanoid")
		if hit.Parent:IsA("Hat") and hit.Parent.Parent then
			humanoid = hit.Parent.Parent:FindFirstChild("Humanoid")
		end 
		if humanoid and myHumanoid and humanoid ~= myHumanoid then 
			tagHumanoid(humanoid, vPlayer)
			humanoid:TakeDamage(damage)
			if hit:FindFirstChild("Fire") == nil then 
				local fire = Instance.new("Fire")
				fire.Parent = hit 
				fire.Color = Color3.new(0, 204/255, 1)
				fire.SecondaryColor = Color3.new(0, 0, 1)
	
				debris:AddItem(fire, 3)
			end 

			local torso = hit.Parent:FindFirstChild("Torso")

			if torso and not torso:FindFirstChild("HammerBV") then
				local bv = Instance.new("BodyVelocity")
				bv.Name = "HammerBV"
				bv.P = 50000
				bv.maxForce = Vector3.new(bv.P, bv.P, bv.P)
				bv.velocity = (torso.Position - myTorso.Position).unit * 15.0 			
				debris:AddItem(bv, 1.25)
				
				humanoid.Sit = true 
			end 
		

			if hit.Parent:FindFirstChild("FreezingHammerSlowScript") == nil then 
				local freezeScript = Tool.FreezingHammerSlowScript:Clone()
				freezeScript.Parent = hit.Parent 
				freezeScript.Disabled = false
			end 
		end 
	end 
end 

function onEquipped()
	vCharacter = Tool.Parent 
	myTorso = vCharacter:FindFirstChild("Torso")
	myHumanoid = vCharacter:FindFirstChild("Humanoid")
end 

Tool.Equipped:connect(onEquipped)

while Tool:FindFirstChild("ThrowHammer") == nil do 
	wait()
end

throwHammer = Tool.ThrowHammer

throwHammer.Changed:connect(function() 
	if myTorso and myHumanoid and throwHammer and throwHammer.Value == true then 		
		hammerClone = Hammer:Clone()		
		
		hammerClone.CFrame = Hammer.CFrame --* CFrame.Angles(0, -math.pi/2, 0)
		
		local float = Instance.new("BodyForce") 
		float.Parent = hammerClone
		float.force = Vector3.new(0, hammerClone:GetMass() * 196.1, 0)

		local target = myHumanoid.TargetPoint 
		local direction = (target - myTorso.Position).unit 

		wait(0.30) 
		Hammer.Transparency = 1.0 		
		hammerClone.Velocity = direction * 60.0
		hammerClone.RotVelocity = Vector3.new(20, 0, 0)

		hammerClone.Parent = game.Workspace 
		hammerClone.Touched:connect(blow)

		debris:AddItem(hammerClone, 5)
		Tool.Enabled = false
		wait(9.0)
		Hammer.Transparency = 0.0
		Tool.Enabled = true
		wait(5.0)
		throwHammer.Value = false 
	end 
end)


