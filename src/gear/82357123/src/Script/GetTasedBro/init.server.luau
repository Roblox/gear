--Stickmasterluke


sp=script.Parent


taseduration=7
rate=.5


local s=Instance.new("Sound")
s.SoundId="http://www.roblox.com/asset/?id=82277505"
s.Looped=true

joints={}
local t=sp:FindFirstChild("HumanoidRootPart")
if t~=nil then
	s.Parent=t
	s:Play()
	for i,v in ipairs(t:GetChildren()) do
		if v.className=="Motor" or v.className=="Motor6D" or v.className=="Weld" or v.className=="ManualWeld" then
			table.insert(joints,v)
		end
	end
end

if #joints>=1 then
	local trippy = script.Trippy:Clone()
	trippy.Parent = sp:FindFirstChild'Humanoid'
	trippy.Disabled = false
	for i=1,taseduration/rate do
		for i,v in ipairs(joints) do
			if v~=nil then
				v.CurrentAngle=(math.random()-.5)*5
			end
		end
		local h=sp:FindFirstChild("Humanoid")
		local t=sp:FindFirstChild("HumanoidRootPart")
		if t~=nil and h~=nil then
			--t.RotVelocity = Vector3.new(math.random()-.5,math.random()-.5,math.random()-.5)*2*360
			wait(rate)
		end
	end
	trippy:Destroy()
end
s:Stop()
script:Destroy()


