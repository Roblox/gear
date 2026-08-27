--[[alexnewtron 2014]]--
model = script.Parent;

local model = script.Parent
model:WaitForChild("Brakelight_Left");
model:WaitForChild("Brakelight_Right");
model:WaitForChild("Headlight_Left");
model:WaitForChild("Headlight_Right");
model:WaitForChild("Wheel_FrontLeft");
model:WaitForChild("Wheel_FrontRight");
model:WaitForChild("Wheel_BackLeft");
model:WaitForChild("Wheel_BackRight");
model:WaitForChild("ExhaustPipe");
model.ExhaustPipe:WaitForChild("Smoke");
model.ExhaustPipe:WaitForChild("Fire");
model:WaitForChild("VehicleSeat");
model:WaitForChild("VehicleSeatBack");
model.VehicleSeatBack:WaitForChild("BodyGyro");
model:WaitForChild("Bumper_Front");
model:WaitForChild("Bumper_Back");

local config = {
	DebrisService = Game:GetService('Debris'),
	PlayersService = Game:GetService('Players'),
	seat = model.VehicleSeat,
	driverInSeat = false,
	smoke = model.ExhaustPipe.Smoke,
	fire = model.ExhaustPipe.Fire,
	brake_L = model.Brakelight_Left,
	brake_R = model.Brakelight_Right,
	brake_L_light = model.Brakelight_Left:WaitForChild('PointLight'),
	brake_R_light = model.Brakelight_Right:WaitForChild('PointLight'),
	light_L = model.Headlight_Left,
	light_R = model.Headlight_Right,
	vehicleSeatBack = model.VehicleSeatBack,
	gyro = model.VehicleSeatBack.BodyGyro,
	backBumperForce = model.Bumper_Back.BodyForce,
	frontBumperForce = model.Bumper_Front.BodyForce,
	seats =	{
		model:WaitForChild('BackSeat1');
		model:WaitForChild('BackSeat2');
		model:WaitForChild('PassengerSeat');
	},
	settings = {
		brakeColor_on = BrickColor.new("Really red"),
		brakeColor_off = BrickColor.new("Reddish brown"),
		lightColor_on = BrickColor.new("Institutional white"),
		lightColor_off = model.Headlight_Left.BrickColor,
		smokeOpacity_throttleOn = 0.5,
		smokeOpacity_throttleOff = 0.1,
		fireSize_big = 7,
		fireSize_small = 3,
		tiltForce = 84000,
		tiltTime = 1
	}
};


function seatChildAddedHandler(child)
	if child.Name=="SeatWeld" then
		config.driverInSeat = true;
		config.smoke.Enabled = true;
		config.smoke.Opacity = config.settings.smokeOpacity_throttleOff;
		config.light_L.BrickColor = config.settings.lightColor_on;
		config.light_R.BrickColor = config.settings.lightColor_on;
		config.fire.Size = config.settings.fireSize_big;
		config.fire.Enabled = true;
		wait(0.3);
		config.fire.Size = config.settings.fireSize_small;
		if config.seat.Throttle==0 then
			config.fire.Enabled = false;
		end
	end
end

function seatChildRemovedHandler(child)
	if child.Name=="SeatWeld" then
		config.driverInSeat = false;
		config.smoke.Enabled = false;
		config.light_L.BrickColor = config.settings.lightColor_off;
		config.light_R.BrickColor = config.settings.lightColor_off;
	end
end

function showBigFire()
	config.fire.Size = config.settings.fireSize_big;
	config.fire.Enabled = true;
	wait(0.3);
	if config.seat.Throttle==1 then
		config.fire.Size = config.settings.fireSize_small
	end
	wait(1)
	if config.seat.Throttle==1 then
		config.fire.Enabled = false
	end
end

function tiltJeepBack()
	wait(config.settings.tiltTime);
end

function tiltJeepForward()
	wait(config.settings.tiltTime);
end

function seatChangedHandler(prop)
	if prop=="Throttle" then
		if config.seat.Throttle==1 then
			config.brake_L.BrickColor = config.settings.brakeColor_off;
			config.brake_R.BrickColor = config.settings.brakeColor_off;
			config.smoke.Opacity = config.settings.smokeOpacity_throttleOn;
			local co = coroutine.create(showBigFire);
			coroutine.resume(co);
			local co2 = coroutine.create(tiltJeepBack);
			coroutine.resume(co2);
		elseif seat.Throttle==0 then
			config.brake_L.BrickColor = config.settings.brakeColor_on;
			config.brake_L_light.Enabled = true;
			config.brake_R.BrickColor = config.settings.brakeColor_on;
			config.brake_R_light.Enabled = true;
			config.smoke.Opacity = config.settings.smokeOpacity_throttleOff;
			config.fire.Enabled = false;
			wait(0.9);
			if config.brake_L.BrickColor==brakeColor_on then
				config.brake_L.BrickColor = config.settings.brakeColor_off;
				config.brake_L_light.Enabled = false;
			end
			if config.brake_R.BrickColor==brakeColor_on then
				config.brake_R.BrickColor = config.settings.brakeColor_off;
				config.brake_R_light.Enabled = false;
			end
		elseif seat.Throttle==-1 then
			config.brake_L.BrickColor = config.settings.lightColor_on;
			config.brake_R.BrickColor = config.settings.lightColor_on;
			config.smoke.Opacity = config.settings.smokeOpacity_throttleOff;
			config.fire.Enabled = false;
			local co = coroutine.create(tiltJeepForward);
			coroutine.resume(co);
		end
	end
end

function checkFareHandler(seat, child)
	if child:IsA('Weld') and child.Part1 and
		child.Part1.Name == 'Torso' and child.Part1.Parent:FindFirstChild('Humanoid') then	
		local sittingCharacter = child.Part1.Parent
		if PlayersService:GetPlayerFromCharacter(sittingCharacter) then
			local sittingPlayer = PlayersService:GetPlayerFromCharacter(sittingCharacter);
		end
	end	
end

-- Returns a character ancestor and its Humanoid, or nil
function FindCharacterAncestor(subject)
	if subject and subject ~= Workspace then
		local humanoid = subject:FindFirstChild('Humanoid')
		if humanoid then
			return subject, humanoid
		else
			return FindCharacterAncestor(subject.Parent)
		end
	end
	return nil
end


function seatFareFunctionFactory(seat)
	seat.ChildAdded:connect(function(child) checkFareHandler(seat, child) end)
end

for _, seat in pairs(config.seats) do
	seatFareFunctionFactory(seat)
end

config.light_L.BrickColor = config.settings.lightColor_off
config.light_R.BrickColor = config.settings.lightColor_off
config.brake_L.BrickColor = config.settings.brakeColor_off
config.brake_R.BrickColor = config.settings.brakeColor_off
config.smoke.Enabled = false
config.fire.Enabled = false



config.seat.ChildAdded:connect(seatChildAddedHandler)
config.seat.ChildRemoved:connect(seatChildRemovedHandler)
config.seat.Changed:connect(seatChangedHandler)

Spawn(function()
	local ownerTag = model:WaitForChild('Owner')
	if ownerTag and ownerTag.Value then
		PlayersService.PlayerRemoving:connect(function(player)
			if player == ownerTag.Value then
				model:Destroy()
			end
		end)
	end
end)

while true do
	if(config.vehicleSeatBack.CFrame.lookVector.y <= 0.707) then
		config.gyro.cframe = CFrame.new( Vector3.new(0,0,0), Vector3.new(0,1,0) )
		config.gyro.maxTorque = Vector3.new(1000, 1000, 1000)
		wait(2)
		config.gyro.maxTorque = Vector3.new(0,0,0)
	end
	if (model == nil or model.Parent == nil) then break; end
	wait(8)
end
