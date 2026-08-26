--[[ alexnewtron 2014 ]]--
script.Parent:WaitForChild("Handle");

local gearConfig = {
	gear = script.Parent,
	equipped = false,
	check = true,
	debris = game:GetService("Debris"),
	tween = require(script:WaitForChild("b")),
	easing = require(script:WaitForChild("e")),
	mesh = script.Parent.Handle:WaitForChild("Mesh"),
	fuseSound = script.Parent.Handle:WaitForChild("Fuse"),
	anims = {
		script.Parent:WaitForChild("Light")
	},
	sparkColors = {Color3.new(255/255,193/255,5/255), Color3.new(207/255, 17/255, 17/255)},
	sparkStartPos = {UDim2.new(0.5,0,0,0), UDim2.new(0.35,0,0,0), UDim2.new(0.85,0,0,0)},
	lit = false,
	readyAnims = {}
};

function gearConfig.lightAnimation()
	local b = Instance.new("BillboardGui");
	b.Size = UDim2.new(1,0,1,0);
	b.Name = "Sparks";
	b.ExtentsOffset = Vector3.new(0,-0.5,0);
	local f = Instance.new("Frame", b);
	f.BackgroundTransparency = 1;
	f.Size = UDim2.new(1,0,1,0);
	gearConfig.debris:AddItem(b, 10);
	b.Parent = script.Parent.Handle;
	b.Adornee = script.Parent.Handle;
	gearConfig.lit = true;
	gearConfig.fuseSound:Play();
	for i=1, 250 do
		if (b.Parent ~= nil and gearConfig.lit) then
			local c = Instance.new("TextLabel", f);
			c.Name = "o";
			c.Text = "";
			c.Size = UDim2.new(0.1,0,0.1,0);
			c.BackgroundTransparency = 0;
			c.BorderSizePixel = 0;
			c.Position = gearConfig.sparkStartPos[math.random(1, #gearConfig.sparkStartPos)];
			c.BackgroundColor3 = gearConfig.sparkColors[math.random(1, #gearConfig.sparkColors)];
			c:TweenSizeAndPosition(UDim2.new(0.05,0,0.05,0), UDim2.new(math.random(),0,1.5,0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 1, false);
			gearConfig.debris:AddItem(c, 1);
			wait(0.005);
		else
			b:Destroy();
			break;
		end
	end
end

function gearConfig.fireFirework()
	local a=gearConfig.tween("forward")a.add(0.5,{x=0.5},gearConfig.easing.inOutQuad)a.add(0.5,{x=0.1},gearConfig.easing.inOutBack)for x=1,200 do local b=a.getCurrentProperties()gearConfig.mesh.Scale=Vector3.new(0.5,b.x,0.5)a.update(0.025)wait(0.025)if b.x<=0.25 then break end end;local a=gearConfig.tween("forward")a.add(0.5,{x=0.1},gearConfig.easing.inOutQuad)a.add(0.5,{x=1},gearConfig.easing.inOutBack)for x=1,200 do local b=a.getCurrentProperties()gearConfig.mesh.Scale=Vector3.new(0.5,b.x,0.5)a.update(0.025)wait(0.025)if b.x>=1 then break end end
	script.Parent.Handle.Transparency = 1;
	gearConfig.fuseSound:Stop();
	gearConfig.lit = false;
	local bomb = script.Parent.Handle:Clone()
	bomb.CanCollide = true
	bomb.Transparency = 0
	bomb.Position = script.Parent.Handle.Position
	bomb.Name = "Shell"
	bomb.Locked = true	
	local new_script = script["Explosions"]:clone()
	new_script.Disabled = false
	new_script.Parent = bomb	
	bomb.Parent = workspace
	repeat wait() until bomb.Parent == nil
	script.Parent.Handle.Transparency = 0;
	gearConfig.mesh.Scale = Vector3.new(0.5,0.5,0.5);
	gearConfig.check = true;
end

gearConfig.gear.Unequipped:connect(function()
	gearConfig.equipped = false;
end);

gearConfig.gear.Equipped:connect(function()
	gearConfig.equipped = true;
	local human = script.Parent.Parent:findFirstChild("Humanoid");
	local torso = script.Parent.Parent:findFirstChild("Torso");
	gearConfig.readyAnims = {};
	for i=1, #gearConfig.anims do
		table.insert(gearConfig.readyAnims, human:LoadAnimation(gearConfig.anims[i]));
		gearConfig.readyAnims[1].KeyframeReached:connect(function(k)
			if (k == "light") then
				gearConfig.lightAnimation();
			elseif (k == "fire") then
				gearConfig.fireFirework();
			end
		end);
	end
end);
gearConfig.gear.Activated:connect(function()
	local human = gearConfig.gear.Parent:FindFirstChild'Humanoid'
	
	if human and (gearConfig.check and human.Health > 0) then
		gearConfig.check = false;
		gearConfig.readyAnims[1]:Play();
	end
end)