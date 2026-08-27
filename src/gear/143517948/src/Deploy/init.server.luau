--Made by Stickmasterluke
--Fixed by TakeoHonorable

sp=script.Parent


local debris=game:GetService("Debris")
equipped=false
check=true


sp.Activated:Connect(function()
	local chr=sp.Parent
	if chr and check and equipped then
		local t=chr:FindFirstChild("HumanoidRootPart")
		local h=chr:FindFirstChildOfClass("Humanoid")
		local animobject1=sp:FindFirstChild("ButtonPress"..h.RigType.Name)
		local animobject2=sp:FindFirstChild("Toss"..h.RigType.Name)
		if t and h and animobject1 and animobject2 and equipped then
			if h.Health>0 then
				check=false
				local anim1=h:LoadAnimation(animobject1)
				if anim1 and h and h.Health>0 and equipped then
					anim1:Play()
					wait(1.6)
					sp.Handle.BeepTone:Play()
					wait(.6)
					sp.Handle.BeepTone:Play()
					wait(.5)
				end
				local anim2=h:LoadAnimation(animobject2)
				if anim2 and h and h.Health>0 and equipped then
					anim2:Play()
					wait(1.2)
				end
				if equipped then
					local p=sp.Handle:Clone()
					p.CanCollide=true
					p.Name="Jump Point"
					p.Anchored=false
					p.Velocity=(t.CFrame.lookVector*20)+Vector3.new(0,20,0)
					local s=script:WaitForChild("Script"):Clone()
					s.Parent=p
					s.Disabled=false
					local gui=sp.JumpPointGui:Clone()
					gui.Parent=p
					local ct=Instance.new("ObjectValue")
					ct.Name="creator"
					ct.Value=game.Players:GetPlayerFromCharacter(chr)
					ct.Parent=p
					local gyro=Instance.new("BodyGyro")		--this will keep the thing standing upright.
					gyro.Parent=p
					p.Parent=game.Workspace
					p:SetNetworkOwner(game.Players:GetPlayerFromCharacter(chr))
					sp:Destroy()
				end
				check=true
			end
		end
	end
end)

sp.Unequipped:Connect(function()
	equipped=false
end)

sp.Equipped:Connect(function()
	equipped = true
end)

