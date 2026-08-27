function Create(ty)
	return function(data)
		local obj = Instance.new(ty)
		for k, v in pairs(data) do
			if type(k) == 'number' then
				v.Parent = obj
			else
				obj[k] = v
			end
		end
		return obj
	end
end

local Player = (game:FindService("Players") or game:GetService("Players")).LocalPlayer

local Tool = script.Parent

local GearRequest = Tool:WaitForChild("GearRequest")

local CloneUI = script:WaitForChild("GearCloneGUI")

local UI,LabelTemplate

local Events = {}

function Equipped()
	UI = CloneUI:Clone()
	LabelTemplate = UI:WaitForChild("Base"):WaitForChild("ScrollFrame"):WaitForChild("Template")
	LabelTemplate.Parent = nil
	local Backpack = Player:WaitForChild("Backpack")
	UI.Parent = Player:WaitForChild("PlayerGui")
	local count = 0
	--Assemble the list!
	local function AssembleList(SearchCriteria)
		count = 0
		local tools = Backpack:GetChildren()
		
		
		for _,entries in pairs(UI:WaitForChild("Base"):WaitForChild("ScrollFrame"):GetChildren()) do--Clear the previous entries
			if entries:IsA("Frame") then
				entries:Destroy()
			end
		end
		
		for i=1,#tools,1 do -- Make new entries
			if tools[i] and tools[i]:IsA("Tool") and (not SearchCriteria or string.find(string.lower(tools[i].Name),string.lower(SearchCriteria))) then
				local Template = LabelTemplate:Clone()
				Template:WaitForChild("ToolName").Text = tools[i].Name
				Template:WaitForChild("Icon").Image = tools[i].TextureId
				Template.Name = tools[i].Name
				Template.Parent = UI:WaitForChild("Base"):WaitForChild("ScrollFrame")
				local ToolRef = Create("ObjectValue"){
					Name = "ToolRef",
					Value = tools[i],
					Parent = Template
				}
				Events[#Events+1] = Template:WaitForChild("ToolName").Activated:Connect(function()
					--print(Template.Name .. " has been activated!")
					GearRequest:FireServer(ToolRef.Value)
					if UI then 
						UI:Destroy()
					end
				end)
				count = count + 1
			end
		end
		LabelTemplate.Parent = UI:WaitForChild("Base"):WaitForChild("ScrollFrame")
		UI:WaitForChild("Base"):WaitForChild("ScrollFrame").CanvasSize = UDim2.new(0,0,0,((LabelTemplate.AbsoluteSize.Y)*count))
		LabelTemplate.Parent = nil
	end
	AssembleList(nil) --Fill up the entry without any specific searches

	Events[#Events+1] = UI:WaitForChild("Base"):WaitForChild("ScrollFrame"):GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		LabelTemplate.Parent = UI:WaitForChild("Base"):WaitForChild("ScrollFrame")
		UI:WaitForChild("Base"):WaitForChild("ScrollFrame").CanvasSize = UDim2.new(0,0,0,((LabelTemplate.AbsoluteSize.Y)*count))
		LabelTemplate.Parent = nil
	end)
	Events[#Events+1] = UI:WaitForChild("Base"):WaitForChild("Search"):GetPropertyChangedSignal("Text"):Connect(function()
		--Change the results based on what was given in the search results
		AssembleList(UI:WaitForChild("Base"):WaitForChild("Search").Text)
	end)
end


function Unequipped()
	if UI then
		UI:Destroy()
	end
	for i=1,#Events do
		if Events[i] then
			Events[i]:Disconnect(); Events[i] = nil
		end
	end
end

Tool.Equipped:Connect(Equipped)
Tool.Unequipped:Connect(Unequipped)