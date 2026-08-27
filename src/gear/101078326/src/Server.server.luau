--Rescripted by TakeoHonorable

local Tool = script.Parent

Tool.Enabled = true

local Handle = Tool:WaitForChild("Handle")

local FirePoint = Handle:WaitForChild("Tip")

local MouseLoc = Tool:WaitForChild("MouseLoc")

local Properties = {
	Damage = 5,
	Range = 300,
	Power = 300,
	MouseDown = false,
	FireTime = 0,
	FireRate = 1/30,
	SpinupTime = 2,
	Rate = 1/30,
	Windvec=Vector3.new(2,-1,1).unit
}

local Services = {
	Debris = (game:FindService("Debris") or game:GetService("Debris")),
	RunService = (game:FindService("RunService") or game:GetService("RunService")),
	Players = (game:FindService("Players") or game:GetService("Players"))
}

local Sounds = {
	Fire = Handle:WaitForChild("Fire")
}

local MyPlayer,MyHumanoid,MyCharacter

function checkintangible(hit)
	if hit then
		if hit:IsDescendantOf(MyCharacter) or hit.Transparency>.8 or hit.Name=="Handle" or hit.Name=="Effect" or hit.Name=="Bullet" or hit.Name=="Laser" or string.lower(hit.Name)=="water" or hit.Name=="Rail" or hit.Name=="Arrow" then
			return true
		end
	end
	return false
end

function IsTeamMate(Player1, Player2)
	return (Player1 and Player2 and not Player1.Neutral and not Player2.Neutral and Player1.TeamColor == Player2.TeamColor)
end

function TagHumanoid(humanoid, player)
	local Creator_Tag = Instance.new("ObjectValue")
	Creator_Tag.Name = "creator";
	Creator_Tag.Value = player;
	Services.Debris:AddItem(Creator_Tag, 2)
	Creator_Tag.Parent = humanoid
end
	
function UntagHumanoid(humanoid)
	for _, v in pairs(humanoid:GetChildren()) do
		if v:IsA("ObjectValue") and v.Name == "creator" then
			v:Destroy()
		end
	end
end

function castray(startpos,vec,length,ignore,delayifhit)
	local hit,endpos2=workspace:FindPartOnRay(Ray.new(startpos,vec*length),ignore)
	if hit then
		if checkintangible(hit) then
			if delayifhit then
				wait()
			end
			hit,endpos2=castray(endpos2+(vec*.01),vec,length-((startpos-endpos2).magnitude),ignore,delayifhit)
		end
	end
	return hit,endpos2
end

function drawbeam(beamstart,beamend,clr,fadedelay)
	local dist=(beamstart-beamend).magnitude
	local laser=Instance.new("Part")
	laser.Name="Effect"
	laser.Anchored=true
	laser.CanCollide=false
	laser.Shape="Block"
	laser.formFactor="Custom"
	laser.Size=Vector3.new(.2,.2,.2)
	laser.Transparency=5
	laser.Material=Enum.Material.Plastic
	laser.Locked=true
	laser.TopSurface=0
	laser.BottomSurface=0
	laser.BrickColor=clr
	laser.CFrame=CFrame.new(beamend,beamstart)*CFrame.new(0,0,-dist/2)*CFrame.Angles(math.pi/2,0,0)
	local m=Instance.new("SpecialMesh")
	m.Scale=Vector3.new(1,dist*5,1)
	m.Parent=laser
	Services.Debris:AddItem(laser,fadedelay*3)
	laser.Parent=game.Workspace

	local frames=math.floor(fadedelay/Properties.Rate)
	for frame=1,frames do
		wait(Properties.Rate)
		local percent=frame/frames
		laser.CFrame=laser.CFrame+Properties.Windvec*Properties.Rate
		laser.Transparency=.5+(percent*.5)
	end
	wait(1)
	laser:Destroy()
end

function Fire()
	if not MyHumanoid or MyHumanoid.Health <= 0 then return end
	local Point = MouseLoc:InvokeClient(MyPlayer)
	
	if not Point or typeof(Point) ~= "Vector3" then
		Point = MyHumanoid.TargetPoint --Probably an NPC
	end
	
	local UnitDirection = (Point-FirePoint.WorldPosition).unit
	
	local p=Instance.new("Part")
		p.Name="Effect"
		p.BrickColor=BrickColor.new("Black")
		p.CanCollide=false
		p.TopSurface="Smooth"
		p.BottomSurface="Smooth"
		p.Size=Vector3.new(.25,2,.25)
		p.BrickColor=BrickColor.new("Bright red")
		local m=Instance.new("SpecialMesh")
		m.Parent=p
		local decal=Instance.new("Decal")
		decal.Texture="http://www.roblox.com/asset/?id=4516761"
		decal.Face="Front"
		decal.Parent=p
		local decal=Instance.new("Decal")
		decal.Texture="http://www.roblox.com/asset/?id=4516761"
		decal.Face="Back"
		decal.Parent=p
		local decal=Instance.new("Decal")
		decal.Texture="http://www.roblox.com/asset/?id=4516761"
		decal.Face="Left"
		decal.Parent=p
		local decal=Instance.new("Decal")
		decal.Texture="http://www.roblox.com/asset/?id=4516761"
		decal.Face="Right"
		decal.Parent=p

		local hit,endpos = castray(FirePoint.WorldPosition,UnitDirection,Properties.Range,MyCharacter,false)
		local fakevec=(endpos-FirePoint.WorldPosition).unit
		
		if hit then
			local newcf=CFrame.new(endpos,endpos+fakevec)*CFrame.Angles(math.pi/2,0,0)*CFrame.new(0,0,0)
			p.CFrame=newcf
			local w=Instance.new("Weld")
			w.Part0=hit
			w.Part1=p
			w.C0=hit.CFrame:inverse()*newcf
			w.C1=newcf:inverse()*newcf
			w.Parent=p

			local Hum = hit.Parent:FindFirstChildOfClass("Humanoid")
			if Hum and Hum ~= MyHumanoid then
				if not IsTeamMate(MyPlayer,Services.Players:GetPlayerFromCharacter(Hum.Parent)) then
					UntagHumanoid(Hum)
					TagHumanoid(Hum,MyPlayer)
					Hum:TakeDamage(Properties.Damage)
				end
			end

		else
			p.CFrame=CFrame.new(endpos,endpos+fakevec)
			p.Velocity=fakevec*Properties.Power
			p.Parent=workspace
		end

		Services.Debris:AddItem(p,2.5+math.random())
		p.Parent = workspace

		delay(0,function()
			drawbeam(FirePoint.WorldPosition,endpos,BrickColor.new("Institutional white"),.1)
		end)

		Sounds.Fire:Play()
end

function Equipped()
	MyCharacter = Tool.Parent
	MyPlayer = Services.Players:GetPlayerFromCharacter(MyCharacter)
	MyHumanoid = MyCharacter:FindFirstChildOfClass("Humanoid")
	
end

function Unequipped()
	Properties.MouseDown = false
end

function Activated()
	if Properties.MouseDown or not Tool.Enabled then return end
	Properties.MouseDown = true
	Tool.Enabled = false
	Properties.FireTime = tick() + Properties.SpinupTime
	repeat
		if tick() > Properties.FireTime then
			Fire()
			wait(Properties.FireRate)
		else
			Sounds.Fire:Play()
			wait(Properties.FireRate+((Properties.FireTime-tick())*.4))
		end
	until not Properties.MouseDown
	wait(1)
	Tool.Enabled = true
end

function Deactivated()
	if not Properties.MouseDown or Tool.Enabled then return end
	Properties.MouseDown = false
end


Tool.Equipped:Connect(Equipped)
Tool.Unequipped:Connect(Unequipped)
Tool.Activated:Connect(Activated)
Tool.Deactivated:Connect(Deactivated)	
	