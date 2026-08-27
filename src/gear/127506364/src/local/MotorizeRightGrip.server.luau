function Create(ty)
	return function(data)
		local obj = Instance.new(ty)
		for k, v in pairs(data) do
			if type(k) == 'number' then
				v.Parent = obj
			else
				obj[k] = v
			end
		end
		return obj
	end
end

local Tool = script.Parent.Parent

local armChildRemovedConn = nil
local Motor6DGrip = nil
local EquippedNum = 0

Tool.Equipped:connect(function()
	EquippedNum = EquippedNum + 1
	local myEquip = EquippedNum
	--some vars
	local Player = game.Players:GetPlayerFromCharacter(Tool.Parent)
	local Character = Player.Character

	local rightarm = Character:FindFirstChild('Right Arm')
	if rightarm and rightarm:FindFirstChild('RightGrip') then
		local rightGrip = rightarm['RightGrip']
		local handle = rightGrip.Part1

		--kill my joint when the normal joint is removed
		--this must be done here so that the joint is removed 
		--_right away_ after unequipping and the character doesn't 
		--glitch up.
		local armChildRemovedConn = rightarm.ChildRemoved:connect(function(ch)
			if ch == rightGrip then
				Motor6DGrip:Remove()
				Motor6DGrip = nil
				--
				if handle and Character:FindFirstChild('Torso') then
					if Tool.Parent.Parent:IsA('Player') then
						--the sword has been deselected
						--put the sword far away so the user doesn't notice that the handle doesn't
						--update for about 0.1 seconds after selecting the tool.
						handle.CFrame = CFrame.new(100000, 100000, 100000)
					else
						--if in the workspace, position the handle where it should be dropped
						--use the size of the handle to make sure it's dropped far enough away
						handle.CFrame = Character.Torso.CFrame * CFrame.new(0, 0, -(handle.Size.magnitude+2))
					end
				end
			end
		end)

		--make my new joint
		Motor6DGrip = Create'Motor6D'{
			Name = 'RightGrip_Motor',
			Part0 = rightarm,
			C0 = CFrame.new(-0.3, 0, 0); 
			C1 = CFrame.Angles(0, -math.pi/2, -math.pi/2);
		}
		--kill the old weld
		rightGrip.Part1 = nil
		rightGrip.Part0 = nil
		handle.Size = Vector3.new(0.55, 0.84, 6.26)
		Motor6DGrip.Part1 = handle
		Motor6DGrip.Parent = rightGrip.Parent
		local mesh = handle:WaitForChild('Mesh')
		mesh.Scale = Vector3.new(1.5,1.5,1.5)
		mesh.TextureId = 'http://www.roblox.com/asset/?id=127402402'
		mesh.MeshId = 'http://www.roblox.com/asset/?id=127402519'
	end
end)

Tool.Unequipped:connect(function()
	EquippedNum = EquippedNum + 1
	if armChildRemovedConn then
		armChildRemovedConn:disconnect()
		armChildRemovedConn = nil
	end
end)
