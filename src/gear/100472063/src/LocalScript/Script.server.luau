--Stickmasterluke


sp=script.Parent


damage=40

local creator=sp:FindFirstChild("creator")
local debris=game:GetService("Debris")

sp.Touched:connect(function(hit)
	if hit~=nil and hit.Parent~=nil then
		local h=hit.Parent:FindFirstChild("Humanoid")
		local ct=sp:FindFirstChild("creator")
		if h~=nil and ct~=nil then
			if ct.Value==game.Players:GetPlayerFromCharacter(hit.Parent) then
				return false
			end
			for _,v in pairs(h:GetChildren()) do
				if v~=nil then
					v:remove()
				end
			end
			ct:clone().Parent=h
			h:TakeDamage(damage)
			damage=damage*.5
		end
	end
end)

wait(4)
sp:remove()
