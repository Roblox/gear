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

local torso = script.Parent

PewPew = Instance.new("Sound")
PewPew.Name = "PewPew"
PewPew.SoundId = "http://www.roblox.com/asset/?id=34315534"
PewPew.Parent = torso
PewPew.Volume = 0.5
PewPew.Looped = true
PewPew:Play()

local Seed = Random.new()

local Velo = Create("BodyVelocity"){
	MaxForce = Vector3.new(1,1,1)*math.huge,
	Velocity = Vector3.new(Seed:NextNumber(0,1),Seed:NextNumber(0,1),Seed:NextNumber(0,1)),
	Parent = torso
}
	
local Angular = Create("BodyAngularVelocity"){
	MaxTorque = Vector3.new(1,1,1)*math.huge,
	AngularVelocity = Vector3.new(Seed:NextNumber(0,5),Seed:NextNumber(0,5),Seed:NextNumber(0,5)),
	Parent = torso
}

local Time,Start,r = 5.25,tick(),game:GetService("RunService")

while (tick()-Start) < Time do
	--Velo.Velocity = Vector3.new(Seed:NextNumber(-5,5),Seed:NextNumber(-5,5),Seed:NextNumber(-5,5))
	--AngularVelocity = Vector3.new(Seed:NextNumber(-1,5),Seed:NextNumber(-1,5),Seed:NextNumber(-1,5))
	r.Heartbeat:Wait()
end

PewPew.Looped = false
if PewPew.TimePosition ~= 0 then
	PewPew.Ended:Wait()
	
end
PewPew:Stop()
Angular:Destroy()
Velo:Destroy()
script:Destroy()