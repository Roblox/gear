local Tool = script.Parent
local throwStrength = 0
local count = false
local p = nil
local gui = nil
local thrower = nil

local Animations = Tool:WaitForChild("Animations")
local R6Folder = Animations:WaitForChild("R6")
local R15Folder = Animations:WaitForChild("R15")

function onEquippedLocal(mouse)

	mouse.Button1Down:connect(mouse1Down)
	mouse.Button1Up:connect(mouse1Up)
	p = game.Players:GetPlayerFromCharacter(Tool.Parent)
	gui = Tool.ThrowGui:clone()
	gui.Parent = p.PlayerGui

	local humanoid = Tool.Parent:FindFirstChild("Humanoid")
	if humanoid ~= nil then 
		if humanoid.RigType == Enum.HumanoidRigType.R15 then
			thrower = humanoid:LoadAnimation(R6Folder:WaitForChild("throw"))
		else
			thrower = humanoid:LoadAnimation(R15Folder:WaitForChild("throw"))
		end
	end

end

function onUnequippedLocal(mouse)

	thrower:remove()
	gui:remove()

end

function mouse1Down()

	throwStrength = 0
	count = true
	countStrength()

end



function mouse1Up()

	wait()
	count = false
	Tool.ThrowStrength.Value = throwStrength
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

