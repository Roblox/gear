local skyMap2 = {
	{1, 1, 1, 0, 1, 1, 1, 0, 1, 0, 1, 0, 1},
	{1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1},
	{0, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 1, 1},
	{0, 1, 0, 0, 1, 0, 1, 0, 1, 0, 0, 0, 1},
	{1, 0, 0, 0, 1, 0, 1, 0, 1, 0, 0, 0, 1},
	{1, 1, 1, 0, 1, 1, 1, 0, 1, 0, 0, 0, 1},
}

local skyMaps = {skyMap2} 

local myMap = skyMaps[math.random(1, #skyMaps)]
local particles = {}

local colorWheel = {Color3.new(1, 0, 0), Color3.new(1, 0, 1), Color3.new(0, 0, 1), Color3.new(0, 1, 1), Color3.new(0, 1, 0), Color3.new(0, 0, 0)}

function makeNewParticle()
	local newPart = Instance.new("Part")
	newPart.Transparency = 1
	newPart.CanCollide = false
	newPart.formFactor = "Custom"
	newPart.Size = Vector3.new(0.2, 0.2, 0.2)

	local newSparkles = Instance.new("Sparkles")
	newSparkles.Name = "Sparkles"
	newSparkles.Parent = newPart

	local newBV = Instance.new("BodyVelocity")
	newBV.P = 1000
	newBV.maxForce = Vector3.new(1, 1, 1)*newBV.P
	newBV.velocity = Vector3.new(0, 0, 0)
	newBV.Parent = newPart

	local newForce = Instance.new("BodyForce")
	newForce.Name = "FloatForce"
	newForce.force = Vector3.new(0, 196.2*newPart:GetMass(), 0)
	newForce.Parent = newPart

	local newFire = Instance.new("Fire")
	newFire.Heat = 12
	newFire.Size = 12
	newFire.Parent = newPart
	
	local newLight = Instance.new('PointLight')
	newLight.Name = 'Light'
	newLight.Range = 60
	newLight.Color = Color3.new(math.random(), math.random(), math.random())
	newLight.Parent = newPart 

	return newPart, newSparkles, newBV, newFire, newLight
end

for y = 1, #myMap do
	local row = myMap[y]
	for x = 1, #row do
		if myMap[y][x] == 1 then
			local newParticle = {}
			newParticle.X = x - #row/2 
			newParticle.Y = #myMap - y + 1
			newParticle.Part, newParticle.Sparkler, newParticle.BV, newParticle.Fire, newParticle.Light = makeNewParticle()

			table.insert(particles, newParticle)
		end
	end
end

FuseSound = Instance.new("Sound")
FuseSound.SoundId = "http://www.roblox.com/asset/?id=11565378"
FuseSound.Parent = script.Parent
FuseSound:Play()

local force = Instance.new("BodyForce")
local shell = script.Parent

force.Parent = shell

for i = 1, 10 do
	force.force = shell.CFrame:vectorToWorldSpace(Vector3.new(1, 0, 0)) * shell:GetMass() * 98 * 3
	wait(.1)
end

force:Remove()

--- BOOM!
local sound = Instance.new("Sound")
sound.SoundId = "rbxasset://sounds\\Rocket shot.wav"
sound.Parent = script.Parent
sound.Volume = 1
sound:play()

function lerpColors(startColor, endColor, timeVar)
	local newR = startColor.r*(1-timeVar) + endColor.r*timeVar
	local newG = startColor.g*(1-timeVar) + endColor.g*timeVar
	local newB = startColor.b*(1-timeVar) + endColor.b*timeVar
	return Color3.new(newR, newG, newB)
end

local r = game:GetService("RunService")

function getNextColor(color)
	return (color % #colorWheel) + 1
end

function changeSparkleColors()
	local startColor = math.random(1, #colorWheel)
	local nextColor = getNextColor(startColor)
	local timeVar = 0

	local fireColorOffset = math.random(1, #colorWheel)
	local fireColor2Offset = math.random(1, #colorWheel)

	while particles and particles[1] and particles[1].Part and particles[1].Part.Parent do
		local currColor = lerpColors(colorWheel[startColor], colorWheel[nextColor], timeVar)
		local currFireColor = lerpColors(colorWheel[getNextColor(startColor + fireColorOffset)], colorWheel[getNextColor(startColor + fireColorOffset + 1)], timeVar)
		local currFire2Color = lerpColors(colorWheel[getNextColor(startColor + fireColor2Offset)], colorWheel[getNextColor(startColor + fireColor2Offset + 1)], timeVar)
		for i = 1, #particles do
			particles[i].Sparkler.SparkleColor = currColor
			particles[i].Fire.Color = currFireColor
			particles[i].Fire.SecondaryColor = currFire2Color
			
			--particles[i].Light.Color = Color.new(math.random(), math.random(), math.random())
		end
		timeVar = timeVar + wait(.01)
		if timeVar > 1 then
			startColor = nextColor
			nextColor = getNextColor(startColor)
			timeVar = timeVar - 1
		end
	end
end

-- make them sparkleez
local rocketCFrame = CFrame.Angles(0, math.random()*math.pi*2, 0)
local spreadAmount = 8 + math.random()*4
for i = 1, #particles do
	local particle = particles[i]
	particle.Part.CFrame = CFrame.new(shell.Position)
	particle.BV.velocity = rocketCFrame:vectorToWorldSpace(Vector3.new(particle.X, particle.Y, 0)) * spreadAmount
	particle.Part.Parent = workspace
end

coroutine.resume(coroutine.create(changeSparkleColors))

-- REMOVING THE SHELL CAUSES CRAZINESS!
shell.Transparency = 1
shell.Anchored = true

function getCentroid()
	local myVector = Vector3.new(0, 0, 0)
	if #particles == 0 then return myVector end

	for i = 1, #particles do
		myVector = myVector + particles[i].Part.CFrame.p
	end
	return myVector / #particles
end

function makeWeld(basePart, littlePart)
	local newWeld = Instance.new("ManualWeld")
	newWeld.Part0 = basePart
	newWeld.Part1 = littlePart
	newWeld.C0 = CFrame.new()
	newWeld.C1 = newWeld.Part1.CFrame:inverse() * newWeld.Part0.CFrame
	newWeld.Parent = basePart
end

wait(1.5)
local centerPart = Instance.new("Part")
centerPart.Anchored = false
centerPart.CanCollide = false
centerPart.Transparency = 1
centerPart.Size = Vector3.new(5, 5, 5)

local newForce = Instance.new("BodyForce")
newForce.force = Vector3.new(0, centerPart:GetMass()*196.2, 0)
newForce.Parent = centerPart

local newBAV = Instance.new("BodyAngularVelocity")
newBAV.P = 10000
newBAV.maxTorque = Vector3.new(1, 1, 1)*newBAV.P
newBAV.angularvelocity = Vector3.new(0, 1, 0)
newBAV.Parent = centerPart

for i = 1, #particles do
	particles[i].Part.CFrame = particles[i].Part.CFrame - particles[i].Part.CFrame.p + shell.CFrame.p + rocketCFrame:vectorToWorldSpace(1.5 * spreadAmount * Vector3.new(particles[i].X, particles[i].Y, 0))
end


centerPart.CFrame = CFrame.new(getCentroid())

for i = 1, #particles do
	particles[i].BV.Parent = nil
	particles[i].Velocity = Vector3.new(0, 0, 0)
	particles[i].RotVelocity = Vector3.new(0, 0, 0)
	makeWeld(centerPart, particles[i].Part)
end

centerPart.Parent = workspace

wait(7)
for i = 1, #particles do
	particles[i].Part:FindFirstChild("FloatForce"):Remove()
end
centerPart.Parent = nil

wait(3)

for i = 1, #particles do
	particles[i].Part.Parent = nil
end

shell.Parent = nil
