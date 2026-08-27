--[[ alexnewtron 2014 ]]--

local ClientAgent = require(script:WaitForChild("ClientAgent"));
local Controller = script:WaitForChild("Controller");
local Gear = script.Parent;

local Character = nil;
local Player = nil;
local Humanoid = nil;

local Check = true;
local Dmg = false;
local swing = false;

local d = { Debris = game:GetService("Debris") };
local s = { 
	["swing"] = script.Parent.Handle:WaitForChild("Swing"),
	["whip"] = script.Parent.Handle:WaitForChild("Whip")
 };

function TagHumanoid(a,b)local c=Instance.new("ObjectValue")c.Name="creator"c.Value=b;d.Debris:AddItem(c,2)c.Parent=a end
function UntagHumanoid(a)for b,c in pairs(a:GetChildren())do if c:IsA("ObjectValue")and c.Name=="creator"then c:Destroy()end end end

function Controller.OnServerInvoke(p, e, ...)
	local tuples={...};
	if (e == ClientAgent.SERVER_START) then
		d.throw();
	elseif (e == ClientAgent.SERVER_PLAY_SOUND) then
		s[tuples[1]]:Play();
	elseif (e == ClientAgent.straight) then
		Gear.Effect.Transparency = 1;
		Gear.Handle.Transparency = 0;
		Dmg = true;
		swing = false;
		wait(.5);
		s["swing"]:Play();
	elseif (e == ClientAgent.done) then
		Gear.Effect.Transparency = 0;
		Gear.Handle.Transparency = 1;
		Dmg = false;
		Check = true;
		wait(.5);
	end
end;

function spin()
	swing = true;
	local gR = Gear.Grip;
	while swing do
		Gear.Grip = Gear.Grip * CFrame.Angles(0,0.2,0);
		wait(.01);
	end
	Gear.Grip = gR;
end


Gear.Equipped:connect(function()
	Character = Gear.Parent;
	Player = game:GetService("Players"):GetPlayerFromCharacter(Character);
	Humanoid = Character:FindFirstChild("Humanoid");
	if not Character or not Humanoid or Humanoid.Health == 0 then return; end
	Gear.Activated:connect(function()
		if not Check or not Humanoid or Humanoid.Health == 0 then return; end
		Check = false;
		Controller:InvokeClient(Player, ClientAgent.REQUEST_ANIMATIONS, "Swing");
		s["whip"]:Play();
		Gear.Effect.Transparency = 0;
		Gear.Handle.Transparency = 1;
		spin();
	end)
end);

Gear.Unequipped:connect(function()
	swing = false;
	Check = true;
	Controller:InvokeClient(Player, ClientAgent.REQUEST_ANIMATIONS_END);
end)

Gear.Handle.Touched:connect(function(p)
	if (Player ~= nil and Character ~= nil and p ~= nil and p.Parent ~= nil and not Check and Dmg and p.Parent ~= Character) then
		local h = p.Parent:findFirstChild("Humanoid");
		local t = p.Parent:findFirstChild("Torso");
		if (h ~= nil and t ~= nil and h.Health > 0) then
			local f = t:findFirstChild("fireDeath");
			local cT = h:findFirstChild("creator");
			if (cT == nil or cT ~= nil and cT.Value ~= Player) then
				for i,v in ipairs(h:GetChildren()) do
					if v.Name=="creator" then
						v:Destroy()
					end
				end	
				UntagHumanoid(h);
				TagHumanoid(h,Player);
				h.Sit = true;
				h:TakeDamage(75);
			end
		end
	end
end);