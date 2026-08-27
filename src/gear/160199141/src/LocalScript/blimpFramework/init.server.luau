--[[ alexnewtron 2014 ]]--
local config = {
	b = script.Parent,
	m = script.Parent:WaitForChild("Mesh"),
	bP = script.Parent:WaitForChild("BodyPosition"),
	bG = script.Parent:WaitForChild("BodyGyro"),
	script.Parent:WaitForChild("BodyGyro"),
	tween = require(script:WaitForChild("b")),
	easing = require(script:WaitForChild("e")),
	owner = script.Parent:WaitForChild("creator")
};

function config.getCreatorHealth()
	if config.owner and config.owner.Value and config.owner.Value.Parent==game.Players and config.owner.Value.Character and config.owner.Value.Character:findFirstChild("Humanoid") then
		return config.owner.Value.Character:FindFirstChild("Humanoid").Health;
	end
end

function config.getCreator()
	if config.owner and config.owner.Value and config.owner.Value.Parent==game.Players and config.owner.Value.Character then
		return config.owner.Value.Character:FindFirstChild("Torso");
	end
end

Spawn(function()
	local ts = config.tween("forward");
	ts.add(2, {x = 1, y = 1, z = 2, m = 0.25}, config.easing.inOutQuad); ts.add(2, {x = 4, y = 4, z = 9, m = 1}, config.easing.inOutQuad);
	for x=1, 200 do
		local p = ts.getCurrentProperties();
		config.b.Size = Vector3.new(p.x, p.y, p.z);
		config.m.Scale = Vector3.new(p.m, p.m, p.m);
		ts.update(0.025); wait(0.025);
		if (p.x >= 4) then config.b.CanCollide = true; break; end
	end
end);

local bBGui = Instance.new("BillboardGui");
bBGui.Size = UDim2.new(10,0,1.5,0);
bBGui.StudsOffset = Vector3.new(0,5,0);

local bTxt = Instance.new("TextLabel", bBGui);
bTxt.BackgroundTransparency = 1;
bTxt.Size = UDim2.new(1,0,1,0);
bTxt.TextColor3 = Color3.new(255/255,255/255,255/255);
bTxt.TextStrokeColor3 = Color3.new(180/255,0/255,3/255);
bTxt.TextScaled = true;
bTxt.TextStrokeTransparency = 0;
bTxt.Font = Enum.Font.SourceSansBold;
bTxt.Text = config.owner.Value.Name.."'s Blimp";

bBGui.Parent = script.Parent;
bBGui.Adornee = script.Parent;

config.b.Anchored = false;
while (script.Parent.Parent ~= nil) do
	wait(0.1);
	local torso = config.getCreator();
	if torso and config.getCreatorHealth()>0 then
		local pos = (CFrame.new(torso.Position)*CFrame.Angles(0,math.pi*2*((tick()/10)%1),0)*CFrame.new(10,10,0));
		config.bP.position = pos.p;
		config.bG.cframe = pos;
	else
		break;
	end
end

script.Parent:Destroy();
script:Destroy();