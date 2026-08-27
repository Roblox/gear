local Tool = script.Parent
local throwStrength = 0
local count = false
local p = nil
local gui = nil
local thrower = nil

local ControllerEvent = Tool:WaitForChild("Controller")

function onEquippedLocal(mouse)

	mouse.Button1Down:connect(mouse1Down)
	mouse.Button1Up:connect(mouse1Up)
	p = game.Players:GetPlayerFromCharacter(Tool.Parent)
	gui = Tool.ThrowGui:clone()
	gui.Parent = p.PlayerGui

	local humanoid = Tool.Parent:FindFirstChild("Humanoid")
	if humanoid ~= nil then 
		local Animation = Tool:WaitForChild("throw")
		if humanoid.RigType == Enum.HumanoidRigType.R15 then 
			Animation = Tool:WaitForChild("R15throw")
		end 
		thrower = humanoid:LoadAnimation(Animation)
	end

end

function onUnequippedLocal(mouse)
	if thrower then 
		thrower:Stop()
		thrower:Destroy()
	end 
	thrower = nil
	gui:Destroy()

end

function mouse1Down()
	if not Tool.Enabled then return end 
	throwStrength = 0
	count = true
	countStrength()

end



function mouse1Up()

	wait()
	count = false
--	Tool.ThrowStrength.Value = throwStrength
	ControllerEvent:FireServer(throwStrength)
	gui.Frame.Visible = false
	thrower:Play(0.1,1,throwStrength/20)

end


function countStrength()

	gui.Frame.Visible = true
	while count do

		throwStrength = throwStrength + 2
		if throwStrength <= 200 then
			p.PlayerGui.ThrowGui.Frame.StrengthBar.Size = UDim2.new(1,0,-throwStrength/200,0)
		end
		wait()

	end

end


Tool.Equipped:connect(onEquippedLocal)
Tool.Unequipped:connect(onUnequippedLocal)

