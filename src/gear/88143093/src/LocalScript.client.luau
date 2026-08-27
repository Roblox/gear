--Made by SolarCrane

local Tool = script.Parent
--plr=game.Players.localPlayer

local buttonUp = false

local RBX_Debris = game:GetService('Debris')

local Mouse

local sparkleHolder
local startColor = Vector3.new(0, 0, 255)
local endColor = Vector3.new(255, 0, 0)

local timeToTarget = 1.25



local myHumanoid

-- Animation
local ChargeAnim


-- Create the pig mesh
local pig = Instance.new('SpecialMesh', rightParticle)
pig.MeshId = 'http://www.roblox.com/asset/?id=15898670'
pig.TextureId = 'http://www.roblox.com/asset/?id=15898665'

function checkintangible(hit)
	if hit and hit~=nil then
		if hit:IsDescendantOf(Tool.Parent) or hit.Transparency>.9 or hit.Name=="Handle" or hit.Name=="Effect" or hit.Name=="Bullet" or hit.Name=="Laser" or string.lower(hit.Name)=="water" then
			return true
		end
	end
	return false
end

function castray(startpos,vec,length,ignore,delayifhit)
	local hit,endpos2=game.Workspace:FindPartOnRay(Ray.new(startpos,vec*length),ignore)
	if hit~=nil then
		if checkintangible(hit) then
			if delayifhit then
				wait()
			end
			hit,endpos2=castray(endpos2+(vec*.01),vec,length-((startpos-endpos2).magnitude),ignore,delayifhit)
		end
	end
	return hit,endpos2
end

-- Todo: improve to use proper tail-call recursion
-- http://weknowmemes.com/wp-content/uploads/2011/11/your-mother-is-so-fat-her-mass-causes-a-stack-overflow.jpg
function calculateMassRecursive(rootPart)
	local sum = 0
	if rootPart:IsA('Part') then sum = sum + rootPart:GetMass() end
	for _, v in pairs(rootPart:GetChildren()) do
		sum = sum + calculateMassRecursive(v)
	end
	return sum
end


function shootParticles(origin, distance, vDirection)
	local rightParticle = Instance.new('Part', Workspace)
	RBX_Debris:AddItem(rightParticle, timeToTarget * 2)
	rightParticle.Shape = Enum.PartType.Ball
	rightParticle.FormFactor = Enum.FormFactor.Symmetric
	rightParticle.Size = Vector3.new(1, 1, 1)
	rightParticle.CanCollide = false
	--local vTorso = Tool.Parent.Torso
	--local origin = vTorso.CFrame.p
	local lookDir = vDirection
	local rightDir = lookDir:Cross(Vector3.new(0, 1, 0)).unit
	local outwardDir = rightDir * (distance / (2 * timeToTarget)) * 2
	local mass = calculateMassRecursive(rightParticle)
	
	rightParticle.Velocity = outwardDir
	-- Using the freefall equation we can derive that F = M * V0 / -t
	local comeBackForce = mass * rightParticle.Velocity / timeToTarget * -1
	local floatingForce = Vector3.new(0, mass * 196.2, 0)
	local forwardVel = lookDir * (distance / (2 * timeToTarget))
	rightParticle.Velocity = rightParticle.Velocity + forwardVel
	rightParticle.RotVelocity = Vector3.new(math.rad(math.random(-360, 360)) * 2,
																	math.rad(math.random(-360, 360)) * 2,
																	math.rad(math.random(-360, 360)) * 2)
	--rightParticle.CFrame = CFrame.new(origin, origin + rightParticle.Velocity)
	rightParticle.Position = origin
	local counteringForce = Instance.new('BodyForce')
	counteringForce.force = comeBackForce + floatingForce
	counteringForce.Parent = rightParticle
	counteringForce.Name = 'CounteringForce'
	

	-- Add some fire to the particle
	local fire = Instance.new('Fire', rightParticle)
	fire.Size = 1
	fire.Heat = 1
	fire.Color = Color3.new(10/255, 10/255, 10/255)
	

	pig:Clone().Parent = rightParticle

	local leftParticle = rightParticle:Clone()
	leftParticle.Name = 'LeftParticle'
	leftParticle.Parent = Workspace
	RBX_Debris:AddItem(leftParticle, timeToTarget * 2)
	leftParticle.Velocity = forwardVel + -1 * outwardDir
	--leftParticle.CFrame = CFrame.new(origin, origin + leftParticle.Velocity)
	leftParticle:FindFirstChild('CounteringForce').force = floatingForce + (comeBackForce * -1)


	-- For now I am going to do a wait until the particles collide
	-- it may be better in the future to actual create a triger volume at the expected destination
	wait(timeToTarget * 2)
	if Tool:FindFirstChild('ExplosionScript') then
		local scriptCopy = Tool:FindFirstChild('ExplosionScript'):Clone()
		scriptCopy.Parent = leftParticle
		scriptCopy.Disabled = false
		local explosionCopy = Tool:FindFirstChild('Explosion'):Clone()
		explosionCopy.Parent = leftParticle
		wait(0.1)
		scriptCopy.Disabled = true
	end
	local hitLocation = origin + forwardVel * timeToTarget * 2
	local explosion = Instance.new('Explosion', Workspace)
	explosion.Position = hitLocation
	explosion.BlastRadius = 15
	--fire.Anchored = true
	
end


function mouseUp()
	buttonUp = true
	if Tool:FindFirstChild('Charge').Value == 100 then
		--fire
		print("Firing")
		Tool:FindFirstChild('Charge').Value = 0
		local vTorso = Tool.Parent.Torso
		local startpos = vTorso.CFrame.p
		if Tool and Tool.Handle then
			startpos = Tool.Handle.Position
		end
		local vDirection = vTorso.CFrame.lookVector
		if Mouse then 
			vDirection = (Mouse.Hit.p-startpos).unit
		end
		local hit, loc = castray(startpos, (Mouse.Hit.p-startpos).unit, 200, Tool.Parent, false)
		local distance = 150
		if hit and distance > 20 then
			distance = (loc - startpos).magnitude
		end
		if sparkleHolder and sparkleHolder:FindFirstChild('Sparkles') then
			sparkleHolder:FindFirstChild('Sparkles'):Remove()
			if ChargeAnim then ChargeAnim:Stop() end
		end
		shootParticles(startpos, distance, vDirection)
	end
end


function mouseDown()
	buttonUp = false
	while not buttonUp do
		wait(0.1)
	if not sparkleHolder then
		sparkleHolder = Instance.new("Part", Tool)
		sparkleHolder.Transparency = 1
		sparkleHolder.CanCollide= false
		sparkleHolder.Size = Vector3.new(1, 1, 1)
		sparkleHolder.Position = Tool.Handle.Position
		local Weld = Instance.new("ManualWeld")
		Weld.C0 = CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
		Weld.C1 = CFrame.new(0.049407959, 0.30989188, -1.74499893, 0.999999881, -0.000551184872, -5.29387343e-008, 0.000551184872, 0.999999762, 1.45519152e-011, 4.31729106e-008, -1.45519152e-011, 1)
		Weld.Part0 = sparkleHolder
		Weld.Part1 = Tool.Handle
		Weld.Parent = sparkleHolder
	end
		Tool:FindFirstChild('Charge').Value = Tool:FindFirstChild('Charge').Value + 10
		if Tool:FindFirstChild('Charge').Value > 20 and sparkleHolder and not sparkleHolder:FindFirstChild('Sparkles') then
			local sparkles = Instance.new("Sparkles", sparkleHolder)
			sparkles.Name = 'Sparkles'
			--if ChargeAnim:IsNotPlaying() then
				if ChargeAnim then ChargeAnim:Play() end
			--end
		end
		if sparkleHolder:FindFirstChild('Sparkles') then
			local vCurrSparkleColor = startColor:Lerp(endColor, Tool:FindFirstChild('Charge').Value / 100)
			sparkleHolder:FindFirstChild('Sparkles').SparkleColor = Color3.new(vCurrSparkleColor.x, vCurrSparkleColor.y, vCurrSparkleColor.z)
		end
		--sparkleHolder.Sparkles.Size = Vector3.new(charge / 20, charge / 20, charge / 20)
		--print('Charging ' .. charge)
	end
end


function onEquipped(mouse)
	equipped=true
	Tool:FindFirstChild('Charge').Value = 1
	myHumanoid = Tool.Parent:FindFirstChild("Humanoid")
	ChargeAnim = myHumanoid:LoadAnimation(Tool.UnstableCharge)
	if mouse~=nil then
		if not Tool.Enabled then 
			mouse.Icon = "rbxasset://textures\\GunWaitCursor.png"
			wait(2) 
			Tool.Enabled = true 
		end
		Mouse = mouse
		Mouse.Icon="rbxasset://textures\\GunCursor.png"
		Mouse.Button1Down:connect(mouseDown)
		Mouse.Button1Up:connect(mouseUp)
	end
end

function onUnequipped()
	myHumanoid = nil
	if sparkleHolder then
		sparkleHolder:Remove()
		sparkleHolder = nil
	end
	if ChargeAnim then
		ChargeAnim:Stop()
		ChargeAnim = nil
	end
	buttonUp = false
end

Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)





