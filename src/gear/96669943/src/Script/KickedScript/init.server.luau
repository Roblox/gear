local MyCharacter = script.Parent

if MyCharacter and MyCharacter:FindFirstChild('Humanoid') and MyCharacter:FindFirstChild('Torso') then
	local humanoid = MyCharacter.Humanoid
	
	MyCharacter.Torso.Anchored=true
	humanoid.Parent=nil
	for _,i in pairs(game.Players:GetPlayerFromCharacter(MyCharacter).Backpack:GetChildren()) do
		i.Parent=nil
	end
	for _,i in pairs(MyCharacter:GetChildren()) do
		if i:IsA('Part') then
			i.CanCollide=false
			print('setting can collide false: ' .. i.Name)
		end
		if i:IsA('Tool') then
			i.Parent=nil
		end
	end
	
	wait(3.3)
	MyCharacter.Torso.Anchored=false
	
	--humanoid.Parent=MyCharacter
	while not script:FindFirstChild('RespawnScript') do print('WAIIIITING') wait() end
	local resScript=script:FindFirstChild('RespawnScript')
	resScript.Parent=game.Players:GetPlayerFromCharacter(MyCharacter).Backpack
	resScript.Disabled=false
end

--script:Destroy()
