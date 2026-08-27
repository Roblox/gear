local Tool = script.Parent
local Character = nil
local debounceHumHits = {}
local debounceHumTimes = {}
local damage = 35

local GLib = require(206209239)

local function WaitForChild(parent, child)
	while not parent:FindFirstChild(child) do parent.ChildAdded:wait() end
	return parent[child]
end

local Handle = WaitForChild(Tool, "Handle")
local Mesh = WaitForChild(Handle, "Mesh")
local GlowSpeed = WaitForChild(Tool, "GlowSpeed")
local SwingValue = WaitForChild(Tool, "SwingValue")

function onHit(hit)
	if not hit then return end
	local hitChar = hit.Parent
	if not hitChar or hitChar == Character then return end

	local hitHum = hitChar:FindFirstChild("Humanoid")
	if not hitHum then return end 

	if not Character or not Character == Tool.Parent then return end -- not in hand
	if not Tool.Enabled then return end -- don't hurt if not swingin'

	-- debounce check, and then do the damage!
	local currTime = tick()
	if (not debounceHumHits[hitHum] or debounceHumHits[hitHum] ~= SwingValue.Value or currTime - debounceHumTimes[hitHum] > 2) and GLib.IsTeammate(GLib.GetPlayerFromPart(hit), GLib.GetPlayerFromPart(Tool))~=true then
		debounceHumTimes[hitHum] = currTime
		debounceHumHits[hitHum] = SwingValue.Value
		hitHum:TakeDamage(damage)
	end
end

function onEquip()
	Character = Tool.Parent
end

function onUnequip()
	Character = nil
end

function glow()
	local glowParam = 0
	local glowDirection = 1
	while true do
		Mesh.VertexColor = Vector3.new(1+glowParam, 1+glowParam, 1+glowParam)
		glowParam = glowParam + glowDirection*GlowSpeed.Value
		if glowParam >= 1 then glowDirection = -1 end
		if glowParam <= 0 then glowDirection = 1 end

		wait(.1) -- 10 frames a second is fine
	end
end

-- make it glow
coroutine.resume(coroutine.create(glow))

Tool.Equipped:connect(onEquip)
Tool.Unequipped:connect(onUnequip)
Handle.Touched:connect(onHit)
