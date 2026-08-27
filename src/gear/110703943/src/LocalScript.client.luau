--Made by Stickmasterluke


sp=script.Parent


cooldown=10
StandTime=60*2

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

						local stool=Instance.new("Seat")
						stool.Name="Stool"
						stool.Friction=1
						stool.Elasticity=0
						stool.Transparency=0
						stool.TopSurface="Smooth"
						stool.BottomSurface="Smooth"
						stool.Material="Wood"
						stool.FormFactor="Custom"
						stool.Size=handle.Size+Vector3.new(.4,0,.4)
						stool.CFrame=handle.CFrame*CFrame.new(0,0,-3)+Vector3.new(0,-1,0)
						stool.CanCollide=true
						stool.Velocity=Vector3.new(0,0,0)
						stool.RotVelocity=Vector3.new(0,0,0)
						handlemesh:clone().Parent=stool

						local gyro=Instance.new("BodyGyro")		--this will keep the thing standing upright.
						debris:AddItem(gyro,3)
						gyro.Parent=stool

						local CreatorTag=Instance.new("ObjectValue")
						CreatorTag.Value=game.Players.LocalPlayer
						CreatorTag.Name="creator"
						CreatorTag.Parent=stool

						--[[local CloneScript=script.Script:clone()
						CloneScript.Parent=stool
						CloneScript.Disabled=false]]

						debris:AddItem(stool,StandTime)
						stool.Parent=game.Workspace

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


