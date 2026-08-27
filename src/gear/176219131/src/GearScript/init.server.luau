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
local s = { ["Cheer"] = Gear.Handle:WaitForChild("Cheer")};

function TagHumanoid(a,b)local c=Instance.new("ObjectValue")c.Name="creator"c.Value=b;d.Debris:AddItem(c,2)c.Parent=a end
function UntagHumanoid(a)for b,c in pairs(a:GetChildren())do if c:IsA("ObjectValue")and c.Name=="creator"then c:Destroy()end end end

function Controller.OnServerInvoke(p, e, ...)
	local tuples={...};
	if (e == ClientAgent.SERVER_PLAY_SOUND) then
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
	if not Gear.Enabled or not Humanoid or Humanoid.Health == 0 then return; end
	Gear.Enabled = false;
	Controller:InvokeClient(Player, ClientAgent.REQUEST_ANIMATIONS, "Yay");
	s["Cheer"]:Play();
	Gear.Handle.Sparkles.Enabled = true;
	Gear.GripForward = Vector3.new(-0.577, 0.817, 0);
	wait(1);
	Gear.Handle.Sparkles.Enabled = false;
	Gear.GripForward = Vector3.new(-1, 0, 0);
	Gear.Enabled = true;
end)