--[[ alexnewtron 2014 ]]--

local c = script.Parent;

c.Anchored = false;

local bP = Instance.new("BodyPosition", c);
bP.maxForce = Vector3.new(math.huge, math.huge, math.huge);
bP.position = c.Position;


while ((bP.position - c.Position).magnitude > 2) do
	bP.position = c.Position;
	wait();
end

c:Destroy();