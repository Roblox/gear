--Credits: xLEGOx for the first creation of the hammer, Luckymaxer for fixing it, BLOX31 for the ideas and animation, gkku for visual design, sounds, and various fixes
--player
player = nil
--selected
selected = false
homerunning = false 
whacking = false 
--save shoulders
RSH, LSH = nil, nil
anim = "none"
--grip
--welds
--what anim
local TwoHandAnim
local HomeRunner
local Whacker
--create the dustcloud object
local prt = Instance.new("Part")
prt.Size = Vector3.new(7.5,7.5,7.5)
prt.BrickColor = BrickColor.new(217)
prt.Anchored = true
prt.CanCollide = false
prt.Transparency = 1
smoke=Instance.new("Smoke", prt)
smoke.Color = BrickColor.new("Brown").Color
smoke.RiseVelocity = -2
smoke.Size = 4.5
smoke.Opacity = 1
--set variables
hammer = script.Parent.Handle
--[[local msh = Instance.new("SpecialMesh")
msh.MeshId = "http://www.roblox.com/asset/?id=1095708"
msh.MeshType = 5
msh.Parent = prt]]

----- show version ----------
script.Parent.Name = "BanHammer V1.1"
---------------------------------

function GetFigures(Parent, Part)
	for i, v in pairs(Parent:GetChildren()) do 
		GetFigures(v, Part)
		if v.className == "Humanoid" then 
			if v == script.Parent.Parent:findFirstChild("Humanoid") == false then 
				if v.Parent:findFirstChild("Torso") then 
					if v.Parent:findFirstChild("Torso"):IsA("BasePart") then 
						if v.Parent:findFirstChild("Torso").Position.x < Part.Position.x + Part.Size.x / 2 
						and v.Parent:findFirstChild("Torso").Position.x > Part.Position.x - Part.Size.x / 2 
						and v.Parent:findFirstChild("Torso").Position.y < Part.Position.y + Part.Size.y / 2 
						and v.Parent:findFirstChild("Torso").Position.y > Part.Position.y - Part.Size.y / 2 
						and v.Parent:findFirstChild("Torso").Position.z < Part.Position.z + Part.Size.z / 2 
						and v.Parent:findFirstChild("Torso").Position.z > Part.Position.z - Part.Size.z / 2 then 
							v.Sit = true 
						end 
						if (Part.Position - v.Parent:findFirstChild("Torso").Position).magnitude < 10 then 
							v.Sit = true 
						end 
					end 
				end 
			end 
		end 
	end 
end 
function Raycast(Pos, Dir, Max, Ignore)
return game:GetService("Workspace"):FindPartOnRay(Ray.new(Pos, Dir.unit * (Max or 999.999)), Ignore) 
end 
function WaitForChild(obj, ch_n)
	local t = time()
	while not obj:FindFirstChild(ch_n) and time() - t < 10 do wait(0.1) end
	return obj:FindFirstChild(ch_n)
end

--onselected, save shoulders and get player
script.Parent.Equipped:connect(function()
	TwoHandAnim = script.Parent.Parent:findFirstChild("Humanoid"):LoadAnimation(script.Parent.TwoHandAnim)
	HomeRunner = script.Parent.Parent:findFirstChild("Humanoid"):LoadAnimation(script.Parent.HomeRun)
	Whacker = script.Parent.Parent:findFirstChild("Humanoid"):LoadAnimation(script.Parent.Whack)
	repeat wait() until TwoHandAnim ~= nil and HomeRunner ~= nil and Whacker ~= nil 
	if selected then return end
	selected = true
	TwoHandAnim:Play()
end)

--griptcf = CFrame.new(0, -1, 0) * CFrame.fromEulerAnglesXYZ(-math.pi/2+0.5, 0, 0)

script.Parent.Unequipped:connect(function()
	selected = false
	if TwoHandAnim ~= nil then 
		TwoHandAnim:Stop()
	end 
	if HomeRunner ~= nil then 
		HomeRunner:Stop()
	end 
	if Whacker ~= nil then 
		Whacker:Stop()
	end 
end)

function HomeRunHit(part)
	if part == nil then return end 
	if part.Parent == nil then return end 
	local h = (part.Parent or game):FindFirstChild("Humanoid") --or findfirstchild optimization
	if h then
		if h == script.Parent.Parent:findFirstChild("Humanoid") == false then 
			--game.SoundService.Bomb:Play()
	--		hammer.Homerun:Play()
			hrs = Instance.new("StringValue")
			hrs.Name = "HomerunSound"
			hrs.Parent = hammer
			h.Sit = true
			h.Parent.Torso.Velocity = (CFrame.new(hammer.Position, h.Parent.Torso.Position).lookVector * 200) + Vector3.new(0, 100, 0)
			h.Parent.Torso.RotVelocity = Vector3.new(math.random(-100, 100), math.random(-100, 100), math.random(-100, 100))
		end 
	end
end

function HomeRun()
	if homerunning == false then 
		homerunning = true 
		anim = "homerun"
		TwoHandAnim:Stop()
		HomeRunner:Play()
		--start HomeRunhit connection--
		local con = hammer.Touched:connect(HomeRunHit)
		----------------------------------------
		wait(.6)
		HomeRunner:Stop()
		if selected == true then 
			TwoHandAnim:Play()
		end 
		----end HomeRun connection---
		con:disconnect()
	--	wait(0.15)
		homerunning = false 
	end
end 
function Whack()
	if homerunning == false then 
	anim = "norm"
	TwoHandAnim:Stop()
	Whacker:Play()
--	hammer.Whack:Play()
		--insert camshake and hit nearby people
		for _, p in pairs(game.Players:GetChildren()) do
			if p.Character == script.Parent.Parent == false then 
				if p.Character:FindFirstChild("Torso") then
					if (p.Character.Torso.Position - (hammer.CFrame*CFrame.new(0, 3, 0)).p).magnitude < 15 then
						local s = script.Parent._CamShake:clone()
						s.Disabled = false
						s.Parent = p.Backpack
						if p ~= player then
		--					p.Character.Humanoid.Sit = true
		--					delay(0.1, function() p.Character.Humanoid.Jump = true end)
							p.Character.Torso.RotVelocity = Vector3.new(math.random(-10, 10), math.random(-10, 10), math.random(-10, 10))
						end
					end 
				end
			end
		end
		--add dust cloud
		delay(0.25, function()
			if anim == "norm" then 
				if selected == true then 
					whacking = true 
					p=Instance.new("Part")
					p.CanCollide = false 
					p.Transparency = 1
					p.Parent = script.Parent.Parent
					p.formFactor = "Custom"
					p.Size = Vector3.new(0.2, 0.2, 0.2)
					p.Anchored = true
					p.CFrame = hammer.CFrame - Vector3.new(0, script.Parent.Parent:findFirstChild("Torso").Size.y/2, 0) + script.Parent.Parent:findFirstChild("Torso").CFrame.lookVector * ((hammer.Size.y / 2) - p.Size.z)
					p.CFrame = CFrame.new(p.CFrame.p) * CFrame.Angles(math.rad(0),math.rad(0),math.rad(0))
					p.CFrame = p.CFrame * CFrame.fromEulerAnglesXYZ(-math.pi/2, 0,  -math.pi/2)
					Hit, Pos = Raycast(p.Position, p.CFrame.lookVector, 4, script.Parent.Parent)
					if Hit ~= nil then 
						if homerunning == false then 
							delay(0.35, function()
								w = Instance.new("StringValue")
								w.Name = "WhackSound"
								w.Parent = hammer
							end)
							local pt = prt:clone()
							pt.Parent = script.Parent.Parent
							pt.CFrame = CFrame.new(hammer.CFrame.x, Pos.y + 0.75, hammer.CFrame.z) + script.Parent.Parent:findFirstChild("Torso").CFrame.lookVector * 1.75
							GetFigures(pt.Parent.Parent, pt)
							game.Debris:addItem(pt, 1.3)
						end 
					end 
					p:Remove()
				end 
			end 
		end)
		wait(0.75)
		Whacker:Stop()
		whacking = false 
		------
		if selected == true then 
			TwoHandAnim:Play()
		end 
	end 
end 
local a = false
local co = nil
--OMGHAX mouseclick
local last_click = 0
script.Parent.MouseClick.Changed:connect(function()
	if homerunning == false and whacking == false then 
		if time() - last_click < 0.3 then
			anim = "homerun"
			last_click = time()
			HomeRun()
		else
			anim = "norm"
			last_click = time()
			Whack() 
		end 
	end 
end)