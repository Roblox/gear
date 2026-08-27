--Stickmasterluke


sp=script.Parent


local debris=game:GetService("Debris")
equipped=false

function waitfor(parent,name)
	while parent:FindFirstChild(name)==nil do
		parent.ChildAdded:wait()
	end
	return parent:FindFirstChild(name)
end

local animobject1=waitfor(sp,"ButtonPress")
local animobject2=waitfor(sp,"Toss")


function onEquipped(mouse)
	equipped=true
	if mouse~=nil then 
		mouse.Button1Down:connect(function()
			local chr=sp.Parent
			if chr and sp.Enabled then
				local t=chr:FindFirstChild("Torso")
				local h=chr:FindFirstChild("Humanoid")
				if t and h and equipped then
					local anim1=h:LoadAnimation(animobject1)
					local anim2=h:LoadAnimation(animobject2)
					if h.Health>0 then
						sp.Enabled=false
						if anim1 and h and h~=nil and h.Health>0 and equipped then
							anim1:Play()
							wait(1.6)
							if equipped then
								sp.Handle.PuzzleSound:Play()
								wait(1.1)
								sp.Handle.PuzzleSound:Stop()
							end
						end
						if anim2 and h and h~=nil and h.Health>0 and equipped then
							anim2:Play()
							wait(1.2)
						end
						if equipped then
							local p=sp.Handle:clone()
							p.CanCollide=true
							p.Name="PuzzleBox"
							p.Anchored=false
							p.Velocity=(t.CFrame.lookVector*20)+Vector3.new(0,20,0)
							local s=sp.Script:clone()
							s.Parent=p
							s.Disabled=false
							debris:AddItem(p,60)
							local ct=Instance.new("ObjectValue")
							ct.Name="creator"
							ct.Value=game.Players.LocalPlayer
							ct.Parent=p
							p.Parent=game.Workspace
							local sound=p:FindFirstChild("ThrowSound")
							if sound then
								sound:Play()
							end
							sp:remove()
						end
					end
				end
			end
		end)
	end
end

function onUnequipped()
	equipped=false
end

sp.Equipped:connect(onEquipped)
sp.Unequipped:connect(onUnequipped)

