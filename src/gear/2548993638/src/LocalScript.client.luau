local Tool = script.Parent
local stabAnim = nil
local throwAnim = nil
local h = nil
local con = nil

local animations =
{
	tridentstab = nil;
	tridentthrow = nil;
}

function standardGrip()
	Tool.GripPos = Vector3.new(0,0,0)
end


function onEquippedLocal(mouse)

	h = Tool.Parent:FindFirstChild("Humanoid")
	if h == nil then return end
	if h and h.RigType == Enum.HumanoidRigType.R15 then
		animations =
		{
			tridentstab = Tool.Animations.R15.tridentstab;
			tridentthrow = Tool.Animations.R15.tridentthrow;
		}
	else
		animations =
		{
			tridentstab = Tool.Animations.R6.tridentstab;
			tridentthrow = Tool.Animations.R6.tridentthrow;
		}
	end
	stabAnim = h:LoadAnimation(animations.tridentstab)
	
	stabAnim.KeyframeReached:connect(function(key)
		if key == "end" then
			Tool.Attacking.Value = false
		end
	end)

	throwAnim = h:LoadAnimation(animations.tridentthrow)
	mouse.Icon = "rbxasset://textures\\GunCursor.png"

end

function onUnequippedLocal()

	stabAnim:Stop()
	stabAnim:Destroy()

	throwAnim:Stop()
	throwAnim:Destroy()

end

Tool.Equipped:connect(onEquippedLocal)
Tool.Unequipped:connect(onUnequippedLocal)

function animationManager(value)
	
	if value == "stab" then
		Tool.GripPos = Vector3.new(0,-1.8,0)
		Tool.Attacking.Value = true
		stabAnim:Play()
		delay(1.1,standardGrip)
	elseif value == "throw"then
		Tool.GripUp = Vector3.new(0,-1,0)
		throwAnim:Play()
		wait(1)
		Tool.GripUp = Vector3.new(0,1,0)
		wait(4)
	end

end

con = Tool:WaitForChild("Action").Changed:connect(animationManager)

