--Made by Stickmasterluke
--[[
	Fixed by ArceusInator
	1/22/2015 - Moved the code to server-side to make it FE-compatible.  Remade the Energy Bomb tool to make it FE-compatible.
--]]


sp=script.Parent


check=true
local debris=game:GetService("Debris")
local is=game:GetService("InsertService")

hair=99030674
local pale=BrickColor.new("Pastel yellow")
local clothes=BrickColor.new("Black")

function waitfor(a,b)
	while a:FindFirstChild(b)==nil do
		a.ChildAdded:wait()
	end
	return a:FindFirstChild(b)
end

sp.Handle.Transparency=.3

function clicked()
	local plr=game.Players:GetPlayerFromCharacter(sp.Parent)
	if plr~=nil and check then
		local chr=plr.Character
		if chr~=nil and check then
			check=false
			for _,v in pairs(chr:GetChildren()) do
				if v.className=="Hat" or v.className=="Accoutrement" then
					local hhandle=v:FindFirstChild("Handle")
					if hhandle~=nil then
						hhandle:BreakJoints()
						hhandle.CanCollide=false
						hhandle.Velocity=hhandle.Velocity+(Vector3.new(math.random()-.5,math.random()-.5,math.random()-.5)*20)+Vector3.new(0,60,0)
						hhandle.RotVelocity=hhandle.RotVelocity+(Vector3.new(math.random()-.5,math.random()-.5,math.random()-.5)*20)
						hhandle.Parent=game.Workspace
					end
					v:remove()
				end
			end
			is:LoadAsset(hair):GetChildren()[1].Parent=chr
			--game.Lighting.SuperHair:clone().Parent=chr
			local torso=chr:FindFirstChild("Torso")
			if torso~=nil then
				if torso:FindFirstChild("SuperSoundScript")==nil then
					local vss=sp.SuperSoundScript:clone()
					vss.Parent=torso
					vss.Disabled=false
				end
			end
			wait(1)
			breakable=sp.Handle:clone()
			local torso=chr:FindFirstChild("Torso")
			if torso~=nil then
				local rightshoulder=torso:FindFirstChild("Right Shoulder")
				if rightshoulder then
					rightshoulder.CurrentAngle=math.pi
				end
				breakable=sp.Handle:clone()
			end
			breakable.CanCollide=false
			breakable.CFrame=CFrame.new(breakable.Position)
			local bf=Instance.new("BodyForce")
			bf.force=Vector3.new(0,((breakable:GetMass()+(.2*.2*.2))*196.2)+5,0)
			bf.Parent=breakable
			breakable.RotVelocity=Vector3.new(0,20,0)
			breakable.Name="Effect"
			debris:AddItem(breakable,6)
			breakable.Parent=game.Workspace
			local mh=sp:FindFirstChild("Handle")
			if mh~=nil then
				mh:remove()
			end
			local tool = require(242620010):Clone()
			tool.Parent = plr.Backpack
			chr.Humanoid:EquipTool(tool)
			--game.StarterPack["Energy Bomb"]:clone().Parent=chr
			sp:remove()
		end
	end
end

sp.Activated:connect(clicked)

