--Made by Stickmasterluke


sp=script.Parent


local damage=34
local sounddebounce=.5

local check=true
local lastsound=0
local debris=game:GetService("Debris")


sp.Touched:connect(function(hit)
	if hit and hit.Parent then
		if lastsound+sounddebounce<time() and hit.CanCollide then
			lastsound=time()
			local sound=sp:FindFirstChild("Sound")
			if sound then
				sound.Volume=math.min(sp.Velocity.magnitude/40,1)
				sound.Pitch=.5+math.random()
				sound:Play()
			end
		end
		if damage>0 then
			local h=hit.Parent:FindFirstChild("Humanoid")
			if h and h.Health>0 then
				local targetplr=game.Players:GetPlayerFromCharacter(hit.Parent)
				local creatortag=sp:FindFirstChild("creator")
				print("Creator:",creatortag,creatortag.Value)
				print("Targetplr:",targetplr)
				if not creatortag or not creatortag.Value or not creatortag.Value.Parent==game.Players or not targetplr or targetplr~=creatortag.Value and (creatortag.Value.Neutral or targetplr.Neutral or targetplr.TeamColor~=creatortag.Value.TeamColor) then	--This was fun to write. Much better than sudoku. I hate sudoku.
					if creatortag then
						for _,v in pairs(h:GetChildren()) do
							if v.className=="creator" then
								v:remove()
							end
						end
						local newcreatortag=creatortag:clone()
						debris:AddItem(newcreatortag,3)
						newcreatortag.Parent=h
					end
					h:TakeDamage(damage*math.min(sp.Velocity.magnitude/40,1))
					damage=0
				end
			end
		end
	end
end)

wait(5)

sp:remove()






