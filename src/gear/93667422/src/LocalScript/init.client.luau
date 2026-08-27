function waitforchild(parent,child)
	while not parent:FindFirstChild(child) do
		wait()
	end
	return parent[child]
end

local Tool=script.Parent
local SpinAni=waitforchild(script,'spin')
local SpinAniTrack
local ThrustAni=waitforchild(script,'Thrust')
local ThrustAniTrack

local lastClick

local MyHumanoid 

local bVel= Instance.new('BodyVelocity')
bVel.maxForce=Vector3.new(9999999,0,9999999)
local thrustSpeed=100

local bRot= Instance.new('BodyAngularVelocity')
bRot.maxTorque=Vector3.new(9999999,99999999,9999999)
bRot.angularvelocity=Vector3.new(0,25,0)
local CanThrustAttack=true
function ThrustAttack()
	CanThrustAttack=false
	ThrustAniTrack:Play(.1,1,2)
	--Tool.Grip=CFrame.new(0, 1.50000012, 1.22391882e-007, 1, 0, 0, 0, -1, -8.74227766e-008, 0, 8.74227766e-008, -1)
	Tool.Grip=CFrame.new(0, 1.76066029, 0.26066035, 1, 0, 0, 0, -0.707106829, 0.707106709, 0, -0.707106709, -0.707106829)
	local torso=waitforchild(Tool.Parent,'Torso')
	local direction=torso.CFrame.lookVector
	bVel.velocity=Vector3.new(direction.x,0,direction.z).unit*thrustSpeed
	bVel.Parent=torso
	wait(.5)
	bVel.Parent=nil
	wait(1)
	Tool.Grip=CFrame.new(0, 1.39999998, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
	
	CanThrustAttack=true
end

local CanSpinAttack=true
function SpinAttack()
	CanSpinAttack=false
	local torso=waitforchild(Tool.Parent,'Torso')
	SpinAniTrack:Play(.1,1,2)
	Tool.Grip=CFrame.new(0, 2, 1.22391882e-007, 1, 0, 0, 0, -1, -8.74227766e-008, 0, 8.74227766e-008, -1)
	bRot.Parent=torso
	wait(1)
	bRot.Parent=nil
	SpinAniTrack:Stop()
	Tool.Grip=CFrame.new(0, 1.39999998, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
	CanSpinAttack=true
end

function OnClick()
	if CanThrustAttack then
		ThrustAttack()
	elseif CanSpinAttack then
		SpinAttack()
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
	mouse.Button1Down:connect(OnClick)
	Tool.Grip=CFrame.new(0, 1.39999998, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
end

Tool.Equipped:connect(OnEquip)