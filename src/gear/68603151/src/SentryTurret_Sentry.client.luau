function Create(ty)
	return function(data)
		local obj = Instance.new(ty)
		for k, v in pairs(data) do
			if type(k) == 'number' then
				v.Parent = obj
			else
				obj[k] = v
			end
		end
		return obj
	end
end

local function class(name)
	local def = {}
	getfenv(0)[name] = def
	return function(ctor, static)
		local nctor = function(...)
			local this = {}
			if ctor then
				ctor(this, ...)
			end
			return this
		end
		getfenv(0)['Create'..name] = nctor
		if static then static(def) end
	end
end

class'Bin'(function(this)
	local mGarbage = {}

	function this:add(func, ident)
		ident = ident or '__unnamed'
		if not mGarbage[ident] then
			mGarbage[ident] = {}
		end
		mGarbage[ident][#mGarbage[ident]+1] = func
	end

	function this:clean(ident)
		local listToCall = mGarbage[ident]
		if listToCall then
			for _, func in pairs(listToCall) do
				func()
			end
			mGarbage[ident] = nil
		end
	end

	function this:cleanAll()
		for ident, list in pairs(mGarbage) do
			for _, func in pairs(list) do
				func()
			end
			mGarbage[ident] = nil
		end
	end
end)

local Bin = CreateBin()

--------------------------------------------------
--                    settings                  --
local MaxRange = 42
local ReloadTime = 0.45
local DamagePerShot = 12
--                                              --
--------------------------------------------------

--game.Workspace.ErrorOut.Value = game.Workspace.ErrorOut.Value.."(( SentryScript Running "

while not script:FindFirstChild("MyTargetTurret") do script.ChildAdded:wait() end
local Model = script.MyTargetTurret.Value
local Humanoid = Model:FindFirstChild("Humanoid")
local Player = (Model:FindFirstChild("TurretOwner") or {}).Value
local PlayerTurretValue = (Player or game):FindFirstChild("SentryValue")
local PlayerTurretTargetValue = (Player or game):FindFirstChild("SentryTargetValue")
--
local CannonPart = Model:FindFirstChild("CannonMove")
local TorsoPart = Model:FindFirstChild("Torso")
local HeadPart = Model:FindFirstChild("Head")
local TorsoToHead = (TorsoPart or game):FindFirstChild("Neck")
local HeadToCannon = (HeadPart or game):FindFirstChild("CannonAttach")
local FireSound = (CannonPart or game):FindFirstChild("FireSound")

if not (Model and Humanoid and Player and PlayerTurretValue and PlayerTurretTargetValue and
        CannonPart and TorsoPart and HeadPart and TorsoToHead and HeadToCannon and FireSound) 
then
	print("FATAL: Sentry setup failed, destroying turret!")
	Model:Destroy()
	Model.Parent = nil
end

--prevent double init
local INITED_HACK = (Model:FindFirstChild("INITED_HACK"))
if not INITED_HACK then
	Create'IntValue'{
		Name = "INITED_HACK",
		Parent = Model,
	}
end
--game.Workspace.ErrorOut.Value = game.Workspace.ErrorOut.Value.."... with"..(INITED_HACK and "out" or "").." INIT ))"


local UnfoldAnimDef = Create'Animation'{
	Parent = Model,
	AnimationId = "http://www.roblox.com/asset/?id=68433924",
}
local FireAnim1Def = Create'Animation'{
	Parent = Model,
	AnimationId = "http://www.roblox.com/asset/?id=68433992",
}
local FireAnim2Def = Create'Animation'{
	Parent = Model,
	AnimationId = "http://www.roblox.com/asset/?id=68433974",
}
local UnfoldAnim = Humanoid:LoadAnimation(UnfoldAnimDef)
local FireAnim1 = Humanoid:LoadAnimation(FireAnim1Def)
local FireAnim2 = Humanoid:LoadAnimation(FireAnim2Def)

if not INITED_HACK then
	UnfoldAnim:Play(0, 1, 1)
end

function TagHumanoid(humanoid)
	local tag = Create'ObjectValue'{
		Name = "creator", 
		Value = Player,
		Parent = humanoid,
	}
	game.Debris:AddItem(tag, 2)
end


Humanoid.Died:connect(function()
	script:Destroy()
end)


---fire from point
local whichFireFrom = true
local function GetFireFrom()
	local dir = (whichFireFrom and 1 or -1)
	return CannonPart.CFrame*CFrame.new(0,dir*0.3,-1.8)
end
local function GetFireAnim()
	if whichFireFrom then
		return FireAnim1
	else
		return FireAnim2
	end
end
local function SwitchFireFrom()
	whichFireFrom = not whichFireFrom
end


function ShowShot(from, to)
	local shotBlast = Create'Part'{
		Name = "ShotBlast",
		CanCollide = false,
		Anchored = true,
		Parent = Model,
		FormFactor = 'Custom',
		Size = Vector3.new(0.5, 0.5, 1.5),
		BrickColor = BrickColor.new(21),
		Transparency = 0.3,
		Create'SpecialMesh'{
			MeshType = 'Sphere',
		},
		Create'Fire'{
			Size = 0,
			Heat = 0,
		},
	}
	local shotLance = Create'Part'{
		Name = "ShotLance",
		CanCollide = false,
		Anchored = true,
		Parent = Model,
		FormFactor = 'Custom',
		BrickColor = BrickColor.new(21),
		Size = Vector3.new(0.2, 0.2, (from-to).magnitude),
		Transparency = 0.3,
	}
	shotBlast.CFrame = CFrame.new(from, to)
	shotLance.CFrame = CFrame.new(from, to)*CFrame.new(0, 0, -(from-to).magnitude/2)
	--
	game.Debris:AddItem(shotBlast, 0.5)
	game.Debris:AddItem(shotLance, 0.5)
	game.Debris:AddItem(shotBlast.Fire, 0.2)
	--
	Spawn(function()
		for i = 0.3, 1, 0.05 do
			wait()
			shotBlast.Transparency = i
			shotLance.Transparency = i
		end
		shotBlast:Destroy()
		shotLance:Destroy()
	end)
end


local PivotOffsetFromHead = CFrame.new(0, 0.4, 0.1)*CFrame.Angles(-math.pi/2, 0, 0)
local HeadOffsetFromPivot = CFrame.new(0, 0, -1)
local GunOffsetFromHead = CFrame.new(0, 0.6, 0.2)*CFrame.Angles(math.pi/2, 0, 0)
function AimAt(pos)
	--edit the swivel joint
	--[[local originalHeadPos = (TorsoPart.CFrame*TorsoToHead.C0*TorsoToHeadAnimMod).p
	local desiredCFrame = CFrame.new(originalHeadPos, 
	                                 Vector3.new(pos.x, originalHeadPos.y, pos.z))*
	                      CFrame.Angles(-math.pi/2, 0, 0)
	TorsoToHead.C1 = desiredCFrame:inverse()*
	                 TorsoPart.CFrame*
	                 TorsoToHead.C0*
	                 TorsoToHeadAnimMod
	]]
	local headPivot = TorsoPart.CFrame*PivotOffsetFromHead
	local desiredCF = CFrame.new(headPivot.p, Vector3.new(pos.x, headPivot.p.y, pos.z))
	desiredCF = desiredCF*CFrame.Angles(-math.pi/2, 0, 0)
	TorsoToHead.C1 = HeadOffsetFromPivot*(desiredCF:inverse()*headPivot)
	--
	local gunPivot = HeadPart.CFrame*GunOffsetFromHead
	local desiredCF = CFrame.new(gunPivot.p, pos)
	HeadToCannon.C1 = desiredCF:inverse()*gunPivot
end

function GetTarget(targetPos)
	local from = GetFireFrom().p
	local ray = Ray.new(from, (targetPos-from))
	local part, hit = game.Workspace:FindPartOnRay(ray, Model)
	--if part then
	--	print("Hit part", part, "in", part.Parent)
	--end
	if part then
		--if it's part of a humanoid, or a humanoid's gear/hats
		local hum = (part.Parent or game):FindFirstChild('Humanoid')
		hum = hum or ((part.Parent or game).Parent or game):FindFirstChild('Humanoid')
		if hum then
			return hum, (hit-from).magnitude, hit
		end
	end
end


function InflictDamageOn(hum)
	TagHumanoid(hum)
	hum:TakeDamage(DamagePerShot)
	GetFireAnim():Play(0, 1, 5)
	FireSound:Play()
end


local mLastShotTime = 0

if not INITED_HACK then
	repeat until UnfoldAnim.KeyframeReached:wait() == 'complete'
	wait()
end

--local beforeErr = ""
while true do
	wait()

	--local st, err = pcall(function()
	local didAttackOnTarget = false

	if PlayerTurretTargetValue.Value then
		local hum = PlayerTurretTargetValue.Value
		if hum.Health > 0 then
			local torso = (hum.Parent or game):FindFirstChild("Torso")
			--find biggest part to target in the thing if no torso exists
			if not torso and hum.Parent then
				local largestPart = nil
				local largestSize = -1
				for _, p in pairs(hum.Parent:GetChildren()) do
					if p:IsA('BasePart') then
						--beforeErr = "281"
						if p.Size.magnitude > largestSize then
							largestPart = p
							largestSize = p.Size.magnitude
						end
					end
				end
				--
				torso = largestPart
			end
			--beforeErr = "291"
			--make sure there were any parts at all
			if torso then
				if hum ~= Humanoid then
					AimAt(torso.Position)
				end
				local hum, dist, hitPos = GetTarget(torso.Position)
				if hum and hum ~= Humanoid and dist < MaxRange then
					AimAt(hitPos)
					didAttackOnTarget = true
					if (tick()-mLastShotTime) > ReloadTime then
						ShowShot(GetFireFrom().p, hitPos)
						InflictDamageOn(hum)
						SwitchFireFrom()
						mLastShotTime = tick()
					end
				end
			end
		end
	end
	
	if not didAttackOnTarget then
		--do targeting
		local targets = {}

		--gather all possible targets
		local fireFrom = GetFireFrom().p
		local targetAtAll = nil --if all else fails, aim at this thing
		for _, p in pairs(game.Players:GetChildren()) do
			if p ~= Player then
				if p.Character and p.Character:FindFirstChild('Torso') then
					local targetPos = p.Character.Torso.Position
					--skip raycasting if the target is too far away
					--beforeErr = tostring(fireFrom)..","..tostring(targetPos)
					if (fireFrom - targetPos).magnitude > MaxRange*2 then
						targetAtAll = targetPos
					else
						--beforeErr = beforeErr.."|328"
						AimAt(targetPos)
						--beforeErr = beforeErr.."|330"
						local hum, dist, hit = GetTarget(targetPos)
						if hum and hum ~= Humanoid and dist < MaxRange then
							targets[hum] = hit
						end
					end
				end
			end
		end

		--beforeErr = beforeErr.."|340"
		--if there are any targets available
		if next(targets) then
			--find the lowest health one, the best to try killing
			local lowestHealth = 10000
			local lowestHealthHum = nil
			for p, _ in pairs(targets) do
				if p.Health < lowestHealth then
					lowestHealth = p.Health
					lowestHealthHum = p
				end
			end

			local to = targets[lowestHealthHum]
			AimAt(to)
			if (tick()-mLastShotTime) > ReloadTime then
				ShowShot(GetFireFrom().p, to)
				InflictDamageOn(lowestHealthHum)
				SwitchFireFrom()
				mLastShotTime = tick()
			end
		elseif targetAtAll then
			--all else failed, just point at something
			AimAt(targetAtAll)
		end
	end
	--end)
	--if not st then 
	--game.Workspace.ErrorOut.Value = game.Workspace.ErrorOut.Value.."[:"..beforeErr..": "..err.."]"
	--break
	--end
end

--script.Name = "RUNNING_"..script.Name