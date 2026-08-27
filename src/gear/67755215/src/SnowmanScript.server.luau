-------------------------------------
-- Makes an RBX::Lua Instance using
-- a table of key-value pairs to
-- initialize it. Values with numeric 
-- keys will be parented to the object
-- and other values will be set
-- as members of the object.
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

---------------------------------------------------------------------------
---------------------------------------------------------------------------
--                                                                       --
--                        main code starts here                          --
--                                                                       --
---------------------------------------------------------------------------
---------------------------------------------------------------------------

local Snowman = script.Parent
local Humanoid = Snowman.Humanoid
local Owner = Snowman.SnowmanOwner.Value
local Target = Owner:FindFirstChild('SnowmanGun_Target') or 
               Instance.new('ObjectValue') --just in case the map I'm in is doing something terrible,
                                           --I want to maintain function and not leave these as garbage
                                           --in the workspace.

local Mid = Snowman.Mid
local Torso = Snowman.Torso
local Hip = Snowman.Torso.Hip
local RightGun = Snowman.Mid.RightGun
local LeftGun = Snowman.Mid.LeftGun

game.Players.ChildRemoved:connect(function(p)
	if p == Owner then
		Humanoid.Health = 0
	end
end)

Humanoid.Died:connect(function()
	--on died, unregister self from owners list of things
	if Owner:FindFirstChild('SnowmanGun_SnowmanList') then
		for _, ch in pairs(Owner.SnowmanGun_SnowmanList:GetChildren()) do
			if ch.Value == Snowman then
				ch.Parent = nil
				break
			end
		end
	end
	--fade my parts to transprent
	for i = 0, 1, 0.1 do
		for _, obj in pairs(Snowman:GetChildren()) do
			if obj:IsA('BasePart') then
				obj.Transparency = i
			end
		end
		wait(0.1)
	end
	--and finally remove self
	Snowman:Remove()
end)

function BumpModel()
	Torso.CFrame = Torso.CFrame * CFrame.new(0, 1, 0)
	Torso.CFrame = Torso.CFrame * CFrame.new(0, -1, 0)
end

local LastShotTime = 0
local ReloadTime = 2
local MaxRange = 100

while true do
	wait()
	local t = Target.Value
	if t and t:IsA('Humanoid') and t ~= Humanoid then
		local torso = (t.Parent or game):FindFirstChild('Torso')
		if torso and t.Health > 0 then
			--aim and fire!
			local aimPos = torso.Position
			local desiredCFrame = CFrame.new(Mid.Position, Vector3.new(aimPos.x, Mid.Position.y, aimPos.z))
			Hip.C1 = desiredCFrame:inverse()*Torso.CFrame*Hip.C0

			--todo: aim the guns as well
			BumpModel() --show the changes

			--find distance. Note: this code is here as the turret should still aim even if
			--it is not going to fire!
			local distToTarget = (Mid.Position-aimPos).magnitude

			if (tick()-LastShotTime) > ReloadTime and distToTarget < MaxRange then
				--fire a shot
				local Shot = Create'Part'{
					Name = 'SnowmanBullet',
					Shape = 'Ball',
					FormFactor = 'Custom',
					Size = Vector3.new(0.8, 0.8, 0.8),
					BrickColor = BrickColor.new(1002),
					CanCollide = false,
					CFrame = Mid.CFrame,
					Create'ObjectValue'{
						Name = 'CreatorSnowman',
						Value = Snowman,
					},
					Create'SpecialMesh'{
						Name = 'Mesh',
						MeshId = 'http://www.roblox.com/asset/?id=66733658',	
					},
					Create'BodyVelocity'{
						Name = 'Propell',
						velocity = CFrame.new(Mid.Position, aimPos).lookVector*60,
						maxForce = Vector3.new(10000, 10000, 10000),
					},
				}

				--put a damage script in it
				local dmg = Snowman.BulletDamage:Clone()
				dmg.Parent = Shot
				dmg.Disabled = false

				--throw it into the workspace
				Shot.Parent = game.Workspace

				--play the fire sound
				Torso.FireSnowball:Play()

				--set the reload
				LastShotTime = tick()
			end
		end
	end
end