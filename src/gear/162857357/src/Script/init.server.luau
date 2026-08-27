--Rescripted by Luckymaxer
--[[alexnewtron 2014]]--

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")
Mesh = Handle:WaitForChild("Mesh")

Players = game:GetService("Players")
Debris = game:GetService("Debris")

Tween = script:WaitForChild("Tween")
Tween = require(Tween)

Easing = script:WaitForChild("Easing")
Easing = require(Easing)

Animations = {
	PlantAnim = {Animation = Tool:WaitForChild("PlantAnim"), FadeTime = nil, Weight = nil, Speed = 0.5, Duration = nil}
}

Sounds = {
	PlaceUmbrella = Handle:WaitForChild("PlaceUmbrella")
}

ReloadTime = 25

StandTime = (60 * 2)

ClientControl = (Tool:FindFirstChild("ClientControl") or Instance.new("RemoteFunction"))
ClientControl.Name = "ClientControl"
ClientControl.Parent = Tool

ServerControl = (Tool:FindFirstChild("ServerControl") or Instance.new("RemoteFunction"))
ServerControl.Name = "ServerControl"
ServerControl.Parent = Tool

Handle.Transparency = 0
Tool.Enabled = true

function InvokeClient(Mode, Value)
	local ClientReturn = nil
	pcall(function()
		ClientReturn = ClientControl:InvokeClient(Player, Mode, Value)
	end)
	return ClientReturn
end

function CheckIntangible(hit)
	if hit and hit~=nil then
		if hit:IsDescendantOf(Character) or hit.Transparency>.8 or hit.Name=="Handle" or string.lower(string.sub(hit.Name,1,6))=="effect" or hit.Name=="Bullet" or hit.Name=="Laser" or string.lower(hit.Name)=="water" or hit.Name=="Rail" or hit.Name=="Arrow" then
			return true
		end
	end
	return false
end

function CastRay(startpos,vec,length,ignore)
	local hit,endpos2=game.Workspace:FindPartOnRayWithIgnoreList(Ray.new(startpos,vec*length),ignore)
	if hit~=nil then
		if CheckIntangible(hit) then
			hit,endpos2=CastRay(endpos2+(vec*.01),vec,length-((startpos-endpos2).magnitude),ignore)
		end
	end
	return hit,endpos2
end

function Activated()
	if not CheckIfAlive() or not Tool.Enabled then
		return
	end
	Tool.Enabled = false
	local CurrentlyEquipped = true
	if ToolUnequipped then
		ToolUnequipped:disconnect()
	end
	ToolUnequipped = Tool.Unequipped:connect(function()
		CurrentlyEquipped = false
	end)
	local MousePosition = InvokeClient("MousePosition")
	local IgnoreTable = {}
	for i, v in pairs(Players:GetChildren()) do
		if v:IsA("Player") and v.Character then
			table.insert(IgnoreTable, v.Character)
		end
	end
	local RayHit, RayPos = CastRay(Torso.Position, (Vector3.new(0, -0.5, 0) + (MousePosition - Torso.Position).unit).unit, 15, IgnoreTable)
	if RayHit then
		InvokeClient("PlayAnimation", Animations.PlantAnim)
		local Umbrella = Handle:clone()
		Umbrella.Name = "Beach Umbrella"
		Umbrella.Transparency = 1
		Umbrella.Size = Vector3.new(1, 10, 1)
		Umbrella.CanCollide = true
		Umbrella.Velocity = Vector3.new(0,0,0)
		Umbrella.RotVelocity = Vector3.new(0,0,0)
		Umbrella:WaitForChild("Mesh").Scale = Vector3.new(3, 4, 3)
		Umbrella.CFrame = CFrame.new(RayPos + Vector3.new(0, 5, 0)) * CFrame.Angles(0, (math.pi * 2 * math.random()), 0)
		local w = Instance.new("Weld")
		w.Part0 = RayHit
		w.Part1 = Umbrella
		w.C1 = Umbrella.CFrame:toObjectSpace(RayHit.CFrame)
		w.Parent = Umbrella
	
		local CreatorTag = Instance.new("ObjectValue")
		CreatorTag.Value = Player
		CreatorTag.Name = "creator"
		CreatorTag.Parent = Umbrella
	
		Debris:AddItem(Umbrella, StandTime)
		Umbrella.Parent = game:GetService("Workspace")

		Delay(1, function()
			if not CurrentlyEquipped then
				return
			end
			if Handle then
				Handle.Transparency = 1
			end
			if Umbrella then
				Umbrella.Transparency = 0
				Delay(3, function()
					if not CurrentlyEquipped then
						return
					end
					if Umbrella then
						Sounds.PlaceUmbrella:Play()
						local lounge = Instance.new("Seat")
						lounge.Friction = 1
						lounge.Elasticity = 0
						lounge.TopSurface = Enum.SurfaceType.Smooth
						lounge.BottomSurface = Enum.SurfaceType.Smooth
						lounge.FormFactor = Enum.FormFactor.Custom
						local m = Instance.new("SpecialMesh")
						m.MeshId = "http://www.roblox.com/asset/?id=162383507"
						m.TextureId = "http://www.roblox.com/asset/?id=162383599"
						m.Scale = Vector3.new(1.6,0.05,1.6)
						m.Parent = lounge
						lounge.Size = Vector3.new(3, 1, 5)
						lounge.CFrame = Umbrella.CFrame * CFrame.new(3, -2, 3) * CFrame.Angles(0, 0.4, 0)
						local bg = Instance.new("BodyGyro")
						Debris:AddItem(bg, 3)
						bg.Parent = lounge
						Debris:AddItem(lounge, StandTime)
						lounge.Parent = game:GetService("Workspace")
						local a=Tween("forward")a.add(1,{x=0.05},Easing.inOutQuad)a.add(1,{x=1.6},Easing.inOutBack)for x=1,200 do local b=a.getCurrentProperties()m.Scale=Vector3.new(1.6,b.x,1.6)a.update(0.025)wait(0.025)if b.x>=1.6 then break end end
						local c = Instance.new("Part")
						c.TopSurface=Enum.SurfaceType.Smooth
						c.BottomSurface=Enum.SurfaceType.Smooth
						c.FormFactor=Enum.FormFactor.Custom
						c.CanCollide = false
						c.Size = Vector3.new(4.25,1.59,7.72)
						c.Anchored = true							
						local cm = Instance.new("SpecialMesh")
						cm.MeshId = "http://www.roblox.com/asset/?id=162383569"
						cm.TextureId = "http://www.roblox.com/asset/?id=162383633"
						cm.Scale = Vector3.new(1, 0.05, 1)
						cm.Parent = c
						c.CFrame = Umbrella.CFrame * CFrame.new(-4, -4.1, 4) * CFrame.Angles(0, -0.4, 0)
						Debris:AddItem(c, StandTime)
						c.Parent=game:GetService("Workspace")
						local a=Tween("forward")a.add(1,{x=0.05},Easing.inOutQuad)a.add(1,{x=1},Easing.inOutBack)for x=1,200 do local b=a.getCurrentProperties()cm.Scale=Vector3.new(1,b.x,1)a.update(0.025)wait(0.025)if b.x>=1 then break end end
					end
				end)
			end
		end)
	end
	wait(ReloadTime)
	Handle.Transparency = 0
	Tool.Enabled = true
end

function CheckIfAlive()
	return (Player and Player.Parent and Character and Character.Parent and Humanoid and Humanoid.Parent and Humanoid.Health > 0 and Torso and Torso.Parent)
end

function Equipped()
	Character = Tool.Parent
	Player = Players:GetPlayerFromCharacter(Character)
	Humanoid = Character:FindFirstChild("Humanoid")
	Torso = Character:FindFirstChild("Torso")
	if not CheckIfAlive() then
		return
	end
	if ToolUnequipped then
		ToolUnequipped:disconnect()
	end
end

function Unequipped()
	for i, v in pairs(Animations) do
		InvokeClient("StopAnimation", v)
	end
	if ToolUnequipped then
		ToolUnequipped:disconnect()
	end
	Handle.Transparency = 0
end

Tool.Activated:connect(Activated)
Tool.Equipped:connect(Equipped)
Tool.Unequipped:connect(Unequipped)

