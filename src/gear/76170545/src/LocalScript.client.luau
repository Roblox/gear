--Made by Stickmasterluke


--Don't read this script. It's horribly messy.

sp=script.Parent
plr=game.Players.LocalPlayer


rate=1/30
gravity=800	--pixels per second
jumpvelocity=350
basespeed=100
acceleration=.15
normalsize=UDim2.new(0,30,0,30)

speed=basespeed
bestdist=0
bestlightcollected=0
bestscore=0
bestdistname=""
bestlightcollectedname=""
bestscorename=""
dist=0
lightcollected=0
score=0
a=0
lastbonusdist=0
chrposition=Vector3.new(0,0,0)
chrvelocity=Vector3.new(0,0,0)
paused=false
equipped=false
running=false
grounded=false
airjumps=0
chrhitwall=false
wpressed=false
wdown=false
adown=false
sdown=false
ddown=false
spacedown=false
plrsactualcf=CFrame.new(0,0,0)
hiddencf=CFrame.new(0,50000,0)


while gui==nil do
	wait()
	gui=sp:FindFirstChild("PlatformerGui")
end

startpos=Vector3.new(0,300,0)

imgjumpeffect="http://www.roblox.com/asset/?id=73166882"

imgstill="http://www.roblox.com/asset/?id=73014404"
imgmoving="http://www.roblox.com/asset/?id=73014420"
imgfalling="http://www.roblox.com/asset/?id=73014435"
imgwallhit="http://www.roblox.com/asset/?id=73014892"
imgwallhit2="http://www.roblox.com/asset/?id=73014915"

local pp1=Instance.new("ImageLabel")
pp1.Name="Generated"
pp1.BackgroundTransparency=1
pp1.Image="http://www.roblox.com/asset/?id=72484181"
pp1.Size=UDim2.new(0,280,0,140)
pp1.ZIndex=5
local pp2=Instance.new("ImageLabel")
pp2.Name="Generated"
pp2.BackgroundTransparency=1
pp2.Image="http://www.roblox.com/asset/?id=72484254"
pp2.Size=UDim2.new(0,280,0,140)
pp2.ZIndex=5
local pp3=Instance.new("ImageLabel")
pp3.Name="Generated"
pp3.BackgroundTransparency=1
pp3.Image="http://www.roblox.com/asset/?id=72484283"
pp3.Size=UDim2.new(0,350,0,100)
pp3.ZIndex=5
local pp4=Instance.new("ImageLabel")
pp4.Name="Generated"
pp4.BackgroundTransparency=1
pp4.Image="http://www.roblox.com/asset/?id=74213080"
pp4.Size=UDim2.new(0,120,0,80)
pp4.ZIndex=5
pathparts={pp1,pp2,pp3,pp4}
pathlp1=gui.GameFrame.MoveFrame.Map.Land1
pathlp2=gui.GameFrame.MoveFrame.Map.Land1
pathlp3=gui.GameFrame.MoveFrame.Map.Land1



sp.Equipped:connect(function(mouse)
	if plr.Character~=nil then
		if plr.Character:FindFirstChild("Torso") then
			plrsactualcf=plr.Character.Torso.CFrame
			wait()
			plr.Character.Torso.CFrame=hiddencf
			plr.Character.Torso.Anchored=true
		end
	end
	if mouse~=nil then
		equipped=true
		mouse.Button1Down:connect(function()
			paused=not paused
			if running then
				gui.GameFrame.Paused.Visible=paused
			else
				gui.GameFrame.Paused.Visible=false
			end
		end)
		mouse.KeyDown:connect(function(key2)
			key=string.byte(key2)
			if key then
				if key==119 or key==17 then		--up
					wdown=true
					wpressed=true
				elseif key==97 or key==20 then	--left
					adown=true
				elseif key==115 or key==18 then	--down
					sdown=true
				elseif key==100 or key==19 then	--right
					ddown=true
				elseif key==32 then					--jump
					spacedown=true
					paused=not paused
					if running then
						gui.GameFrame.Paused.Visible=paused
					else
						gui.GameFrame.Paused.Visible=false
					end
				end
			end
		end)
		mouse.KeyUp:connect(function(key2)
			key=string.byte(key2)
			if key then
				if key==119 or key==17 then		--up
					wdown=false
				elseif key==97 or key==20 then	--left
					adown=false
				elseif key==115 or key==18 then	--down
					sdown=false
				elseif key==100 or key==19 then	--right
					ddown=false
				elseif key==32 then					--jump
					spacedown=false
				end
			end
		end)
		gui.Background.Transparency=1
		gui.Parent=plr.PlayerGui
		--fade in
		gui.Background.Transparency=0
	end
end)

sp.Unequipped:connect(function()
	if plr.Character~=nil then
		if plr.Character:FindFirstChild("Torso") then
			plr.Character.Torso.Anchored=false
			plr.Character.Torso.CFrame = plrsactualcf + Vector3.new(0, 5, 0)
		end
	end
	equipped=false
	gui.Parent=sp
	if running then
		paused=true
		gui.GameFrame.Paused.Visible=true
	end
end)

function checkintersect(l1p1,l1p2,l2p1,l2p2)
	local l1p1=l1p1*Vector3.new(1,1,0)
	local l1p2=l1p2*Vector3.new(1,1,0)
	local l2p1=l2p1*Vector3.new(1,1,0)
	local l2p2=l2p2*Vector3.new(1,1,0)
	d=(l1p1.x-l1p2.x)*(l2p1.y-l2p2.y)-(l1p1.y-l1p2.y)*(l2p1.x-l2p2.x)
	if d==0 then
		return false
	end
	local xi=((l2p1.x-l2p2.x)*(l1p1.x*l1p2.y-l1p1.y*l1p2.x)-(l1p1.x-l1p2.x)*(l2p1.x*l2p2.y-l2p1.y*l2p2.x))/d
	local yi=((l2p1.y-l2p2.y)*(l1p1.x*l1p2.y-l1p1.y*l1p2.x)-(l1p1.y-l1p2.y)*(l2p1.x*l2p2.y-l2p1.y*l2p2.x))/d
	local l1m=Vector3.new((l1p1.x+l1p2.x)/2,(l1p1.y+l1p2.y)/2,0)
	local l2m=Vector3.new((l2p1.x+l2p2.x)/2,(l2p1.y+l2p2.y)/2,0)
	local l1d2=(l1p2-l1p1):Dot(l1p2-l1p1)
	local l2d2=(l2p2-l2p1):Dot(l2p2-l2p1)
	local iToM1Dist=Vector3.new(xi-l1m.x,yi-l1m.y,0)
	local iToM2Dist=Vector3.new(xi-l2m.x,yi-l2m.y,0)
	return ((iToM1Dist:Dot(iToM1Dist)<=l1d2/4) and (iToM2Dist:Dot(iToM2Dist)<=l2d2/4))
end

function properresize(gchr,dx,dy)
	if gchr.Size~=UDim2.new(0,dx,0,dy) then
		chrposition=chrposition+Vector3.new(gchr.Size.X.Offset-dx,gchr.Size.Y.Offset-dy,0)
		gchr.Size=UDim2.new(0,dx,0,dy)
	end
end

function start()
	local gchr=gui.GameFrame.MoveFrame.Character
	running=false
	local frames=1/rate
	for frame=1,frames do
		gui.GameFrame.WhiteFrame.BackgroundTransparency=1-(frame/frames)
		wait(rate)
	end
	gui.GameFrame.TitlePage.Visible=false
	gui.GameFrame.ScorePage.Visible=false
	properresize(gchr,30,30)
	chrvelocity=Vector3.new(0,0,0)
	chrposition=startpos
	chrhitwall=false
	gui.GameFrame.BlackFade.Position=UDim2.new(0,-10,1.5,-10)
	gchr.Position=UDim2.new(0,chrposition.x,0,chrposition.y)
	gui.GameFrame.MoveFrame.Position=UDim2.new(.5,-100,.5,0)-(gchr.Position+gchr.Size)
	local mhp=(((gchr.Position.Y.Offset+gchr.Size.Y.Offset*.5)+50)/1050)
	if mhp>1 then
		mhp=1
	elseif mhp<0 then
		mhp=0
	end
	mhp=1-mhp
	local mdp=-(gchr.Position.X.Offset+gchr.Size.X.Offset*.5)
	gui.GameFrame.Mountians1.Position=UDim2.new(0,((mdp*.15)%600)-600,.5*mhp,0)
	gui.GameFrame.Mountians2.Position=UDim2.new(0,((mdp*.1)%600)-600,.075+(.35*mhp),0)
	gui.GameFrame.Mountians3.Position=UDim2.new(0,((mdp*.05)%600)-600,.15+(.2*mhp),0)
	gchr.Image=imgstill
	gui.GameFrame.Score.Text="Score: 0"
	speed=basespeed
	lastbonusdist=0
	dist=0
	score=0
	lightcollected=0
	lastpos=chrposition
	for i,v in ipairs(gui.GameFrame.MoveFrame.Map:GetChildren()) do
		if v.Name=="Generated" then
			v:remove()
		end
	end
	pathlp1=gui.GameFrame.MoveFrame.Map.Land1
	pathlp2=gui.GameFrame.MoveFrame.Map.Land1
	pathlp3=gui.GameFrame.MoveFrame.Map.Land1
	local frames=2/rate
	for frame=1,frames do
		gui.GameFrame.WhiteFrame.BackgroundTransparency=frame/frames
		wait(rate)
	end
	running=true
end

gui.GameFrame.TitlePage.Play.MouseButton1Click:connect(function()
	start()
end)

gui.GameFrame.TitlePage.Controls.MouseButton1Click:connect(function()
	local frames=1/rate
	for frame=1,frames do
		gui.GameFrame.BlackFrame.BackgroundTransparency=1-(frame/frames)
		wait(rate)
	end
	gui.GameFrame.TitlePage.Visible=false
	gui.GameFrame.Controls.Visible=true
	local frames=1/rate
	for frame=1,frames do
		gui.GameFrame.BlackFrame.BackgroundTransparency=frame/frames
		wait(rate)
	end
end)

gui.GameFrame.Controls.Back.MouseButton1Click:connect(function()
	local frames=1/rate
	for frame=1,frames do
		gui.GameFrame.BlackFrame.BackgroundTransparency=1-(frame/frames)
		wait(rate)
	end
	gui.GameFrame.TitlePage.Visible=true
	gui.GameFrame.Controls.Visible=false
	local frames=1/rate
	for frame=1,frames do
		gui.GameFrame.BlackFrame.BackgroundTransparency=frame/frames
		wait(rate)
	end
end)

gui.GameFrame.ScorePage.Okay.MouseButton1Click:connect(function()
	local frames=1/rate
	for frame=1,frames do
		gui.GameFrame.BlackFrame.BackgroundTransparency=1-(frame/frames)
		wait(rate)
	end
	gui.GameFrame.TitlePage.Visible=true
	gui.GameFrame.ScorePage.Visible=false
	local frames=1/rate
	for frame=1,frames do
		gui.GameFrame.BlackFrame.BackgroundTransparency=frame/frames
		wait(rate)
	end
end)

function reset()
	running=false
	local gchr=gui.GameFrame.MoveFrame.Character
	gui.GameFrame.BlackFade.Position=UDim2.new(0,-10,1.5,-10)
	gui.GameFrame.BlackFade.Frame.BackgroundTransparency=0
	local frames=2/rate
	for frame=1,frames do
		gui.GameFrame.BlackFade.Position=UDim2.new(0,-10,1.5-((frame/frames)*2),-10)
		wait(rate)
	end
	gui.GameFrame.BlackFade.Position=UDim2.new(0,-10,-1.5,-10)
	--gui.GameFrame.TitlePage.Visible=true
	dist=math.floor(dist/4)
	score=math.floor(score)
	if score>=bestscore then
		bestscore=score
		gui.GameFrame.ScorePage.LastScore.TextStrokeTransparency=.65
		gui.GameFrame.ScorePage.BestScore.Text="Best Score: "..tostring(bestscore)
	else
		gui.GameFrame.ScorePage.LastScore.TextStrokeTransparency=1
	end
	if dist>=bestdist then
		bestdist=dist
		gui.GameFrame.ScorePage.LastDist.TextStrokeTransparency=.65
		gui.GameFrame.ScorePage.BestDist.Text="Best Distance: "..tostring(bestdist)
	else
		gui.GameFrame.ScorePage.LastDist.TextStrokeTransparency=1
	end
	if lightcollected>bestlightcollected then
		bestlightcollected=lightcollected
		gui.GameFrame.ScorePage.LastLight.TextStrokeTransparency=.65
		gui.GameFrame.ScorePage.BestLight.Text="Max orbs collected: "..tostring(bestlightcollected)
	else
		gui.GameFrame.ScorePage.LastLight.TextStrokeTransparency=1
	end
	gui.GameFrame.ScorePage.LastScore.Text="Score: "..tostring(score)
	gui.GameFrame.ScorePage.LastDist.Text="Distance: "..tostring(dist)
	gui.GameFrame.ScorePage.LastLight.Text="Orbs Collected: "..tostring(lightcollected)
	gui.GameFrame.ScorePage.Visible=true
	paused=false
	gui.GameFrame.Paused.Visible=false
--[[	local frames=3/rate
	for frame=1,frames do
		gui.GameFrame.BlackFade.Frame.BackgroundTransparency=frame/frames
		wait(rate)
	end]]
	gui.GameFrame.BlackFade.Position=UDim2.new(0,-10,1.5,-10)
	gui.GameFrame.BlackFade.Frame.BackgroundTransparency=1
end

function createsparkle(spklpos)
	local lighte=Instance.new("ImageLabel")
	local lightv3=Instance.new("Vector3Value")
	lightv3.Name="Velocity"
	lightv3.Value=Vector3.new(math.random(),(math.random()*2)-1,0)*200--(Vector3.new((math.random()*2)-1,(math.random()*2)-1,0)*(chrvelocity.magnitude))
	lightv3.Parent=lighte
	lighte.Name="Light"
	lighte.Image="http://www.roblox.com/asset/?id=74274038"
	lighte.BackgroundTransparency=1
	lighte.ZIndex=5
	lighte.Size=UDim2.new(0,15,0,15)
	lighte.Position=spklpos+UDim2.new(0,lightv3.Value.x*rate,0,lightv3.Value.y*rate)
	lighte.Parent=gui.GameFrame.MoveFrame.Effects
end


while true do
	if equipped then
		if running and not paused then
			a=a+1
			local gchr=gui.GameFrame.MoveFrame.Character
			verticalaction=1
			if wdown and not grounded then
				if chrvelocity.y>=gravity*.1 then
					verticalaction=3
				end
			end
			if wpressed then
				wpressed=false
				if grounded then
					verticalaction=2
					airjumps=1
				elseif airjumps<2 then
					local je=Instance.new("ImageLabel")
					je.Name="JumpEffect"
					je.Image=imgjumpeffect
					je.BackgroundTransparency=1
					je.ZIndex=gchr.ZIndex-1
					je.Size=UDim2.new(0,20,0,10)
					je.Position=UDim2.new(0,chrposition.x+(gchr.Size.X.Offset/2)-(je.Size.X.Offset/2),0,chrposition.y+gchr.Size.Y.Offset-(je.Size.X.Offset/2))
					je.Parent=gui.GameFrame.MoveFrame.Effects
					airjumps=airjumps+1
					verticalaction=2
				end
			end
			if sdown then
				verticalaction=4
			end
			if verticalaction==1 then						--falling
				chrvelocity=chrvelocity+Vector3.new(0,gravity*rate,0)
				properresize(gchr,30,30)
			elseif verticalaction==2 then					--jump
				chrvelocity=(chrvelocity*Vector3.new(1,0,0))+Vector3.new(0,-jumpvelocity,0)
				properresize(gchr,30,30)
			elseif verticalaction==3 then					--glide
				chrvelocity=(chrvelocity*Vector3.new(1,0,0))+Vector3.new(0,gravity*.1,0)
				properresize(gchr,50,10)
			elseif verticalaction==4 then					--slam/crouch
				if chrvelocity.y<gravity*2 and not grounded then
					local slame=Instance.new("ImageLabel")
					slame.Name="SlamEffect"
					slame.Image=imgjumpeffect
					slame.BackgroundTransparency=1
					slame.ZIndex=gchr.ZIndex-1
					slame.Size=UDim2.new(0,16,0,10)
					slame.Position=UDim2.new(0,chrposition.x+(gchr.Size.X.Offset/2)-(slame.Size.X.Offset/2),0,chrposition.y-(slame.Size.X.Offset/2))
					slame.Parent=gui.GameFrame.MoveFrame.Effects
				end
				chrvelocity=(chrvelocity*Vector3.new(1,0,0))+Vector3.new(0,gravity*2,0)
				properresize(gchr,40,15)
			end
			speed=speed+acceleration
			chrvelocity=(chrvelocity*Vector3.new(0,1,0))+Vector3.new(speed,0,0)
			local point1=chrposition+Vector3.new(gchr.Size.X.Offset,0,0)
			local point2=chrposition+Vector3.new(gchr.Size.X.Offset,gchr.Size.Y.Offset,0)
			if chrvelocity.y>=0 then
				point3=chrposition+Vector3.new(0,gchr.Size.Y.Offset,0)
			else
				point3=chrposition
			end
			horizontalhit=nil
			horizontalhight=nil
			verticalhit=nil
			for i,v in ipairs(gui.GameFrame.MoveFrame.Map:GetChildren()) do
				if v.Name=="Generated" then
					if v.Position.X.Offset+v.Size.X.Offset<gchr.Position.X.Offset-200 then
						v:remove()
					end
				end
				if v then
					--[[if horizontalhit==nil or horizontalhit>v.Position.X.Offset then
						local check1a=checkintersect(point1,point1+(chrvelocity*rate),Vector3.new(v.Position.X.Offset,v.Position.Y.Offset,0),Vector3.new(v.Position.X.Offset,v.Position.Y.Offset+v.Size.Y.Offset,0))
						local check2a=checkintersect(point2,point2+(chrvelocity*rate),Vector3.new(v.Position.X.Offset,v.Position.Y.Offset,0),Vector3.new(v.Position.X.Offset,v.Position.Y.Offset+v.Size.Y.Offset,0))
						local check3a=checkintersect(point3,point3+(chrvelocity*rate),Vector3.new(v.Position.X.Offset,v.Position.Y.Offset,0),Vector3.new(v.Position.X.Offset,v.Position.Y.Offset+v.Size.Y.Offset,0))
						if check1a or check2a then
							horizontalhit=v.Position.X.Offset
							horizontalhight=v.Position.Y.Offset
						end
					end]]
					if chrvelocity.y>=0 then
						if verticalhit==nil or verticalhit>v.Position.Y.Offset then
							--local check1b=checkintersect(point1+Vector3.new(0,-5,0),point1+(chrvelocity*rate),Vector3.new(v.Position.X.Offset,v.Position.Y.Offset,0),Vector3.new(v.Position.X.Offset+v.Size.X.Offset,v.Position.Y.Offset,0))
							local check2b=checkintersect(point2,point2+(chrvelocity*rate),Vector3.new(v.Position.X.Offset,v.Position.Y.Offset,0),Vector3.new(v.Position.X.Offset+v.Size.X.Offset,v.Position.Y.Offset,0))
							local check3b=checkintersect(point3+Vector3.new(0,-5,0),point3+(chrvelocity*rate),Vector3.new(v.Position.X.Offset,v.Position.Y.Offset,0),Vector3.new(v.Position.X.Offset+v.Size.X.Offset,v.Position.Y.Offset,0))
							if check1b or check2b or check3b then
								verticalhit=v.Position.Y.Offset
							end
						end
					--[[else
						if verticalhit==nil or verticalhit<v.Position.Y.Offset+v.Size.Y.Offset then
							local check1c=checkintersect(point1,point1+(chrvelocity*rate),Vector3.new(v.Position.X.Offset,v.Position.Y.Offset+v.Size.Y.Offset,0),Vector3.new(v.Position.X.Offset+v.Size.X.Offset,v.Position.Y.Offset+v.Size.Y.Offset,0))
							local check2c=checkintersect(point2,point2+(chrvelocity*rate),Vector3.new(v.Position.X.Offset,v.Position.Y.Offset+v.Size.Y.Offset,0),Vector3.new(v.Position.X.Offset+v.Size.X.Offset,v.Position.Y.Offset+v.Size.Y.Offset,0))
							local check3c=checkintersect(point3,point3+(chrvelocity*rate),Vector3.new(v.Position.X.Offset,v.Position.Y.Offset+v.Size.Y.Offset,0),Vector3.new(v.Position.X.Offset+v.Size.X.Offset,v.Position.Y.Offset+v.Size.Y.Offset,0))
							if check1c or check2c or check3c then
								verticalhit=v.Position.Y.Offset+v.Size.Y.Offset
							end
						end]]
					end
				end
			end
			if (chrvelocity).magnitude<=gravity*rate and grounded then
				gchr.Image=imgstill
			elseif math.abs(chrvelocity.x)>math.abs(chrvelocity.y) then
				gchr.Image=imgmoving
			else
				gchr.Image=imgfalling
			end
			chrposition=chrposition+(chrvelocity*rate)
			dist=dist+(chrvelocity*rate).x
			grounded=false
			if verticalhit~=nil then
				if chrvelocity.y>=0 then
					grounded=true
					airjumps=0
					chrposition=Vector3.new(chrposition.x,(verticalhit-gchr.Size.Y.Offset)-.01,0)
					chrvelocity=chrvelocity*Vector3.new(1,0,0)
				else
					chrposition=Vector3.new(chrposition.x,verticalhit+.01,0)
					chrvelocity=chrvelocity*Vector3.new(1,0,0)
				end
			end
			if horizontalhit~=nil and horizontalhight~=nil then
				if verticalhit and grounded then
					if horizontalhight<verticalhit then
						chrhitwall=true
					end
				else
					chrhitwall=true
				end
			end
			if chrposition.x>=30000 then
				chrposition=chrposition+Vector3.new(-24000,0,0)
				for i,v in ipairs(gui.GameFrame.MoveFrame.Map:GetChildren()) do
					if v.Name=="Generated" then
						v.Position=v.Position+UDim2.new(0,-24000,0,0)
					end
				end
				for i,v in ipairs(gui.GameFrame.MoveFrame.Effects:GetChildren()) do
					v.Position=v.Position+UDim2.new(0,-24000,0,0)
				end
				for i,v in ipairs(gui.GameFrame.MoveFrame.Bonus:GetChildren()) do
					v.Position=v.Position+UDim2.new(0,-24000,0,0)
				end
			end
			gchr.Position=UDim2.new(0,chrposition.x,0,chrposition.y)
			gui.GameFrame.MoveFrame.Position=UDim2.new(.5,-100,.5,0)-(gchr.Position+gchr.Size)
			local mhp=(((gchr.Position.Y.Offset+gchr.Size.Y.Offset*.5)+50)/1050)
			if mhp>1 then
				mhp=1
			elseif mhp<0 then
				mhp=0
			end
			mhp=1-mhp
			local mdp=-(gchr.Position.X.Offset+gchr.Size.X.Offset*.5)
			gui.GameFrame.Mountians1.Position=UDim2.new(0,((mdp*.15)%600)-600,.5*mhp,0)
			gui.GameFrame.Mountians2.Position=UDim2.new(0,((mdp*.1)%600)-600,.075+(.35*mhp),0)
			gui.GameFrame.Mountians3.Position=UDim2.new(0,((mdp*.05)%600)-600,.15+(.2*mhp),0)
			if pathlp1.Position.X.Offset<gchr.Position.X.Offset+400 then
				local npathlp1=pathparts[math.random(1,#pathparts)]:clone()
				npathlp1.Position=pathlp1.Position+UDim2.new(0,(speed*(math.random()*1.75))+pathlp1.Size.X.Offset,0,100*((math.random()*2)-1))
				if npathlp1.Position.Y.Offset>600-npathlp1.Size.Y.Offset then
					npathlp1.Position=UDim2.new(0,npathlp1.Position.X.Offset,0,600-npathlp1.Size.Y.Offset)
				elseif npathlp1.Position.Y.Offset<0 then
					npathlp1.Position=UDim2.new(0,npathlp1.Position.X.Offset,0,0)
				end
				npathlp1.Parent=gui.GameFrame.MoveFrame.Map
				pathlp1=npathlp1
			end
			if pathlp2.Position.X.Offset<gchr.Position.X.Offset+400 then
				local npathlp2=pathparts[math.random(1,#pathparts)]:clone()
				npathlp2.Position=pathlp2.Position+UDim2.new(0,(speed*(math.random()*1.75))+pathlp2.Size.X.Offset,0,100*((math.random()*2)-1))
				if npathlp2.Position.Y.Offset>600-npathlp2.Size.Y.Offset then
					npathlp2.Position=UDim2.new(0,npathlp2.Position.X.Offset,0,600-npathlp2.Size.Y.Offset)
				elseif npathlp2.Position.Y.Offset<0 then
					npathlp2.Position=UDim2.new(0,npathlp2.Position.X.Offset,0,0)
				end
				npathlp2.Parent=gui.GameFrame.MoveFrame.Map
				pathlp2=npathlp2
			end
			if pathlp3.Position.X.Offset<gchr.Position.X.Offset+400 then
				local npathlp3=pathparts[math.random(1,#pathparts)]:clone()
				npathlp3.Position=pathlp3.Position+UDim2.new(0,(speed*(math.random()*1.75))+pathlp3.Size.X.Offset,0,100*((math.random()*2)-1))
				if npathlp3.Position.Y.Offset>600-npathlp3.Size.Y.Offset then
					npathlp3.Position=UDim2.new(0,npathlp3.Position.X.Offset,0,600-npathlp3.Size.Y.Offset)
				elseif npathlp3.Position.Y.Offset<0 then
					npathlp3.Position=UDim2.new(0,npathlp3.Position.X.Offset,0,0)
				end
				npathlp3.Parent=gui.GameFrame.MoveFrame.Map
				pathlp3=npathlp3
			end
			for i,v in ipairs(gui.GameFrame.MoveFrame.Effects:GetChildren()) do
				if v.Name=="JumpEffect" then
					if v.Size.X.Offset>=76 then
						v:remove()
					else
						v.Size=v.Size+UDim2.new(0,4,0,2)
						v.Position=v.Position-UDim2.new(0,2,0,1)
					end
				elseif v.Name=="SlamEffect" then
					if v.Size.X.Offset>=54 then
						v:remove()
					else
						v.Size=v.Size+UDim2.new(0,6,0,4)
						v.Position=v.Position-UDim2.new(0,3,0,2)
					end
				elseif v.Name=="TredEffect" then
					v.Velocity.Value=v.Velocity.Value+Vector3.new(0,gravity*rate,0)
					v.Position=v.Position+UDim2.new(0,v.Velocity.Value.x*rate,0,v.Velocity.Value.y*rate)
					if v.Velocity.Value.y>gravity*.25 then
						v:remove()
					end
				elseif v.Name=="Light" then
					v.Velocity.Value=v.Velocity.Value+Vector3.new(0,gravity*rate,0)
					v.Position=v.Position+UDim2.new(0,v.Velocity.Value.x*rate,0,v.Velocity.Value.y*rate)
					if v.Velocity.Value.y>gravity*3 then
						v:remove()
					end
				elseif v.Name=="Light" then
					if v.Size.X.Offset>=100 then
						v:remove()
					else
						v.Size=v.Size+UDim2.new(0,2,0,2)
						v.Position=v.Position-UDim2.new(0,1,0,1)
					end
				end
			end
			for i,v in ipairs(gui.GameFrame.MoveFrame.Bonus:GetChildren()) do
				v.Position=v.Position+UDim2.new(0,0,0,1)
				if v.Position.X.Offset<chrposition.x-450 then
					v:remove()
				else
					local bonuschecka1=checkintersect(lastpos+Vector3.new(30,0,0),chrposition+Vector3.new(30,0,0),Vector3.new(v.Position.X.Offset,v.Position.Y.Offset,0),Vector3.new(v.Position.X.Offset+v.Size.X.Offset,v.Position.Y.Offset+v.Size.Y.Offset,0))
					local bonuschecka2=checkintersect(lastpos+Vector3.new(30,30,0),chrposition+Vector3.new(30,30,0),Vector3.new(v.Position.X.Offset,v.Position.Y.Offset,0),Vector3.new(v.Position.X.Offset+v.Size.X.Offset,v.Position.Y.Offset+v.Size.Y.Offset,0))
					local bonuscheckb1=checkintersect(lastpos+Vector3.new(30,0,0),chrposition+Vector3.new(30,0,0),Vector3.new(v.Position.X.Offset+v.Size.X.Offset,v.Position.Y.Offset,0),Vector3.new(v.Position.X.Offset,v.Position.Y.Offset+v.Size.Y.Offset,0))
					local bonuscheckb2=checkintersect(lastpos+Vector3.new(30,30,0),chrposition+Vector3.new(30,30,0),Vector3.new(v.Position.X.Offset+v.Size.X.Offset,v.Position.Y.Offset,0),Vector3.new(v.Position.X.Offset,v.Position.Y.Offset+v.Size.Y.Offset,0))
					if bonuschecka1 or bonuschecka2 or bonuscheckb1 or bonuscheckb2 then
						--v.Parent=gui.GameFrame.MoveFrame.Effects
						v:remove()
						createsparkle(v.Position+UDim2.new(0,v.Size.X.Offset/2,0,v.Size.Y.Offset/2))
						createsparkle(v.Position+UDim2.new(0,v.Size.X.Offset/2,0,v.Size.Y.Offset/2))
						createsparkle(v.Position+UDim2.new(0,v.Size.X.Offset/2,0,v.Size.Y.Offset/2))
						createsparkle(v.Position+UDim2.new(0,v.Size.X.Offset/2,0,v.Size.Y.Offset/2))
						lightcollected=lightcollected+1
						score=(score*1.05)+200
					end
				end
			end
			score=score+math.floor(speed/100)+2
			gui.GameFrame.Score.Text="Score: "..tostring(math.floor(score))--chrposition.x/6))
			if dist>lastbonusdist+1000 then
				lastbonusdist=dist
				local lighte=Instance.new("ImageLabel")
				lighte.Name="Light"
				lighte.Image="http://www.roblox.com/asset/?id=74274038"
				lighte.BackgroundTransparency=1
				lighte.ZIndex=gchr.ZIndex-1
				lighte.Size=UDim2.new(0,30,0,30)
				lighte.Position=UDim2.new(0,chrposition.x+430,0,math.random(-50,500))
				lighte.Parent=gui.GameFrame.MoveFrame.Bonus
			end
			if grounded then
				if a%5==1 then
					local trede=Instance.new("ImageLabel")
					local tredv3=Instance.new("Vector3Value")
					tredv3.Name="Velocity"
					tredv3.Value=Vector3.new(0,-jumpvelocity*.6,0)
					tredv3.Parent=trede
					trede.Name="TredEffect"
					trede.Image="http://www.roblox.com/asset/?id=74246393"
					trede.BackgroundTransparency=1
					trede.ZIndex=gchr.ZIndex-1
					trede.Size=UDim2.new(0,math.random(2,5),0,math.random(2,5))
					trede.Position=UDim2.new(0,chrposition.x-(trede.Size.X.Offset/2),0,chrposition.y+gchr.Size.Y.Offset)
					trede.Parent=gui.GameFrame.MoveFrame.Effects
				end
			end
			if chrhitwall then
				chrposition=Vector3.new(horizontalhit-gchr.Size.X.Offset,chrposition.y,0)
				gchr.Image=imgwallhit
				wait(.15)
				gchr.Image=imgwallhit2
				wait(.15)
				reset()
			elseif chrposition.y>1000 then
				reset()
			end
			lastpos=chrposition
		end
	end
	wait(rate)
end


