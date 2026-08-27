--Made by Stickmasterluke
--Fixed by TakeoHonorable

local MyPlayer,MyCharacter,MyHumanoid

local sp=script.Parent

local firerate=7
local power=50
local floats=true
local rate=1/30

local debris=game:GetService("Debris")
local Players = game:GetService("Players")

local handle = sp:WaitForChild("Handle")

local Remote = sp:WaitForChild("MouseLoc")

function onEquipped(mouse)
	MyCharacter = sp.Parent
	MyHumanoid = MyCharacter:FindFirstChildOfClass("Humanoid")
	MyPlayer = Players:GetPlayerFromCharacter(MyCharacter)
end

function onActivated()
		print("Active")
	if sp.Enabled and MyHumanoid and MyHumanoid.Health>0 then

		local MouseLoc = Remote:InvokeClient(MyPlayer)
			
		if typeof(MouseLoc) ~= "Vector3" then return end -- no exploits
		
		sp.Enabled = false
		
		local sound=sp.Handle:FindFirstChildOfClass("Sound")
		if sound then
			sound:Play()
		end
		
		local p=Instance.new("Part")
		p.Name="Effect"
		p.BrickColor=BrickColor.new("Medium stone grey")
		p.CanCollide=false
		p.TopSurface="Smooth"
		p.BottomSurface="Smooth"
		p.Shape="Ball"
		p.formFactor="Symmetric"
		p.Size=Vector3.new(1,1,1)
		local vec=(MouseLoc-handle.Position).unit
		p.CFrame=CFrame.new(handle.Position,handle.Position+vec)*CFrame.new(0,0,-2)
		p.Velocity=(vec*power)+Vector3.new(0,power*.15,0)

		local m=Instance.new("SpecialMesh")
		m.MeshId="http://www.roblox.com/asset/?id=88545836"
		m.TextureId="http://www.roblox.com/asset/?id=88545941"
		m.Scale=Vector3.new(2.5,2.5,2.5)
		m.Parent=p

		local f = Instance.new("Fire")
		f.Color = Color3.new(1,1,1)
		f.SecondaryColor = Color3.new(0,0,0)
		f.Heat = 2
		f.Size = 3
		f.Parent = p

		local c = Instance.new("ObjectValue")
		c.Name = "creator"
		c.Value = MyPlayer
		c.Parent = p

		local s=script.Script:Clone()
		s.Parent=p
		s.Disabled=false

		if floats then
			local bf = Instance.new("BodyForce")
			bf.Force = Vector3.new(0,196.2*p:GetMass(),0)
			bf.Parent = p
			p.Velocity = (vec*power)
		end
			
		debris:AddItem(p,30)
		p.Parent = workspace
		wait(firerate)
		sp.Enabled = true
	end
end

function onUnequipped()
	MyCharacter,MyHumanoid,MyPlayer = nil,nil,nil
end

sp.Activated:Connect(onActivated)
sp.Equipped:Connect(onEquipped)
sp.Unequipped:Connect(onUnequipped)





