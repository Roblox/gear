--[[
	By ArceusInator
--]]
local GLib = require(206209239)
local Tool = script.Parent

local Equipped = false
local AttackOn = false
local InSpecial = false
local LastSwingAt = 0
local AttackId = 0
local SwingLength = 0
local PointingGyro
local SwingDebounce = 0.8
local UsingHumanoid

Tool.Equipped:connect(function()
	if Equipped then return end
	Equipped = true
end)

Tool.Unequipped:connect(function()
	if not Equipped then return end
	Equipped = false
	
	-- Reset state
	AttackOn = false
	Charging = false
	AttackId = AttackId + 1
	
	if UsingHumanoid then
		UsingHumanoid.WalkSpeed = 16
		UsingHumanoid.PlatformStand = false
		UsingHumanoid.AutoRotate = true
	end
	if PointingGyro then
		PointingGyro:Destroy()
		PointingGyro = nil
	end
end)

script.AttackStateChanged.Event:connect(function(state)
	local character, player, humanoid = GLib.GetCharacter(Tool)
	UsingHumanoid = humanoid
	
	if not InSpecial and humanoid and humanoid.Health > 0 then
		if state == true and AttackOn == false then
			AttackId = AttackId + 1
			AttackOn = true
			
			local thisAttackId = AttackId
			delay(0.2, function()
				if Equipped and AttackId == thisAttackId then -- They haven't released, start charging
					Charging = true
					Tool.Animator.PlayAnimation:Fire('Charge_Start', 1/0.8)
					
					humanoid.WalkSpeed = 0
					humanoid.AutoRotate = false
					PointingGyro = GLib.Create'BodyGyro'{
						maxTorque = Vector3.new(0, 40000, 0),
						D = 50,
						Parent = humanoid.Torso
					}
					Tool.LocalCharacterPointer.StartPointing:FireClient(player, PointingGyro)
					
					delay(0.5, function()
						if Equipped and AttackId == thisAttackId then -- They still haven't released, signal full charge
							FullCharge = true
							Tool.Animator.PlayAnimation:Fire('Charge_FullIdle')
							
							for index, obj in next, Tool.GhostHandle:GetChildren() do
								if obj:IsA'ParticleEmitter' then obj.Enabled = true end
							end
						end
					end)
				end
			end)
		elseif state == false and AttackOn == true then
			AttackId = AttackId + 1
			AttackOn = false
			
			Tool.Animator.StopAnimation:Fire('Charge_FullIdle')
			Tool.LocalCharacterPointer.StopPointing:FireClient(player)
			
			if Charging then
				if FullCharge then
					local charge = true
					local start = humanoid.Torso.Position
					local target = humanoid.Torso.CFrame.p + humanoid.Torso.CFrame.lookVector*15
					local pointerBP = GLib.Create'BodyPosition'{
						Parent = humanoid.Torso
					}
					local chaseHum = nil
					--humanoid.PlatformStand = true
					InSpecial = true
					PointingGyro.maxTorque = Vector3.new(40000, 40000, 40000)
					
					while charge do
						-- Update aesthetic
						PointingGyro.cframe = CFrame.new(start, target)
						
						-- Collect hit parts
						local hitParts = {}
						local humanoids = {}
						local here = start
						while (here - target).magnitude > 0.01 do
							local hit, pos = workspace:FindPartOnRayWithIgnoreList(
								Ray.new(
									here,
									(target-here)
								),
								{
									character,
									Tool.Shield.Value or Tool,
									unpack(hitParts)
								}
							)
							
							if hit ~= nil then
								-- ignore this part
								table.insert(hitParts, hit)
								
								-- check for humanoid
								local char, plr, hum = GLib.GetCharacter(hit)
								local pass = false
								
								if hum and hum.Health > 0 and hum.Torso then
									pass = true
									
									if plr then
										pass = not GLib.IsTeammate(plr, player)
									end
								end
								
								if pass then
									humanoids[hum] = true
								end
								
								if hum == nil then
									target = pos
									break
								end
							end
							
							here = pos
						end
						
						-- Deal damage
						for hum in next, humanoids do
							GLib.TagHumanoid(hum, player)
							hum:TakeDamage(30)
						end
						
						-- Reposition
						humanoid.Torso.CFrame = humanoid.Torso.CFrame + (target - humanoid.Torso.Position)
						
						-- Select a new target
						local hums = {}
						for hum in next, humanoids do
							if hum.Health > 0 then
								table.insert(hums, hum)
							end
						end
						
						if chaseHum == nil or humanoids[chaseHum] == nil then
							chaseHum = hums[1]
						end
						
						if chaseHum then
							local targetUp = target + Vector3.new(0, chaseHum.Torso.Position.y-target.y, 0)
							local dist = (targetUp - chaseHum.Torso.Position).magnitude * 1/2
							local to = targetUp + Vector3.new((math.random()-.5)*dist, 0, (math.random()-.5)*dist)
							local dir = (to - chaseHum.Torso.Position).unit
							
							local hit1, pos1 = workspace:FindPartOnRayWithIgnoreList(
								Ray.new(
									chaseHum.Torso.Position,
									dir*15/2
								),
								{
									character,
									Tool.Shield.Value or Tool,
									unpack(hitParts)
								}
							)
							local hit2, pos2 = workspace:FindPartOnRayWithIgnoreList(
								Ray.new(
									chaseHum.Torso.Position,
									-dir*15/2
								),
								{
									character,
									Tool.Shield.Value or Tool,
									unpack(hitParts)
								}
							)
							
							start, target = pos1, pos2
							pointerBP.position = start
							PointingGyro.cframe = CFrame.new(start, target)
							Tool.Animator.PlayAnimation:Fire('Charge_Slash')
						else
							pointerBP.position = target
							PointingGyro.cframe = CFrame.new(start, target)
							Tool.Animator.PlayAnimation:Fire('Charge_Finish')
							charge = false
						end
						
						Tool.Sound.PlaySound:Fire('Dash')
						
						-- Wait
						wait(1)
						
						-- Check for cancel
						if not Equipped then charge = false end
					end
					
					InSpecial = false
					if Tool:FindFirstChild'GhostHandle' then
						for index, obj in next, Tool.GhostHandle:GetChildren() do
							if obj:IsA'ParticleEmitter' then obj.Enabled = false end
						end
					end
					humanoid.WalkSpeed = 16
					humanoid.PlatformStand = false
					humanoid.AutoRotate = true
					if PointingGyro then
						PointingGyro:Destroy()
						PointingGyro = nil
					end
					pointerBP:Destroy()
				else
					Tool.Animator.PlayAnimation:Fire('Charge_Cancel')
					delay(0.2, function() Tool.Sound.PlaySound:Fire('DoubleSlash') end)
					LastSwingAt = tick()
					SwingLength = 0.8
					
					delay(0.8, function()
						if not Charging then
							humanoid.WalkSpeed = 16
							humanoid.AutoRotate = true
							if PointingGyro then
								PointingGyro:Destroy()
								PointingGyro = nil
							end
							Tool.LocalCharacterPointer.StopPointing:FireClient(player)
						end
					end)
				end
			elseif tick() - LastSwingAt > SwingDebounce then
				local slashId = math.random(1, 3)
				Tool.Animator.PlayAnimation:Fire('Slash_'..slashId)
				delay(0.1, function() Tool.Sound.PlaySound:Fire('Slash') end)
				LastSwingAt = tick()
				SwingLength = 0.4
			end
			
			Charging = false
			FullCharge = false
			humanoid.AutoRotate = true
		end
	end
end)

Tool.Handle.Touched:connect(function(hit)
	local character, player, humanoid = GLib.GetCharacter(Tool)
	
	if not InSpecial and hit and humanoid and humanoid.Health > 0 then
		local char, plr, hum = GLib.GetCharacter(hit)
		
		if hum ~= nil and not GLib.IsTeammate(player, plr) then
			local damage = 5
			if tick() - LastSwingAt < SwingLength then
				damage = 15
			end
			
			GLib.TagHumanoid(hum, player)
			hum:TakeDamage(damage)
		end
	end
end)