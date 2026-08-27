local RbxUtility = LoadLibrary('RbxUtility')
local Create = RbxUtility.Create

------------------------------------------
local function WaitFor(parent)
	return setmetatable({}, {
		__index = function(tb, child)
			return function()
				while not parent:FindFirstChild(child) do 
					parent.ChildAdded:wait()
				end
				return parent:FindFirstChild(child)			
			end
		end;
	})
end
----------------------------------------

local GhostValue = WaitFor(script).Target()
while not GhostValue.Value do wait() end

local Ghost = GhostValue.Value
local GhostTorso = WaitFor(Ghost).Torso()
local GhostHealth = WaitFor(Ghost).Health()

-----------------------------------------

local creator = WaitFor(WaitFor(Ghost).GhostScript()).creator()
while not creator.Value do wait() end
local Player = creator.Value
local PlayerGui = WaitFor(Player).PlayerGui()

------------------------------------------

--bail out if the ghost already died
if Player.Character.Humanoid.Health <= 0 or GhostHealth.Value <= 0 then
	script:Destroy()
	return
end

------------------------------------------

local Gui = Create'BillboardGui'{
	Parent = PlayerGui;
	Adornee = GhostTorso;
	Size = UDim2.new(2,0,1,0);
	--
	Create'TextLabel'{
		Name = 'HealthLabel';
		Font = 'ArialBold';
		TextScaled = true;
		Text = "150/150";
		BackgroundTransparency = 1;
		TextColor3 = Color3.new(0, 0.8, 0);
		TextStrokeColor3 = Color3.new(0, 0.3, 0);
		TextStrokeTransparency = 0.2;
		Size = UDim2.new(1,0,1,0);
	};
}

-----------------------------------------

Ghost.Changed:connect(function(pr)
	if pr == 'Parent' and not Ghost.Parent then
		--destroy us
		Gui:Destroy()
		script:Destroy()
	end
end)

------------------------------------------

GhostHealth.Changed:connect(function()
	Gui.HealthLabel.Text = ""..math.floor(GhostHealth.Value).."/150"
end)