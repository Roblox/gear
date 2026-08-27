local Tool = script.Parent
local Remote = Tool:WaitForChild("Remote")
local Handle = Tool:WaitForChild("Handle")

Handle.Transparency = 1

local Equipping = false

local Feet = {}
local FootFrame = CFrame.new(0, -0.8, 0) * CFrame.Angles(0, math.pi, 0)
local WalkAnim
local WalkId

local Slow = 8
local SlowedHuman

local AttackRange = 3
local AttackDamage = 10

function getPlayer()
	local char = Tool.Parent
	return game:GetService("Players"):GetPlayerFromCharacter(char)
end

function contains(t, v)
	for _, val in pairs(t) do
		if val == v then
			return true
		end
	end
	return false
end

function tagHuman(human)
	local tag = Instance.new("ObjectValue")
	tag.Value = getPlayer()
	tag.Name = "creator"
	tag.Parent = human
	game:GetService("Debris"):AddItem(tag)
end

function stop(human)
	local delta = human.WalkSpeed
	human.WalkSpeed = human.WalkSpeed - delta
	delay(0.1, function()
		human.WalkSpeed = human.WalkSpeed + delta
	end)
end

function tryHit(part)
	local victims = {}
	local pos = part.Position
	local a = pos - Vector3.new(AttackRange, AttackRange, AttackRange)
	local b = pos + Vector3.new(AttackRange, AttackRange, AttackRange)
	local region = Region3.new(a, b)
	for _, part in pairs(workspace:FindPartsInRegion3(region)) do
		if not part:IsDescendantOf(Tool.Parent) then
			if part.Parent and part.Parent:FindFirstChild("Humanoid") then
				local human = part.Parent.Humanoid
				if not contains(victims, human) then
					table.insert(victims, human)
					tagHuman(human)
					human:TakeDamage(AttackDamage)
					
					local root = human.Parent:FindFirstChild("HumanoidRootPart")
					if root then
						root.Velocity = Vector3.new(0, 128, 0)
					end
				end
			end
		end
	end
end

function onFootTouched(foot, part)
	if part:IsDescendantOf(Tool.Parent) then return end
	if foot:FindFirstChild("Cooldown") then return end
	
	local cd = Instance.new("BoolValue")
	cd.Name = "Cooldown"
	cd.Parent = foot
	game:GetService("Debris"):AddItem(cd, 0.4)
	
	local sound = Tool.Handle.Stomp:Clone()
	sound.PlayOnRemove = true
	sound.Pitch = math.random(90, 110)/100
	sound.Volume = 0.25
	sound.Parent = foot
	game:GetService("Debris"):AddItem(sound, 0)
	
	tryHit(foot)
end

function onEquip()
	if Equipping then return end
	
	Equipping = true
	
	--attach the feet
	local foot = Handle:Clone()
	foot.Mesh.MeshId = "http://www.roblox.com/asset/?id=200902905"
	foot.Transparency = 0
	foot.CanCollide = false
	
	local char = Tool.Parent
	if char then
		local lleg = char:FindFirstChild("Left Leg")
		if lleg then
			local left = foot:Clone()
			left.Parent = char
			
			local weld = Instance.new("Weld")
			weld.Part0 = lleg
			weld.Part1 = left
			weld.C0 = FootFrame
			weld.Parent = weld.Part0
			
			left.Touched:connect(function(part)
				onFootTouched(left, part)
			end)
			
			table.insert(Feet, left)
		end
		
		local rleg = char:FindFirstChild("Right Leg")
		if rleg then
			local right = foot:Clone()
			right.Parent = char
			
			local weld = Instance.new("Weld")
			weld.Part0 = rleg
			weld.Part1 = right
			weld.C0 = FootFrame
			weld.Parent = weld.Part0
			
			right.Touched:connect(function(part)
				onFootTouched(right, part)
			end)
			
			table.insert(Feet, right)
		end
	end
	
	--change the animation
	WalkAnim = Tool.Parent:FindFirstChild("WalkAnim", true)
	if WalkAnim then
		WalkId = WalkAnim.AnimationId
		WalkAnim.AnimationId = Tool.Walk.AnimationId
	end
	
	--change the walk speed
	SlowedHuman = Tool.Parent:FindFirstChild("Humanoid")
	if SlowedHuman then
		SlowedHuman.WalkSpeed = SlowedHuman.WalkSpeed - Slow
		stop(SlowedHuman)
	end
	
	Equipping = false
end

function onUnequip()
	--feet
	for _, foot in pairs(Feet) do
		foot:Destroy()
	end
	Feet = {}
	
	--animation
	if WalkAnim then
		WalkAnim.AnimationId = WalkId
		WalkAnim = nil
		WalkId = nil
	end
	
	--speed
	if SlowedHuman then
		SlowedHuman.WalkSpeed = SlowedHuman.WalkSpeed + Slow
		stop(SlowedHuman)
		SlowedHuman = nil
	end
end

Tool.Equipped:connect(onEquip)
Tool.Unequipped:connect(onUnequip)