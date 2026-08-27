--Stickmasterluke was here last


sp=script.Parent


local debris=game:GetService("Debris")
local creator=sp:WaitForChild("creator")


damage=62
local splatted=false

local flakes = {168187887, 168187896, 168187907, 168187916, 168187923, 168187935}	--Alexnewtron created these splats
local globs = {168187916, 168187923}

local HitSound=Instance.new("Sound")
HitSound.SoundId="http://www.roblox.com/asset/?id=27127113"
HitSound.Parent=sp
HitSound.Volume=1

function Snowface(p)
	local guiMain = Instance.new("GuiMain") 
	guiMain.Parent = p.PlayerGui 
	local mainFrame = Instance.new("Frame") 
	mainFrame.Name = "PaintballEffect"
	mainFrame.Position = UDim2.new(0, 0, 0, 0) 
	mainFrame.Size = UDim2.new(1, 0, 1, 0) 
	mainFrame.BackgroundColor = BrickColor.new(1,1,1)
	mainFrame.Transparency = 1
	mainFrame.BorderColor = BrickColor.new(1,1,1)
	debris:AddItem(guiMain, 10)
	mainFrame.Parent = guiMain

	--- big glob
	local s = Instance.new("ImageLabel")
	local size = (math.random() * .2) + .5
	s.Size = UDim2.new(size,0,size,0)
	s.Position = UDim2.new(math.random() - (size/2),0, math.random() - (size/2),0)
	s.SizeConstraint = Enum.SizeConstraint.RelativeXX
	s.Transparency = 1
	s.Image = "http://www.roblox.com/asset/?id=" .. globs[math.random(1, #globs)]
	debris:AddItem(s, 5 + (math.random() * 2))
	s.Parent = mainFrame

	--flakes
	for i=1,10 do
		local s = Instance.new("ImageLabel")
		local size = (math.random() * .05) + .05
		s.Size = UDim2.new(size,0,size,0)
		s.Position = UDim2.new(math.random() - (size/2),0, math.random() - (size/2),0)
		s.SizeConstraint = Enum.SizeConstraint.RelativeXX
		s.Transparency = 1
		s.Image = "http://www.roblox.com/asset/?id=" .. flakes[math.random(1, #flakes)]
		debris:AddItem(s, 3 + (math.random() * 6))
		s.Parent = mainFrame
	end
	
end


function onTouched(hit)
	if not splatted and hit.Parent and sp and sp:isDescendantOf(game.Workspace) and string.lower(string.sub(hit.Name,1,6))~="effect" and hit.Name~="Handle" then
		local targetplayer=game.Players:GetPlayerFromCharacter(hit.Parent)
		if creator and creator.Value and creator.Value.Character and not hit:isDescendantOf(creator.Value.Character) then
			splatted=true
			sp.Name="Effect"
			HitSound:Play()
			local humanoid=hit.Parent:FindFirstChild("Humanoid")
			if humanoid and targetplayer then
				for _,v in pairs(humanoid:GetChildren()) do
					if v.Name=="creator" then
						v:remove()
					end
				end
				local killertag=creator:clone()
				debris:AddItem(killertag,1)
				killertag.Parent=humanoid
				humanoid:TakeDamage(damage)
				Snowface(targetplayer)
			end
			--[[if part:IsA("Part") then	--color hit part
				overallSize=part.Size.x+hit.Size.y+hit.Size.z
				if overallSize<40 then
					part.BrickColor=sp.BrickColor
				end
			end]]
			sp.CanCollide=false
			sp.Anchored=true
			sp.Transparency=1
			local fire=Instance.new("Fire")
			fire.Heat=0
			fire.Parent=sp
			fire.Color=sp.BrickColor.Color
			fire.SecondaryColor=sp.BrickColor.Color
			fire.Parent=sp
			wait(.3)
			if fire then
				fire.Enabled=false
			end
			wait(2)
			sp:remove()
		end
	end
end


sp.Touched:connect(onTouched)
debris:AddItem(sp,30)

wait(.1)
if sp then
	sp.CanCollide=true	--we do this so that the ball bounces off what it hits, then becomes invisible and the fire particles happen on the side of the surface that was it.
end