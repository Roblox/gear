--[[ alexnewtron 2014 ]]--
script.Parent:WaitForChild("Handle");
local gearConfig = {
	gear = script.Parent,
	handle = script.Parent["Handle"],
	newAnimate = script:WaitForChild("NewAnimate"),
	slam = script.Parent.Handle:WaitForChild("Slam"),
	character = nil,
	equipped = false,
	check = true,
	leftCymbal = nil,
	newAnimation = nil,
	anims = {
		script.Parent:WaitForChild("Slam")
	},
	readyAnims = {}
};

function gearConfig.createFakeCymbal()
	gearConfig.leftCymbal = gearConfig.handle:Clone();
	gearConfig.leftCymbal.Name = "FakeHandle";
	gearConfig.leftCymbal.CanCollide = false;
	
	local LeftSwordWeld = Instance.new("ManualWeld");
	LeftSwordWeld.Part1 = gearConfig.leftCymbal;
	LeftSwordWeld.C0 = CFrame.new(0.25,-1,0)*CFrame.Angles(0,-1.5,1.5);
	LeftSwordWeld.C1 = CFrame.new(0,0,-0.1)*CFrame.Angles(0,1.5,0);
	
	local LeftArm = gearConfig.character:FindFirstChild("Left Arm");
	LeftSwordWeld.Part0 = LeftArm;
	gearConfig.leftCymbal.Parent = gearConfig.gear;
	LeftSwordWeld.Parent = gearConfig.leftCymbal;
end

function gearConfig.loadNewAnimation()
	local oA = gearConfig.character:FindFirstChild("Animate");
	if oA then oA.Disabled = true; end	
	gearConfig.newAnimation = gearConfig.newAnimate:Clone();
	gearConfig.newAnimation.Disabled = false;
	gearConfig.newAnimation.Parent = gearConfig.character;
end

gearConfig.gear.Unequipped:connect(function()
	gearConfig.equipped = false;
	if (gearConfig.leftCymbal ~= nil) then
		gearConfig.leftCymbal:Destroy();
		gearConfig.leftCymbal = nil;
	end
	if (gearConfig.newAnimation ~= nil) then
		gearConfig.newAnimation:Destroy();
		gearConfig.character:FindFirstChild("Animate").Disabled = false;
	end
	gearConfig.readyAnims[1]:Stop();
	gearConfig.slam:Stop();
end);

gearConfig.gear.Equipped:connect(function(m)
	gearConfig.equipped = true;
	if (m ~= nil) then
		local human=script.Parent.Parent:findFirstChild("Humanoid");
		local torso=script.Parent.Parent:findFirstChild("Torso");
		gearConfig.readyAnims = {};
		for i=1, #gearConfig.anims do
			table.insert(gearConfig.readyAnims, human:LoadAnimation(gearConfig.anims[i]));		
		end
		gearConfig.readyAnims[1].KeyframeReached:connect(function(k)
			if (k == "slam") then
				gearConfig.slam:Play();
			end
		end);
		gearConfig.character = game.Players.LocalPlayer.Character
		local FakeHandle = gearConfig.gear:FindFirstChild("FakeHandle")
		if FakeHandle then
			FakeHandle:Destroy()
		end
		wait();	
		gearConfig.createFakeCymbal();
		gearConfig.loadNewAnimation();		
		m.Button1Down:connect(function()
			if (gearConfig.check and human.Health > 0) then
				gearConfig.check = false; 
				gearConfig.readyAnims[1]:Play(); -- Swing!
				gearConfig.readyAnims[1]:AdjustSpeed(1);
				wait(1);
				gearConfig.check = true;
			end	
		end);
		
	end
end);