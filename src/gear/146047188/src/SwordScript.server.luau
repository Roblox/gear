--By Luckymaxer

r = game:service("RunService")

local damage = 1

local slash_damage = 5

sword = script.Parent.Handle
Tool = script.Parent

local SlashSound = sword:WaitForChild("SlashSound")

function blow(hit)
	if not hit or not hit.Parent then
		return
	end
	local humanoid = hit.Parent:findFirstChild("Humanoid")
	local vCharacter = Tool.Parent
	local vPlayer = game.Players:playerFromCharacter(vCharacter)
	local hum = vCharacter:findFirstChild("Humanoid") -- non-nil if tool held by a character
	if humanoid~=nil and humanoid.Health > 0 and humanoid ~= hum and hum ~= nil then
		-- final check, make sure sword is in-hand

		local right_arm = vCharacter:FindFirstChild("Right Arm") or vCharacter:FindFirstChild("RightHand")
		if (right_arm ~= nil) then
			local joint = right_arm:FindFirstChild("RightGrip")
			if (joint ~= nil and (joint.Part0 == sword or joint.Part1 == sword)) then
				tagHumanoid(humanoid, vPlayer)
				humanoid:TakeDamage(damage)
				if humanoid.Health == 0 then
					for i, v in pairs(humanoid.Parent:GetChildren()) do
						if v:IsA("BasePart") then
							for ii = 1, 2 do
								local Wood = Instance.new("Part")
								Wood.Name = "Wood"
								Wood.Locked = true
								Wood.CanCollide = true
								Wood.Anchored = false
								Wood.FormFactor = Enum.FormFactor.Custom
								Wood.TopSurface = Enum.SurfaceType.Smooth
								Wood.BottomSurface = Enum.SurfaceType.Smooth
								Wood.Size = Vector3.new(1, 0.8, 1)
								Wood.Material = Enum.Material.Wood
								Wood.BrickColor = BrickColor.new("Dark orange")
								game:GetService("Debris"):AddItem(Wood, 5)
								Wood.Parent = game:GetService("Workspace")
								Wood.CFrame = v.CFrame + Vector3.new(0, (ii * Wood.Size.y), 0)
								v:Destroy()
							end

						end
					end
				end
			end
		end


	end
end


function tagHumanoid(humanoid, player)
	local creator_tag = Instance.new("ObjectValue")
	creator_tag.Value = player
	creator_tag.Name = "creator"
	creator_tag.Parent = humanoid

	game.Debris:AddItem(creator_tag, 1)

end


function attack()
	damage = slash_damage
	SlashSound:play()
	local anim = Instance.new("StringValue")
	anim.Name = "toolanim"
	anim.Value = "Slash"
	anim.Parent = Tool
end

function swordUp()
	Tool.GripForward = Vector3.new(-1,0,0)
	Tool.GripRight = Vector3.new(0,1,0)
	Tool.GripUp = Vector3.new(0,0,1)
end

function swordOut()
	Tool.GripForward = Vector3.new(0,0,1)
	Tool.GripRight = Vector3.new(0,-1,0)
	Tool.GripUp = Vector3.new(-1,0,0)
end

function swordAcross()
	-- parry
end


Tool.Enabled = true
local last_attack = 0
function onActivated()

	if not Tool.Enabled then
		return
	end

	Tool.Enabled = false

	local character = Tool.Parent;
	local humanoid = character.Humanoid
	if humanoid == nil then
		print("Humanoid not found")
		return 
	end

	t = r.Stepped:wait()

	attack()

	last_attack = t

	--wait(.5)

	Tool.Enabled = true
end

function onEquipped()
end

script.Parent.Activated:connect(onActivated)
script.Parent.Equipped:connect(onEquipped)

connection = sword.Touched:connect(blow)