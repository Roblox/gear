--Stickmasterluke
--[[
	Fixed by ArceusInator
	- Works in FE
--]]


sp=script.Parent


local debris=game:GetService("Debris")
local equipped=false
local check=true

function onEquipped()
	equipped=true
end

function onUnequipped()
	equipped=false
end

function onActivated()
	local chr=sp.Parent
	if chr and check then
		local t=chr:FindFirstChild("Torso")
		local h=chr:FindFirstChild("Humanoid")
		local animobject1=sp:FindFirstChild("ButtonPress")
		local animobject2=sp:FindFirstChild("Toss")
		if t and h and animobject1 and animobject2 then
			if h.Health>0 and equipped and check then
				check=false
				script.Parent.Empty.Value=true
				anim1=h:LoadAnimation(animobject1)
				if anim1 and h and h~=nil and h.Health>0 then
					anim1:Play()
					wait(1.6)
				end
				if equipped then
					anim2=h:LoadAnimation(animobject2)
					if anim2 and h and h~=nil and h.Health>0 then
						anim2:Play()
						wait(1.2)
					end
					if equipped then	
						local handle=sp:FindFirstChild("Handle")
						if handle then
							handle.Parent=game.Workspace
							local firescript=handle:FindFirstChild("FireworksScript")
							if firescript then
								firescript.Disabled=false
								handle.Parent=game.Workspace
								handle:BreakJoints()
								local bg=Instance.new("BodyGyro")
								bg.cframe=CFrame.new(0,0,0)
								bg.maxTorque=Vector3.new(1,0,1)*10000
								bg.Parent=handle
								handle.CanCollide=true
							end
						end
						sp:remove()
					end
				end
			end
		end
	end
end


sp.Equipped:connect(onEquipped)
sp.Unequipped:connect(onUnequipped)
sp.Activated:connect(onActivated)

