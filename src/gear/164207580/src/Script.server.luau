--[[alexnewtron 2014]]--
--[[
	Fixed by ArceusInator
	- Works with FE
	- Wheels no longer spaz out
	- Spawns facing away from the character just like every other vehicle
	- No longer bounces around when spawning
--]]
local GLib = require(206209239)
local config = {
	gear = script.Parent,
	check = true,
	PlayersService = Game:GetService('Players'),
	DebrisService = Game:GetService('Debris'),
	MyCharacter = nil,
	MyTorso = nil,
	DeployedCar = nil,
	Tool = script.Parent,
	Handle = script.Parent:WaitForChild('Handle'),
	COOLDOWN_TIME = 15,
	Car = Game:GetService('InsertService'):LoadAsset(163379061):GetChildren()[1]
};

function config.CreateOwnerTag()
	local ownerTag = Instance.new('ObjectValue')
	ownerTag.Value = config.PlayersService:GetPlayerFromCharacter(config.MyCharacter)
	ownerTag.Name = "Owner"
	return ownerTag
end

function config.SpawnCar()
	if config.MyTorso then
		local ownerTag = config.CreateOwnerTag()
		if config.DeployedCar ~= nil then
			config.DeployedCar:Destroy();
		end
		local carClone = config.Car:Clone();
		ownerTag.Parent = carClone;
		carClone.Parent = workspace;
--		carClone:TranslateBy((config.MyTorso.CFrame.p - config.Car:GetModelCFrame().p) + Vector3.new(0,5,0) + config.MyTorso.CFrame.lookVector * 15)
		carClone:SetPrimaryPartCFrame(config.MyTorso.CFrame * CFrame.new(0, -0.5, -15) * CFrame.Angles(0, math.pi, 0))
		carClone:MakeJoints()
		
		-- Fix the wheels flying around.  Thanks um3k!
		for index, joint in next, game.JointsService:GetChildren() do
			if joint:IsA'Rotate' and joint.Part0 and joint.Part0:IsDescendantOf(carClone) and joint.Part1 then
				joint.C0, joint.C1 = joint.C0-joint.C0.p, joint.C1-joint.C1.p + joint.Part1.CFrame:toObjectSpace(joint.Part0.CFrame).p
			end
		end
		
		-- Stop flying around
		for i, obj in next, GLib.GetDescendants(carClone) do
			if obj:IsA'BasePart' then
				obj.Velocity = Vector3.new()
				obj.RotVelocity = Vector3.new()
			end
		end
		
		-- Please stop
		carClone.PrimaryPart.Anchored = true
		wait(0.5)
		carClone.PrimaryPart.Anchored = false
		
		config.DeployedCar = carClone
		game:GetService'Debris':AddItem(config.DeployedCar, 60 * 15)
	end
end


config.gear.Click.OnServerEvent:connect(function(client)
	if client.Character == config.gear.Parent and config.check then
		config.MyCharacter = config.gear.Parent
		config.MyTorso = config.MyCharacter.HumanoidRootPart
		
		config.check = false
		config.SpawnCar()
		wait(config.COOLDOWN_TIME)
		config.check = true
	end
end)

config.gear.Unequipped:connect(function()
	if config.DeployedCar ~= nil then
		config.DeployedCar:Destroy()
	end
end);