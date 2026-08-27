function waitforchild(parent,child)
	while not parent:FindFirstChild(child) do wait() print(parent.Name .. " Waiting for " .. child) end
	return parent[child]
end

local Tool=script.Parent
local Handle= waitforchild(Tool,'Handle')
local EvilSound = waitforchild(Handle,'evilSound')
local BoneScript = waitforchild(Tool, 'BoneDamageScript')
local SpinAni=waitforchild(script,'spin')
local SpinAniTrack
local ThrustAni=waitforchild(script,'Thrust')
local ThrustAniTrack
local PoundAni=waitforchild(script,'StaffPound')
local PoundAniTrack

local lastClick

local MyHumanoid 

local bVel= Instance.new('BodyVelocity')
bVel.maxForce=Vector3.new(9999999,0,9999999)
local thrustSpeed=20

local bRot= Instance.new('BodyAngularVelocity')
bRot.maxTorque=Vector3.new(9999999,99999999,9999999)
bRot.angularvelocity=Vector3.new(0,25,0)


function InitializeBall()
	local tball=Instance.new('Part')
	tball.Size = Vector3.new(18.36, 18.36, 18.36)
	tball.Elasticity = 0
	tball.Shape = 'Ball'
	local tmesh=Instance.new('SpecialMesh')
	tmesh.MeshId = "http://www.roblox.com/asset/?id=99795003"
	tmesh.TextureId = "http://www.roblox.com/asset/?id=99795207"
	tmesh.Scale = Vector3.new(50,50,50)
	local tfire = Instance.new('Fire')
	tfire.Color=Color3.new(34/255,106/255,12/256)
	tfire.SecondaryColor=Color3.new(121/255,255/255,84/255)
	tfire.Size=5
	tfire.Parent=tball
	local tsmoke=Instance.new('Smoke')
	tsmoke.Color=Color3.new(51/255,168/255,38/255)
	tsmoke.Opacity=.25
	tsmoke.Size=.1
	tsmoke.RiseVelocity=0
	tsmoke.Parent=tball

	tmesh.Parent=tball
	tball.CanCollide=true

	return tball
	
end


local CanThrustAttack=true
function ThrustAttack()
	CanThrustAttack=false
	ThrustAniTrack:Play(.1,1,3)
	--Tool.Grip=CFrame.new(0, 1.50000012, 1.22391882e-007, 1, 0, 0, 0, -1, -8.74227766e-008, 0, 8.74227766e-008, -1)
	--Tool.Grip=CFrame.new(0, 1.76066029, 0.26066035, 1, 0, 0, 0, -0.707106829, 0.707106709, 0, -0.707106709, -0.707106829)
	local torso=waitforchild(Tool.Parent,'Torso')
	local direction=torso.CFrame.lookVector
	wait(1)
	--Tool.Grip=CFrame.new(0, 1.39999998, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
	
	CanThrustAttack=true
end

local CanSpinAttack=true
function SpinAttack()
	CanSpinAttack=false
	local torso=waitforchild(Tool.Parent,'Torso')
	SpinAniTrack:Play(.1,1,2)
	--Tool.Grip=CFrame.new(0, 2, 1.22391882e-007, 1, 0, 0, 0, -1, -8.74227766e-008, 0, 8.74227766e-008, -1)
	bRot.Parent=torso
	wait(1)
	bRot.Parent=nil
	SpinAniTrack:Stop()
	--Tool.Grip=CFrame.new(0, 1.39999998, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
	CanSpinAttack=true
end

local CanSpawnBall=true
function SpawnBall()
	CanSpawnBall=false
	--Tool.Grip=CFrame.new(0, 1.39999998, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
	PoundAniTrack:Play(.1,1,2)
	wait(1)
	EvilSound:Play()
	local torso=waitforchild(Tool.Parent,'Torso')
	local direction=torso.CFrame.lookVector

		local tball = InitializeBall()
		local tbvel=bVel:Clone()
		local tscript=BoneScript:Clone()
		tscript.Parent=tball
		tscript.Disabled=false
		tbvel.velocity=(direction*thrustSpeed)+(Vector3.new(math.random()-.5,math.random()-.5,math.random()-.5)*thrustSpeed)
		tbvel.Parent=tball
		tball.CFrame=torso.CFrame+(direction*10)+Vector3.new(0,20,0)
		tball.Parent=Tool
		game.Debris:AddItem(tball,10)
		wait(.25)

	CanSpawnBall=true
end

function OnClick()
	if CanThrustAttack and CanSpawnBall then
		ThrustAttack()
	elseif CanSpawnBall then
		SpawnBall()
	end

end

function OnUnequip()
	if SpinAniTrack then
		SpinAniTrack:Stop()
		SpinAniTrack.Parent=nil
	end
	if ThrustAniTrack then
		ThrustAniTrack.Parent=nil
	end
	if PoundAniTrack then
		PoundAniTrack.Parent=nil
	end
	bVel.Parent=nil
	bRot.Parent=nil
	CanSpinAttack=true
	CanThrustAttack=true
end

Tool.Unequipped:connect(OnUnequip)

function OnEquip(mouse)
	MyHumanoid=waitforchild(Tool.Parent,'Humanoid')
	SpinAniTrack=MyHumanoid:LoadAnimation(SpinAni)
	ThrustAniTrack=MyHumanoid:LoadAnimation(ThrustAni)
	PoundAniTrack=MyHumanoid:LoadAnimation(PoundAni)
	mouse.Button1Down:connect(OnClick)
	--Tool.Grip=CFrame.new(0, 1.39999998, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
end

Tool.Equipped:connect(OnEquip)