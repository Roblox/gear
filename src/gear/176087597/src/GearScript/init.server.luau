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

local d = { Debris = game:GetService("Debris") };
local s = { ["Fly"] = Gear.Handle:WaitForChild("FlyingSound")};

function TagHumanoid(a,b)local c=Instance.new("ObjectValue")c.Name="creator"c.Value=b;d.Debris:AddItem(c,2)c.Parent=a end
function UntagHumanoid(a)for b,c in pairs(a:GetChildren())do if c:IsA("ObjectValue")and c.Name=="creator"then c:Destroy()end end end

function Controller.OnServerInvoke(p, e, ...)
	local tuples={...};
	if (e == ClientAgent.SERVER_PLAY_SOUND) then
		s[tuples[1]]:Play();
	elseif (e == ClientAgent.FIRE) then
		Spawn(fire);
	end
end;

function fire()
	local targetPos = Controller:InvokeClient(Player, ClientAgent.REQUEST_TARGETPOINT);
	local v = (targetPos - Character.Head.Position).unit;	
	s["Fly"]:Play();
	local missile = Gear.Handle;
	local spawnPos = Character.PrimaryPart.Position;
	targetPos = spawnPos + (v * 100);
	Gear.Parent = workspace;
	local bodyp = Instance.new("BodyPosition");	
	bodyp.maxForce = Vector3.new(1e3,1e3,1e3);
	bodyp.D = 1.5e3;
	bodyp.P = 1e3;
	bodyp.position = targetPos;
	bodyp.Parent = missile;
	wait(1);
	bodyp.position = Vector3.new(targetPos.X,0,targetPos.Z);
	bodyp.D = 1.6e3;
	wait(1);
	bodyp:Destroy();
	s["Fly"]:Stop();
	Gear.Enabled = true;
end

Gear.Equipped:connect(function()
	Character = Gear.Parent;
	Player = game:GetService("Players"):GetPlayerFromCharacter(Character);
	Humanoid = Character:FindFirstChild("Humanoid");
	if not Character or not Humanoid or Humanoid.Health == 0 then return; end
	Gear.Activated:connect(function()
		if not Gear.Enabled or not Humanoid or Humanoid.Health == 0 then return; end
		Gear.Enabled = false;
		Controller:InvokeClient(Player, ClientAgent.REQUEST_ANIMATIONS, "Throw");
	end)
end);

Gear.Handle.Touched:connect(function(part)
	local h = part.Parent:FindFirstChild("Humanoid");
	if h ~= nil and Gear.Parent == workspace then
		s["Fly"]:Stop();
		local bP = Gear.Handle:findFirstChild("BodyPosition");
		if (bP ~= nil) then
			bP:Destroy();
		end		
		Gear.Enabled = true;
	end
end);