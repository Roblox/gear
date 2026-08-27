--[[ alexnewtron 2014 ]]--

function Create(ty)
	return function(data)
		local obj = Instance.new(ty)
		for k, v in pairs(data) do
			if type(k) == 'number' then
				v.Parent = obj
			else
				obj[k] = v
			end
		end
		return obj
	end
end

local ClientAgent = require(script:WaitForChild("ClientAgent"));
local Controller = script:WaitForChild("Controller");
local Gear = script.Parent;

local Character = nil;
local Player = nil;
local Humanoid = nil;

local Check = true;

local Events = {}

local d = { Debris = game:GetService("Debris") };
local s = { ["pin"] = Gear.Handle:WaitForChild("pin") };

function TagHumanoid(a,b)local c=Instance.new("ObjectValue")c.Name="creator"c.Value=b;d.Debris:AddItem(c,2)c.Parent=a end
function UntagHumanoid(a)for b,c in pairs(a:GetChildren())do if c:IsA("ObjectValue")and c.Name=="creator"then c:Destroy()end end end

function Controller.OnServerInvoke(p, e, ...)
	local tuples={...};
	if (e == ClientAgent.SERVER_START) then
		--d.throw();
	elseif (e == ClientAgent.SERVER_PLAY_SOUND) then
		s[tuples[1]]:Play();
	end
end;

function d.throw()
	if not Gear:IsDescendantOf(Character) then Gear.Handle.Transparency = 0;Check = true return end
	Gear.Handle.Transparency = 1;
	local head = Character:FindFirstChild("Head");
	if (head) then
		local fB = Instance.new("Part");
		fB.Transparency = 0;
		fB.Name = "Effect";
		fB.BrickColor = BrickColor.new("Bright orange");
		fB.Size = Vector3.new(2,2,2);
		fB.CanCollide = true;
		fB.CFrame = CFrame.new(Gear.Handle.Position + head.CFrame.lookVector * 4);
		fB.Velocity=head.CFrame.lookVector * math.random(50,80)+Vector3.new(0,25,0);
		fB.TopSurface=Enum.SurfaceType.Smooth;
		fB.BottomSurface=Enum.SurfaceType.Smooth;
		local fM = Instance.new("SpecialMesh", fB);
		fM.MeshId = "http://www.roblox.com/asset/?id=166887416";
		fM.TextureId = "http://www.roblox.com/asset/?id=166887373";
		local sound1 = Instance.new("Sound", fB);
		sound1.SoundId = "http://www.roblox.com/asset/?id=168192032";
		sound1.Name = "Splat";
		local tag=Instance.new("ObjectValue")
		tag.Name="creator"
		tag.Value=game.Players:GetPlayerFromCharacter(script.Parent.Parent)
		tag.Parent=fB
		local bang = script.bang:Clone();
		Create("ObjectValue"){
			Name = "Creator",
			Value = Player,
			Parent = bang
		}
		bang.Parent = fB;
		bang.Disabled = false;
		d.Debris:AddItem(fB, 10);
		fB.Parent = workspace;
		wait(.5);
		Controller:InvokeClient(Player, ClientAgent.REQUEST_ANIMATIONS_END);
	end
	wait(4);
	Gear.Handle.Transparency = 0;
	Check = true;
end

Gear.Equipped:Connect(function()
	Character = Gear.Parent;
	Player = game:GetService("Players"):GetPlayerFromCharacter(Character);
	Humanoid = Character:FindFirstChildOfClass("Humanoid");
	if not Character or not Humanoid or Humanoid.Health == 0 then return; end
	Events[#Events+1] = Gear.Activated:Connect(function()
		if not Check or not Humanoid or Humanoid.Health == 0 then return; end
	--	local TargetPoint = Controller:InvokeClient(Player, ClientAgent.REQUEST_TARGETPOINT);
	--	if not TargetPoint then return; end
		Check = false;
		if Humanoid then
			coroutine.wrap(function()
				if Humanoid.RigType == Enum.HumanoidRigType.R15 then
					Controller:InvokeClient(Player, ClientAgent.REQUEST_ANIMATIONS, "R15Throw");
				else
					Controller:InvokeClient(Player, ClientAgent.REQUEST_ANIMATIONS, "Throw");
				end
			end)()
			wait(1.5)
			d.throw();
		end
	end)
end);

Gear.Unequipped:Connect(function()
	for i=1,#Events,1 do
		if Events[i] then Events[i]:Disconnect();Events[i] = nil end
	end
	Events = {}
	--Controller:InvokeClient(Player, ClientAgent.REQUEST_ANIMATIONS_END)
end);