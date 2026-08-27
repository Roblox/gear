local Tool = script.Parent
local stabAnim = nil
local throwAnim = nil
local h = nil
local con = nil

function standardGrip()
	Tool.GripPos = Vector3.new(0,0,0)
end


function onEquippedLocal(mouse)

	h = Tool.Parent:FindFirstChild("Humanoid")
	if h == nil then return end
	stabAnim = h:LoadAnimation(Tool.tridentstab)

	stabAnim.KeyframeReached:connect(function(key)
		if key == "end" then
			Tool.Attacking.Value = false
		end
	end)

	throwAnim = h:LoadAnimation(Tool.tridentthrow)
	mouse.Icon = "rbxasset://textures\\GunCursor.png"

end

function onUnequippedLocal()

	stabAnim:Stop()
	stabAnim:remove()

	throwAnim:Stop()
	throwAnim:remove()

end

Tool.Equipped:connect(onEquippedLocal)
Tool.Unequipped:connect(onUnequippedLocal)

function animationManager(value)
	
	if value == "stab" then
		Tool.GripPos = Vector3.new(0,0,-1.8)
		Tool.Attacking.Value = true
		stabAnim:Play()
		delay(1.1,standardGrip)
	elseif value == "throw"then
		Tool.GripUp = Vector3.new(0,0,-1)
		throwAnim:Play()
		wait(1)
		Tool.GripUp = Vector3.new(0,0,1)
		wait(4)
	end

end

con = Tool.Action.Changed:connect(animationManager)

