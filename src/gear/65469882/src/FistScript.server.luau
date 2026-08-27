local Tool = script.Parent
local Fist = Tool.Handle

local vCharacter
local myTorso
local myHumanoid
local vPlayer

local playAnim

local debris = game:GetService("Debris")

local damage = 20

local bv

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
		local humanoid = hit.Parent:FindFirstChild("Humanoid")
		if hit.Parent.className == "Hat" and hit.Parent.Parent then 
			humanoid = hit.Parent.Parent:FindFirstChild("Humanoid")
		end
		if humanoid and myHumanoid and humanoid ~= myHumanoid then 
			local opponent = humanoid.Parent:FindFirstChild("Torso")
			tagHumanoid(humanoid, vPlayer)
			humanoid:TakeDamage(damage)
			if opponent then
				local bodyVelocity = Instance.new("BodyVelocity") 
				bodyVelocity.P = 100000 
				bodyVelocity.maxForce = Vector3.new(bodyVelocity.P, bodyVelocity.P, bodyVelocity.P) 
				bodyVelocity.velocity = (opponent.Position - myTorso.Position) * 15
				bodyVelocity.Parent = opponent 
				wait(0.5) 
				if bodyVelocity ~= nil then bodyVelocity:remove() end 				
			end
		end
	end
end


Tool.Enabled = true

function onActivated()
	if Tool.Enabled == false then 
		return 
	end

	if myTorso == nil or myHumanoid == nil then 
		return
	end

	playAnim = Tool:FindFirstChild("PlayAnim")
	if playAnim then
		if playAnim.Value == false then 
			playAnim.Value = true 
		else 
			return 
		end
	end 

	Tool.Enabled = false 

	local target = myHumanoid.TargetPoint 
	local direction = (target - Fist.Position).unit

	bv = Instance.new("BodyVelocity")
	bv.P = 500000
	bv.maxForce = Vector3.new(bv.P, bv.P, bv.P)
	bv.velocity = direction * 60.0
	bv.Parent = myTorso

	myTorso.CFrame = CFrame.new(myTorso.Position, myTorso.Position + direction) 

	wait(0.5)
	if bv then bv:Remove() end

	wait(2.0)
	Tool.Enabled = true
end

function onEquipped()
	vCharacter = Tool.Parent 
	myTorso = vCharacter:FindFirstChild("Torso")
	myHumanoid = vCharacter:FindFirstChild("Humanoid")
	vPlayer = game.Players:GetPlayerFromCharacter(vCharacter)
	
	local ratio = myHumanoid.Health/myHumanoid.MaxHealth
	myHumanoid.MaxHealth = 150 	
	while myHumanoid.Health < ratio * 150 do 
		myHumanoid.Health = ratio * 150 
		wait()
	end
end

function onUnequipped()
	if bv then bv:Remove() end
	
	myHumanoid.Health = myHumanoid.Health/myHumanoid.MaxHealth * 100 
	myHumanoid.MaxHealth = 100
end

Tool.Activated:connect(onActivated)
Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)

Fist.Touched:connect(blow)
