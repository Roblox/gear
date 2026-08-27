local Damage=20


local Handle=script.Parent

function TagHumanoid(Humanoid, Player)
	if Humanoid ~= nil then 
		creatorTag = Instance.new("ObjectValue")
		creatorTag.Name = "creator"
		creatorTag.Value = Player
		creatorTag.Parent = Humanoid 
		game.Debris:AddItem(creatorTag, 2)
	end
end

local function weldBetween(a, b)
    local weld = Instance.new("Weld")
    weld.Part0 = a
    weld.Part1 = b
    weld.C0 = CFrame.new()
    weld.C1 = b.CFrame:inverse() * a.CFrame
    weld.Parent = a
    return weld;
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
			if HitHumanoid.Health<25 then

				for _,i in pairs(Part.Parent:GetChildren()) do
					if i:IsA('Part') then
						local tpart = i:Clone()
						tpart.Parent=Handle
						weldBetween(Handle,tpart)
					end
				end

				for _,i in pairs(Part.Parent:GetChildren()) do
					if i:IsA('Part') then
						i:Destroy()
					end
				end

			end
		end
	end
end


script.Parent.Touched:connect(OnTouched)
