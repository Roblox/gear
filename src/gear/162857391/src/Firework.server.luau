--Stickmasterluke


sp=script.Parent


local debris=game:GetService("Debris")
equipped=false
check=true

function seticon(icon)
	script.Parent.SetMouseIcon:FireAllClients(icon)
end

function onEquipped()
	equipped=true
	if check then
		seticon"rbxasset://textures\\ArrowCursor.png"
	else
		seticon"rbxasset://textures\\ArrowFarCursor.png"
	end
end

function onActivated()
	local chr=sp.Parent
	if chr and check then
		local t=chr:FindFirstChild("Torso")
		local h=chr:FindFirstChild("Humanoid")
		local animobject2=sp:FindFirstChild("Toss")
		if t and h and animobject2 then
			if h.Health>0 and equipped and check then
				check=false
				seticon"rbxasset://textures\\ArrowFarCursor.png"
				if equipped then
					anim2=h:LoadAnimation(animobject2)
					if anim2 and h and h~=nil and h.Health>0 then
						anim2:Play()
						wait(1.2)
					end
					if equipped then	
						p=sp.Handle:clone()
						p.CanCollide=true
						p.Transparency=0
						p.Name="Timebomb"
						p.Anchored=false
						p.Velocity=p.Velocity+(t.CFrame.lookVector*20)+Vector3.new(0,20,0)
						local tag=Instance.new("ObjectValue")
						tag.Name="creator"
						tag.Value=game.Players.LocalPlayer
						tag.Parent=p
						local s=sp.Script:clone()
						s.Parent=p
						s.Disabled=false
						debris:AddItem(p,20)
						p.Parent=game.Workspace
						sp.Handle.Transparency=1
					end
				end
				wait(5)
				sp.Handle.Transparency=0
				seticon"rbxasset://textures\\ArrowCursor.png"
				check=true
			end
		end
	end
end

function onUnequipped()
	equipped=false
end


sp.Equipped:connect(onEquipped)
sp.Unequipped:connect(onUnequipped)
sp.Activated:connect(onActivated)

