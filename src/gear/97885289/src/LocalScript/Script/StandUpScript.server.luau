--Stickmasterluke

sp=script.Parent

local h=sp:FindFirstChild("Humanoid")
if h~=nil then
	h.PlatformStand=true
end

wait(4)

local h=sp:FindFirstChild("Humanoid")
if h~=nil then
	h.PlatformStand=false
end
wait(5)
script:remove()



