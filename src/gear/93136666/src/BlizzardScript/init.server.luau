--Stickmasterluke


sp=script.Parent


function waitfor(parent,name)
	while parent:FindFirstChild(name)==nil do
		parent.ChildAdded:wait()
	end
	return parent:FindFirstChild(name)
end

timer=waitfor(script,"Timer")
gui=waitfor(script,"BlizzardGui")
blizscript=waitfor(gui,"LocalScript")

local h=sp:FindFirstChild("Humanoid")
if h~=nil then
	h.WalkSpeed=10
end

local plr=game.Players:GetPlayerFromCharacter(sp)
if plr~=nil then
	local plrgui=plr:FindFirstChild("PlayerGui")
	if plrgui~=nil then
		gui.Parent=plrgui
		blizscript.Disabled=false
	end
end

while timer~=nil and timer.Value>0 do
	timer.Value=timer.Value-1
	wait(1)
end

if h~=nil then
	h.WalkSpeed=16
end

if blizscript~=nil then
	blizscript.Disabled=true
end
if gui~=nil then
	gui:remove()
end

script:remove()


