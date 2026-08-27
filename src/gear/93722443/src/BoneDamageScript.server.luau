local Damage=9


local Handle=script.Parent

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
	myHumanoid = Handle.Parent.Parent:FindFirstChild("Humanoid")
	myPlayer = game.Players:GetPlayerFromCharacter(Handle.Parent.Parent)

	if HitHumanoid and myHumanoid and myHumanoid ~= HitHumanoid then
		print('getting here')
		rightArm = myHumanoid.Parent:FindFirstChild("Right Arm")
		if rightArm then 
			TagHumanoid(HitHumanoid, myPlayer)	
			HitHumanoid:TakeDamage(Damage)
		end
	end
end


script.Parent.Touched:connect(OnTouched)
