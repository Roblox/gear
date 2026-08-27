local Tool = script.Parent 
local Remote = Tool.Handle

local vCharacter
local myTorso 
local myHumanoid 

local RE = Tool:WaitForChild("RemoteEvent")

Tool.Enabled = true 

local c4Clone,c4Touch

local exploded

local debris = game:GetService("Debris") 

local players = game:GetService("Players")

function IsTeamMate(Player1, Player2)
	return (Player1 and Player2 and not Player1.Neutral and not Player2.Neutral and Player1.TeamColor == Player2.TeamColor)
end

function onActivated(targetPos)
	if not Tool.Enabled then 
		return 
	end 

	if not myTorso or not myHumanoid then
		return 
	end

	Tool.Enabled = false

	if not c4Clone or not c4Clone.Parent or exploded then 
		exploded = false 
		local target = targetPos
		local lookAt = (target - Remote.Position).Unit 
		
		local findPart = workspace:FindPartOnRay(Ray.new(Remote.Position, lookAt * 8.0), vCharacter)
		if findPart then 			
			c4Clone = Remote:Clone()	
			c4Clone.CFrame = Remote.CFrame 
			c4Clone.Velocity = lookAt * 9.0 
			c4Clone.Parent = workspace
			c4Clone.Anchored = false
			c4Clone.Locked = true
			c4Clone.CanCollide = true
			if c4Clone:CanSetNetworkOwnership() then
				c4Clone:SetNetworkOwner(nil)
			end
			local Activate = c4Clone:FindFirstChild("Beep")
			if Activate then
				Activate:Play()
			end
			c4Touch = c4Clone.Touched:Connect(function(part)
				if part and part.Parent and not part.Anchored and part.Parent ~=  vCharacter and part.Parent ~= Tool and not part.Parent:IsA("Accoutrement") and not part:IsGrounded() then 
					local FF = part.Parent:FindFirstChildOfClass("ForceField")
					if FF then return end
					local c4Weld = Instance.new("Weld")
					c4Weld.Part0 = part 
					c4Weld.Part1 = c4Clone 
					c4Weld.Name = "C4Weld"
					c4Weld.Parent = c4Clone 
					c4Weld.C1 = part.CFrame * c4Clone.CFrame:inverse()		
				end 				
			end) 

			if Remote:FindFirstChildOfClass("SpecialMesh") then 
				Remote:FindFirstChildOfClass("SpecialMesh").MeshId = "http://www.roblox.com/asset/?id=74322546"
				Remote:FindFirstChildOfClass("SpecialMesh").TextureId = "http://www.roblox.com/asset/?id=74322558"
			end  

			if Tool:FindFirstChild("TooFar") then Tool.TooFar.Value = 2 end 
		else 		
			if Tool:FindFirstChild("TooFar") then 
				Tool.TooFar.Value = 1
			end 
		end  	
	elseif c4Clone and c4Clone.Parent then 
		local explosion = Instance.new("Explosion")
		explosion.BlastRadius = 15.0 
		explosion.DestroyJointRadiusPercent = 0
		explosion.BlastPressure = 0	
		explosion.Position = c4Clone.Position 		
		c4Clone.Anchored = true
		local Boom = c4Clone:FindFirstChild("Boom")
		if Boom then
			Boom:Play()
		end
		
		if c4Clone:FindFirstChildOfClass("SpecialMesh") then
			 c4Clone.Transparency = 1
		end
		
		if c4Touch then
			c4Touch:Disconnect();c4Touch = nil
		end
		
		explosion.Hit:Connect(function(hit)
			if hit and hit.Parent then 
				local humanoid,FF = hit.Parent:FindFirstChildOfClass("Humanoid"),hit.Parent:FindFirstChildOfClass("ForceField")
				if humanoid and humanoid ~= myHumanoid and not FF and not IsTeamMate(vPlayer,players:GetPlayerFromCharacter(humanoid.Parent)) then 
					local creatorTag = Instance.new("ObjectValue")
					creatorTag.Name = "creator"
					creatorTag.Value = vPlayer
					creatorTag.Parent = humanoid 
					debris:AddItem(creatorTag, 1.0) 
				end 
				if hit and hit.Parent and (not humanoid or not IsTeamMate(vPlayer,players:GetPlayerFromCharacter(humanoid.Parent))) and not FF then
					hit:BreakJoints()
					if hit:CanSetNetworkOwnership() then
						hit:SetNetworkOwner(nil)
					end
					hit.Velocity = (hit.Position-explosion.Position).Unit * 10^2.5
				end
			end 
		end) 

		explosion.Parent = workspace

		exploded = true

		if Remote:FindFirstChildOfClass("SpecialMesh") then 
			Remote:FindFirstChildOfClass("SpecialMesh").MeshId = "http://www.roblox.com/asset/?id=74322628"
			Remote:FindFirstChildOfClass("SpecialMesh").TextureId = "http://www.roblox.com/asset/?id=74322630"
		end 		

		if Tool:FindFirstChild("TooFar") then Tool.TooFar.Value = 0 end 
		debris:AddItem(c4Clone,2)
	end 

	wait(2.0)
	
	Tool.Enabled = true 
end 

function onEquipped()
	vCharacter = Tool.Parent 
	myTorso = vCharacter:FindFirstChild("Torso") or vCharacter:FindFirstChild("UpperTorso")
	myHumanoid = vCharacter:FindFirstChildOfClass("Humanoid") 
	vPlayer = game.Players:GetPlayerFromCharacter(vCharacter)

	if (not c4Clone or not c4Clone.Parent) and Remote:FindFirstChild("Mesh") then 
		Remote.Mesh.MeshId = "http://www.roblox.com/asset/?id=74322628"
		Remote.Mesh.TextureId = "http://www.roblox.com/asset/?id=74322630"
	end 
end 

function onUnequipped()
	if Remote:FindFirstChild("Mesh") then 
		Remote.Mesh.MeshId = "http://www.roblox.com/asset/?id=74322546"
		Remote.Mesh.TextureId = "http://www.roblox.com/asset/?id=74322558"
	end  	
end

RE.OnServerEvent:Connect(function(player, func, ...)
	if not player == game:GetService("Players"):GetPlayerFromCharacter(Tool.Parent) then return end
	
	if func == "Activate" then
		onActivated(...)
	end
end)
Tool.Equipped:Connect(onEquipped)
Tool.Unequipped:Connect(onUnequipped)
