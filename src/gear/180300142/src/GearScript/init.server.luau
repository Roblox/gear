--[[ alexnewtron 2014 ]]--

local ClientAgent = require(script:WaitForChild("ClientAgent"));
local Controller = script:WaitForChild("Controller");
local Gear = script.Parent;

local Character = nil;
local Player = nil;
local Humanoid = nil;

local Check = true;

local d = { Debris = game:GetService("Debris") };
local s = {};

function TagHumanoid(a,b)local c=Instance.new("ObjectValue")c.Name="creator"c.Value=b;d.Debris:AddItem(c,2)c.Parent=a end
function UntagHumanoid(a)for b,c in pairs(a:GetChildren())do if c:IsA("ObjectValue")and c.Name=="creator"then c:Destroy()end end end

function d.throw()
	local bomb = script.Parent.Handle:Clone()
	bomb.CanCollide = true
	bomb.Transparency = 0
	bomb.Position = script.Parent.Handle.Position;
	bomb.Name = "TrickOrTrap"
	bomb.Locked = true;
	local gyro = Instance.new("BodyGyro", bomb);
	gyro.maxTorque = Vector3.new(400000, 400000, 400000);
	gyro.P = 3000;
	gyro.D = 500;	
	local owner = Instance.new("ObjectValue", bomb);
	owner.Name = "creator";
	owner.Value = game.Players.LocalPlayer;
	local new_script = script.TrickOrTreat:clone()
	new_script.Disabled = false
	new_script.Parent = bomb	
	bomb.Parent = workspace
	Gear:Destroy();
end

function Controller.OnServerInvoke(p, e, ...)
	local tuples={...};
	if (e == ClientAgent.SERVER_START) then
		d.throw();
	elseif (e == ClientAgent.SERVER_PLAY_SOUND) then
		s[tuples[1]]:Play();
	end
end;

Gear.Equipped:connect(function()
	Character = Gear.Parent;
	Player = game:GetService("Players"):GetPlayerFromCharacter(Character);
	Humanoid = Character:FindFirstChild("Humanoid");
	if not Character or not Humanoid or Humanoid.Health == 0 then return; end
end);

Gear.Activated:connect(function()
	if not Check or not Humanoid or Humanoid.Health == 0 then return; end
	Check = false;
	Controller:InvokeClient(Player, ClientAgent.REQUEST_ANIMATIONS, "Prepare");
end)

Gear.Unequipped:connect(function()
	Character = nil;
	Player = nil;
	Humanoid = nil;
end);