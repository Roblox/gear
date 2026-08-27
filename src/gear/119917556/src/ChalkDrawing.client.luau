local DRAW_RANGE = 40

local Tool = script.Parent
local Equipped = false

Tool.Equipped:connect(function(mouse)
	Equipped = true
	local MouseDown = false
	local Character = Tool.Parent
	local Torso = Character:WaitForChild('HumanoidRootPart')
	--
	mouse.KeyDown:connect(function(key)
		if key:upper() == 'Q' then
			Tool.DrawMode.Value = not Tool.DrawMode.Value
		end
	end)
	--
	local function makePart()
		local part = Instance.new('Part')
		part.Name = 'ChalkEffect'
		part.FormFactor = 'Custom'
		part.TopSurface = 'Smooth'
		part.BottomSurface = 'Smooth'
		part.BrickColor = BrickColor.new('White')
		part.Anchored = true
		part.CanCollide = false
		game.Debris:AddItem(part, 30)
		return part
	end
	--
	local function linearFactor(arr, ai, bi)
		if bi-ai <= 2 then return 1 end
		--
		local a, b, c = arr[ai], arr[bi], arr[math.floor((ai+bi)/2)]
		local edge1 = (b - a).unit
		local edge2 = (b - c).unit
		--
		local at = c
		local norm = edge1:Cross(edge2).unit
		--
		for i = ai+1, bi-1 do
			local p = arr[i]

			-- check for being in the plane
			local planesep = (p - at):Dot(norm)
			if planesep > 0.01 then
				return 0
			end 

			-- check for linearity
			local sep = p - a
			local proj = edge1 * sep:Dot(edge1)
			local dist = (sep-proj).magnitude
			if dist > 0.1 then
				return 0
			end
		end
		--
		return 1
	end
	--
	mouse.Button1Down:connect(function()
		MouseDown = true
		--
		if not Tool.DrawMode.Value then return end
		--
		local atArray = {}
		local lastPart = nil
		--
		function commitPart(a, b)
			local Camera = game:GetService("Workspace").CurrentCamera
			local sep = (b-a).magnitude
			lastPart.Size = Vector3.new(0.2,0.2,sep)
			lastPart.CFrame = CFrame.new(a, b) * CFrame.new(0, 0, -sep/2)
			--
			lastPart = makePart()
			lastPart.Parent = Camera
			lastPart.Size = Vector3.new(0.2,0.2,0.2)
			lastPart.CFrame = CFrame.new(b, b+(b-a))
		end
		--
		while MouseDown and Equipped and Tool.DrawMode.Value do
			if mouse.Target and 
			   (mouse.Hit.p - Torso.Position).magnitude < DRAW_RANGE and
			   not (mouse.Target.Parent and mouse.Target.Parent:FindFirstChild('Humanoid')) 
			then
				local Camera = game:GetService("Workspace").CurrentCamera
				if #atArray == 0 or (mouse.Hit.p - atArray[#atArray]).magnitude > 0.2 then
					if #atArray > 0 and (mouse.Hit.p - atArray[#atArray]).magnitude > 2 then
						-- "jumped", stop drawing
						-- stop drawing, make the last line a linear segment
						commitPart(atArray[1], atArray[#atArray])
						lastPart:Destroy()
						atArray = {}					
					else
						atArray[#atArray+1] = mouse.Hit.p
						if #atArray == 1 then
							lastPart = makePart()
							lastPart.Parent = Camera
							lastPart.Size = Vector3.new(0.2, 0.2, 0.2)
							lastPart.CFrame = CFrame.new(atArray[1])
						else
							local lastStartPoint = 1
							for i = 2, #atArray do
								if linearFactor(atArray, lastStartPoint, i) < 0.5 then
									-- Roll back and draw the line between the last start point and the last index,
									-- and make the last index the last start point.
									commitPart(atArray[lastStartPoint], atArray[i-1])
									lastStartPoint = i-1
								end
							end
							--
							if lastStartPoint ~= #atArray then
								local sep = (atArray[lastStartPoint]-atArray[#atArray]).magnitude
								lastPart.Size = Vector3.new(0.2, 0.2, sep)
								lastPart.CFrame = CFrame.new(atArray[lastStartPoint], atArray[#atArray])*
								                  CFrame.new(0, 0, -sep/2)
							end
							--
							-- kill entiries up to the last start point
							for i = 1, lastStartPoint-1 do
								table.remove(atArray, 1)
							end
						end
					end
				elseif (mouse.Hit.p - atArray[#atArray]).magnitude > 0.1 then
					-- no new point
					-- assume remains linear (lastStartPoint = 1 --> mouse.Hit)
					local sep = (atArray[1]-mouse.Hit.p).magnitude
					lastPart.Size = Vector3.new(0.2, 0.2, sep)
					lastPart.CFrame = CFrame.new(atArray[1], mouse.Hit.p)*CFrame.new(0, 0, -sep/2)					
				end
			elseif #atArray > 0 then
				-- stop drawing, make the last line a linear segment
				commitPart(atArray[1], atArray[#atArray])
				lastPart:Destroy()
				atArray = {}
			end
			--
			wait()
		end
		-- if we have uncommitted stuff then commit it
		if #atArray > 1 then
			commitPart(atArray[1], atArray[#atArray])
		end
		if lastPart then
			lastPart:Destroy()
		end
	end)
	mouse.Button1Up:connect(function()
		MouseDown = false
	end)
end)

Tool.Unequipped:connect(function()
	Equipped = false
end)