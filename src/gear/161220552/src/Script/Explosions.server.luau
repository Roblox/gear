--[[ alexnewtron 2014 ]]--
local config = {
	force = nil,
	shell = script.Parent,
	colors = {Color3.new(1,0,0), Color3.new(0,1,0), Color3.new(0,0,1), Color3.new(1,.5,0), Color3.new(0,.5,1)},
	starMap = {Vector2.new(0,0), Vector2.new(468,0), Vector2.new(0,468)},
	debris = game:GetService("Debris"),
	explodeSound = script.Parent:WaitForChild("Explode"),
	flySound = script.Parent:WaitForChild("Fly"),
	spreadAmount = 8 + math.random()*4,
	rocketCFrame = CFrame.Angles(0, math.random()*math.pi*2, 0),
	r = {}
};

if (config.shell:findFirstChild("Sparks")) then
	config.shell["Sparks"]:Destroy();
end
config.force = Instance.new("BodyForce", config.shell);

config.flySound:Play();
for i=1,10 do
	config.force.force = config.shell.CFrame:vectorToWorldSpace(Vector3.new(0, 1, 0)) * config.shell:GetMass() * 98 * 3;
	wait(.1)
end
config.explodeSound:Play();
config.force:Remove()

for j=1,120 do
	local p = Instance.new("Part");
	p.Size = Vector3.new(1,1,1);
	p.Transparency = 1;
	p.Position = config.shell.Position + ( Vector3.new(math.random() - .5, math.random() - .5, math.random() - .5) * 10);
	p.Velocity =  config.shell.Velocity;
	local c = config.colors[math.random(1,#config.colors)];
	local s = Instance.new("Sparkles", p);
	s.Color = c;
	local l = Instance.new("PointLight", p);
	l.Color = c;
	l.Brightness = 10;
	l.Range = 8;
	l.Enabled = true;
	local star = Instance.new("BillboardGui");
	star.Size = UDim2.new(5,0,5,0);
	star.Name = "Star";
	local sImg = Instance.new("ImageLabel", star);
	sImg.Size = UDim2.new(1,0,1,0);
	sImg.BackgroundTransparency = 1;
	sImg.Image = "rbxassetid://161037657";
	sImg.ImageRectSize = Vector2.new(468,468);
	sImg.ImageRectOffset = config.starMap[math.random(1, #config.starMap)];
	star.Parent = p;
	star.Adornee = p;
	local bv = Instance.new("BodyVelocity", p);
	bv.P = 1000;
	bv.maxForce = Vector3.new(1, 1, 1)*1000;
	bv.velocity = Vector3.new(0, 0, 0);
	config.debris:AddItem(p, 12);
	p.Parent = workspace;
	local r = math.random(1,2);
	if r == 1 then
		bv.velocity = config.rocketCFrame:vectorToWorldSpace(Vector3.new(math.random(), math.random(), math.random())) * config.spreadAmount
	elseif r == 2 then
		bv.velocity = config.rocketCFrame:vectorToWorldSpace(Vector3.new(-math.random(), -math.random(), -math.random())) * config.spreadAmount
	end	
	table.insert(config.r, p);
end
wait(0.5);
for i=1, #config.r do
	config.r[i]["BodyVelocity"].velocity = config.r[i]["BodyVelocity"].velocity / 2;
end
config.shell.Transparency = 1
wait(2)

config.explodeSound:Stop();
config.shell:Remove()
