--imports
local RbxUtility = LoadLibrary('RbxUtility')
local Create = RbxUtility.Create

--main vars
local Tool = script.Parent
local Equipped = false
local Flying = false

--character stuff
local Character, Player, Humanoid, Torso;

--anim tracks
local GliderHold, GliderFly, GliderBomb;


---========================== main code ==========================--

local FlyingGyro;
local FlyingForce;

local DesiredFlightCFrame;

local Gui;

local function BeginFlight()
	Humanoid.Jump = true
	wait(0.2)
	if Flying then return end
	Flying = true
	game.Workspace.CurrentCamera.CameraSubject = Tool.Handle
	game.Workspace.CurrentCamera.CameraType = 'Track'
	Humanoid.Sit = true
	FlyingGyro = Create'BodyGyro'{
		Parent = Torso;
		maxTorque = Vector3.new(0,0,0);
		cframe = Torso.CFrame;
	}
	FlyingForce = Create'BodyForce'{
		Parent = Torso;
		force = Vector3.new(0,0,0);
	}
	Spawn(function()
		for i = 0, 1, 0.1 do
			FlyingGyro.maxTorque = Vector3.new(i*10000,i*10000,i*10000)
		end
	end)
	GliderFly:Play(0.3)
	DesiredFlightCFrame = (Torso.CFrame - Torso.CFrame.p)*CFrame.Angles(0, 0, 0.01)
	Gui.Frame.Message.Text = --Fix implemented by Luckymaxer
		"Click and Hold to direct yourself.\n"..
		"Jump to stop gliding."
end

local function EndFlight()
	Flying = false
	game.Workspace.CurrentCamera.CameraSubject = Character
	game.Workspace.CurrentCamera.CameraType = 'Custom'
	GliderFly:Stop(0.3)
	Humanoid.Sit = false
	FlyingGyro:Destroy()
	FlyingForce:Destroy()
	--Torso.Velocity = Vector3.new(0,0,0)
	Torso.RotVelocity = Vector3.new(0,0,0)
	Torso.CFrame = CFrame.new(Torso.Position)
	Gui.Frame.Message.Text = "Click to Glide."
end


local function GetMassOf(model)
	if model:IsA('BasePart') then
		return model:GetMass()
	else
		local mass = 0
		for _, ch in pairs(model:GetChildren()) do
			mass = mass + GetMassOf(ch)
		end
		return mass
	end
end


local LastBombAt = tick()
local RELOAD_TIME = 0.8
local function DropBomb()
	if not Flying then return end
	if tick() - LastBombAt > RELOAD_TIME then
		LastBombAt = tick()
		--
		GliderBomb:Play()
		--
		local bomb = Create'Part'{
			Size = Vector3.new(1,2,1);
			TopSurface = 'Smooth';
			BottomSurface = 'Smooth';
			Archivable = false;
			Position = (Character['Left Arm'].CFrame*CFrame.new(0,-1,0)).p - Vector3.new(0,2,0);
			--
			Create'SpecialMesh'{
				MeshId = 'http://www.roblox.com/asset/?id=90793198';
				TextureId = 'http://www.roblox.com/asset/?id=90793278';
			};
			--
			Create'Sound'{
				Name = 'ExplodeSound';
				SoundId = 'rbxasset://sounds//Rocket shot.wav';
			};
		}
		--
		local sc = Tool.MineScript:Clone()
		sc.Disabled = false
		sc.creator.Value = Player
		sc.Parent = bomb
		--
		bomb.Parent = game.Workspace
	end
end

local function Slerp(t, a, b)
	local om = math.acos(math.min(1, a:Dot(b)))
	if om < 0.01 then
		return (1-t)*a +
		          t *b
	else
		return (math.sin((1-t)*om)/math.sin(om))*a +
		       (math.sin(   t *om)/math.sin(om))*b
	end
end


while not Tool:FindFirstChild('Handle') do wait() end
Tool.Handle.Touched:connect(function(part)
	if Equipped and not part:IsDescendantOf(Character) and Flying then
		EndFlight()
	end
end)


Tool.Equipped:connect(function(mouse)
	Character = Tool.Parent
	Player = game.Players:GetPlayerFromCharacter(Character)
	Humanoid = Character.Humanoid
	Torso = Character.Torso
	--
	Equipped = true
	--
	GliderHold = Humanoid:LoadAnimation(Tool.ANIM_Hold)
	GliderFly =  Humanoid:LoadAnimation(Tool.ANIM_Fly )
	GliderBomb = Humanoid:LoadAnimation(Tool.ANIM_Bomb)
	--
	GliderHold:Play()
	--
	local MouseDown = false
	local KeyState
	mouse.Button1Down:connect(function()
		MouseDown = true
		if not Flying then
			BeginFlight()
		end
	end)
	mouse.Button1Up:connect(function()
		MouseDown = false
	end)
	mouse.KeyDown:connect(function(key)
		if key == ' ' then
			if Flying then
				EndFlight()
			end
		elseif key:byte() == 48 or key:byte() == 45 or key:byte() == 50 or 
		       key:byte() == 52 or key:byte() == 13 or key:lower() == 'q' or key:lower() == 'e' 
		then
			--DropBomb()
		end
	end)
	--
	Gui = Create'ScreenGui'{
		Parent = Player.PlayerGui;
		Create'Frame'{
			Name = 'Frame';
			Style = 'RobloxRound';
			Position = UDim2.new(0.5, -125, 1, -170);
			Size = UDim2.new(0, 250, 0, 80);
			Create'TextLabel'{
				Name = 'Message';
				TextWrapped = true;
				BackgroundTransparency = 1;
				Font = 'Arial';
				FontSize = 'Size14';
				TextColor3 = Color3.new(0.9, 0.9, 0.9);
				Text = "Click to Glide";
				Size = UDim2.new(1,0,1,0);
			};
		};
	}
	--
	local LastTime = tick()
	while true do
		local Now = tick()
		local dt = Now - LastTime
		LastTime = Now
		--
		if Flying then
			--make me fly
			local moveDir = game.Workspace.CurrentCamera.CoordinateFrame*CFrame.Angles(0.6, 0, 0)
			if MouseDown then
				local theta = math.acos(DesiredFlightCFrame.lookVector:Dot(moveDir.lookVector))
				local frac = math.min(1, 1.5*dt/theta)
				local unit = Slerp(frac, DesiredFlightCFrame.lookVector, moveDir.lookVector)
				print(unit)
				DesiredFlightCFrame = CFrame.new(Vector3.new(0,0,0), unit)
			end
			--
			local velo = Torso.Velocity
			local veloXZ = (velo - Vector3.new(0, velo.y, 0))
			--
			local dir = DesiredFlightCFrame.lookVector
			local dirXZ = (dir - Vector3.new(0, dir.y, 0)).unit
			--
			FlyingGyro.cframe = DesiredFlightCFrame*
			                    CFrame.Angles(0, 0, Torso.RotVelocity.y/3 * (1-math.abs(dir.y)^2))*
			                    CFrame.Angles(-math.pi/2, 0, 0)
			--
			local headingForceFactor = -dir.y -- heading up => negative force
			local liftForceFactor = dir.y --hading up => positive lift
			--
			local forwardsSpeed = math.max(0, velo.magnitude)
			--
			local weight = GetMassOf(Character)*20*9.81
			--
			local dragForce = (velo.magnitude/10)^2 * weight
			local dragForceY = (velo.y/15)^2 * weight
			local dragForceXZ = (veloXZ.magnitude/35)^2 * weight
			--
			local suspendFactor = 0
			if dir.y < 0 then
				suspendFactor = (-dir.y)^2
			end
			--
			FlyingForce.force = Vector3.new(0, weight*(1.0 - suspendFactor + 0.3*liftForceFactor), 0)
			                    + (dirXZ * (weight*1.0 * math.max(0, (0.5*headingForceFactor+0.6))))
			                    - (veloXZ.unit * dragForceXZ)
			                    - (Vector3.new(0, velo.y, 0).unit * dragForceY)
			--
			--print(string.format("RotVelocity: %.1f, Velo: %.2f",
			--                    Torso.RotVelocity.y, velo.magnitude))
		end
		wait()
	end
end)

Tool.Unequipped:connect(function()
	if Flying then EndFlight() end
	Equipped = false
	--
	if Gui then
		Gui:Destroy()
	end
	--
	GliderHold:Stop()
	GliderFly:Stop()
	GliderBomb:Stop()
end)