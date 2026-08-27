-- // Updated for R15 avatars by StarWars
function Create(ty)
	return function(data)
		local obj = Instance.new(ty)
		for k, v in pairs(data) do
			if type(k) == 'number' then
				v.Parent = obj
			else
				obj[k] = v
			end
		end
		return obj
	end
end


local Grenade = script.Parent
local creator = script:WaitForChild("creator")

local EFFECT_RADIUS = 10

function IsTeamMate(Player1, Player2)
	return (Player1 and Player2 and not Player1.Neutral and not Player2.Neutral and Player1.TeamColor == Player2.TeamColor)
end

local function FindHumanoid(part)
	return (part.Parent or game):FindFirstChildOfClass('Humanoid') or
	       ((part.Parent or game).Parent or game):FindFirstChildOfClass('Humanoid')
end

--wait for us to hit something that isn't a humanoid and is cancollide
do
	local hitSomethingEvent = Instance.new('BindableEvent')
	Grenade.Touched:connect(function(part)
		if part.CanCollide and not FindHumanoid(part) then
			hitSomethingEvent:Fire()
		end
	end)
	hitSomethingEvent.Event:Wait()
end


--remove the grenade
Grenade.CanCollide = false
Grenade.Anchored = true
Grenade.Transparency = 1


--generate our zombie effect
local EffectAt = Grenade.Position

local ZombieHands = {}
for i = 1, 10 do
	--find an location to put the hand at.
	local at = EffectAt + Vector3.new(math.random(-EFFECT_RADIUS,EFFECT_RADIUS),
	                                  0,
	                                  math.random(-EFFECT_RADIUS,EFFECT_RADIUS))
	local foundSpot;
	local ignoreList = {}
	local ray = Ray.new(at+Vector3.new(0, 20, 0), Vector3.new(0,-999,0))
	while true do
		local hit, at = game.Workspace:FindPartOnRayWithIgnoreList(ray, ignoreList)
		if hit then
			if not hit.CanCollide or FindHumanoid(hit) then
				ignoreList[#ignoreList+1] = hit
			else
				foundSpot = at
				break
			end
		else
			break
		end
	end

	if foundSpot then
		--found a spot to place a hand at
		local hand = {}
		hand.CFrame = CFrame.new(foundSpot)*CFrame.Angles(0, 2*math.random()*math.pi, 0)

		--make a bunch of bits of "earth" around the hand
		hand.EarthBits = {}
		for i = 1, 3 do
			local bit = {}
			bit.Part = Create('Part'){
				Name = 'EarthBit';
				Anchored = true;
				CanCollide = false;
				TopSurface = Enum.SurfaceType.Smooth;
				BottomSurface = Enum.SurfaceType.Smooth;
				Material = Enum.Material.Concrete;
				FormFactor = 'Custom';
				Size = Vector3.new(1 + math.random(),0.4,1+math.random());
				BrickColor = BrickColor.new(217);
			}
			bit.C0 = CFrame.Angles(0, math.pi*2/3*i + math.random()*0.1, 0)
			bit.C1 = CFrame.new(0, 0, 0.5)
			hand.EarthBits[i] = bit
		end

		--make the part
		hand.Part = Create('Part'){
			Name = 'ZombieHand';
			Anchored = true;
			CanCollide = false;
			FormFactor = 'Custom';
			Size = Vector3.new(2,1,1);
			--
			Create('SpecialMesh'){
				Name = 'Mesh';
				MeshId = 'http://www.roblox.com/asset/?id=89391425';
				TextureId = 'http://www.roblox.com/asset/?id=89391492';
				Scale = Vector3.new(3,3,3);
			};
		}

		--make some other data for the hand
		hand.Level = 0
		hand.Mode = 'Rise' --Rise / Search / Fall
		hand.Caught = nil
		hand.A = math.random()
		hand.Delay = math.random()
		ZombieHands[hand] = true
	end
end


--set up touched handling for hands
for hand, _ in pairs(ZombieHands) do
	hand.Part.Touched:Connect(function(part)
		local hum = FindHumanoid(part)
		if hum and not IsTeamMate(creator.Value,game:GetService("Players"):GetPlayerFromCharacter(hum.Parent)) and creator.Value ~= game:GetService("Players"):GetPlayerFromCharacter(hum.Parent) then
			local FF = hum.Parent:FindFirstChildOfClass("ForceField")
			if not FF then
				hand.Mode = 'Fall'
				hand.Caught = hum
				--tag
				local tag = creator:Clone()
				tag.Parent = hum
				game:GetService("Debris"):AddItem(tag, 3)
			end
		end
	end)
end


--9 seconds in we should start all of the hands falling
delay(9, function()
	for hand, _ in pairs(ZombieHands) do
		hand.Mode = 'Fall'
	end
end)


--animate it
local StartTime = tick()
local LastTime = StartTime
while true do
	local Now = tick()
	local dt = Now-LastTime
	LastTime = Now
	local Elapsed = Now-StartTime

	--end after 10 seconds
	if Elapsed > 10 then break end
	
	--
	for hand, _ in pairs(ZombieHands) do
		local Elapsed = Elapsed - hand.Delay
		if Elapsed > 0 then

			--place the hand
			hand.Part.Parent = Grenade
			hand.Part.CFrame = hand.CFrame * 
			                   CFrame.Angles(math.sin(Elapsed+hand.A)*0.5, 0, math.sin(Elapsed)*0.5) *
			                   CFrame.new(0, hand.Level-1.2, 0) *
			                   CFrame.Angles(math.pi/2, -math.pi/2, 0) *
			                   CFrame.new(0, 0, -0.4)

			--first, rise or fall the hand
			if hand.Mode == 'Rise' then
				hand.Level = math.min(2, hand.Level + dt*2)
				if hand.Level >= 2 then
					hand.Mode = 'Search'
				end
			elseif hand.Mode == 'Fall' then
				hand.Level = math.max(0, hand.Level - dt*2)
				if hand.Level <= 0 then
					ZombieHands[hand] = nil
					hand.Part:Destroy()

					--make sure we kill the caught
					if hand.Caught then
						hand.Caught.Parent:BreakJoints()
						--hand.Caught:TakeDamage(hand.Caught.Health)
					end
				end

				--if it captured something then drag it down
				if hand.Caught then
					local torso,FF = hand.Caught.Parent:FindFirstChild('HumanoidRootPart'),hand.Caught.Parent:FindFirstChildOfClass('ForceField')
				
					if not IsTeamMate(creator.Value,game:GetService("Players"):GetPlayerFromCharacter(hand.Caught.Parent)) and not FF and creator.Value ~= game:GetService("Players"):GetPlayerFromCharacter(hand.Caught.Parent) then
						if torso then
							torso.Anchored = true
							torso.CFrame = CFrame.new(0,-dt*4,0)*torso.CFrame
							hand.Caught:TakeDamage(2)
						else
							hand.Caught.Parent:BreakJoints()
							--hand.Caught:TakeDamage(hand.Caught.Health)
							hand.Caught = nil
						end
					end
					
				end
			else
				--nothing to do
			end

			--now if it's just started rising move the dirt bits
			if Elapsed < 0.8 then
				local T = Elapsed/0.8
				for _, bit in pairs(hand.EarthBits) do
					bit.Part.Parent = Grenade
					bit.Part.CFrame = hand.CFrame * bit.C0 * 
					                  CFrame.Angles(T*0.3, 0, 0) * CFrame.new(0, 0.2+0.2*T, T*0.5) *   
					                  bit.C1
				end
			end

			--
			if hand.Mode == 'Fall' then
				for _, bit in pairs(hand.EarthBits) do
					bit.Part.Transparency = 1-(hand.Level/2)
				end
			end
		end
	end
	--
	wait()
end

--kill any remaining caught players
for hand, _ in pairs(ZombieHands) do
	if hand.Caught then
		hand.Caught:TakeDamage(hand.Caught.Health)
	end
end


--destroy us. All of our stuff has been parented to the grenade so this will do cleanup
Grenade:Destroy()

