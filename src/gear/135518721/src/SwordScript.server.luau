--Stickmasterluke

local Tool = script.Parent
local Sword = Tool.Handle
local Debris = game:GetService("Debris")
local Anims = {'RightSlash', 'OverHeadSwing', 'SwordSpin'}	--,"LeftSlash"

local UnsheathSound = Instance.new("Sound")
UnsheathSound.SoundId = "rbxasset://sounds\\unsheath.wav"
UnsheathSound.Parent = Sword
UnsheathSound.Volume = .5

-- CONSTANTS --

local BASE_DMG = 7
local SLASH_DMG = 15
local SPIN_ATTACK_DMG = 10
local SWING_DMG = 20
local Damage = BASE_DMG

function WaitFor(parent, name)
	while true do
		local child = parent:FindFirstChild(name)
		if child ~= nil then
			return child
		end
		wait()
	end
end

WaitFor(Tool,"RunAnim")
local Sparkles = WaitFor(Sword,"Sparkles")

function OnSwordHit(hit)
	if Tool.Enabled then return end
	
	if hit.Parent then
		local hitHumanoid = hit.Parent:FindFirstChild("Humanoid")
		local character = Tool.Parent
		if character and hitHumanoid then
			local player = game.Players:playerFromCharacter(character)
			if player then
				local humanoid = character:findFirstChild("Humanoid")
				if humanoid and hitHumanoid ~= humanoid and humanoid.Health > 0 then
					local rightArm = character:FindFirstChild("Right Arm")
					if rightArm then
						local joint = rightArm:FindFirstChild("RightGrip")
						if joint and (joint.Part0 == Sword or joint.Part1 == Sword) then
							TagHumanoid(hitHumanoid, player)
							hitHumanoid:TakeDamage(Damage)
						end
					end
				end
			end
		end
		if hit.Name=="Handle" then
			Sparkles.Enabled=true
			wait(.3)
			Sparkles.Enabled=false
		end
	end
end


function TagHumanoid(hitHumanoid, player)
	for i,v in ipairs(hitHumanoid:GetChildren()) do
		if v.Name=="creator" then
			v:remove()
		end
	end
	local creator_tag=Instance.new("ObjectValue")
	creator_tag.Value=player
	creator_tag.Name="creator"
	creator_tag.Parent=hitHumanoid
	Debris:AddItem(creator_tag,1)
end

Tool.Enabled = true

function OnActivated()
	if Tool.Enabled then
		Tool.Enabled = false
		local character = Tool.Parent
		local hitHumanoid = character.Humanoid
		
		if not hitHumanoid then
			print("Humanoid not found")
			return 
		end
		
		local newAnim = Anims[math.random(1,#Anims)]
		
		while newAnim == Tool.RunAnim.Value do
			newAnim = Anims[math.random(1,#Anims)]
		end
		
		-- value changed, sends callback to local script
		Tool.RunAnim.Value = newAnim
		
		if newAnim == 'OverHeadSwing' then
			Damage = SWING_DMG
			wait(1)
		elseif newAnim == 'SwordSpin' then
			Damage = SPIN_ATTACK_DMG
			wait(1)
		else
			Damage = SLASH_DMG
		end
		
		wait(.75)
		Damage = BASE_DMG
		Tool.Enabled = true
	end
end

function OnEquipped()
	UnsheathSound:play()
	Sparkles.Enabled = false
end

Tool.Activated:connect(OnActivated)
Tool.Equipped:connect(OnEquipped)

connection = Sword.Touched:connect(OnSwordHit)


