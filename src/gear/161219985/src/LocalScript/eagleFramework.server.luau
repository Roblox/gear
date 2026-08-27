--[[ alexnewtron 2014 ]]--
local config = {
	b = script.Parent,
	bP = script.Parent:WaitForChild("BodyPosition"),
	bG = script.Parent:WaitForChild("BodyGyro"),
	attack = script.Parent:WaitForChild("EagleAttack"),
	attackH = script.Parent:WaitForChild("EagleAttackHumanoid"),
	reachedTarget = false,
};
while not config.reachedTarget do
	local attacking = config.attack.Value;
	if (attacking ~= nil and attacking.Parent ~= nil) then
		local attackPosition = attacking.Position;
		config.bG.cframe = CFrame.new(script.Parent.Position, attackPosition);
		config.bP.position = attackPosition;
		if ((script.Parent.Position - attackPosition).magnitude < 10) then
			config.reachedTarget = true;
			attacking.Velocity = script.Parent.Velocity * 4;
		end
	else
		break;
	end
	wait();
end
local attacking = config.attack.Value;
if (attacking ~= nil and attacking.Parent ~= nil) then
	local w = Instance.new("Weld");
	w.Parent = script.Parent;
	w.Part0 = attacking;
	w.Part1 = script.Parent;
	w.C0 = script.Parent.CFrame:inverse(script.Parent);
	w.C1 = attacking.CFrame:inverse(attacking);	
	config.bP.position = script.Parent.Position + Vector3.new(250,200,0);
	config.bG.cframe = CFrame.new(script.Parent.Position, config.bP.position);
	wait(2);
	config.attackH.Value:TakeDamage(20);
	w:Destroy();
	config.attackH.Value.Sit = true;
end
wait(2);
script.Parent.Parent = nil;
script.Parent:Destroy();
script:Destroy();
