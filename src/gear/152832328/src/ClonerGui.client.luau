while not game.Workspace do wait() end

local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Create = LoadLibrary('RbxUtility').Create

local getAllEggs = ReplicatedStorage:WaitForChild('GetAllEggs')
local chooseEgg = script.Parent.ChooseEgg

local gui
local tool = script.Parent

local function CreateGui()
	local EggsModels = getAllEggs:InvokeServer()
	local player = game.Players.LocalPlayer
	if not player then return false end
	gui = Create'ScreenGui'{
		Name = 'ClonerGui';
		Parent = game.Players.LocalPlayer:WaitForChild('PlayerGui');
		Create'Frame'{
			Name = 'Frame';
			BackgroundTransparency = 1;
		};
	}
	local i = 0
	for _, eggModel in pairs(EggsModels) do 
		if eggModel.Respawn.Value >= 1800 then
			local eggButton = Create'ImageButton'{
				Name = eggModel.Name;
				Parent = gui.Frame; 
				Image = "http://www.roblox.com/asset/?id=" .. eggModel.UnselectedIcon.Value ;
				BackgroundTransparency = 1.0;
				Size = UDim2.new(0, 80, 0, 80) ;
				Position = UDim2.new(0, i*80 , 0, 0) ;
			}
			i = i + 1
			eggButton.MouseButton1Click:connect(function()
				for _, eButton in pairs(gui.Frame:GetChildren()) do 
					eButton.Image = "http://www.roblox.com/asset/?id=" .. eggModel.UnselectedIcon.Value 
				end
				eggButton.Image = "http://www.roblox.com/asset/?id=" .. eggModel.SelectedIcon.Value
				chooseEgg:FireServer(eggModel.Name)
			end)
		end
	end 
	gui.Frame.Position = UDim2.new(0.5, -i*40, 0.850000024, -120);
	gui.Frame.Size = UDim2.new(0, i*80, 0, 80);
end 

function OnEquipped()
	if not gui then CreateGui() end
	gui.Frame.Visible = true
end

tool.Equipped:connect(OnEquipped)
tool.Unequipped:connect(function() if gui then gui.Frame.Visible = false end end)
