local Tool = script.Parent
local Sword = Tool.Handle

local vCharacter
local myHumanoid
local myTorso

local slashAnim
local waveAnim

local co

local wave

local waveDamage = 15

function wait25()
	wait(25)
end

function blow(hit)	
	if hit.Parent then 
		humanoid = hit.Parent:FindFirstChild("Humanoid")
		tempTorso = hit.Parent:FindFirstChild("Torso")
	end
	vCharacter = Tool.Parent
	myHumanoid = vCharacter:FindFirstChild("Humanoid")
	myTorso = vCharacter:FindFirstChild("Torso")
	vPlayer = game.Players:GetPlayerFromCharacter(vCharacter)
	if humanoid ~= nil and myHumanoid ~= humanoid then 				
		humanoid:TakeDamage(waveDamage)	
	end
	if hit.Anchored == false then 
		bv = Instance.new("BodyVelocity")
		bv.P = 100000
		bv.maxForce = Vector3.new(bv.P, 0, bv.P)
		if humanoid == nil and not vCharacter:IsAncestorOf(hit) then 
			bv.velocity = (hit.Position - myTorso.Position).unit * 50.0 
			bv.Parent = hit
		elseif vCharacter:IsAncestorOf(hit) == false and humanoid ~= myHumanoid then
			bv.velocity = (tempTorso.Position - myTorso.Position).unit * 50.0 
			bv.Parent = tempTorso 	
		end 
	end
end

function turnOnTheHeat(key)
	if key:lower() == "e" then 
		if co == nil or coroutine.status == 'dead' then 
			co = coroutine.create(wait25)
			coroutine.resume(co)
			if myHumanoid then 
				waveAnim = myHumanoid:LoadAnimation(Tool.WaveAnim)
				if waveAnim then waveAnim:Play() end
				wait(0.5)
			end			
			wave = Instance.new("Part")
			wave.Name = "SUMMERTIME"
			wave.Size = Vector3.new(7, 7, 10)
			wave.CanCollide = false
			wave.CFrame = (myTorso.CFrame + (myTorso.CFrame.lookVector * 6.0)) * CFrame.Angles(math.pi/2, 0, 0)
			wave.Parent = game.Workspace

			float = Instance.new("BodyForce")
			float.force = Vector3.new(0, wave:GetMass() * 196.1, 0)
			float.Parent = wave

			bav = Instance.new("BodyAngularVelocity")
			bav.P = 5000000
			bav.maxTorque = Vector3.new(bav.P, bav.P, bav.P)
			bav.angularvelocity = Vector3.new(20, 0, 0)
			bav.Parent = wave
			
			waveMesh = Instance.new("SpecialMesh")
			waveMesh.MeshId = "http://www.roblox.com/asset/?id=54662987"
			waveMesh.TextureId = "http://www.roblox.com/asset/?id=54663425"
			waveMesh.Scale = Vector3.new(2, 2, 2)
			waveMesh.Parent = wave

			wave.Touched:connect(blow)
			myTorso.Anchored = true
			wait(2.0)
			myTorso.Anchored = false
			wait(1.0)
			if wave then wave:Remove() end
		end
	end
end

function onActivated()
	if Tool.Enabled == false then return end	
	
	myHumanoid = vCharacter:FindFirstChild("Humanoid")
	if myHumanoid == nil then return end
	
	slashAnim = myHumanoid:LoadAnimation(Tool.SlashAnim)
	if slashAnim then slashAnim:Play() end
end

function onEquipped(mouse)
	vCharacter = Tool.Parent
	myHumanoid = vCharacter:FindFirstChild("Humanoid")
	myTorso = vCharacter:FindFirstChild("Torso")
	mouse.KeyDown:connect(turnOnTheHeat)
end

function onUnequipped()
	if slashAnim then slashAnim:Stop() end
	if waveAnim then waveAnim:Stop() end
end

Tool.Activated:connect(onActivated)
Tool.Equipped:connect(onEquipped)
Tool.Unequipped:connect(onUnequipped)
