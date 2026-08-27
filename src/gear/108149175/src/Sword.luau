--[[
	Rewritten by ArceusInator
	
	This script is the Sword module.  This runs on either the server (when FilteringEnabled is on) or the client (when FilteringEnabled is off)
--]]
local Tool = script.Parent
local Handle = Tool.Handle
local Config = Tool:WaitForChild'Configurations'
local GLib = require(Tool:WaitForChild'GLib') -- Library of useful functions
GLib.Script.Name = 'GLib'
GLib.Script.Parent = Tool

local Sword = {
	-- Advanced settings
	DoubleClickMaxTime = 0.2,
	
	-- Variables
	State = 'Idle', -- Idle, Slashing, Lunging
	SlashingStartedAt = 0,
	AttackTicket = 0,
	Tracks = {},
	LeftSword = nil,
	ParticleTextures = {105075642,105075668,105075677,105230409,105230748,105230760},
	SpinDebounce = false,
	Spins = 0,
	SpinTicket = 0,
	StormEye = GLib.Create'Part'{
		Name = 'DualDarkhearts_StormEye',
		Transparency = 1,
		FormFactor = 'Custom',
		Size = Vector3.new(1,1,1)*3,
		CanCollide = false,
		
		GLib.Create'BodyForce'{
			Name = 'BodyForce'
		},
		GLib.Create'BodyPosition'{
			Name = 'BodyPosition',
			P = 100000,
			maxForce = Vector3.new(1,1,1)*100000
		}
	},
	SkullBase = GLib.Create'Part'{
		Name = 'DualDarkhearts_Skull',
		Transparency = 1,
		FormFactor = 'Custom',
		Size = Vector3.new(1,1,1)*.2,
		CanCollide = false,
		
		GLib.Create'Motor6D'{
			Name = 'SkullMotor',
			MaxVelocity = 0.1,
			C0 = CFrame.Angles(math.pi/2, 0, 0)
		}
	},
	SpinForce = GLib.Create'BodyAngularVelocity'{
		Name = 'DualDarkhearts_SpinForce',
		P = 1000000,
		angularvelocity = Vector3.new(0, 20, 0),
		maxTorque = Vector3.new(1,1,1)*1000000
	},
	StayUpright = GLib.Create'BodyGyro'{
		Name = 'DualDarkhearts_StayUpright',
		P = 1000000,
		maxTorque = Vector3.new(1, 0, 1)*1000000,
		cframe = CFrame.new()
	}
}

--
--
function Sword:CreateSmoke(part)
	local size = (14-6)*math.random()+6
	
	local bbg = GLib.Create'BillboardGui'{ -- Change this to a ParticleEmitter once it comes out
		Name = 'DualDarkhearts_SmokeParticle',
		Parent = part,
		Size = UDim2.new(size, 0, size, 0),
		Adornee = part,
		
		GLib.Create'ImageLabel'{
			Name = 'Image',
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 1, 0),
			Image = 'rbxassetid://'..Sword.ParticleTextures[math.random(1, #Sword.ParticleTextures)],
		}
	}
	
	return bbg
end

function Sword:Spin()
	if Sword.State ~= 'Lunging' then return end
	if Sword.SpinDebounce then return end
	Sword.SpinDebounce = true
	
	local character = GLib.GetCharacterFromPart(Tool)
	local root = character and (character:FindFirstChild'HumanoidRootPart' or character:FindFirstChild'Torso')
	local humanoid = character and GLib.GetHumanoid(character)
	
	if character and root and root:IsA'BasePart' and humanoid and humanoid.Health>0 then
		Sword.Spins = Sword.Spins + 1 print('spins',Sword.Spins)
		Sword.SpinTicket = Sword.SpinTicket + 1
		local mySpinTicket = Sword.SpinTicket
		
		if Sword.Spins >= Config.SpinsToWhirlwind.Value then
			Sword:Whirlwind()
			Sword.Spins = 0
		else
			if Sword.Spins == Config.SpinsToWhirlwind.Value-1 then
				Tool.Data.WhirlwindAvailable.Value = true
			end
			
			delay(3, function()
				while mySpinTicket == Sword.SpinTicket do
					Sword.Spins = Sword.Spins - 1
					Tool.Data.WhirlwindAvailable.Value = false
					
					if Sword.Spins <= 0 then break end
					wait(0.5)
				end
			end)
			
			Sword.SpinForce.Parent = root
			Sword.StayUpright.Parent = root
			Sword:MotorAnimate'StaffSpin'
			wait(0.5)
			Sword:MotorAnimate('StaffSpin', 'Stop')
			Sword.SpinForce.Parent = nil
			Sword.StayUpright.Parent = nil
		end
	end
	
	Sword.SpinDebounce = false
end

function Sword:ForceSpin() -- Used for mobile controls so that mobile users don't have to double-tap and then press the button
	Sword.AttackTicket = Sword.AttackTicket+1
	GLib.FastSpawn(function() Sword:Lunge(Sword.AttackTicket) end)
	Sword:Spin() -- Now that we're lunging we can spin
end

function Sword:Whirlwind()
	if Sword.WhirlwindDebounce then return end
	Sword.WhirlwindDebounce = true
	Tool.Data.WhirlwindAvailable.Value = false
	
	local character = GLib.GetCharacterFromPart(Tool)
	local root = character and (character:FindFirstChild'HumanoidRootPart' or character:FindFirstChild'Torso')
	local humanoid = character and GLib.GetHumanoid(character)
	
	if character and root and root:IsA'BasePart' and humanoid and humanoid.Health>0 then
		Handle.StormSound:Play()
		
		local stormMass = 0
		local skullParts = {}
		
		local angle = math.random()*math.pi*2
		
		local function skullPartHit(hit)
			Sword:Blow(hit, Config.SkullDamage.Value)
		end
		
		for i=1, Config.SkullParts.Value do
			local radius = (i/Config.SkullParts.Value)*20 + 2
			local skull = Sword.SkullBase:Clone()
			skull.SkullMotor.C1 = CFrame.Angles(math.pi/2, 0, 0) + Vector3.new(
				0,
				-((1-(i/Config.SkullParts.Value))^5)*50, -- magic
				0
			) + radius*Vector3.new(math.sin(angle), 0, math.sin(angle))
			skull.SkullMotor.DesiredAngle = skull.SkullMotor.CurrentAngle + 5000*(math.random()-.5)*2
			skull.SkullMotor.MaxVelocity = 0.05+math.random()*0.15
			skull.SkullMotor.Part0 = Sword.StormEye
			skull.SkullMotor.Part1 = skull
			skull.Parent = Sword.StormEye
			table.insert(skullParts, skull)
			Sword:CreateSmoke(skull)
			skull.Touched:connect(function(hit) Sword:Blow(hit, 20) end)
			
			stormMass = stormMass+skull:GetMass()
		end
		
		stormMass = stormMass + Sword.StormEye:GetMass()
		Sword.StormEye.BodyForce.force = Vector3.new(0, stormMass*196.2, 0)
		Sword.StormEye.CFrame = root.CFrame
		Sword.StormEye.BodyPosition.position = root.Position - Vector3.new(0, 3, 0)
		
		humanoid.WalkSpeed = 8
		Sword.SpinForce.Parent = root
		Sword.StayUpright.Parent = root
		
		local whirlwindActive = true
		local whirlwindStartedAt = tick()
		GLib.FastSpawn(function()
			while whirlwindActive do
				if Tool.Parent == character and whirlwindActive then
					humanoid.WalkSpeed = humanoid.WalkSpeed + 0.2
					Sword.StormEye.BodyPosition.position = root.Position
				else
					return
				end
				
				wait()
			end
			
			humanoid.WalkSpeed = 16
		end)
		
		Sword.StormEye.Parent = workspace
		for i=1, 5 do
			wait(1)
			if Tool.Parent == character then
				Sword:MotorAnimate'StaffSpin'
			else
				Sword:MotorAnimate('StaffSpin', 'Stop')
				return
			end
		end
		
		Sword.SpinForce.Parent = nil
		Sword.StayUpright.Parent = nil
		whirlwindActive = false
		
		for index, skull in next, skullParts do
			skull.SkullMotor:Destroy()
			skull.Velocity = 40*(skull.Position - root.Position).unit
		end
		
		wait(4)
		Sword.StormEye.Parent = nil
		
		wait(3)
		for index, skull in next, skullParts do
			skull:Destroy()
		end
	end
	
	Sword.WhirlwindDebounce = false
end

function Sword:Blow(hit, damage)
	local myPlayer = GLib.GetPlayerFromPart(Tool)
	local character, player, humanoid = GLib.GetCharacterFromPart(hit)
	
	if myPlayer~=nil and character~=nil and humanoid~=nil and myPlayer~=player then
		local isTeammate = GLib.IsTeammate(myPlayer, player)
		local myCharacter = myPlayer.Character
		local myHumanoid = myCharacter and myCharacter:FindFirstChild'Humanoid'
		
		if (Config.CanTeamkill.Value==true or isTeammate~=true) and (myHumanoid and myHumanoid:IsA'Humanoid' and myHumanoid.Health > 0) and (Config.CanKillWithForceField.Value or myCharacter:FindFirstChild'ForceField'==nil) and humanoid.Health > 0 then
			local doDamage = Config.IdleDamage.Value
			if Sword.State == 'Slashing' then
				doDamage = Config.SlashDamage.Value
			elseif Sword.State == 'Lunging' then
				doDamage = Config.LungeDamage.Value
			end
			if damage then doDamage=damage end
			
			myHumanoid.Health = myHumanoid.Health + doDamage*0.4
			GLib.TagHumanoid(humanoid, myPlayer, 1)
			humanoid:TakeDamage(doDamage)
			
			if humanoid.Health <= 0 then
				-- Do the effect and regen health
				local parts = {}
				for index, obj in next, GLib.GetDescendants(character) do
					if obj:IsA'BasePart' then
						table.insert(parts, obj)
						obj.BrickColor = Config.DeadGuyColor.Value
					elseif obj:IsA'FileMesh' then
						obj.VertexColor = Vector3.new(Config.DeadGuyColor.Value.r, Config.DeadGuyColor.Value.g, Config.DeadGuyColor.Value.b)
					elseif obj:IsA'Fire' then
						obj.Color = Config.DeadGuyColor.Value.Color
						obj.SecondaryColor = Config.DeadGuyColor.Value.Color
					elseif obj:IsA'Smoke' then
						obj.Color = Config.DeadGuyColor.Value.Color
					elseif obj:IsA'Sparkles' then
						obj.SparkleColor = Config.DeadGuyColor.Value.Color
					end
				end
				
				for index, part in next, parts do
					part.CanCollide = true
					part.Anchored = true
				end
				
				wait(0.25)
				
				for index, part in next, parts do
					local v = Instance.new'BodyVelocity'
					v.velocity = Vector3.new(math.random()-.5, 0, math.random()-.5).unit*2*40
					v.maxForce = Vector3.new(1,1,1)*1e5
					v.Parent = part
					
					part.Anchored = false 
				end
			end
		end
	end
end

function Sword:Connect()
	local function swordTouched(hit)
		Sword:Blow(hit)
	end
	
	Handle.Touched:connect(swordTouched)
	
	Tool.Unequipped:connect(function()
		for name, track in next, Sword.Tracks do
			track:Stop()
		end
		
		Sword.Tracks = {}
		
		if Sword.LeftSword then Sword.LeftSword:Destroy() Sword.LeftSword=nil end
	end)
	Tool.Equipped:connect(function() if Sword.LeftSword then return end
		Sword.LeftSword = Tool.Handle:Clone()
		Sword.LeftSword.Name = 'LeftSword'
		Sword.LeftSword.Parent = Tool
		local weld = Instance.new("ManualWeld")
		weld.Name = 'Weld'
		weld.Part1 = Sword.LeftSword
		weld.C0 = CFrame.new(0, -1, 0, 1, 0, -0, 0, 0, 1, 0, -1, -0)
		weld.C1 = CFrame.new(0, 0, -1.5, 0, 0, 1, 1, 0, 0, 0, 1, 0)
		weld.Part0 = Tool.Parent:FindFirstChild'Left Arm'
		weld.Parent = Sword.LeftSword
		
		Sword.LeftSword.Touched:connect(swordTouched)
	end)
end

function Sword:Attack()
	local myCharacter, myPlayer, myHumanoid = GLib.GetCharacterFromPart(Tool)
	
	if myHumanoid~=nil and myHumanoid.Health > 0 then
		if Config.CanKillWithForceField.Value or myCharacter:FindFirstChild'ForceField'==nil then
			local now = tick()
			
			if Sword.State == 'Slashing' and now-Sword.SlashingStartedAt < Sword.DoubleClickMaxTime then
				Sword.AttackTicket = Sword.AttackTicket+1
				
				Sword:Lunge(Sword.AttackTicket)
			elseif Sword.State == 'Idle' then
				Sword.AttackTicket = Sword.AttackTicket+1
				Sword.SlashingStartedAt = now
				
				Sword:Slash(Sword.AttackTicket)
			end
		end
	end
end

function Sword:Slash(ticket)
	Sword.State = 'Slashing'
	
	Sword:MotorAnimate'DualSlash'
	Handle.SlashSound:Play()
	
	wait(0.5)
	
	if Sword.AttackTicket == ticket then
		Sword.State = 'Idle'
	end
end

function Sword:Lunge(ticket)
	Sword.State = 'Lunging'
	
	Sword:MotorAnimate'DualLunge'
	Handle.LungeSound:Play()
	
	local force = Instance.new'BodyVelocity'
	force.velocity = Vector3.new(0, 10, 0)
	force.maxForce = Vector3.new(0, 4000, 0)
	force.Parent = Tool.Parent.Torso
	
	wait(0.25)
	Tool.Grip = CFrame.new(0, 0, -1.5, 0, -1, -0, -1, 0, -0, 0, 0, -1)
	if Tool:FindFirstChild'LeftSword' then
		Tool.LeftSword.Weld.C0 = CFrame.new(0, -1, 0, 1, 0, -0, 0, 0, 1, 0, -1, -0)
		Tool.LeftSword.Weld.C1 = CFrame.new(0, 0, -1.5, 0, -1, -0, -1, 0, -0, 0, 0, -1)
	end
	wait(0.25)
	force:Destroy()
	wait(0.5)
	Tool.Grip = CFrame.new(0, 0, -1.5, 0, 0, 1, 1, 0, 0, 0, 1, 0)
	if Tool:FindFirstChild'LeftSword' then
		Tool.LeftSword.Weld.C0 = CFrame.new(0, -1, 0, 1, 0, -0, 0, 0, 1, 0, -1, -0)
		Tool.LeftSword.Weld.C1 = CFrame.new(0, 0, -1.5, 0, 0, 1, 1, 0, 0, 0, 1, 0)
	end
	
	Sword.State = 'Idle'
end

function Sword:Animate(name)
	local tag = Instance.new'StringValue'
	tag.Name = 'toolanim'
	tag.Value = name
	tag.Parent = Tool -- Tag gets removed by the animation script
end

function Sword:MotorAnimate(name, action)
	local animation = Tool:FindFirstChild(name)
	local character, player, humanoid = GLib.GetCharacterFromPart(Tool)
	if humanoid then
		local track = Sword.Tracks[animation] or humanoid:LoadAnimation(animation)
		Sword.Tracks[animation] = track
		
		if action == 'Play' or action == nil then
			track:Play()
		elseif action == 'Stop' then
			track:Stop()
		end
	end
end

function Sword:InterpretInput(type, state, keycode)
	if (type == 'Keyboard' and state == 'Begin' and (keycode == 'E' or keycode == 'Q' or keycode == 'F'))
		or (type == 'Gamepad1' and state == 'Begin' and keycode == 'ButtonX') then
		Sword:Spin()
	end
end

--
function Sword:Initialize()
	Sword:Connect()
end

--
--
return Sword