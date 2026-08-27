--Made by Stickmasterluke


local sp=script.Parent


wait(2)


local timer=60*3
local healamount=100

local floatradius=1
local floatcycletime=5
local floatpoint=sp.Position+Vector3.new(0,3,0)
local debris=game:GetService("Debris")


local bb=Instance.new("BillboardGui")
bb.Parent=sp
bb.Size=UDim2.new(5.1,0,5.7,0)
bb.StudsOffset=Vector3.new(0,4.2,0)
local il=Instance.new("ImageLabel")
il.BackgroundTransparency=1
il.Image="http://www.roblox.com/Asset?ID=161265144"
il.Size=UDim2.new(1,0,1,0)
il.Parent=bb
bb.Adornee=sp

delay(6,function()
	bb:remove()
end)


local bp=Instance.new("BodyPosition")
bp.maxForce=Vector3.new(1,1,1)*100000
bp.position=floatpoint
bp.Parent=sp

sp.Touched:connect(function(hit)
	if hit and hit.Parent and not pickedup then
		local h=hit.Parent:FindFirstChild("Humanoid")
		if h then
			pickedup=true
			local healscript=script:FindFirstChild("HealScript")
			if healscript then
				healscript.Parent=h
				healscript.Disabled=false
				--[[local t=hit.Parent:FindFirstChild("Torso")
				if t then
					local s=Instance.new("Sparkles")
					debris:AddItem(s,3)
					s.Parent=t
					local s=Instance.new("Sparkles")
					debris:AddItem(s,3)
					s.Parent=sp
				end]]
			end
		end
	end
end)

local starttime=tick()
while bp and sp and sp.Parent==game.Workspace and not pickedup do
	local t=tick()
	local d=t-starttime
	if d>timer then
		break
	end
	bp.position=floatpoint+Vector3.new(0,math.sin((d/floatcycletime)*math.pi*2)*floatradius,0)
	wait(.1)
end

for i=1,100 do
	if sp and sp.Parent and sp.Parent==game.Workspace then
		local m=sp:FindFirstChild("Mesh")
		if m then
			sp.Anchored=true
			m.Scale=Vector3.new(2,2,2)*(1-(i/100))
			wait()
		end
	end
end

sp:remove()


