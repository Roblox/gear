--4th of July 2012 Firework
local Tool = script.Parent
local Handle = Tool.Handle

local ReloadTime = 10 

--Shoots a rocket off into the sky
function FireRocket(Position)
	--Clone the handle
	local Rocket = Handle:Clone()
	Rocket.CanCollide = false
	Rocket.Transparency = 0
	Rocket.Position = Position
	Rocket.Name = "Firework"
	Rocket.Parent = game.Workspace

	--Tag the player
	local CreatorTag = Instance.new("ObjectValue")
	CreatorTag.Parent = Rocket
	CreatorTag.Value = game.Players:playerFromCharacter(Tool.Parent)
	CreatorTag.Name = "Creator"
	
	--Attach the RocketFlight script to it
	local FlightScript = Tool.FireworkExplosion:Clone()
	FlightScript.Parent = Rocket
	FlightScript.Disabled = false

	--Attach a particle effect to it flying off into the sky
	local FlightParticle = Instance.new("Sparkles")
	FlightParticle.Name = "Particle"
	FlightParticle.Color = BrickColor.Yellow().Color
	FlightParticle.Parent = Rocket	

end



Tool.Enabled = true
function onActivated()
	--Make sure we can't fire alot of rockets
	if not Tool.Enabled then return end
	Tool.Enabled = false

	--Hide the handle
	Tool.Handle.Transparency = 1
	
	--Shoot the rocket
	FireRocket(Tool.Handle.Position)

	--Clean up and re-enabled the tool
	wait(ReloadTime)
	Tool.Handle.Transparency = 0
	Tool.Enabled = true	

end

Tool.Activated:connect(onActivated)
