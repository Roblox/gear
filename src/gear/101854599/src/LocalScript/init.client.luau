--Stickmasterluke


sp=script.Parent

lit=false
check=true
ready=tick()
debris=game:GetService("Debris")

function waitfor(a,b)
	while a:FindFirstChild(b)==nil do
		a.ChildAdded:wait()
	end
	return a:FindFirstChild(b)
end

local effectpart=waitfor(sp.Handle,"EffectPart")
local sparkles=waitfor(effectpart,"Sparkles")
local waveanimation=waitfor(sp,"WaveAnim")

grid={
{0,9,9,0,0,0,9,9,0,0,0,9,0,0,0,9,9,0},
{9,0,0,9,0,9,0,0,9,0,9,9,0,0,9,0,0,9},
{0,0,9,0,0,9,0,0,9,0,0,9,0,0,0,0,9,0},
{0,9,0,0,0,9,0,0,9,0,0,9,0,0,9,0,0,9},
{9,9,9,9,0,0,9,9,0,0,9,9,9,0,0,9,9,0},
}

function makepart(pos)
	local p=Instance.new("Part")
	p.BrickColor=BrickColor.new("New Yeller")
	p.TopSurface="Smooth"
	p.BottomSurface="Smooth"
	p.FormFactor="Custom"
	p.Name="Effect"
	p.Anchored=true
	p.CanCollide=false
	p.Locked=true
	p.Transparency=.25
	p.Reflectance=.3
	p.Size=Vector3.new(.5,.5,.5)
	p.CFrame=CFrame.new(pos)*CFrame.Angles(math.random()*6,math.random()*6,math.random()*6)
	local s=script.Script:clone()
	s.Parent=p
	s.Disabled=false
	debris:AddItem(p,10)
	p.Parent=game.Workspace
end

function drawgrid()
	local t=sp.Parent:FindFirstChild("Torso")
	if t~=nil then
		for y=1,#grid do
			for x=1,#grid[y] do
				if grid[y][x]==9 then
					local pos=(t.CFrame*CFrame.new(-9+x,5+(5-y),-5)).p
					makepart(pos)
				end
			end
		end
	end
end

function onEquipped(mouse)
	if mouse~=nil then
		mouse.Icon="rbxasset://textures\\ArrowCursor.png"
		sparkles.Enabled=false
		mouse.Button1Down:connect(function()
			if mouse~=nil then
				mouse.Icon="rbxasset://textures\\ArrowFarCursor.png"
				if not sparkles.Enabled then
					local lightsound=sp.Handle:FindFirstChild("LightSound")
					if lightsound~=nil then
						lightsound:Play()
					end
					local burnsound=sp.Handle:FindFirstChild("BurnSound")
					if burnsound~=nil then
						burnsound:Play()
					end
					sparkles.Enabled=true
					lit=true
					while lit do
						if check then
							makepart(effectpart.Position)
						end
						wait(.2)
					end
				else
					local h=sp.Parent:FindFirstChild("Humanoid")
					if h~=nil and h.Health>0 then
						waveAnim=h:LoadAnimation(waveanimation)
						if waveAnim then
							waveAnim:Play(nil,nil,2)
							if ready<tick() then
								check=false
								ready=tick()+6
								drawgrid()
								wait(7)
								check=true
							end
						end
					end
				end
			end
		end)
	end
end

function onUnequipped()
	sparkles.Enabled=false
	if waveAnim then
		waveAnim:Stop()
	end
	local burnsound=sp.Handle:FindFirstChild("BurnSound")
	if burnsound~=nil then
		burnsound:Stop()
	end
	lit=false
end

sparkles.Enabled=false

sp.Unequipped:connect(onUnequipped)
sp.Equipped:connect(onEquipped)
