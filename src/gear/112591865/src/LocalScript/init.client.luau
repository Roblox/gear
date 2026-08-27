--Made by Stickmasterluke


sp=script.Parent


cooldown=20
StandTime=60*2
floatieness=.618

debris=game:GetService("Debris")
check=true

function waitfor(parent,name)
	while parent:FindFirstChild(name)==nil do
		wait()
	end
	return parent:FindFirstChild(name)
end

lastuse=sp:WaitForChild("LastUse")
handle=sp:WaitForChild("Handle")
handlemesh=handle:WaitForChild("Mesh")

function onEquipped(mouse)
	equipped=true
	local plr=game.Players.LocalPlayer
	if mouse~=nil and plr~=nil then
		if tick()-cooldown<lastuse.Value then
			mouse.Icon="rbxasset://textures\\GunWaitCursor.png"
			sp.Handle.Transparency=1
			wait(lastuse.Value-(tick()-cooldown))
			mouse.Icon="rbxasset://textures\\GunCursor.png"
			sp.Handle.Transparency=0
		else
			mouse.Icon="rbxasset://textures\\GunCursor.png"
			sp.Handle.Transparency=0
		end
		mouse.Button1Down:connect(function()
			if tick()-cooldown>lastuse.Value and mouse.Target and mouse.Target~=nil and mouse.Hit then
				local chr=sp.Parent
				if chr and check then
					local h=chr:FindFirstChild("Humanoid")
					if h and h.Health>0 then
						check=false
						lastuse.Value=tick()
						mouse.Icon="rbxasset://textures\\GunWaitCursor.png"
						sp.Handle.Transparency=1

						local ball=handle:clone()
						ball.Name="Beach Ball"
						ball.Friction=.1
						ball.Elasticity=1
						ball.Transparency=0
						ball.TopSurface="Smooth"
						ball.BottomSurface="Smooth"
						ball.Size=Vector3.new(3,3,3)
						ball.CFrame=handle.CFrame--*CFrame.new(0,0,-3)+Vector3.new(0,-1,0)
						ball.CanCollide=true
						ball.Velocity=Vector3.new(0,0,0)
						ball.RotVelocity=Vector3.new(0,0,0)
						ball:WaitForChild("Mesh").Scale=Vector3.new(3,3,3)

						local CreatorTag=Instance.new("ObjectValue")
						CreatorTag.Value=game.Players.LocalPlayer
						CreatorTag.Name="creator"
						CreatorTag.Parent=ball
						
						local bf=Instance.new("BodyForce")
						bf.force=Vector3.new(0,(ball:GetMass()*196.2)*floatieness,0)
						bf.Parent=ball

						local CloneScript=script.Script:clone()
						CloneScript.Parent=ball
						CloneScript.Disabled=false

						debris:AddItem(ball,StandTime)
						ball.Parent=game.Workspace

						wait(cooldown)
						sp.Handle.Transparency=0
						mouse.Icon="rbxasset://textures\\GunCursor.png"
						check=true
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


