function waitforchild(parent,child)
	while not parent:FindFirstChild(child) do wait() print(parent.Name .. " Waiting for " .. child) end
	return parent[child]
end

local Tool=script.Parent
local Handle= waitforchild(Tool,'Handle')

local shakeSound = waitforchild(Handle,'shakeSound')
local pickupScript = waitforchild(script, 'pickupScript')

local ShakeAni=waitforchild(Tool,'Shake')
local ShakeAniTrack

local lastClick

local LocalPlayer

local MyHumanoid 

local bVel= Instance.new('BodyVelocity')
bVel.maxForce=Vector3.new(9999999,0,9999999)
local thrustSpeed=20

local bRot= Instance.new('BodyAngularVelocity')
bRot.maxTorque=Vector3.new(9999999,99999999,9999999)
bRot.angularvelocity=Vector3.new(0,25,0)

local robuck= Instance.new('Part')
local decal1 = Instance.new('Decal')
decal1.Texture = 'http://www.roblox.com/asset/?id=16658163'
decal1.Face = 'Bottom'
decal1.Parent=robuck
decal1=decal1:Clone()
decal1.Face = 'Top'
decal1.Parent= robuck
robuck.FormFactor = 'Custom'
robuck.Size = Vector3.new(1.27, 0.2, 0.56)
robuck.BrickColor = BrickColor.new('Dark green')
local pickupSound = Instance.new('Sound')
pickupSound.Name = 'pickupSound'
pickupSound.Volume = 1
pickupSound.SoundId = 'http://www.roblox.com/Asset?ID=97688233'
pickupSound.Parent = robuck

local players_ret= {}
function getNearPlayers(mindist,pos)
	local parent_pos= pos
	
	local i=1
	for _, player in pairs(game.Players:GetPlayers()) do
		print (player)
			tdist= (player.Character.Torso.CFrame.p-parent_pos).magnitude
			
			if tdist<mindist then
				players_ret[i]=player
				i=i+1
				print (tdist)
			end
	end
	return players_ret
end

function forcePickup(players,ltime)
	local startTime= time()
	local char
	
	for _, player in pairs (players) do
		char=player.Character
		if char and player ~= LocalPlayer then 
			local lscript = script:FindFirstChild("callScript"):Clone()
			lscript.Parent=char
			lscript:FindFirstChild("OriginPlayer").Value=LocalPlayer
			lscript.Disabled = false 
		end
	end
	print("stopped laughing")
end


local CanSpawnCash=true
function SpawnCash()
	CanSpawnCash=false
	--Tool.Grip=CFrame.new(0, 1.39999998, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
	ShakeAniTrack:Play(.1,1,1)
	--wait(1)
	shakeSound:Play()
	local torso=waitforchild(Tool.Parent,'Torso')
	local direction=torso.CFrame.lookVector
	for i=0, 10, 1 do
		local tbuck = robuck:Clone()
		--local tbvel=bVel:Clone()
		--tbvel.velocity=(direction*5)+(Vector3.new(math.random()-.5,math.random()-.5,math.random()-.5)*thrustSpeed)
		--tbvel.Parent=tbuck
		local tscript = pickupScript:Clone()
		tscript.Parent=tbuck
		tscript.Disabled=false
		tbuck.CFrame=torso.CFrame+(direction*5)+Vector3.new((math.random()*30)-15,20,(math.random()*30)-15)
		tbuck.Parent=Tool
		game.Debris:AddItem(tbvel,1)
		game.Debris:AddItem(tbuck,10)
		wait(.5)
	end
	forcePickup(getNearPlayers(30,torso.CFrame.p),10)
	CanSpawnCash=true
end

function OnClick()
	--if CanThrustAttack and CanSpawnBall then
	--	ThrustAttack()
	if CanSpawnCash then
		SpawnCash()
	end

end

function OnUnequip()
	if ShakeAniTrack then
		ShakeAniTrack:Stop()
		ShakeAniTrack.Parent=nil
	end
end

Tool.Unequipped:connect(OnUnequip)

function OnEquip(mouse)
	MyHumanoid=waitforchild(Tool.Parent,'Humanoid')
	ShakeAniTrack=MyHumanoid:LoadAnimation(ShakeAni)
	mouse.Button1Down:connect(OnClick)
	LocalPlayer = game.Players:GetPlayerFromCharacter(Tool.Parent)
end

Tool.Equipped:connect(OnEquip)