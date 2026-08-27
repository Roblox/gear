--[[ alexnewtron 2014 ]]--
-- Fixed by ArceusInator

local ClientAgent = require(script:WaitForChild("ClientAgent"));
local Controller = script:WaitForChild("Controller");
local Gear = script.Parent;

local PlayersService = Game:GetService('Players');
local DebrisService = Game:GetService('Debris');

local Character = nil;
local Player = nil;
local Humanoid = nil;

local Check = true;

local d = { Debris = game:GetService("Debris") };
local s = { 
	["BashHit"] = Gear.Handle:WaitForChild("BashHit"),
	["BashMiss"] = Gear.Handle:WaitForChild("BashMiss"),
	["Slash"] = Gear.Handle:WaitForChild("Slash"),
	["SwordDraw"] = Gear.Handle:WaitForChild("SwordDraw"),
	["SwordHit"] = Gear.Handle:WaitForChild("SwordHit"),
	["Yell"] = Gear.Handle:WaitForChild("Yell"),
 };

function TagHumanoid(a,b)local c=Instance.new("ObjectValue")c.Name="creator"c.Value=b;d.Debris:AddItem(c,2)c.Parent=a end
function UntagHumanoid(a)for b,c in pairs(a:GetChildren())do if c:IsA("ObjectValue")and c.Name=="creator"then c:Destroy()end end end


if (Gear:FindFirstChild("Ammo")) then
	Gear["Ammo"]:Destroy();
end

function Controller.OnServerInvoke(p, e, ...)
	local tuples={...};
	if (e == ClientAgent.SERVER_START) then
		d.throw();
	elseif (e == ClientAgent.SERVER_PLAY_SOUND) then
		s[tuples[1]]:Play();
	end
end;

function weldShield()
	local leftArm = Character:FindFirstChild("Left Arm");
	if (leftArm ~= nil) then
		local s = Instance.new("Part");
		s.Name = "Shield";
		s.BottomSurface = 'Smooth'
		s.TopSurface = 'Smooth'
		s.Parent = leftArm;
		s.Size = Vector3.new(2.82, 3.25, 0.58);
		s.CanCollide = false;
		local m = Instance.new("SpecialMesh")
		m.MeshId = "http://www.roblox.com/asset/?id=176248871";
		m.TextureId = "http://www.roblox.com/asset/?id=176248956";
		m.Scale = Vector3.new(1.5,1.35,1.5);
		m.Parent = s;
		
		local w = Instance.new("Weld", s);
		w.Part0 = s;
		w.Part1 = leftArm;
		w.C0 = CFrame.new(0,-.25,1)*CFrame.Angles(1.5,100,-250);
	end
	
end

Gear.Equipped:connect(function()
	Character = Gear.Parent;
	Player = game:GetService("Players"):GetPlayerFromCharacter(Character);
	Humanoid = Character:FindFirstChild("Humanoid");
	if not Character or not Humanoid or Humanoid.Health == 0 then return; end
	Controller:InvokeClient(Player, ClientAgent.REQUEST_ANIMATIONS, "ShieldWalk");
	weldShield();
	s["SwordDraw"]:Play();
	Gear.Activated:connect(function()
		if not Check or not Humanoid or Humanoid.Health == 0 then return; end
		Check = false;
		Controller:InvokeClient(Player, ClientAgent.REQUEST_ANIMATIONS, "QuickSlash");
		Spawn(function()
			for i=1, 15 do
				local p = Instance.new("Part", workspace);
				p.Transparency = 1;
				p.Anchored = true;
				p.CanCollide = false;
				p.CFrame = Gear.Handle.CFrame;
				local f = Gear.Handle.Fire:Clone();
				f.Parent = p;
				f.Enabled = true;
				d.Debris:AddItem(p, 4);
				wait();		
			end
		end)
		s["BashMiss"]:Play();
		wait(.3);
		Check = true;
	end)
end);

Gear.Unequipped:connect(function()
	swing = false;
	Check = true;
	Controller:InvokeClient(Player, ClientAgent.REQUEST_ANIMATIONS_END);
	local leftArm = Character:findFirstChild("Left Arm");
	if (leftArm:findFirstChild("Shield")) then
		leftArm["Shield"]:Destroy();
	end
end)

Gear.Handle.Touched:connect(function(p)
	if (Player ~= nil and Character ~= nil and p ~= nil and p.Parent ~= nil and p.Parent ~= Character) then
		local h = p.Parent:findFirstChild("Humanoid");
		local t = p.Parent:findFirstChild("Torso");
		if (h ~= nil and t ~= nil and h.Health > 0) then
			local cT = h:findFirstChild("creator");
			if (cT == nil or cT ~= nil and cT.Value ~= Player) then
				for i,v in ipairs(h:GetChildren()) do
					if v.Name=="creator" then
						v:Destroy()
					end
				end	
				UntagHumanoid(h);
				TagHumanoid(h,Player);
				h:TakeDamage(30);
				s["SwordHit"]:Play();
			end
		end
	end
end);