local Particle = Instance.new('Part')
Particle.Name = 'Effect'
Particle.Size = Vector3.new(.2,.2,.2)
Particle.CanCollide = false
Particle.Transparency = 1
local PartMesh = Instance.new('SpecialMesh')
PartMesh.Name = 'PartMesh'
PartMesh.MeshId = 'http://www.roblox.com/asset/?id=87112830'--'http://www.roblox.com/asset/?id=96501868'--
PartMesh.TextureId = 'http://www.roblox.com/asset/?id=99871304'
PartMesh.Parent=Particle
local PartVelocity = Instance.new('BodyVelocity')
PartVelocity.maxForce = Vector3.new(99999999,99999999,999999)
PartVelocity.velocity= Vector3.new(0,1,0)
PartVelocity.Parent=Particle
local PartSpin = Instance.new('BodyAngularVelocity')
PartSpin.maxTorque = Vector3.new(999999999,99999999,999999)
PartSpin.angularvelocity =Vector3.new(1,1,1)
PartSpin.Parent=Particle

local Lifetime = 2
local Rate =.1

function TweenTransparency(element,starta,enda,length)
	local startTime = time()
	while time() - startTime < length do
		element.Transparency = ((enda - starta) * ((time() - startTime)/length)) + starta
		wait(.01)
	end
	element.Transparency = enda
end

function TweenScale(element,starts,ends,length)
	local startTime = time()
	while time() - startTime < length do
		element.Scale = ((ends - starts) * ((time() - startTime)/length)) + starts
		wait(.01)
	end
	element.Scale = ends
end

function TweenColor(element,startc,endc,length)
	local startTime = time()
	while time() - startTime < length do
		element.VertexColor = ((endc - startc) * ((time() - startTime)/length)) + startc
		wait(.01)
	end
	element.VertexColor = endc
end

while true do
	PartVelocity.velocity= Vector3.new((math.random()-.5)/2,math.random()+3,(math.random()-.5)/2)
	PartMesh.Scale= Vector3.new((math.random()/2)+.2,math.random()/2+.2,math.random()/2+.2)
	PartSpin.angularvelocity =Vector3.new(math.random()*3,math.random()*3,math.random()*3)
	Particle.CFrame= script.Parent.CFrame
	local npart= Particle:Clone()
	local nmesh = npart:FindFirstChild('PartMesh')
	npart.Transparency = 1
	npart.Parent=script.Parent
	
	Spawn(function() 
		TweenTransparency(npart, 1,.5,.1) 
		TweenTransparency(npart, .5,1,1.5) 
	end)
	--Spawn(function() 
		--TweenColor(nmesh, Vector3.new(.8+(math.random()*.4),1,1),Vector3.new(.5,.5,.5),1.5) 
	--end)
	Spawn(function() TweenScale(nmesh,nmesh.Scale,nmesh.Scale*math.random()*.5,1.5) end)
	game.Debris:AddItem(npart,Lifetime)
	wait(Rate)

end