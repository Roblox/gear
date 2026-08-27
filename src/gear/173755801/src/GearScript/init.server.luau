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
local s = { 
	["Equip"] = Gear.Handle:WaitForChild("EquipSound"),
	["Slash1"] = Gear.Handle:WaitForChild("SlashSound"),
	["SwordHit"] = Gear.Handle:WaitForChild("SwordHit")
 };

function TagHumanoid(a,b)local c=Instance.new("ObjectValue")c.Name="creator"c.Value=b;d.Debris:AddItem(c,2)c.Parent=a end
function UntagHumanoid(a)for b,c in pairs(a:GetChildren())do if c:IsA("ObjectValue")and c.Name=="creator"then c:Destroy()end end end

function Controller.OnServerInvoke(p, e, ...)
	local tuples={...};
	if (e == ClientAgent.SERVER_START) then
		d.throw();
	elseif (e == ClientAgent.SERVER_PLAY_SOUND) then
		s[tuples[1]]:Play();
	elseif (e == ClientAgent.DAMAGE_PLAYER) then
		UntagHumanoid(tuples[1]);
		TagHumanoid(tuples[1],Player);
		tuples[1]:TakeDamage(tuples[2]);
		s["SwordHit"]:Play();
		if (tuples[1].Health <= 0) then
			local p = tuples[1].Parent:GetChildren();
			for i=1, #p do
				if (p[i]:IsA("Part")) then
					p[i].BrickColor = BrickColor.new("Cyan");
					p[i].Material = Enum.Material.Foil;
					local s = Instance.new("Sparkles", p[i]);
				elseif (p[i]:IsA("Shirt") or p[i]:IsA("Pants") or p[i]:IsA("CharacterMesh")) then
					p[i]:Destroy();
				end
			end
		end
	end
end;


Gear.Equipped:connect(function()
	Character = Gear.Parent;
	Player = game:GetService("Players"):GetPlayerFromCharacter(Character);
	Humanoid = Character:FindFirstChild("Humanoid");
	if not Character or not Humanoid or Humanoid.Health == 0 then return; end
	Controller:InvokeClient(Player, ClientAgent.REQUEST_ANIMATIONS, "Equip");
	s["Equip"]:Play();
	Gear.Activated:connect(function()
		if not Gear.Enabled or not Humanoid or Humanoid.Health == 0 then return; end
		Gear.Enabled = false;
		s["Slash1"]:Play();
		Controller:InvokeClient(Player, ClientAgent.REQUEST_ANIMATIONS, "SlashAnim");
		Spawn(function()
			while not Gear.Enabled do
				local c = Gear.Handle:Clone();
				c.Anchored = true;
				c.CanCollide = false;
				c.Transparency = .5;
				c.CFrame = Gear.Handle.CFrame;
				d.Debris:AddItem(c, 3);
				c.Parent = workspace;				
				wait();
			end
		end)
		wait(.5);
		Gear.Enabled = true;
	end)
end);

Gear.Unequipped:connect(function()
	swing = false;
	Gear.Enabled = true;
	Controller:InvokeClient(Player, ClientAgent.REQUEST_ANIMATIONS_END);
	local leftArm = Character:findFirstChild("Left Arm");
	if (leftArm:findFirstChild("Shield")) then
		leftArm["Shield"]:Destroy();
	end
end)

