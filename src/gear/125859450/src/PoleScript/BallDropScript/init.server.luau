game.Debris:AddItem(script, 12)

local CreatorTag = script:WaitForChild('creator')

local Create = LoadLibrary('RbxUtility').Create

local Player = CreatorTag.Value

local SOUND_HitGround = script:WaitForChild('SOUND_HitGround')

local Location = script:WaitForChild('Target')

local spire = Create'Part'{
	Anchored = true;
	FormFactor = 'Custom';
	Size = Vector3.new(1, 16, 1);
	Create'SpecialMesh'{
		MeshId = 'http://www.roblox.com/asset/?id=125754493';
		TextureId = 'http://www.roblox.com/asset/?id=125753829';
	};
}

game.Debris:AddItem(spire, 12)

local ball = Create'Part'{
	Anchored = true;
	FormFactor = 'Custom';
	Size = Vector3.new(4,4,4);
	Create'SpecialMesh'{
		MeshId = 'http://www.roblox.com/asset/?id=125754306';
		TextureId = 'http://www.roblox.com/asset/?id=125753829';
	};	
	Create'PointLight'{
		Range = 10;
		Color = Color3.new(1,0,1);
		Brightness = 2;
	};	
}

SOUND_HitGround.Parent = ball

local function FindCharacterAncestor(subject)
	if subject and subject ~= Workspace then
		local humanoid = subject:FindFirstChild('Humanoid')
		if humanoid then
			return subject, humanoid
		else
			return FindCharacterAncestor(subject.Parent)
		end
	end
	return nil
end

game.Debris:AddItem(ball, 12)

spire.Parent = Workspace
ball.Parent = Workspace

SOUND_HitGround:Play()

spire.CFrame = CFrame.new(Location.Value + Vector3.new(0, 8, 0))

local function DropBall(frac)
	ball.CFrame = spire.CFrame * CFrame.new(0, 4.5-10.5*frac, 0)
end

DropBall(0)

local startT = tick()
while tick()-startT < 4 do
	wait()
	local frac = (tick()-startT)/4
	frac = frac^4
	DropBall(frac)
end

local function createExplosionBit()
	local part = Create'Part'{
		FormFactor = 'Custom';
		Size = Vector3.new(math.random(5,15)/10, math.random(5,15)/10, math.random(5,15)/10);
		BrickColor = BrickColor.new(1015);
		Create'PointLight'{
			Brightness = 2;
			Range = 7;
			Color = Color3.new(1,0,1);
		};
	}
	return part
end

local function damagePlayer(bit, part)
	local ch, hum = FindCharacterAncestor(part)
	if ch and Player and ch ~= Player.Character then
		local tag = CreatorTag:Clone()
		tag.Parent = hum
		game.Debris:AddItem(tag, 0.2)
		hum:TakeDamage(60)
		bit:Destroy()
	end
end

ball:Destroy()

for i = 1, 20 do
	local part = createExplosionBit()
	part.CFrame = ball.CFrame + Vector3.new(math.random(-10,10)/10, math.random(-10,10)/10, math.random(-10,10)/10)
	part.Velocity = Vector3.new(math.random(-80,80), math.random(40,80), math.random(-80,80))
	part.RotVelocity = Vector3.new(math.random(-10,10), math.random(-10,10), math.random(-10,10))
	game.Debris:AddItem(part, math.random(10,40)/10)
	part.Touched:connect(function(p) damagePlayer(part, p) end)
	part.Parent = Workspace
end

wait(2)

spire:Destroy()




















