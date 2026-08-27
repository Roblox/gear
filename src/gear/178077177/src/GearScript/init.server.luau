--[[ alexnewtron 2014 ]]--

local ClientAgent = require(script:WaitForChild("ClientAgent"));
local Controller = script:WaitForChild("Controller");
local Gear = script.Parent;

local PlayersService = Game:GetService('Players');
local DebrisService = Game:GetService('Debris');

local Character = nil;
local Player = nil;
local Humanoid = nil;

Gear:WaitForChild("Handle");

local d = { 
	Debris = game:GetService("Debris"),
	left = false,
	right = false,
	up = false,
	down = false,
	forward = false,
	back = false,
	turnAlpha = .5,
	alphaDampening = .2,
	LastPosition = nil,
	ActualVelocity = Vector3.new(0,0,0),
	CurrentSpeed = 0,
	turnSpeed = 0,
	turnSpeedAim = 5,
	pitchSpeed = 0,
	Equipped = false,
	
	a = {
		TurnGyro = nil,
		thrustForce = nil,
		RotationForce = nil,
		torsoWeld = nil
	}
};

local s = { ["Running"] = Gear.Handle:WaitForChild("Running")};

function TagHumanoid(a,b)local c=Instance.new("ObjectValue")c.Name="creator"c.Value=b;d.Debris:AddItem(c,2)c.Parent=a end
function UntagHumanoid(a)for b,c in pairs(a:GetChildren())do if c:IsA("ObjectValue")and c.Name=="creator"then c:Destroy()end end end

function Controller.OnServerInvoke(p, e, ...)
	local tuples={...};
	if (e == ClientAgent.SERVER_PLAY_SOUND) then
		s[tuples[1]]:Play();
	elseif (e == ClientAgent.KEY_DOWN) then
		local Key = tuples[1];
		if (Key == 'w') then
			d.up = true;
			while (d.up) do
				d.pitchSpeed = math.min(8,d.pitchSpeed+(d.turnAlpha));
				wait(1/30);
			end
		elseif (Key == 'a') then
			d.left = true;
			while (d.left) do
				d.turnSpeed = math.min(3,d.turnSpeed+(d.turnAlpha));
				wait(1/30);
			end
		elseif (Key == 's') then
			d.down = true;
			while (d.down) do
				d.pitchSpeed= math.min(8,d.pitchSpeed-(d.turnAlpha))
				wait(1/30);
			end
		elseif (Key == 'd') then
			d.right = true;
			while (d.right) do
				d.turnSpeed= math.max(-3,d.turnSpeed-(d.turnAlpha))
				wait(1/30);
			end
		end
	elseif (e == ClientAgent.KEY_UP) then
		local Key = tuples[1];
		if (Key == 'w') then
			d.up = false;
		elseif (Key == 'a') then
			d.left = false;
		elseif (Key == 's') then
			d.down = false;
		elseif (Key == 'd') then
			d.right = false;
		end
	end
end;

function d.ThrustUpdater()
	while d.Equipped do
		if (math.abs(d.turnSpeed)>d.alphaDampening) then
			d.turnSpeed = d.turnSpeed - ((d.alphaDampening)*(math.abs(d.turnSpeed)/d.turnSpeed));
		else
			d.turnSpeed = 0;
		end
		
		if (math.abs(d.pitchSpeed)>d.alphaDampening) then
			d.pitchSpeed = d.pitchSpeed-((d.alphaDampening)*(math.abs(d.pitchSpeed)/d.pitchSpeed));
		else
			d.pitchSpeed = 0;
		end
		
		local leanAmount = -d.turnSpeed*(math.pi/6)/1.5;
		local direction = Gear.Handle.CFrame.lookVector;
		local xzdirection = Vector3.new(direction.x,0,direction.z).unit;
		
		d.a.thrustForce.velocity = direction*(d.CurrentSpeed);
		s["Running"].Pitch = 1+(math.abs(d.CurrentSpeed/50)*1);
		
		local xznormal = CFrame.Angles(0,math.pi/2,0)*xzdirection;
		if (math.abs(direction.y)>.99) then
			d.a.RotationForce.angularvelocity = d.a.TurnGyro.cframe*Vector3.new(0, d.turnSpeed, 0);
			d.pitchSpeed = 0;
		elseif not d.up and not d.down and not d.left and not d.right then
			local tforce = (d.pitchSpeed + (math.sin(tick()*4)*3));
			d.a.RotationForce.angularvelocity = d.a.TurnGyro.cframe*Vector3.new(tforce*xznormal.x, d.turnSpeed, tforce*xznormal.z);
		else
			d.a.RotationForce.angularvelocity = d.a.TurnGyro.cframe*Vector3.new(d.pitchSpeed*xznormal.x, d.turnSpeed, d.pitchSpeed*xznormal.z);
		end
		
		d.a.TurnGyro.cframe = CFrame.Angles(leanAmount*xzdirection.x,0,leanAmount*xzdirection.z);
		wait(1/60);
	--[[	if (LastPosition ~= nil) then
			local npos = Vector3.new(Character.Torso.CFrame.p.x,0,Character.TOrso.CFrame.p.z);
			local velocityDifference = math.abs(((npos-d.LastPosition).magnitude - (d.a.thrustForce.velocity.magnitude/30)));
			if (velocityDifference > 1) then
				
			end
		end
	]]--
	end
end


Gear.Equipped:connect(function()
	Character = Gear.Parent;
	Player = game:GetService("Players"):GetPlayerFromCharacter(Character);
	Humanoid = Character:FindFirstChild("Humanoid");
	if not Character or not Humanoid or Humanoid.Health == 0 then return; end
	
	local lMotor = Gear.Handle.lmotor;
	local rMotor = Gear.Handle.rmotor;	
	
	lMotor.AncestryChanged:connect(function()
		Spawn(function() lMotor.Parent = Gear.Handle end)
	end)
	
	rMotor.AncestryChanged:connect(function()
		Spawn(function() rMotor.Parent = Gear.Handle end)
	end)
	
	Spawn(function()
		while true do
			lMotor.DesiredAngle =1;
			rMotor.DesiredAngle = -1;
			wait(.5);
			lMotor.DesiredAngle = 0;
			rMotor.DesiredAngle = 0;
			wait(.5);
		end
	end);

	Controller:InvokeClient(Player, ClientAgent.REQUEST_ANIMATIONS, "holdAni");
	s["Running"]:Play();
	d.CurrentSpeed = 25;
	d.turnSpeed = 0;
	d.Equipped = true;
	
	local myTorso = Character:WaitForChild("Torso");
	Gear.Handle.CFrame = myTorso.CFrame;
	Humanoid.PlatformStand = true;
	
	if (d.a.TurnGyro ~= nil) then d.a.TurnGyro:Destroy(); end
	d.a.TurnGyro = Instance.new('BodyGyro', Gear.Handle);
	d.a.TurnGyro.maxTorque = Vector3.new(math.huge,0,math.huge);
	
	if (d.a.thrustForce ~= nil) then d.a.thrustForce:Destroy(); end
	d.a.thrustForce = Instance.new("BodyVelocity", Gear.Handle);
	d.a.thrustForce.maxForce = Vector3.new(math.huge,math.huge,math.huge);
	d.a.thrustForce.velocity = Vector3.new(0,0,0);
	
	if (d.a.RotationForce ~= nil) then d.a.RotationForce:Destroy() end
	d.a.RotationForce = Instance.new("BodyAngularVelocity", Gear.Handle);
	d.a.RotationForce.maxTorque = Vector3.new(math.huge, math.huge, math.huge);
	d.a.RotationForce.angularvelocity = Vector3.new(0,0,0);
	
	Spawn(d.ThrustUpdater);
	
	Spawn(function()
		myTorso.Anchored = true;
		myTorso.CFrame = myTorso.CFrame + Vector3.new(0,3,0);
		
		if (d.a.torsoWeld ~= nil) then d.a.torsoWeld:Destroy(); end
		d.a.torsoWeld = Instance.new("Weld", myTorso);
		d.a.torsoWeld.C0 = CFrame.new(0, -2.49999952, -0.200000003, 1, 0, 0, 0, 1, 0, 0, 0, 1);
		d.a.torsoWeld.Part0 = myTorso;
		d.a.torsoWeld.Part1 = Gear.Handle;
		
		wait(.1);
		Gear.Handle.CanCollide = true;
		myTorso.Anchored = false;
		myTorso.CFrame = myTorso.CFrame + Vector3.new(0,3,0);
		local rgrip = Character:WaitForChild("Right Arm"):FindFirstChild("RightGrip");
		if (rgrip ~= nil) then rgrip:Destroy() end;
	end);
end);

Gear.Unequipped:connect(function()
	d.Equipped = false;
	wait(.3);
	Gear.Handle.Size = Vector3.new(.2,.2,.2);
	
	d.up = false;
	d.left = false;
	d.right = false;
	d.down = false;
	
	s["Running"]:Stop();
	
	Humanoid.WalkSpeed = 16;
	Humanoid.PlatformStand = false;
	Controller:InvokeClient(Player, ClientAgent.REQUEST_ANIMATIONS_END);

	if (d.a.torsoWeld ~= nil) then d.a.torsoWeld:Destroy(); d.a.torsoWeld = nil; end
	
end);

