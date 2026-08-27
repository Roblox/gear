--Made by Stickmasterluke


sp=script.Parent

check=true

debris=game:GetService("Debris")
cooldown=.2

function findsquirrel()
	for _,v in pairs(game.Workspace:GetChildren()) do
		if v.Name=="Squirrel" then
			local creatortag=v:FindFirstChild("creator")
			if creatortag and creatortag.Value==game.Players.LocalPlayer then
				sp.Handle.Transparency=1
				return v
			end
		end
	end
end

function onEquipped(mouse)
	equipped=true
	local plr=game.Players.LocalPlayer
	if mouse~=nil and plr~=nil then
		findsquirrel()
		mouse.Icon="rbxasset://textures\\GunCursor.png"
		mouse.Button1Down:connect(function()
			local chr=sp.Parent
			if chr and check then
				local t=chr:FindFirstChild("Torso")
				local h=chr:FindFirstChild("Humanoid")
				if t and h and h.Health>0 then
					check=false
					mouse.Icon="rbxasset://textures\\GunWaitCursor.png"
					local squirrel=findsquirrel()
					if squirrel==nil then
						local m=Instance.new("Model")
						m.Name="Squirrel"
						local p=sp.Handle:clone()
						p.Friction=.2
						p.Name="Torso"
						p.Transparency=0
						p.CanCollide=true
						p.CFrame=CFrame.new()
						local rd=Vector3.new((math.random()-.5)*15,(math.random()-.5)*5,(math.random()-.5)*15)
						p.Position=sp.Handle.Position+rd
						p.Velocity=rd
						p.Parent=m
						local he=Instance.new("Part")
						he.Name="Head"
						he.formFactor="Custom"
						he.Transparency=1
						he.Size=Vector3.new(0,0,0)
						he.Parent=m
						local w=Instance.new("Weld")
						w.Name="Neck"
						w.Part0=p
						w.Part1=he
						w.Parent=p
						local h=Instance.new("Humanoid")
						h.MaxHealth=100
						h.Health=100
						h.WalkSpeed=18
						h.Parent=m
						local orders=Instance.new("StringValue")
						orders.Name="Orders"
						orders.Value="Follow"
						orders.Parent=m
						local target=Instance.new("ObjectValue")
						target.Name="Target"
						target.Parent=m
						local targetpos=Instance.new("Vector3Value")
						targetpos.Name="TargetPos"
						targetpos.Parent=m
						local ct=Instance.new("ObjectValue")
						ct.Value=game.Players.LocalPlayer
						ct.Name="creator"
						ct.Parent=m
						local s=script.Script:clone()
						s.Parent=m
						s.Disabled=false
						debris:AddItem(m,5*60)
						m.Parent=game.Workspace
						p.Position=sp.Handle.Position+rd
						sp.Handle.Transparency=1
					elseif mouse.Target~=nil then
						local th=mouse.Target.Parent:FindFirstChild("Humanoid") or mouse.Target.Parent.Parent:FindFirstChild("Humanoid")
						--print(th,th.Parent:FindFirstChild("Torso"))
						if th and th.Parent:FindFirstChild("Torso") then
							squirrel.Target.Value=th.Parent
							squirrel.Orders.Value="Attack"
						else
							squirrel.Target.Value=mouse.Target
							squirrel.TargetPos.Value=mouse.Hit.p
							squirrel.Orders.Value="MoveTo"
						end
					end
					wait(cooldown)
					mouse.Icon="rbxasset://textures\\GunCursor.png"
					check=true
				end
			end
		end)
	end
end

function onUnequipped()
	equipped=false
	sp.Handle.Transparency=0
end

sp.Equipped:connect(onEquipped)
sp.Unequipped:connect(onUnequipped)

