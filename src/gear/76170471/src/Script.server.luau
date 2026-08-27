--Stickmasterluke


sp=script.Parent


check=true

s1=Instance.new("Sound")
s1.SoundId="http://www.roblox.com/asset/?id=76115411"
s1.Parent=sp.Handle

s2=Instance.new("Sound")
s2.SoundId="http://www.roblox.com/asset/?id=76115431"
s2.Parent=sp.Handle

s3=Instance.new("Sound")
s3.SoundId="http://www.roblox.com/asset/?id=76115441"
s3.Parent=sp.Handle

s4=Instance.new("Sound")
s4.SoundId="http://www.roblox.com/asset/?id=76115450"
s4.Parent=sp.Handle

local sounds={s1, s2, s3, s4}
lastsound=2
newsound=1

local initGrip 

function onActivated()
	if check then
		check=false
		sp.Grip=CFrame.new(-2,-.8,0.65)*CFrame.Angles(0,math.pi,-.3)
		while lastsound==newsound do
			newsound=math.random(1,#sounds)
		end
		lastsound=newsound
		sounds[newsound]:Play()
		wait(2)
		--sp.Grip=CFrame.new(-.2,-.2,0.2)*CFrame.Angles(math.pi/2,-math.pi/2,1.2)
		sp.Grip = initGrip 
		check=true
	end
end

function onEquipped()
	initGrip = sp.Grip 
	for i=1,#sounds do
		sounds[i].Volume = 1
	end
end

function onUnequipped()
	for i=1,#sounds do
		sounds[i].Volume = 0
	end
end

sp.Activated:connect(onActivated)
sp.Equipped:connect(onEquipped)
sp.Unequipped:connect(onUnequipped)
