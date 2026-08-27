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
	["FireSound"] = Gear.Handle:WaitForChild("FireSound"),
	["HitSound"] = Gear.Handle:WaitForChild("HitSound"),
};

local a = {
	Grips = {
		CFrame.new(0, -0.55, 1.3, 1, 0, 0, 0, 1, 0, 0, 0, 1),
		CFrame.new(0, -0.55, 1.2, 1, 0, 0, 0, 1, 0, 0, 0, 1)
	},
	Speed = 50,
	Gravity = 196.2,
	Damage = 30,
	ArrowsShot = 0,
	ArrowStock = 10,
	ReloadTime = .5,
	ReloadAmmoTime = 3
};

local Arrow = Instance.new("Part");
Arrow.Name = "Arrow";
Arrow.Material = Enum.Material.Plastic;
Arrow.Shape = Enum.PartType.Block;
Arrow.TopSurface = Enum.SurfaceType.Smooth;
Arrow.BottomSurface = Enum.SurfaceType.Smooth;
Arrow.FormFactor = Enum.FormFactor.Custom;
Arrow.Size = Vector3.new(1,1,1);
Arrow.BrickColor = BrickColor.new("Bright red");
local ArrowMesh = Instance.new("SpecialMesh");
ArrowMesh.MeshType = Enum.MeshType.FileMesh;
ArrowMesh.MeshId = "http://www.roblox.com/asset?id=172088909";
ArrowMesh.TextureId = "http://www.roblox.com/asset/?id=176248618"
ArrowMesh.Scale = Vector3.new(2, 2, 2);
ArrowMesh.Parent = Arrow;
ArrowSound = s["HitSound"]:Clone();
ArrowSound.Parent = Arrow;

function TagHumanoid(a,b)local c=Instance.new("ObjectValue")c.Name="creator"c.Value=b;d.Debris:AddItem(c,2)c.Parent=a end
function UntagHumanoid(a)for b,c in pairs(a:GetChildren())do if c:IsA("ObjectValue")and c.Name=="creator"then c:Destroy()end end end

Gear.Equipped:connect(function()
	Character = Gear.Parent;
	Player = game:GetService("Players"):GetPlayerFromCharacter(Character);
	Humanoid = Character:FindFirstChild("Humanoid");
	if not Character or not Humanoid or Humanoid.Health == 0 then return; end
end);

Gear.Activated:connect(function()
	if not Gear.Enabled or not Humanoid or Humanoid.Health == 0 then return; end
	Gear.Enabled = false;
	local TargetPoint = Controller:InvokeClient(Player, ClientAgent.REQUEST_TARGETPOINT);
	local TargetInFront = math.acos((TargetPoint - Gear.Handle.Position).unit:Dot(Gear.Handle.CFrame.lookVector))
	if a.ArrowsShot >= a.ArrowStock then
		a.ArrowsShot = 0;
		Gear.Enabled = false;
		Controller:InvokeClient(Player, ClientAgent.REQUEST_ANIMATIONS, "Reload");
		wait(a.ReloadAmmoTime);
		Gear.Enabled = true;
		return;
	end	
	a.ArrowsShot = (a.ArrowsShot + 1);
	Gear.Enabled = false;
	Gear.Grip = a.Grips[2];
	s["FireSound"]:Play();
		
	local ArrowClone = Arrow:Clone();
	local HitDebounce = false;
	
	
	ArrowClone.Touched:connect(function(Hit)
		if not Hit or not Hit.Parent or HitDebounce or Hit.Name == "Arrow" then
			return;
		end
		if Hit.Parent == Character or Hit.Parent.Parent == Character then
			return;
		end
		HitDebounce = true
		ArrowClone.HitSound:Play();
		local Weld = Instance.new("Weld");
		Weld.Part0 = Hit;
		Weld.Part1 = ArrowClone;
		local humanHit = Hit.Parent:FindFirstChild("Humanoid");
		if humanHit and humanHit ~= Humanoid then
			UntagHumanoid(humanHit);
			TagHumanoid(humanHit, Player);
			humanHit:TakeDamage(math.random(10,20));
			local StickCFrame = CFrame.new(Hit.CFrame.p, ArrowClone.Position) * CFrame.new(0, 0, -1) * CFrame.Angles((math.pi / 2), (math.random() * math.pi * 2), 0);
			Weld.C1 = StickCFrame:inverse() * Hit.CFrame;
		else
			Weld.C1 = ArrowClone.CFrame:inverse() * Hit.CFrame;
		end
		Weld.Parent = ArrowClone;
		ArrowClone.CanCollide = false;
	end);
	
	local Direction = CFrame.new(Gear.Handle.Position, TargetPoint);
	local Mass = (ArrowClone:GetMass() * a.Gravity);
	local BodyGyro = Instance.new("BodyGyro");
	BodyGyro.maxTorque = Vector3.new(math.huge, math.huge, math.huge);
	BodyGyro.cframe = Direction;
	BodyGyro.Parent = ArrowClone;
	local BodyVelocity = Instance.new("BodyVelocity");
	BodyVelocity.maxForce = Vector3.new(Mass, Mass, Mass);
	BodyVelocity.velocity = Direction.lookVector * a.Speed;
	BodyVelocity.Parent = ArrowClone;
	ArrowClone.Velocity = BodyVelocity.velocity;
	d.Debris:AddItem(ArrowClone, 5);
	ArrowClone.Parent = game:GetService("Workspace");
	ArrowClone.CFrame = Gear.Handle.CFrame + Gear.Handle.CFrame.lookVector * ((Gear.Handle.Size.Z / 2) + (ArrowClone.Size.Z / 2));
	ArrowClone.CFrame = CFrame.new(ArrowClone.Position, TargetPoint);
	wait(a.ReloadTime);
	Gear.Grip = a.Grips[1];
	Gear.Enabled = true;
end)