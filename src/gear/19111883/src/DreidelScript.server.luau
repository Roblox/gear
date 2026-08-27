-------- OMG HAX

debris = game:GetService("Debris")
r = game:service("RunService")


Tool = script.Parent

--local Pellet = Tool.Handle:Clone() --Tool.Handle:Clone()
--Tool.CoinScript:Clone().Parent = Pellet
Tool.CoinScript.Disabled = false


function onEquipped()	

	--body of the dreidel
	dBody= Instance.new("Part")
	dBody.Parent = game.Workspace
	dBody.Name = "DreidelBody"
	dBody.BrickColor = BrickColor.Red()
	dBody.Size = Vector3.new(2.56,2.56,2.56) 
	dBody.Shape = 1
	dBody.BackSurface = "Smooth"  --used this of debugging to test which side was face up
	dBody.BottomSurface = "Smooth"
	dBody.FrontSurface = "Studs"
	dBody.TopSurface = "Smooth"
	dBody.LeftSurface = "Smooth"
	dBody.RightSurface = "Smooth"
	Tool.Handle.Mesh:Clone().Parent = dBody --sets the dreidel mesh to the cube part of the dreidel
	
	--Dreidle Sound
	dreidlesound = Instance.new("Sound")
	dreidlesound.SoundId = "http://www.roblox.com/asset/?id=19073736" -- replace me
	dreidlesound.Parent = dBody

	--Coin Sound
	coinsound = Instance.new("Sound")
	coinsound.SoundId = "http://www.roblox.com/asset/?id=19073176"  --replace me
	coinsound.Parent = dBody

	--base of the dreidel
	dBase = Instance.new("Part")
	dBase.Parent = game.Workspace
	dBase.Name = "DreidelBase"
	dBase.BrickColor = BrickColor.Black()
	dBase.Size = Vector3.new(2,2,2)
	dBase.Shape = 0
	dBase.Transparency = 1

	--welding the body fo the dredeil to the base
	w2 = Instance.new("Weld")
	w2.Name = "DreidelWeld" 
	w2.Part0 = dBody
	w2.Part1 = dBase
	w2.C0 = CFrame.new(0,0,0)
	w2.C1 = CFrame.new(0,1.75,0)
	w2.Parent = script.Parent.Handle 

end

Tool.Enabled = true
function onActivated(mouse_pos)

	Tool.Handle.Transparency = 1
	if not Tool.Enabled then
		return
	end

	Tool.Enabled = false

	local character = Tool.Parent;
	local humanoid = character.Humanoid
	if humanoid == nil then
		print("Humanoid not found")
		return 
	end

	--locates the position the mouse is targeting
	local targetPos = humanoid.TargetPoint
	
	local vPlayer = game.Players:playerFromCharacter(character)
	head = character:findFirstChild("Head")
	if head == nil then
		print("Humanoid not found")
		return
	end

	--calculates the distance between the person and the possible dreidle location
	dist = (head.Position-targetPos).magnitude

	--prevents the dreidle for being created too far away from the player
	if dist > 30 then 
		Tool.Enabled = true
		Tool.Handle.Transparency = 0
		return 
	end

	--PLAY DREIDLE SOUND
	dreidlesound:Play()

	--moves the dreidle to the requested location
	dBody.CFrame = CFrame.fromEulerAnglesXYZ(0,0,0) + targetPos + Vector3.new(0,2.5,0)

	--adds a random rotation velocity with a slight downward angle to cause the dreidle to spin
	dBody.RotVelocity = Vector3.new(math.random(0,7),math.random(20,80),math.random(7,9)) --set rotational velocity

	wait(2.8) -- delay to allow the dreidel to settle
	
	--identifies what face is up and what face is on bottom

	frontVector = dBody.CFrame:vectorToWorldSpace(Vector3.FromNormalId(Enum.NormalId.Front))

	leftVector = dBody.CFrame:vectorToWorldSpace(Vector3.FromNormalId(Enum.NormalId.Left))

	--dot product of the vectors with (0,1,0)
	test1 = frontVector.y
	test2 = leftVector.y

	--takes the largest y value and tests positive or negative to identify the 4 faces it could land on
	if math.abs(test1)>math.abs(test2) then
		if test1>0 then
			--print("Nun")
			count = 0
		else
			--print("Shin")
			count = 5
		end
	else
		if test2>0 then
			--print("Hey")
			count = 15
		else
			--print("Gimmel")
			count = 25
		end
	end

	-- generates the necissary number of coins and throws them a random distance from the dreidle

	--PLAY COIN SOUND
	coinsound:Play()

	for i=1,count do
		local p = Instance.new("Part")
		p.BrickColor = BrickColor.new(23)
		p.formFactor = 2
		p.Size = Vector3.new(1,.2,1)
		p.TopSurface = 0
		p.BottomSurface = 0
		
		local a = math.random() * 6.28  -- magic number??
		local d = Vector3.new(math.cos(a), 0, math.sin(a)).unit
		p.Velocity = d * 25
		p.RotVelocity = d
		p.Position = dBody.Position + Vector3.new(0,2,0) + Vector3.new(0, math.random() * 3, 0) + (d * 2)
		p.Parent = game.Workspace
		Tool.Mesh:Clone().Parent = p
		Tool.CoinScript:Clone().Parent = p

		debris:AddItem(p, 60)
	end

	Tool.Enabled = true
	Tool.Handle.Transparency = 0
end

--removes the dreidle on unequip
function onUnequipped()
	if (dBody ~= nil) then
		dBody:Remove()
	end
	if (dBase ~= nil) then
		dBase:Remove()
	end
end

--connecting the equip, unequip, and mouseClick functions
script.Parent.Equipped:connect(onEquipped)
script.Parent.Unequipped:connect(onUnequipped)
script.Parent.Activated:connect(onActivated)




