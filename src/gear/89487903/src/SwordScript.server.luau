-- Stickmasterluke
 -- A nice simple axe

function WaitForChild(obj, name)
	while not obj:FindFirstChild(name) do
		wait()
		print("1waiting for " .. name)
	end
	return obj:FindFirstChild(name)
end

local Tool = script.Parent
local Damage = 25

local Sword = Tool.Handle
local Hitbox = Sword:FindFirstChild("stickbox")

local SlashSound = Instance.new("Sound")
SlashSound.SoundId = "rbxasset://sounds\\Swordslash.wav"
SlashSound.Parent = Sword
SlashSound.Volume = .7

local UnsheathSound = Instance.new("Sound")
UnsheathSound.SoundId = "rbxasset://sounds\\unsheath.wav"
UnsheathSound.Parent = Sword
UnsheathSound.Volume = 1

local EquipTime = time()

function AttachAxe(hit)
	local taxe = script.Parent:FindFirstChild("Handle")
	local axeFrame = taxe.CFrame
	taxe.Parent = hit
	local tweld = Instance.new("Weld")
	tweld.Part0 = hit
	tweld.Part1 = taxe
	tweld.C0 = CFrame.new()
	tweld.C1 = axeFrame:inverse() * hit.CFrame
	tweld.Parent = hit
	
	local stickscript = taxe:FindFirstChild("waitBin"):FindFirstChild("stickScript"):Clone()
	stickscript.Parent = taxe
	stickscript.Disabled = false
	Sword:FindFirstChild("axehit"):Play()
end

local BlowMade = false
function Blow(hit)
	if (hit.Parent == nil) or time() - EquipTime<2 then return end -- happens when bullet hits Sword
	local humanoid = hit.Parent:findFirstChild("Humanoid")
	local vCharacter = Tool.Parent
	local vPlayer = game.Players:playerFromCharacter(vCharacter)
	local hum = vCharacter:findFirstChild("Humanoid") -- non - nil if Tool held by a character
	
	if humanoid ~= nil and humanoid ~= hum and hum ~= nil then
		-- final check, make sure Sword is in - hand
		local right_arm = vCharacter:FindFirstChild("Right Arm")
		if (right_arm ~= nil) then
			local joint = right_arm:FindFirstChild("RightGrip")
			if (joint ~= nil and (joint.Part0 == Sword or joint.Part1 == Sword)) and not BlowMade then
				BlowMade = true
				AttachAxe(hit)
				
				script.Parent.Parent = Sword
				TagHumanoid(humanoid, vPlayer)
				humanoid:TakeDamage(Damage)
				wait(1)
				UnTagHumanoid(humanoid)
				BlowMade = false
			end
		end
	end
end


function TagHumanoid(humanoid, player)
	local creator_tag = Instance.new("ObjectValue")
	creator_tag.Value = player
	creator_tag.Name = "creator"
	creator_tag.Parent = humanoid
end

function UnTagHumanoid(humanoid)
	if humanoid ~= nil then
		local tag = humanoid:findFirstChild("creator")
		if tag ~= nil then
			tag.Parent = nil
		end
	end
end

function DoSuperStrike()
	local bvelocity = Instance.new("BodyVelocity")
	bvelocity.maxForce = Vector3.new(9999999, 99999999, 99999999)
	local dir = (script.Parent.Parent:FindFirstChild("Humanoid").TargetPoint - Sword.CFrame.p).unit
	bvelocity.velocity = Vector3.new(dir.x * 75, dir.y * 75, dir.z * 75)
	Tool.Parent = game.Workspace
	bvelocity.Parent = Sword
	wait(2)
	bvelocity:Destroy()
end

Tool.Enabled = true
function OnActivated()
	if Tool.Enabled and time() - EquipTime>2 then
		Tool.Enabled = false
		local character = Tool.Parent;
		local humanoid = WaitForChild(character, "Humanoid")
		if humanoid == nil then
			print("Humanoid not found")
			return 
		end
		SlashSound:play()
		if time() - script.Parent:FindFirstChild("lastSuperStrike").Value<2 then
			DoSuperStrike()
		else
			Tool.doStrike.Value = not Tool.doStrike.Value
			wait(1)
		end
		Tool.Enabled = true
	end
end

function ReAttachStickbox()
 -- wait(2)
	local tweld = Instance.new("Weld")
	Sword:FindFirstChild("stickbox").CFrame = CFrame.new(Sword.CFrame * Vector3.new(0, 1, 0), Sword.CFrame.lookVector)
	tweld.Part0 = Sword -- > part0 has to be the parent 
	tweld.Part1 = Sword:FindFirstChild("stickbox")
	tweld.C0 = CFrame.new()
	tweld.C1 = Sword:FindFirstChild("stickbox").CFrame:inverse() * Sword.CFrame
	tweld.Parent = Sword
end

function OnEquipped()
	EquipTime = time()
	UnsheathSound:play()
	ReAttachStickbox()
end


Tool.Activated:connect(OnActivated)
Tool.Equipped:connect(OnEquipped)

Hitbox.Touched:connect(Blow)