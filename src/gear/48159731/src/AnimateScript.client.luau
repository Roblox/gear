--Fixed by Luckymaxer

Tool = script.Parent
Handle = Tool:WaitForChild("Handle")

-- Animations
local slashAnim
local twoHandAnim
local twoHandedSlashAnim

ToolEquipped = false

function animate()
	if Tool:FindFirstChild("Growth").Value > 3 and ToolEquipped then
		if twoHandAnim then
			twoHandAnim:Stop()
		end
		myHumanoid = Tool.Parent:FindFirstChild("Humanoid")
		twoHandAnim = myHumanoid:LoadAnimation(Tool.TwoHandAnim)
		twoHandAnim:Play()
	end
end

function onActivatedL()
	myHumanoid = Tool.Parent:FindFirstChild("Humanoid")
	if myHumanoid == nil then 
		return
	end
	if Tool.Enabled == true and ToolEquipped then 
		if Tool:FindFirstChild("Growth").Value > 3 then
			twoHandedSlashAnim = myHumanoid:LoadAnimation(Tool.TwoHandedSlash)
			twoHandedSlashAnim:Play()
			wait(0.5)
		else
			slashAnim = myHumanoid:LoadAnimation(Tool.SideSlash)
			slashAnim:Play()
		end
	end
end

function onEquippedL()
	ToolEquipped = true
end

function onUnequippedL()
	ToolEquipped = false
	for i, v in pairs({slashAnim, twoHandAnim, twoHandedSlashAnim}) do
		if v then
			v:Stop()
		end
	end
	if connection then connection:disconnect() end
end

Tool.Activated:connect(onActivatedL)
Tool.Equipped:connect(onEquippedL)
Tool.Unequipped:connect(onUnequippedL)

connection = Tool:FindFirstChild("Growth").Changed:connect(animate)
