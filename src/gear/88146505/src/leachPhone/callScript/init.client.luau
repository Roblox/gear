local player = script.Parent--script:FindFirstChild("target").Value--game.Players.LocalPlayer
local character = player:FindFirstChild("Humanoid")

local laughAni= Instance.new("Animation")
	laughAni.AnimationId = "http://www.roblox.com/Asset?ID=87684948"

local startTime= time()
local hum=script.Parent:FindFirstChild('Humanoid')
local animTrack=hum:LoadAnimation(laughAni)
local ltime=script:FindFirstChild("laughTime")
while not ltime do
	ltime=script:FindFirstChild("laughTime")
	wait()
end
animTrack:Play()
animTrack:AdjustSpeed(3)
--local chat= Instance.new("Dialog")
--chat.Parent=script.Parent


local bg = Instance.new("BillboardGui")
bg.Parent = player--.PlayerGui--game.Workspace
bg.Adornee = player.Head
bg.Size = UDim2.new(10, 0, 3, 0)
-- Above (defaults to inside)
bg.StudsOffset = Vector3.new(0, 4, 0)



local mesgs={}
mesgs[1]="OMG BBQ FTW"
mesgs[2]="CALLZ ME, MAY B?"
mesgs[3]="D0NT B A H8TR"
mesgs[4]="U MAD BR0"
mesgs[5]="JUST FED THE CAT LOLOLOLOL"
mesgs[6]="GG"
mesgs[7]="C U L8R"
mesgs[8]="LOLOLOLOLOLOL"
mesgs[9]="I R A HAXOR"
mesgs[10]="ON MY WY TO TEH MALL"

function fadeImgGuiElement()
	local image = Instance.new('ImageLabel')
	image.Parent = frame
	image.Position = UDim2.new(0, 0, 0, 0)
	image.Size = UDim2.new(10.25, 0, 10.25, 0)
	image.Image = 'http://www.roblox.com/asset/?id=86621103'
	
	local fadetime=math.random()+1
	image:TweenPosition(UDim2.new(0, 0, 0, 0))
	wait(fadetime)
	image.Destory()
end

function fadeTxtGuiElement(mesg)
	local frame = Instance.new("Frame")
	frame.Parent = bg
	frame.Size = UDim2.new(1, 0, 1, 0)
	frame.BackgroundTransparency = 0.0
	frame.BackgroundColor3 = Color3.new(1, 1, 1)

	local text = Instance.new('TextLabel')
	text.Parent = frame
	text.Font=Enum.Font.ArialBold
	text.Position = UDim2.new(0, 0, 0, 0)
	text.Size = UDim2.new(1, 0, 1, 0)
	text.TextScaled=true
	text.Text=mesg
	
	local fadetime=math.random()+1
	--text:TweenPosition(UDim2.new(0, 0, 0, 0))
	wait(fadetime)
	frame:Destroy()
end

local onTouchConn = nil

function onTouch(part)
	local h = part.Parent:findFirstChild("Humanoid")
	if h and not h.Parent:FindFirstChild("callScript") then
		if onTouchConn then
			print('Disconnecting touch')
			onTouchConn:disconnect()
			print('Touch Connected is ' .. tostring(onTouchConn.connected))
			onTouchConn = nil
		end
		local lscript = script:Clone()
		lscript.Parent=h.Parent
		lscript:FindFirstChild("laughTime").Value=5
		lscript.Disabled = false 
		local tphone=script:FindFirstChild("Handle"):Clone()
		tphone.Name= "Handle"
		tphone.Parent = lscript
		local tweld= Instance.new("Weld")
		tweld.Parent = h.Parent:FindFirstChild("Right Arm")
		tweld.Part0 = h.Parent:FindFirstChild("Right Arm") --> part0 has to be the parent 
		tweld.Part1 = tphone
		tweld.C0 = CFrame.new(0.5,-1.0,0,1,0,0,0,0,1,0,-1,0)  
		
		--lscript
	end
		script:FindFirstChild("laughTime").Value=5
end

local Handle = script:FindFirstChild("Handle")

if Handle then
	onTouchConn = Handle.Touched:connect(onTouch)
end

local players_ret= {}
function getNearestPlayer(pos)
	local parent_pos= pos
	local nearest
	local mindist=-1
	local tdist=-1
	local i=1
	for _, tplayer in pairs(game.Players:GetPlayers()) do
			-- If the player is dead then they will not have a torso
			if tplayer.Character:FindFirstChild('Torso') then
			tdist= (tplayer.Character.Torso.CFrame.p-parent_pos).magnitude
			
			if (tdist<mindist or mindist<0) and tplayer~=game.Players.LocalPlayer and not tplayer.Character:FindFirstChild("callScript") then
				nearest=tplayer
				mindist=tdist
				i=i+1
				print (tdist)
			end
			end
	end
	--table.setn(players,i+1)
	return nearest
end
function forceMove()
	if not script.Parent.Torso then return end
	local nearplayer = getNearestPlayer(script.Parent.Torso.CFrame.p)
	if not nearplayer then return end
	print (character)
	character:MoveTo(nearplayer.Character.Torso.CFrame.p,nearplayer.Character.Torso)
end

while(time()-startTime<ltime.Value) do
	forceMove()
	wait(.3)
	forceMove()
	fadeTxtGuiElement(mesgs[math.random(table.getn(mesgs))])
	wait(.2)
end


animTrack:Stop()

print("stopped laughing")

bg:Destroy()

script:Destroy()