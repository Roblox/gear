local Tool = script.Parent

function removeSwords(itemsToRemove)
	for i = 1, #itemsToRemove do 
		itemsToRemove[i]:Remove()  
	end
end

function createAllSeasonSword(summerSword)
	summerSword.GripPos = Vector3.new(0, 0, -2.5)
	sword = summerSword.Handle
	swordMesh = sword.Mesh
	swordMesh.MeshId = "http://www.roblox.com/asset/?id=54383785"
	swordMesh.TextureId = "http://www.roblox.com/asset/?id=54383840"
	summerSword.TextureId = "http://www.roblox.com/asset/?id=54383861"

	summerSword.Parent = script.Parent

	wait(0.5)
	
	summerSword.Name = "AllSeasonsSword"
	summerScript = summerSword:FindFirstChild("SummerSwordScript")
	sumAnimateScript = summerSword:FindFirstChild("SummerAnimateScript")
	if summerScript then summerScript.Disabled = true summerScript:Remove() end
	if sumAnimateScript then sumAnimateScript.Disabled = true sumAnimateScript:Remove() end

	seasonsScript = summerSword:FindFirstChild("SeasonsSwordScript")
	if seasonsScript then seasonsScript.Disabled = false end
	
	seasonsAnimScript = summerSword:FindFirstChild("SeasonsAnimateScript")
	if seasonsAnimScript then seasonsAnimScript.Disabled = false end

	regenScript = summerSword:FindFirstChild("RegenScript")
	--if regenScript then regenScript.Disabled = true wait(1.0) regenScript.Disabled = false end

	checkScript = summerSword:FindFirstChild("CheckForAllSeasons")
	if checkScript then checkScript:Remove() end

	wait(1.0)
	script:Remove()
end

while true do 
	wait(3.0)
	local summerSword	
	vPlayer = game.Players:GetPlayerFromCharacter(script.Parent)
	local count = 0
	local countSummer = 0
	local itemsToRemove = {}
	if vPlayer ~= nil then
		items = vPlayer.Backpack:GetChildren()
		for i = 1, #items do 
			if items[i].Name == "FallSwordFixed" or items[i].Name == "SpringSwordOfGrowth" or items[i].Name == "WinterSword" then 
				print("Finding others")
				count = count + 1
				table.insert(itemsToRemove, items[i])
			elseif items[i].Name == "SummerSword" and countSummer == 0 then
				print("Finding Summer")
				count = count + 1
				countSummer = 1 
				if summerSword  == nil then 
					summerSword = items[i]:Clone() 
				end
				table.insert(itemsToRemove, items[i])
			end
		end
	end	
	if count == 4 then 		
		removeSwords(itemsToRemove)		
		createAllSeasonSword(summerSword)
	end
end


