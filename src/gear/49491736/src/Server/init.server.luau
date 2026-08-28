--Rescripted by TakeoHonorable

local Tool = script.Parent

local Handle = Tool:WaitForChild("Handle")

--Handle:WaitForChild("Smoke").Enabled = true

local SpellGui = Tool:WaitForChild("SpellGui"):Clone()

local BookSound = Handle:WaitForChild("BookSound")

local Remote = Tool:WaitForChild("ClientInput")
--local MouseLoc = Tool:WaitForChild("MouseLoc")

local ChosenSpellTag -- Dosen't do anything until a spell is chosen

local BaseUrl = "http://www.roblox.com/asset/?id="

local Properties = {
	CurrentRadius = 20,
}

local Services = {
	Debris = (game:FindService("Debris") or game:GetService("Debris")),
	Players = (game:FindService("Players") or game:GetService("Players")),
}

local MyPlayer,MyCharacter,MyHumanoid,MyTorso


function IsTeamMate(Player1, Player2)
	return (Player1 and Player2 and not Player1.Neutral and not Player2.Neutral and Player1.TeamColor == Player2.TeamColor)
end
	
function TagHumanoid(humanoid, player)
	local Creator_Tag = Instance.new("ObjectValue")
	Creator_Tag.Name = "creator";
	Creator_Tag.Value = player;
	Services.Debris:AddItem(Creator_Tag, 2)
	Creator_Tag.Parent = humanoid
end
	
function UntagHumanoid(humanoid)
	for _, v in pairs(humanoid:GetChildren()) do
		if v:IsA("ObjectValue") and v.Name == "creator" then
			v:Destroy()
		end
	end
end

function IsInTable(Table,Value)
	for _,v in pairs(Table) do
		if v == Value then
			return true
		end
	end
	return false
end

local IconConnections = {}

local function SelectSpell(ChosenSpell,SpellUI)
	--print("Choosing Spell")
	if not SpellGui or not ChosenSpell then return end
	for _,v in pairs(SpellUI:GetDescendants()) do
		if v.Name == "Flavor" then
			v.Visible = v.Parent == ChosenSpell
		end
	end
	ChosenSpellTag = ChosenSpell.Name
end


local Spell1,Spell2,Spell3,Spell4 = true,true,true,true -- Allows for consecutive reloads

local SpellFunctions = {
	["OneHealth"] = function(CharTable)
		if not Spell1 then return end
		Spell1 = false
		
		Handle:WaitForChild("BookSound"):Play()
		
		local Anim = MyHumanoid:LoadAnimation(Tool:FindFirstChild("BookAnim"..MyHumanoid.RigType.Name))
		if Anim then Anim:Play() end
		
		local Icon = SpellGui:WaitForChild("SpellGuiFrame"):WaitForChild(ChosenSpellTag)
		local Overlay = Icon:WaitForChild("Overlay")
		local LastText = Overlay.Text
		Icon.Image = BaseUrl.."2690241454"
		coroutine.wrap(function()
			for _,charaters in pairs(CharTable) do
				if not charaters:FindFirstChild("OneHealth") then
					local Script = script:WaitForChild("OneHealth"):Clone()
					Script.Parent = charaters
					Script.Disabled = false
				end
			end
		end)()
			
		for timer=20,1,-1 do
			Overlay.Text = ".."..timer..".."
			wait(1)
		end
		Overlay.Text = LastText
		Icon.Image = BaseUrl.."2689173936"
		Spell1 = true
		end,
		
	["HalfHealth"] = function(CharTable)
		if not Spell2 then return end
		Spell2 = false
		
		Handle:WaitForChild("BookSound"):Play()
		local Anim = MyHumanoid:LoadAnimation(Tool:FindFirstChild("BookAnim"..MyHumanoid.RigType.Name))
		if Anim then Anim:Play() end
			
		local Icon = SpellGui:WaitForChild("SpellGuiFrame"):WaitForChild(ChosenSpellTag)
		local Overlay = Icon:WaitForChild("Overlay")
		local LastText = Overlay.Text
		Icon.Image = BaseUrl.."2690242636"
		coroutine.wrap(function()
			for _,charaters in pairs(CharTable) do
				if not charaters:FindFirstChild("HalfHealth") then
					local Script = script:WaitForChild("HalfHealth"):Clone()
					Script.Parent = charaters
					Script.Disabled = false
				end
			end
		end)()
		for timer=10,1,-1 do
			Overlay.Text = ".."..timer..".."
			wait(1)
		end
		Overlay.Text = LastText
		Icon.Image = BaseUrl.."2689174848"
		Spell2 = true
	end,
	["Health&Speed"] = function(CharTable)
		if not Spell3 then return end
		Spell3 = false
		
		Handle:WaitForChild("BookSound"):Play()
		
		local Anim = MyHumanoid:LoadAnimation(Tool:FindFirstChild("BookAnim"..MyHumanoid.RigType.Name))
		if Anim then Anim:Play() end
		
		local Icon = SpellGui:WaitForChild("SpellGuiFrame"):WaitForChild(ChosenSpellTag)
		local Overlay = Icon:WaitForChild("Overlay")
		local LastText = Overlay.Text
		Icon.Image = BaseUrl.."2690242263"
		coroutine.wrap(function()
			for _,charaters in pairs(CharTable) do
				if not charaters:FindFirstChild("Health&Speed") then
					local Script = script:WaitForChild("Health&Speed"):Clone()
					local Creator = Instance.new("ObjectValue")
					Creator.Name = "Creator"
					Creator.Value = MyPlayer
					Creator.Parent = Script
					Script.Parent = charaters
					Script.Disabled = false
				end
			end
		end)()
		for timer=7,1,-1 do
			Overlay.Text = ".."..timer..".."
			wait(1)
		end
		Overlay.Text = LastText
		Icon.Image = BaseUrl.."2689174652"
		Spell3 = true
	end,
		["LessSpeed"] = function(CharTable)
		if not Spell4 then return end
		Spell4 = false
		
		Handle:WaitForChild("BookSound"):Play()
		
		local Anim = MyHumanoid:LoadAnimation(Tool:FindFirstChild("BookAnim"..MyHumanoid.RigType.Name))
		if Anim then Anim:Play() end
		
		local Icon = SpellGui:WaitForChild("SpellGuiFrame"):WaitForChild(ChosenSpellTag)
		local Overlay = Icon:WaitForChild("Overlay")
		local LastText = Overlay.Text
		Icon.Image = BaseUrl.."2690241889"
		coroutine.wrap(function()
			for _,charaters in pairs(CharTable) do
				if not charaters:FindFirstChild("LessSpeed") then
					local Script = script:WaitForChild("LessSpeed"):Clone()
					Script.Parent = charaters
					Script.Disabled = false
				end
			end
		end)()
		for timer=12,1,-1 do
			Overlay.Text = ".."..timer..".."
			wait(1)
		end
		Overlay.Text = LastText
		Icon.Image = BaseUrl.."2689174397"
		Spell4 = true
	end
}

function Equipped()
	MyCharacter = Tool.Parent;
	MyHumanoid = MyCharacter:FindFirstChildOfClass("Humanoid");
	MyPlayer = Services.Players:GetPlayerFromCharacter(MyCharacter);
	MyTorso = MyCharacter:WaitForChild("HumanoidRootPart")
	SpellGui.Parent = MyPlayer:WaitForChild("PlayerGui")
	IconConnections[#IconConnections+1] = SpellGui:WaitForChild("SpellGuiFrame"):WaitForChild("HalfHealth").MouseButton1Click:Connect(function()
		SelectSpell(SpellGui:WaitForChild("SpellGuiFrame"):WaitForChild("HalfHealth"),SpellGui)
	end)
	IconConnections[#IconConnections+1] = SpellGui:WaitForChild("SpellGuiFrame"):WaitForChild("Health&Speed").MouseButton1Click:Connect(function()
		SelectSpell(SpellGui:WaitForChild("SpellGuiFrame"):WaitForChild("Health&Speed"),SpellGui)
	end)
	IconConnections[#IconConnections+1] = SpellGui:WaitForChild("SpellGuiFrame"):WaitForChild("LessSpeed").MouseButton1Click:Connect(function()
		SelectSpell(SpellGui:WaitForChild("SpellGuiFrame"):WaitForChild("LessSpeed"),SpellGui)
	end)
	IconConnections[#IconConnections+1] = SpellGui:WaitForChild("SpellGuiFrame"):WaitForChild("OneHealth").MouseButton1Click:Connect(function()
		SelectSpell(SpellGui:WaitForChild("SpellGuiFrame"):WaitForChild("OneHealth"),SpellGui)
	end)
end

function Unequipped()
	--MyCharacter,MyHumanoid,MyPlayer,MyTorso = nil,nil,nil,nil
	SpellGui.Parent = nil
	for _,v in pairs(IconConnections) do
		if v then
			v:Disconnect()
		end
	end
end

function Activated()
	if (MyCharacter and MyHumanoid) and MyHumanoid.Health ~= 0 and ChosenSpellTag then
		if ChosenSpellTag then
			--if not Tool.Enabled then return end
			--Tool.Enabled = false
			--print("Activated")
			local Pos = MyTorso.CFrame.p + Vector3.new(1,1,1)*Properties.CurrentRadius
			local Neg = MyTorso.CFrame.p - Vector3.new(1,1,1)*Properties.CurrentRadius
			local Region = Region3.new(Neg,Pos)
			local CharacterTable = {}
			for _,parts in pairs(workspace:FindPartsInRegion3WithIgnoreList(Region,{MyCharacter},math.huge)) do
				if parts and parts.Parent and (parts.CFrame.p-MyTorso.CFrame.p).Magnitude <= Properties.CurrentRadius and parts.Parent:FindFirstChildOfClass("Humanoid") and not IsInTable(CharacterTable,parts.Parent) then
					local Hum,ForceField = parts.Parent:FindFirstChildOfClass("Humanoid"),parts.Parent:FindFirstChildOfClass("ForceField")
					if not ForceField and Hum and Hum.Health ~= 0 and not IsTeamMate(MyPlayer,Services.Players:GetPlayerFromCharacter(Hum.Parent)) then
						CharacterTable[#CharacterTable+1] = parts.Parent
					end
				end
			end
			SpellFunctions[ChosenSpellTag](CharacterTable)
			--Handle:WaitForChild("Smoke").Enabled = true
			--Tool.Enabled = true
		end
	end
end

Tool.Equipped:Connect(Equipped)
Tool.Unequipped:Connect(Unequipped)
Tool.Activated:Connect(Activated)

Remote.OnServerEvent:Connect(function(Player,KeyCode)
	if Player ~= MyPlayer or not MyCharacter or not MyHumanoid then return end
	
	if KeyCode == Enum.KeyCode.Q then
		SelectSpell(SpellGui:WaitForChild("SpellGuiFrame"):WaitForChild("OneHealth"),SpellGui)
	elseif KeyCode == Enum.KeyCode.E then
		SelectSpell(SpellGui:WaitForChild("SpellGuiFrame"):WaitForChild("HalfHealth"),SpellGui)
	elseif KeyCode == Enum.KeyCode.R then
		SelectSpell(SpellGui:WaitForChild("SpellGuiFrame"):WaitForChild("Health&Speed"),SpellGui)
	elseif KeyCode == Enum.KeyCode.X then
		SelectSpell(SpellGui:WaitForChild("SpellGuiFrame"):WaitForChild("LessSpeed"),SpellGui)
	end
end)