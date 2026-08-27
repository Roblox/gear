local RbxUtility = LoadLibrary('RbxUtility')
local Create = RbxUtility.Create

local creator = script:WaitForChild('creator')
local Ghost = script.Parent
repeat wait() until creator.Value
local Player = creator.Value
local Character = Player.Character
local Humanoid = Character.Humanoid
local Alive = true

local Health = Create'NumberValue'{
	Parent = Ghost;
	Name = 'Health';
	Value = 150;
}

----------------------------------------

--change alive and remove us soon when health reaches 0
Health.Changed:connect(function()
	if Health.Value <= 0 then
		Alive = false
		--if the humanoid is dead, explode will handle us
		if Humanoid.Health <= 0 then
			--nothing to do
		else
			--otherwise, play a dissapearing anim here
			for i = 0, 1, 0.05 do
				Ghost.Torso.Transparency = i
				wait()
			end
			Ghost:Destroy()
		end
	end
end)


--kill us on character died
Character.Humanoid.Died:connect(function()
	--kill us
	local damageToDo = Health.Value
	Health.Value = 0

	--explode
	local ringAt = Character.Torso.Position
	local ring = Create'Part'{
		Parent = Ghost;
		Transparency = 1;
		FormFactor = 'Custom';
		Size = Vector3.new(1,1,1);
		Anchored = true;
		CanCollide = false;
		--
		Create'Decal'{
			Texture = 'http://www.roblox.com/asset/?id=11187115';
			Face = 'Top';
			Shiny = 0;
			Name = 'DecalA';
		};
		--
		Create'Decal'{
			Texture = 'http://www.roblox.com/asset/?id=11187115';
			Face = 'Bottom';
			Shiny = 0;
			Name = 'DecalB';
		};
	}

	--expand
	for i = 0, 1, 0.05 do
		ring.Size = Vector3.new(i*i*22*2, 0, i*i*22*2)
		ring.CFrame = CFrame.new(ringAt)
		ring.DecalA.Transparency = i
		ring.DecalB.Transparency = i
		Ghost.Torso.Mesh.Scale = Vector3.new(1+i*2, 1+i*2, 1+i*2)
		Ghost.Torso.Transparency = 0.2 + 0.8*i
		wait()
	end

	--do damage
	local allParts = game.Workspace:FindPartsInRegion3(Region3.new(ringAt - Vector3.new(15, 5, 15),
	                                                               ringAt + Vector3.new(15, 5, 15)))
	local didDamageTo = {[Humanoid] = true}
	for _, part in pairs(allParts) do
		if (part.Position - ringAt).magnitude < 15 then
			if part.Parent and part.Parent:FindFirstChild('Humanoid') then
				local hum = part.Parent:FindFirstChild('Humanoid')
				if not didDamageTo[hum] then
					didDamageTo[hum] = true
					hum:TakeDamage(hum.Health)
				end
			end
		end
	end

	--get rid of ring and ghost
	ring:Destroy()
	Ghost:Destroy()
end)


--tracking of "healing bits" to show when the ghost is healing you
local HealingBitList = {}
local ToBeHealed = 0
function AddHealingBit(health)
	ToBeHealed = ToBeHealed + health
	local bit = {}
	bit.Part = Create'Part'{
		Name = 'HealingBit';
		Parent = Ghost;
		Shape = 'Ball';
		Anchored = true;
		CanCollide = false;
		FormFactor = 'Custom';
		Size = Vector3.new(1,1,1);
		BrickColor = BrickColor.new(28);
		Transparency = 0.2;
	}
	bit.Direction = Vector3.new(math.random(-10,10), math.random(-10,10), math.random(-10,10)).unit
	bit.From = Ghost.Torso.Position
	bit.Timestamp = tick()
	bit.Health = health
	HealingBitList[bit] = true
end
Spawn(function()
	local LastTime = tick()
	while true do
		wait()
		local Now = tick()
		local dt = LastTime-Now
		LastTime = Now
		--
		local torsoPos = Character.HumanoidRootPart.Position
		for bit, _ in pairs(HealingBitList) do
			local elapsed = (Now - bit.Timestamp)/1.0
			if elapsed > 1 then
				--done, heal player and remove bit
				HealingBitList[bit] = nil
				bit.Part:Destroy()
				Humanoid.Health = Humanoid.Health + bit.Health
				ToBeHealed = ToBeHealed - bit.Health
			else
				local toTorso = torsoPos - bit.From
				bit.Part.CFrame = CFrame.new(bit.From + toTorso*elapsed + bit.Direction*6*(1-elapsed))
			end
		end
	end
end)


--set up the healing loop
Spawn(function()
	local LastHealedAt = tick()
	while true do
		wait()
		if not Alive then break end
		--
		if Health.Value > 0 and Humanoid.Health + ToBeHealed < Humanoid.MaxHealth then
			if tick()-LastHealedAt > 0.5 then
				local toHeal = math.min(Humanoid.MaxHealth-Humanoid.Health, Health.Value, 5)
				Health.Value = Health.Value - toHeal
				AddHealingBit(toHeal)
				LastHealedAt = tick()
			end
		end
	end
end)


--create the Ghost
Create'Part'{
	Name = 'Torso';
	Parent = Ghost;
	Shape = 'Ball';
	Size = Vector3.new(2,2,2);
	Transparency = 0.2;
	CanCollide = false;
	CFrame = CFrame.new(Character.HumanoidRootPart.Position + Vector3.new(1,1,1),
		                Character.HumanoidRootPart.Position + Vector3.new(1,1,1) + Character.HumanoidRootPart.CFrame.lookVector);
	--
	Create'SpecialMesh'{
		MeshId = 'http://www.roblox.com/asset/?id=89391602';
		TextureId = 'http://www.roblox.com/asset/?id=89391636';
		VertexColor = Vector3.new(0.8, 1.0, 0.8);
		Scale = Vector3.new(0.8,0.8,0.8);
		Name = 'Mesh';
	};
	--
	Create'BodyPosition'{
		Name = 'Float';
		position = Character.HumanoidRootPart.Position + Vector3.new(1,1,1);
	};
	Create'BodyGyro'{
		Name = 'Rotate';
		cframe = Character.HumanoidRootPart.CFrame;
		maxTorque = Vector3.new(40000, 20000, 40000);
	};
}


--set up ghost following you
Spawn(function()
	while Alive do
		local torsoAt = Character.HumanoidRootPart.Position
		local toGhost = Ghost.Torso.Position - torsoAt
		toGhost = Vector3.new(toGhost.x, 0, toGhost.z).unit
		local ghostAt = torsoAt + toGhost*3 + Vector3.new(0, 2 + 1*math.sin(tick()), 0)
		--
		Ghost.Torso.Float.position = ghostAt
		Ghost.Torso.Rotate.cframe = Character.HumanoidRootPart.CFrame
		--
		wait()
	end
end)


--and finally set up a veiw of our health
local GhostLocal = script:WaitForChild('GhostLocal')
GhostLocal:WaitForChild('Target')
--
local sc = GhostLocal:Clone()
sc.Target.Value = Ghost
sc.Parent = Character
sc.Disabled = false