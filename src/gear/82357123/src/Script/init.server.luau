--Stickmasterluke


sp=script.Parent


powertime=3

equipped=false
powered=false


while sp:FindFirstChild("ElectricWeld")==nil do 
	wait()
end
local storeweld=sp.ElectricWeld
local initCF = storeweld.C0

sp.Handle.Touched:connect(function(hit)
	if hit~=nil and powered then
		local eh=hit.Parent:FindFirstChild("Humanoid")
		local h=sp.Parent:FindFirstChild("Humanoid")
		if h~=nil and eh~=nil and h~=eh then
			if h.Health>0 and eh.Health>0 and h.Parent:FindFirstChild("GetTasedBro")==nil then
				--[[powered=false
				sp.Enabled=false]]
				local ts=script.GetTasedBro:clone()
				ts.Parent=hit.Parent
				ts.Disabled=false
			end
		end
	end
end)

sp.Activated:connect(function()
	local chr=sp.Parent
	local h=chr:FindFirstChild("Humanoid")
	if h~=nil then
		if h.Health>0 and not powered then
			sp.Enabled=false
			powered=true
			local s=sp.Handle:FindFirstChild("Sound")
			if s~=nil then
				s:Play()
			end
			delay(0,function()
				local ii=0
				while powered do
					ii=ii+1					
					if storeweld and ii%2==0 then
						storeweld.C0 = initCF * CFrame.Angles(0, 0, math.random()/3.0) --* CFrame.Angles(0, 1.3, 0)
					end
					local pain=sp:FindFirstChild("Pain")
					if pain~=nil then
						pain.Transparency=ii%2
					end
					wait(.1)
				end
				storeweld.C0 = initCF
				local s=sp.Handle:FindFirstChild("Sound")
				if s~=nil then
					s:Stop()
				end
				local pain=sp:FindFirstChild("Pain")
				if pain~=nil then
					pain.Transparency=1
				end
			end)
			wait(powertime)
			sp.Enabled=true
			powered=false
		end
	end
end)

sp.Equipped:connect(function()
	equipped=true
	powered=false
	local pain=sp:FindFirstChild("Pain")
	if pain~=nil then
		pain.Transparency=1
	end
	if storeweld then
		storeweld.Parent=sp
	end 
end)
sp.Unequipped:connect(function()
	powered=false
	equipped=false
end)




