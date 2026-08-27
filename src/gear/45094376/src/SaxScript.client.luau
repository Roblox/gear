local Sax = script.Parent

local oldGF = Vector3.new(0, 1, 0)
local oldGP = Vector3.new(0.15, -0.25, -0.5)
local oldGR = Vector3.new(1, 0, 0)
local oldGU = Vector3.new(0, 0, 1)

local newGF = Vector3.new(-.6821, .5751, -.4517)
local newGP = Vector3.new(.15, -.25, -.15)
local newGR = Vector3.new(.7313, .5364, -.4214)
local newGU = Vector3.new(.00001568, .6178, .7864)

local saxAnimation = nil

Sax.Enabled = true
function playSax()
		if not Sax.Enabled then return end
		Sax.Enabled = false

		if saxAnimation then saxAnimation:Play() end
		moveToPlay()

		if math.random(1, 2) == 1 then Sax.Handle.FirstLoop:Play()
		else Sax.Handle.SecondLoop:Play() end

		if saxAnimation then wait(5) end
		moveFromPlay()

		Sax.Enabled = true
end

function loadAnim()
	local vChar = Sax.Parent
	
	if vChar ~= nil then
		local hum = vChar:FindFirstChild("Humanoid")
		if hum ~= nil then
			saxAnimation = hum:LoadAnimation(Sax.SaxNoLoop)
		end
	end
end

function destroyAnim()
	saxAnimation = nil
end

function moveToPlay()
	for i = 1, 10 do
		Sax.GripForward = i/10*newGF + (10-i)/10*oldGF
		Sax.GripPos = i/10*newGP + (10-i)/10*oldGP
		Sax.GripRight = i/10*newGR + (10-i)/10*oldGR
		Sax.GripUp = i/10*newGU + (10-i)/10*oldGU
		wait(.05)
	end
end

function moveFromPlay()
	for i = 1, 10 do
		Sax.GripForward = i/10*oldGF + (10-i)/10*newGF
		Sax.GripPos = i/10*oldGP + (10-i)/10*newGP
		Sax.GripRight = i/10*oldGR + (10-i)/10*newGR
		Sax.GripUp = i/10*oldGU + (10-i)/10*newGU
		wait(.05)
	end
end

Sax.Equipped:connect(loadAnim)
Sax.Activated:connect(playSax)
Sax.Unequipped:connect(destroyAnim)

