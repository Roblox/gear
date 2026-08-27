--Stickmasterluke


sp=script.Parent

r=game:service("RunService")


local basedamage=4
local slashdamage=10
local damage=basedamage

sword=sp.Handle

local SlashSound=Instance.new("Sound")
SlashSound.SoundId="rbxasset://sounds\\swordslash.wav"
SlashSound.Parent=sword
SlashSound.Volume=.7

local UnsheathSound=Instance.new("Sound")
UnsheathSound.SoundId="rbxasset://sounds\\unsheath.wav"
UnsheathSound.Parent=sword
UnsheathSound.Volume=1


function blow(hit)
	if (hit.Parent==nil) then return end -- happens when bullet hits sword
	local humanoid=hit.Parent:findFirstChild("Humanoid")
	local vCharacter=sp.Parent
	local vPlayer=game.Players:playerFromCharacter(vCharacter)
	local hum=vCharacter:findFirstChild("Humanoid") -- non-nil if sp held by a character
	if humanoid~=nil and humanoid~=hum and hum~=nil then
		-- final check, make sure sword is in-hand
		local right_arm=vCharacter:FindFirstChild("Right Arm")
		if (right_arm~=nil) then
			local joint=right_arm:FindFirstChild("RightGrip")
			if (joint~=nil and (joint.Part0==sword or joint.Part1==sword)) then
				tagHumanoid(humanoid, vPlayer)
				humanoid:TakeDamage(damage)
				wait(1)
				untagHumanoid(humanoid)
			end
		end
	end
end


function tagHumanoid(humanoid, player)
	local creator_tag=Instance.new("ObjectValue")
	creator_tag.Value=player
	creator_tag.Name="creator"
	creator_tag.Parent=humanoid
end

function untagHumanoid(humanoid)
	if humanoid~=nil then
		local tag=humanoid:findFirstChild("creator")
		if tag~=nil then
			tag.Parent=nil
		end
	end
end

function swordUp()
	sp.GripForward=Vector3.new(-1,0,0)
	sp.GripRight=Vector3.new(0,-1,0)
	sp.GripUp=Vector3.new(0,0,1)
end

function swordOut()
	sp.GripForward=Vector3.new(0,0,-1)
	sp.GripRight=Vector3.new(0,-1,0)
	sp.GripUp=Vector3.new(-1,0,0)
end


sp.Enabled=true
function onActivated()
	if not sp.Enabled then
		return
	end
	sp.Enabled=false
	local character=sp.Parent;
	local humanoid=character.Humanoid
	if humanoid==nil then
		print("Humanoid not found")
		return 
	end
	damage=slashdamage
	SlashSound:play()
	sp.Runslash.Value=not sp.Runslash.Value
	wait(1.5)
	damage=basedamage
	sp.Enabled=true
end

function onEquipped()
	UnsheathSound:play()
end

sp.Activated:connect(onActivated)
sp.Equipped:connect(onEquipped)

connection=sword.Touched:connect(blow)


