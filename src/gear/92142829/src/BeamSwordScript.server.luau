local function WaitForChild(parent, child)
	while parent:FindFirstChild(child) == nil do 
		wait()
	end 
	return parent[child] 
end 

local Tool = script.Parent
local Handle = Tool.Handle
local Character = nil


local OnSound = WaitForChild(Handle, "LightsaberOn")
local OffSound = WaitForChild(Handle, "LightsaberOff")
local IdleLoop = WaitForChild(Handle, "IdleLoop")

local SlashSounds = {
	WaitForChild(Handle, "Slash1"),
	WaitForChild(Handle, "Slash2"),	
}

function TagHumanoid(Humanoid, Player)
	if Humanoid ~= nil then 
		creatorTag = Instance.new("ObjectValue")
		creatorTag.Name = "creator"
		creatorTag.Value = Player
		creatorTag.Parent = Humanoid 
		game.Debris:AddItem(creatorTag, 1)
	end
end

function onTouched(Part)
	if not Character then return end
	HitHumanoid = Part.Parent:FindFirstChild("Humanoid")
		
	myHumanoid = Character:FindFirstChild("Humanoid")
	myPlayer = game.Players:GetPlayerFromCharacter(vCharacter)

	if HitHumanoid ~= nil and myHumanoid ~= nil and myHumanoid ~= HitHumanoid then
		rightArm = Character:FindFirstChild("Right Arm")
		if rightArm then 
			rightGrip = rightArm:FindFirstChild("RightGrip")
			if rightGrip and (rightGrip.Part0 == Handle or rightGrip.Part1 == Handle) then 	
				TagHumanoid(HitHumanoid, myPlayer)	
				if Part.Name == "Right Arm" or Part.Name == "Left Arm" then			
					Part:BreakJoints()
				else
					HitHumanoid:TakeDamage(9)
				end	
							
			end
		end
	end
end


function onActivated()
	SlashSounds[math.random(1, #SlashSounds)]:Play()

end
Tool.Activated:connect(onActivated)


function onEquipped()
	Character = Tool.Parent
	OnSound:Play()
	IdleLoop:Play()
end
Tool.Equipped:connect(onEquipped)


function onUnequipped()
	Character = nil
	OffSound:Play()
	IdleLoop:Stop()
end
Tool.Unequipped:connect(onUnequipped)

Handle.Touched:connect(onTouched)