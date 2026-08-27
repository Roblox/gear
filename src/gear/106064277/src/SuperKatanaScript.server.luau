-- Ninja Katana FTW!!

-- handle to the game service object
r = game:service("RunService")

-- Normal damage
local nonslash_damage = 5

-- special damage when the Ninja slash occurs
local slash_damage = 10

local damage = nonslash_damage

-- Handle to the tool and its object
sword = script.Parent.Handle
Tool = script.Parent

function ChangeColor(part)
	if Tool.Parent == game.Workspace or part.Parent == script.Parent or part.Parent == script.Parent.Parent then return end
	part.BrickColor = BrickColor.new('Pink')
	for _, i in pairs(part:GetChildren()) do
		if i:IsA('DataModelMesh') then
			i.VertexColor = Vector3.new(0.8, 0.3, 0.6)
			if i:IsA('FileMesh') and i.MeshId ~= "" then
				i.TextureId = 'http://www.roblox.com/asset/?id=105905724'
			end
			
		end
		
	end
	if part.Parent:FindFirstChild('Humanoid') then
		for _, i in pairs(part.Parent:GetChildren()) do
			if i:IsA('CharacterMesh') then
				i.BaseTextureId =  105907211 
				i.OverlayTextureId =  105907211 
			end
			if i:IsA('Hat') and i:FindFirstChild('Handle') then
				ChangeColor(i.Handle)
			end
			if i:IsA('Shirt') then
				i:Destroy()
			end
			if i:IsA('Pants') then
				i:Destroy()
			end
		end
	end
	
end

-- Called when the katana(held by a player) comes in contact with 
-- another humanoid object
function blow(hit)
	local humanoid = hit.Parent:findFirstChild("Humanoid")
	local vCharacter = Tool.Parent
	local vPlayer = game.Players:playerFromCharacter(vCharacter)
	local hum = vCharacter:findFirstChild("Humanoid") -- non-nil if tool held by a character
	if humanoid~=nil and humanoid ~= hum and hum ~= nil then
		-- final check, make sure sword is in-hand

		local right_arm = vCharacter:FindFirstChild("Right Arm")
		if (right_arm ~= nil) then
			local joint = right_arm:FindFirstChild("RightGrip")
			if (joint ~= nil and (joint.Part0 == sword or joint.Part1 == sword)) then
				tagHumanoid(humanoid, vPlayer)
				humanoid:TakeDamage(damage)
				wait(1)
				untagHumanoid(humanoid)
			end
		end


	end
	ChangeColor(hit)
end

function tagHumanoid(humanoid, player)
	local creator_tag = Instance.new("ObjectValue")
	creator_tag.Value = player
	creator_tag.Name = "creator"
	creator_tag.Parent = humanoid
end

function untagHumanoid(humanoid)
	if humanoid ~= nil then
		local tag = humanoid:findFirstChild("creator")
		if tag ~= nil then
			tag.Parent = nil
		end
	end
end


function attack()
	--SlashSound:play()
	local anim = Instance.new("StringValue")
	anim.Name = "toolanim"
	anim.Value = "Slash"
	anim.Parent = Tool
end

local debounce = false
function onActivated()
	if debounce then return end
	debounce = true
	damage = slash_damage
	print("A")
	while Tool.Enabled do wait() end -- necessary to avoid debouncing conflicts between this script and LocalKatanaScript!
	attack()
	while not Tool.Enabled do wait() end -- necessary to avoid debouncing conflicts between this script and LocalKatanaScript!
	damage = nonslash_damage
	print("B")
	debounce = false
end

script.Parent.Activated:connect(onActivated)
script.Parent.Equipped:connect(onEquipped)

connection = sword.Touched:connect(blow)



