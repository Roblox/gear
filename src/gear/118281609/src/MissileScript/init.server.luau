local NewInstance = LoadLibrary('RbxUtility')

local SquidGui = NewInstance.Create'ScreenGui'
				{
					Name = 'SquidGui';

					NewInstance.Create'Frame'
					{
						Name = 'SquidFrame';
						Size = UDim2.new(1, 0, 1, 0);
						BackgroundTransparency = 1.0; 
						Position = UDim2.new(0, 0, 0, 0); 
					}
				}
				

local Missile = script.Parent 

local Debris = Game:GetService('Debris') 

local Images_List = {118259001,  118261268} 

local function FireInk(sGui)
	if not sGui then return end 
	local img = NewInstance.Create'ImageLabel' 
				{
					Name = 'Ink';
					BackgroundTransparency = 1.0;
					Size = UDim2.new(0, math.random(125, 150), 0, math.random(125, 150));
					Position = UDim2.new(math.random(), 0, math.random(), 0);
					Image = 'http://www.roblox.com/asset/?id=' .. Images_List[math.random(1, #Images_List)];
					Parent = sGui:WaitForChild('SquidFrame');										
				}
				
	Debris:AddItem(img, 7.5) 
end 

Missile.Touched:connect(function(hPart)
	if hPart and hPart.Parent and Missile then 
		local character = hPart.Parent 
		local player = Game.Players:GetPlayerFromCharacter(character) 
		if script:WaitForChild('Character').Value == character then 
			return 
		end 
		if player then 
			local playerGui = player:FindFirstChild('PlayerGui')
			if playerGui then 
				local sGui = playerGui:FindFirstChild('SquidGui') 
				if not sGui then 				
					local sGui = SquidGui:Clone()
					sGui.Parent = playerGui 
				end 
				FireInk(sGui) 
			end 
		end 
		
	Missile:Destroy() 
	end 
end) 

wait(10.0)
Missile:Destroy() 