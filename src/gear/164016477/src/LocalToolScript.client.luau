--Made by Stickmasterluke


local sp=script.Parent


local handle=sp:WaitForChild("Handle")
local debounce=true



function onequipped(mouse)
	mouse.Button1Down:connect(function()
		local plr=game.Players.LocalPlayer
		if plr and plr.Character and debounce then
			debounce=false
			local h=plr.Character:FindFirstChild("Humanoid")
			local a=sp:FindFirstChild("Toss")
			if h and a then
				local anim=h:LoadAnimation(a)
				if anim and h and h~=nil and h.Health>0 then
					anim:Play()
				end
			end
			wait(1)
			local p=handle:clone()
			p.CanCollide=true
			p.Velocity=(p.CFrame.lookVector*20)+Vector3.new(0,15,0)
			local bg=Instance.new("BodyGyro")
			bg.maxTorque=Vector3.new(1,0,1)*100000
			bg.cframe=CFrame.new()
			bg.Parent=p
			local bv=Instance.new("BodyAngularVelocity")
			bv.maxTorque=Vector3.new(1,1,1)*100000
			bv.angularvelocity=Vector3.new(0,math.pi,0)
			bv.Parent=p
			p:WaitForChild("RubyScript").Disabled=false
			p.Parent=game.Workspace
			sp:remove()
			wait(1)
			debounce=true
		end
	end)
end

sp.Equipped:connect(onequipped)



