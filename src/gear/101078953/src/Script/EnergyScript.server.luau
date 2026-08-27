--Stickmasterluke


sp=script.Parent


local h=sp:FindFirstChild("Humanoid")
local t=sp:FindFirstChild("Torso")
if h~=nil and t~=nil and h.Health>0 then
	local f=Instance.new("Fire")
	f.Color=Color3.new(1,0,0)
	f.SecondaryColor=Color3.new(1,1,1)
	f.Size=3
	f.Heat=2
	f.Parent=t
	h.WalkSpeed=32
	wait(15)
	h.WalkSpeed=28
	wait(15)
	h.WalkSpeed=24
	wait(15)
	h.WalkSpeed=20
	wait(15)
	h.WalkSpeed=16
	if f~=nil then
		f:remove()
	end
end
script:remove()


