local Tool = script.Parent
Tool.Enabled = true
local Players = game:GetService'Players'

function BuildCharacterRig(Character, AppearanceModel, IsR15)
	local Humanoid,FF = Character:FindFirstChildOfClass("Humanoid"),Character:FindFirstChildOfClass("ForceField")
	if not Humanoid and Humanoid.Health > 0 or FF then return end 	

	local AnimateScript = Character:FindFirstChild("Animate")
	if not AnimateScript then return end 
	
	for _, Object in next, Character:GetChildren() do
		if Object:IsA("Accessory") then
			Object:Destroy()
		elseif Object.Name == "Head" then
			local Face = Object:FindFirstChild("face")
			if Face then
				Face.Texture = "rbxasset://textures/face.png"
			end
		elseif Object:IsA("Shirt") or Object:IsA("Pants") or Object:IsA("ShirtGraphic") or Object:IsA("BodyColors") then
			Object:Destroy()
		end
	end
	
	if IsR15 then		
		for _, Object in next, AppearanceModel:GetChildren() do
			if Object.Name == "R15" and Object:IsA("Folder") then
				for _, Part in next, Object:GetChildren() do
					if Part:IsA("BasePart") then
						local HasLimb = Character:FindFirstChild(Part.Name)
						if HasLimb then
							HasLimb:Destroy()
						end
						Part.Parent = Character
						Humanoid:BuildRigFromAttachments()
					end
				end
			elseif Object.Name == "R15Anim" and Object:IsA("Folder") then
				for _, AnimationObject in next, Object:GetChildren() do
					local HasAnimObject = AnimateScript:FindFirstChild(AnimationObject.Name)
					if HasAnimObject then
						HasAnimObject:Destroy()
					end
					
					AnimationObject.Parent = AnimateScript
				end
			elseif Object:IsA("Accessory") then
				Humanoid:AddAccessory(Object)
			elseif Object:IsA("Pants") or Object:IsA("Shirt") or Object:IsA("ShirtGraphic") or Object:IsA("BodyColors") then
				Object.Parent = Character
			elseif Object.Name == "face" then
				local Head = Character:FindFirstChild("Head")
				if Head then
					local Face = Head:FindFirstChild("face")
					if Face then
						Face.Texture = Object.Texture
					else
						Object.Parent = Head
					end
				end
			elseif Object.Name == "BodyDepthScale" or Object.Name == "BodyHeightScale" or Object.Name == "BodyWidthScale" or Object.Name == "HeadScale" then
				local ValueObject = Humanoid:FindFirstChild(Object.Name)
				if ValueObject then
					ValueObject.Value = Object.Value
				else
					Object.Parent = Humanoid
				end
			end
		end				
	else
		for _, Object in next, AppearanceModel:GetChildren() do
			if Object:IsA("Accessory") then
				Humanoid:AddAccessory(Object)
			elseif Object:IsA("Pants") or Object:IsA("Shirt") or Object:IsA("ShirtGraphic") or Object:IsA("BodyColors") then
				Object.Parent = Character
			elseif Object.Name == "face" then
				Object.Parent = Character:FindFirstChild("Head")				
			end
		end
	end
end

Tool.SwapWith.OnServerEvent:Connect(function(client, character)
	if client == Players:GetPlayerFromCharacter(Tool.Parent) and client.Character and Tool.Enabled then
		local otherPlayer = Players:GetPlayerFromCharacter(character)
		if not otherPlayer then return end -- Remove to make it work with NPCs
		
		local clienttorso,targettorso = client.Character:FindFirstChild("Torso") or client.Character:FindFirstChild("UpperTorso"),character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
		if not clienttorso or not targettorso or (targettorso.Position-clienttorso.Position).Magnitude > 50 then return end
		
		local ClientCharacterAppearance = Players:GetCharacterAppearanceAsync(client.UserId)		
		local OtherCharacterAppearance = Players:GetCharacterAppearanceAsync(otherPlayer.UserId)
		
		
		local ClientHumanoid = client.Character:FindFirstChildOfClass("Humanoid")
		local OtherHumanoid = character:FindFirstChildOfClass("Humanoid")
		if ClientHumanoid and OtherHumanoid then
			BuildCharacterRig(client.Character, OtherCharacterAppearance, ClientHumanoid.RigType == Enum.HumanoidRigType.R15)
			BuildCharacterRig(character, ClientCharacterAppearance, OtherHumanoid.RigType == Enum.HumanoidRigType.R15)
		end
		
		ClientCharacterAppearance:Destroy()
		OtherCharacterAppearance:Destroy()

		if otherPlayer and client.Character:FindFirstChild'HumanoidRootPart' and character:FindFirstChild'HumanoidRootPart' and client.Character.HumanoidRootPart.Anchored == false and character.HumanoidRootPart.Anchored == false then
			local posA, posB = client.Character.HumanoidRootPart.CFrame, character.HumanoidRootPart.CFrame
			client.Character.HumanoidRootPart.CFrame = posB
			character.HumanoidRootPart.CFrame = posA
		end
		Tool.Enabled = false
		delay(5,function()
			Tool.Enabled = true
		end)
	end 
end)