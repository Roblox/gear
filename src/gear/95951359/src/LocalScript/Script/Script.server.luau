--Stickmasterluke


sp=script.Parent


damage=22

sp.Touched:connect(function(hit)
	if hit~=nil and hit.Parent~=nil then
		local creator=sp:FindFirstChild("creator")
		local h=hit.Parent:FindFirstChild("Humanoid")
		local speed=sp.Velocity.magnitude
		if creator~=nil and h~=nil and h.Health>0 and speed>1 then
			local plr=game.Players:GetPlayerFromCharacter(h.Parent)
			if plr~=nil and creator.Value~=nil then
				if creator.Value==plr then
					return
				end
			end
			for i,v in ipairs(h:GetChildren()) do
				if v.Name=="creator" then
					v:remove()
				end
			end
			creator:clone().Parent=h
			local percent=math.min(speed/60,1)
			print(damage*percent)
			h:TakeDamage(damage*percent)
		end
	end
end)

wait(10)

sp:remove()
