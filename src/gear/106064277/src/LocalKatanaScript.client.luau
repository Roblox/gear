local Tool = script.Parent
Tool.Enabled = true

local r = game:GetService("RunService")

--invisible forces to move player around
--body velocity
local newBV = nil
--body gyro
local newBG = nil
--body angualar velocity
local newBAV = nil
--body position
local newBP = nil

local slashSound = Tool.Handle.SlashSound
local spinSound = Tool.Handle.SpinSound
local whackSound = Tool.Handle.WhackSound


function ChangeColor(part)
	if part.Parent == Tool or part.Parent == Tool.Parent then return end
	part.BrickColor = BrickColor.new('Pink')
	for _, i in pairs(part:GetChildren()) do
		if i:IsA('DataModelMesh') then
			i.VertexColor = Vector3.new(0.8, 0.3, 0.6)
			if i:IsA('FileMesh') and i.MeshId ~= "" then
				i.TextureId = 'http://www.roblox.com/asset/?id=105905724'
			end
			
		end
		
	end
	if part.Parent:FindFirstChild('Humanoid') then
		for _, i in pairs(part.Parent:GetChildren()) do
			if i:IsA('CharacterMesh') then
				i.BaseTextureId =  105907211 
				i.OverlayTextureId =  105907211 
			end
			if i:IsA('Hat') and i:FindFirstChild('Handle') then
				ChangeColor(i.Handle)
			end
			if i:IsA('Shirt') then
				i:Destroy()
			end
			if i:IsA('Pants') then
				i:Destroy()
			end
		end
	end
	
end


function FirePinksplosion(self)
	local startSize = Vector3.new(.2,.2,.2)
	local endSize = Vector3.new(2,2,2)*self.BlastRadius
	local npart = Instance.new('Part')
	npart.Shape = 'Ball'
	--npart.Anchored = true
	local nbodypos = Instance.new('BodyPosition')
	nbodypos.position = self.Position
	nbodypos.maxForce = Vector3.new(5000,math.huge,5000)
	nbodypos.Parent = npart
	npart.Size = startSize
	npart.CFrame = Tool.Handle.CFrame
	npart.Transparency =.5
	npart.BrickColor = BrickColor.new('Pink')
	npart.CanCollide = false
	npart.Parent = Tool.Parent
	npart.Touched:connect(self.Hit)

	game.Debris:addItem(npart,3.5)
	Delay(.5,function() 
		local startTime = tick()
		while tick()-startTime<2.5 do
			npart.Transparency = .5+(.5*(((tick()-startTime)/2.5)))

			wait()
		end
	end)
	Spawn(function()
		local startTime = tick()
		while tick()-startTime<3 do
			npart.Size = startSize:Lerp(endSize,(tick()-startTime)/3)
			npart.CFrame = CFrame.new(self.Position)
			wait()
		end
	end)
	
end



--hum = local player's humanoid model
--torso = local player's torso
function slashIt(hum, torso)
	nsAnim = hum:LoadAnimation(Tool["Ninja Slash"])
	if nsAnim == nil then Tool.Enabled = true return end
	
	nsAnim:Play()
	--where the player's torso is pointing
	if game.Players.NumPlayers>1 then 
		target = getNearestPlayer().Character.Torso.CFrame.p  
	else target = hum.TargetPoint end

	local dir = (target - torso.Position) * Vector3.new(1, 0, 1)
	newBV = nil
	if dir.magnitude > .01 then 
		-- make 'em dash forwards too
		dir = dir.unit
		newBV = Instance.new("BodyVelocity")
		newBV.P = 100000
		newBV.maxForce = Vector3.new(newBV.P, 0, newBV.P)
		newBV.velocity = dir * 50
		newBV.Parent = torso

		torso.CFrame = CFrame.new(torso.Position, target * Vector3.new(1, 0, 1) + Vector3.new(0, torso.Position.Y, 0))
	end
	
	wait(.5)
	slashSound:Play()
	if newBV ~= nil then newBV:remove() end
	nsAnim:Stop()
	wait(.5)
end

function blowIt(iterations)

	nsAnim = hum:LoadAnimation(Tool["dualslash2"])
	nsAnim:Play()
	wait(.75)
	--create line explosion
	local exp_loc=Tool.Handle.CFrame.p
	--local exp_dir= Vector3.new(Tool.Parent.Torso.CFrame.lookVector)
	local exp_dir= torso.CFrame.lookVector
	Tool.lineExplosion:Play()
	for i=2, iterations, 1 do
		local explosion = {}
		explosion.ExplosionType = Enum.ExplosionType.NoCraters
		explosion.Position=exp_loc+(exp_dir*(i*10))
		explosion.BlastPressure = 1
		explosion.BlastRadius = 10
		explosion.Hit=function(cpart)
			ChangeColor(cpart)
		end
		FirePinksplosion(explosion)
		--explosion.Parent = Workspace
		wait(.05)
	end
	
end

--returns closest player object
function getNearestPlayer()
	local nearest=nil
	local nearest_distance=0
	local tdist = 0
	local parent_pos= game.Players.LocalPlayer.Character.Torso.CFrame.p
	local player= nil
	for _, player in pairs(game.Players:GetPlayers()) do
		print (player)
		if player.Character and player~=game.Players.LocalPlayer then
			tdist= (player.Character.Torso.CFrame.p-parent_pos).magnitude
			if nearest==nil or tdist<nearest_distance then
				nearest_distance=tdist
				nearest=player
			end
		end
	end
	return nearest
end

--hum = local player's humanoid model
--torso = local player's torso
function dashIt(hum, torso)

	ndAnim = hum:LoadAnimation(Tool["Ninja Dash"])
	if ndAnim == nil then Tool.Enabled = true return end
	wait(0)
	if game.Players.NumPlayers>1 then 
		target = getNearestPlayer().Character.Torso.CFrame.p  
	else target = hum.TargetPoint end

	print (target)
	local dir = (target - torso.Position) * Vector3.new(1, 0, 1)
	if dir.magnitude < .01 then Tool.Enabled = true return end
	dir = dir.unit

	newBG = Instance.new("BodyGyro")
	newBG.P = 30000
	newBG.maxTorque = Vector3.new(newBG.P, newBG.P, newBG.P)
	--newBG.cframe = torso.CFrame * CFrame.Angles(-math.pi/2, 0, 0)
	local torsoPosition = torso.Position
	newBG.cframe = CFrame.new(torsoPosition, target*Vector3.new(1,0,1) + Vector3.new(0, torsoPosition.Y, 0) ) * CFrame.Angles(-math.pi/2, 0, 0)
	--newBG.Parent = torso
	
	newBP = Instance.new("BodyPosition")
	newBP.P = 100000
	newBP.maxForce = Vector3.new(newBP.P, newBP.P, newBP.P)
	newBP.position = torsoPosition + Vector3.new(0, 1.5, 0)
	newBP.Parent = torso

	newBAV = Instance.new("BodyAngularVelocity")
	newBAV.P = 100000
	newBAV.maxTorque = Vector3.new(newBAV.P, newBAV.P, newBAV.P)
	
	newBV = Instance.new("BodyVelocity")
	newBV.P = 100000
	newBV.maxForce = Vector3.new(newBV.P, 0, newBV.P)
	newBV.velocity = dir * 64

	ndAnim:Play()
	Tool.Grip = CFrame.new(0, -2, 0, 0.707106769, 0, 0.707106769, 0.707106769, -4.37113883e-008, -0.707106769, 3.09086197e-008, 1, -3.09086197e-008)
	wait(.5)
	spinSound:Play()
	newBG.maxTorque = Vector3.new(newBP.P, 0, newBP.P)
	newBP.maxForce = Vector3.new(0, newBP.P, 0)
	newBV.Parent = torso

	newBAV.angularvelocity = torso.CFrame:vectorToWorldSpace(Vector3.new(0, -30, 0))
	hum.Sit = true
	newBAV.Parent = torso
	
	wait(1)

	hum.Sit = false
	if newBAV ~= nil then newBAV:remove() end
	if newBP ~= nil then newBP:remove() end
	if newBV ~= nil then newBV:remove() end

	if newBG ~= nil then newBG.cframe = CFrame.new(torsoPosition, target*Vector3.new(1,0,1) + Vector3.new(0, torsoPosition.Y, 0) ) end
	if newBG ~= nil then newBG.maxTorque = Vector3.new(newBG.P, newBG.P, newBG.P) end
	spinSound:Stop()
	wait(.25)
	if newBG ~= nil then newBG:remove() end
	ndAnim:Stop()
	Tool.Grip = CFrame.new(0, -2, 0, 1, -0, -0, 0, 1, -0, 0, 0, 1)
end

local ultra_step_num=-1
--time last key was pressed
local lastWDown = 0
local lastADown = 0
local lastDDown = 0
--time that dash was activated(see onKeyDown)
local dashTime = 0
--time of last slatsh effect
local lastSlash = 0
local lastSuperStrike = 0
local amAnimating = false
function onActivated()
	--cant find vChar's declaration??
	--vChar=player?
	vChar = Tool.Parent
	if vChar == nil then return end
	--hum = humanoid(player model)
	hum = vChar:FindFirstChild("Humanoid")
	if hum == nil then return end
	--if not Tool.Enabled then return end
	if amAnimating then return end
	Tool.Enabled = false
	amAnimating = true

	torso = vChar:FindFirstChild("Torso")
	if torso == nil then Tool.Enabled = true return end

	t = r.Stepped:wait()
	if t - lastSuperStrike < .2 then
		blowIt(10)
		wait(.5)  -- reload time
		amAnimating = false
	elseif t - dashTime < .2 then		--special double click
		-- dash attack
		dashIt(hum, torso)
		wait(.5)  -- reload time
		amAnimating = false
	elseif t - lastSlash < .2 then	--normal double click
		-- slash attack
		slashIt(hum, torso)
		--wait(1)
		amAnimating = false
		--wait(.5)  -- reload time
	else
		-- normal attack
		whackSound:Play()
		lastSlash = t
		amAnimating = false -- here must be before the wait, to allow for double-clix
		wait(.5)
	end
	if not amAnimating then Tool.Enabled = true end
end

local keyConnection = nil
local keytime = 0
function onKeyDown(key)
	keytime = r.Stepped:wait()
	if key:lower() == "w" then
		if (keytime - lastWDown < .2) then dashTime = keytime end
		lastWDown = keytime
	elseif key:lower() == "a" then
		lastADown = keytime
	elseif key:lower() == "d" then
		lastDDown = keytime
		if lastDDown-lastADown <.4 and lastWDown>lastADown then 
			print("SUPER STRIKE") 
			lastSuperStrike=keytime
		end
	end
end

function onEquippedLocal(mouse)
	
	slashSound.Volume = 1 
	spinSound.Volume = 1
	whackSound.Volume = 1

	keyConnection = mouse.KeyDown:connect(onKeyDown)

	vChar = Tool.Parent
	if vChar == nil then return end
	--hum = humanoid(player model)
	hum = vChar:FindFirstChild("Humanoid")
end

function onUnequippedLocal()
	if keyConnection ~= nil then keyConnection:disconnect() end

	if newBV ~= nil then newBV:remove() end
	if newBG ~= nil then newBG:remove() end
	if newBAV ~= nil then newBAV:remove() end
	if newBP ~= nil then newBP:remove() end
	if nsAnim then nsAnim:Stop() end
	if ndAnim then ndAnim:Stop() end
	slashSound.Volume = 0
	spinSound.Volume = 0
	whackSound.Volume = 0
end

Tool.Equipped:connect(onEquippedLocal)
Tool.Unequipped:connect(onUnequippedLocal)
Tool.Activated:connect(onActivated)
 