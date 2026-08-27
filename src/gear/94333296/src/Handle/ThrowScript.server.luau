--Made by Stickmasterluke


sp=script.Parent

local Played = false
sp.Touched:Connect(function(hit)
	if hit and hit.Parent then
		if not hit.Parent:FindFirstChildOfClass("Humanoid") and string.lower(hit.Name)~="water" and string.lower(string.sub(hit.Name,1,6))~="effect" and hit.Name~="Handle" then
			local sound=sp:FindFirstChild("Break")
			if sound and not Played then
				Played = true
				sound:Play()
			end
			--sp.Anchored=false
			--sp.CanCollide=false
			--sp.Transparency=1
			wait(3)
			sp:Destroy()
		end
	end
end)

wait(5)

sp:Destroy()

