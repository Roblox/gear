Tool = script.Parent 
Handle = Tool:WaitForChild("Handle")
AnimPlaying = Tool:WaitForChild("AnimPlaying")
AnimReloading = Tool:WaitForChild("AnimReloading")
PlaySound = Handle:WaitForChild("PlaySound")

Debris = game:GetService("Debris")
Players = game:GetService("Players")

Animating = false
MouseDown = false

Camera = game:GetService("Workspace").CurrentCamera

Animating = false

function OnEquipped(Mouse)
	Character = Tool.Parent 
	Player = Players:GetPlayerFromCharacter(Character)
	Torso = Character:FindFirstChild("Torso")
	Humanoid = Character:FindFirstChild("Humanoid") 
	
	AnimPlayingConnection = AnimPlaying.Changed:connect(function()
		if AnimPlaying.Value then
			Animating = true
			ArmsUpTrack = Humanoid:LoadAnimation(Tool.ArmsUp)
			ArmsUpTrack:Play()
		else
			if ArmsUpTrack then
				ArmsUpTrack:Stop()
			end
			Animating = false
		end
	end)

	Mouse.Button1Down:connect(function()
		if not Animating then 
			MouseDown = true
			Charge_Animation = Humanoid:LoadAnimation(Tool.ChargeAnim)
			Charge_Animation:Play()
			while MouseDown do
				wait()
			end
			if Charge_Animation then
				Charge_Animation:Stop()
			end 
			local vDirection = (Torso.Position - Camera.CoordinateFrame.p).unit 
			local mDirection = (Humanoid.TargetPoint - Camera.CoordinateFrame.p).unit 

			PlaySound.Value = "62337944"

			local AngleBetweenVectors = math.abs(math.acos(vDirection:Dot(mDirection)))
			if AngleBetweenVectors < 0.5 then 
				Slash_Animation = Humanoid:LoadAnimation(Tool.SlashAnim)
				Slash_Animation:Play()						
			else
				Stab_Animation = Humanoid:LoadAnimation(Tool.StabAnim)
				Stab_Animation:Play()
			end				
		end 
	end) 

	Mouse.Button1Up:connect(function()
		MouseDown = false 
		if not Animating then 
			Tool.Enabled = false
			Animating = true 
			wait(1.5)			
			Tool.Enabled = true 
			Animating = false 		
		end 		
	end)
	
	Mouse.KeyDown:connect(function(Key)
		Key = Key:lower()
		if Key == "q" and not AnimReloading.Value then
			AnimPlaying.Value = true
		end
	end)
end 

function OnUnequipped()
	if Charge_Animation then
		Charge_Animation:Stop()
	end 
	if Slash_Animation then
		Slash_Animation:Stop()
	end 
	if Stab_Animation then
		Stab_Animation:Stop()
	end
	if ArmsUpTrack then
		ArmsUpTrack:Stop()
	end
	if AnimPlayingConnection and AnimPlayingConnection.connected then
		AnimPlayingConnection:disconnect()
	end
	Animating = false
	MouseDown = false
end 

Tool.Equipped:connect(OnEquipped)
Tool.Unequipped:connect(OnUnequipped)