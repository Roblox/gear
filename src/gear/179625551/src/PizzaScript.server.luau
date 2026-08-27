--[[ alexnewtron 2014 ]]--
-- voice by ejob
--Updated for R15 avatars by StarWars

local Tool = script.Parent;
enabled = true;

ghostChar = nil;
ghostHuman = nil;


function makeMeGhostly(trans)
	if ghostChar == nil then return end
	for i, v in pairs(ghostChar:GetChildren()) do
		if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then
			v.Transparency = trans
		end
	end	
end

function onActivated()
	if not enabled  then
		return;
	end
	enabled = false;
	Tool.GripForward = Vector3.new(.995, -.0995, -0)
	Tool.GripPos = Vector3.new(1.5, -0.9, -0.5)
	Tool.GripRight = Vector3.new(1, 0, 0.01)
	Tool.GripUp = Vector3.new(0.0995, .995, 0)
	Tool.Handle.DrinkSound:Play();
	wait(.8);
	local h = Tool.Parent:FindFirstChild("Humanoid");
	if (h ~= nil) then
		if (h.MaxHealth > h.Health + 1.6) then
			h.Health = h.Health + 1.6
		else	
			h.Health = h.MaxHealth
		end
		makeMeGhostly(.5)	
		h.WalkSpeed = 21;
	end
	Tool.GripForward = Vector3.new(0, 0, -1)
	Tool.GripPos = Vector3.new(0, 0, -0.55)
	Tool.GripRight = Vector3.new(-1, 0, 0.013)
	Tool.GripUp = Vector3.new(0,1,0)
	enabled = true;
end
function onEquipped()
	Tool.Handle.OpenSound:play();
	ghostChar = Tool.Parent;
	ghostHuman = Tool.Parent:FindFirstChild("Humanoid");
end
function onUnequipped()
	makeMeGhostly(0);
	if (ghostHuman ~= nil) then
		ghostHuman.WalkSpeed = 16;
	end
end
script.Parent.Activated:connect(onActivated);
script.Parent.Equipped:connect(onEquipped);
script.Parent.Unequipped:connect(onUnequipped)