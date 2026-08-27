while not script:FindFirstChild('DamageHelper') do
	script.ChildAdded:wait()
end
while not script:FindFirstChild('EndTime') do
	script.ChildAdded:wait()
end
script.DamageHelper.Disabled = false
while not script:FindFirstChild('TargetModel') do
	script.ChildAdded:wait()
end
local Target = script:FindFirstChild('TargetModel').Value
while not Target:FindFirstChild('StunScriptRef') do
	Target.ChildAdded:wait()
end
local StunScriptRef = Target:FindFirstChild('StunScriptRef')

local Player = game.Players:GetPlayerFromCharacter(Target)
local Humanoid = Target:FindFirstChild("Humanoid")

if not Humanoid then
	--we need a humanoid to proceed, so destroy us now 
	--if there is none
	StunScriptRef:Destroy()
	script:Destroy()
	return
end

--we don't need a player, but we need to prevent equiping
--of tools and dis-equip the current tool if there is a player
Humanoid:UnequipTools()
local PlayerCleanup;
if Player then
	local ToolEquipCnList = {}
	for _, ch in pairs(Player.Backpack:GetChildren()) do
		local cn = ch.Equipped:connect(function()
			wait()
			Humanoid:UnequipTools()
		end)
		ToolEquipCnList[cn] = true
	end
	PlayerCleanup = function()
		for cn, _ in pairs(ToolEquipCnList) do
			cn:disconnect()
		end
	end
else
	--stub to avoid a more branching later
	PlayerCleanup = function() end
end

--now, make the player shield ears
local ScreamAnim = Instance.new("Animation")
ScreamAnim.AnimationId = 'http://www.roblox.com/asset/?id=73137648'
ScreamAnim.Name = "ANIM_Scream"
ScreamAnim.Parent = Target


--play the anim, and put walkwpeed to 0
local track = Humanoid:LoadAnimation(ScreamAnim)
track:Play(0.2, 1, 4)
Humanoid.WalkSpeed = 0

local EndTime = tick() + 3
script.EndTime.Changed:connect(function()
	EndTime = tick() + 3
end)

while EndTime > tick() do
	wait(EndTime - tick())
end

--and stop the anim, and put walkspeed back to normal
Humanoid.WalkSpeed = 16
track:Stop()
ScreamAnim:Destroy()

--and clean up the player effects
PlayerCleanup()

StunScriptRef:Destroy()
script:Destroy()