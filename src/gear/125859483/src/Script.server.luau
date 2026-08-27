local HEAL_AMOUNT = 33


--Stickmasterluke


local Tool=script.Parent
local handle=Tool:WaitForChild("Handle")
local mesh=handle:WaitForChild("Mesh")
local pizzasound=handle:WaitForChild("PizzaSound")
local bodyp=handle:WaitForChild("BodyPosition")
local debris=game:GetService("Debris")
bodyp.maxForce=Vector3.new(0,0,0)


enabled=true

function fire(v)
	pizzasound:Play()
	if not handle.FlyingSound.IsPlaying then
		handle.FlyingSound:Play()
	end
	local vCharacter=Tool.Parent
	local vPlayer=game.Players:playerFromCharacter(vCharacter)
	local startpos=handle.Position
	local targetpos=startpos+(v*100)
	
	local effect=Instance.new("Part")
	effect.Name="Effect"
	effect.TopSurface="Smooth"
	effect.BottomSurface="Smooth"
	effect.Size=Vector3.new(.2,.2,.2)
	effect.CanCollide=false
	effect.Anchored=false
	effect.Velocity=v*-10+Vector3.new(math.random()-.5,3,math.random()-.5)*10
	effect.RotVelocity=Vector3.new(math.random()-.5,math.random()-.5,math.random()-.5)*10
	effect.CFrame=handle.CFrame
	local m=Instance.new("SpecialMesh")
	m.MeshId="http://www.roblox.com/asset/?id=125887676"		--new "just box" mesh goes here. Does not need to be done. Not really noticeable that it is offset.
	m.TextureId="http://www.roblox.com/asset/?id=125728597"
	m.Parent=effect
	debris:AddItem(effect,3)
	effect.Parent=game.Workspace

	Tool.Parent=game.Workspace
	handle.CFrame=CFrame.new(startpos+v*5)
	handle.RotVelocity=Vector3.new(0,20,0)
	bodyp.maxForce=Vector3.new(1500,1500,1500)
	bodyp.D=1500
	bodyp.P=1000
	bodyp.position=targetpos
	mesh.MeshId="http://www.roblox.com/asset/?id=125732887"		--new "just pizza" mesh goes here.
	Tool.GripPos=Vector3.new(.5,-0.8,1.5)						--Align pizza to mouth here. I tried to guess the best location if it was centered.
	wait(1)
	bodyp.position=targetpos*Vector3.new(1,0,1)
	bodyp.D=1600
	wait(1)
	bodyp.maxForce=Vector3.new(0,0,0)
	handle.FlyingSound:Stop()
end

function onActivated()
	if enabled then
		enabled=false
		local character=Tool.Parent
		local humanoid=character:FindFirstChild("Humanoid")
		if humanoid then
			local vec=(humanoid.TargetPoint-handle.Position).unit
			fire(vec)
		end
		wait(1.5)
		Tool.GripPos=Vector3.new(-.9,-1,.5)
		mesh.MeshId="http://www.roblox.com/asset/?id=125736357"
		enabled=true
	end
end

--[[
function onTouched(part)
	if string.lower(string.sub(part.Name,1,6))~="effect" then
		local h=part.Parent:FindFirstChild("Humanoid")
		if h~=nil and Tool.Parent==game.Workspace then
			Tool.Handle.FlyingSound:Stop()
			bodyp.maxForce=Vector3.new(0,0,0)
		end
	end
end
]]

local function OnToolChanged(property)
	if property == 'Parent' and Tool.Parent and bodyp.maxForce ~= Vector3.new(0, 0, 0) then
		local parent = Tool.Parent
		if parent and parent:IsA('Model') then
			local humanoid = parent:FindFirstChild('Humanoid')
			if humanoid then
				humanoid.Health = math.min(humanoid.Health + HEAL_AMOUNT, humanoid.MaxHealth)
				Tool.Handle.FlyingSound:Stop()
				bodyp.maxForce=Vector3.new(0, 0, 0)
			end
		end
	end
end

--handle.Touched:connect(onTouched)
Tool.Changed:connect(OnToolChanged)
Tool.Activated:connect(onActivated)

