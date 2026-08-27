local Damage=9

while not script.Parent:FindFirstChild('Handle') do wait() end
local Handle=script.Parent.Handle

function TagHumanoid(Humanoid, Player)
	if Humanoid ~= nil then 
		creatorTag = Instance.new("ObjectValue")
		creatorTag.Name = "creator"
		creatorTag.Value = Player
		creatorTag.Parent = Humanoid 
		game.Debris:AddItem(creatorTag, 1)
	end
end

function OnTouched(Part)
	HitHumanoid = Part.Parent:FindFirstChild("Humanoid")
	myHumanoid = script.Parent.Parent:FindFirstChild("Humanoid")
	myPlayer = game.Players:GetPlayerFromCharacter(script.Parent.Parent)

	if HitHumanoid and myHumanoid and myHumanoid ~= HitHumanoid then
		print('getting here')
		rightArm = myHumanoid.Parent:FindFirstChild("Right Arm")
		if rightArm then 
			rightGrip = rightArm:FindFirstChild("RightGrip")
			print('getting there')
			if rightGrip and (rightGrip.Part0 == Handle or rightGrip.Part1 == Handle) then 	
				print('doing damage')
				TagHumanoid(HitHumanoid, myPlayer)	
				HitHumanoid:TakeDamage(Damage)
			end
		end
	end
end


script.Parent.Handle.Touched:connect(OnTouched)
