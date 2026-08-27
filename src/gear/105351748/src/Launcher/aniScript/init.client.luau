--[[Super Util]]--
function WaitForChild(parent,child)
	while not parent:FindFirstChild(child) do  wait(1/30) end
	return parent[child]
end

function MakeValue(class,name,value,parent)
	local temp = Instance.new(class)
	temp.Name = name
	temp.Value = value
	temp.Parent = parent
	return temp
end	

function TweenProperty(obj, propName, inita, enda, length)
	local startTime = tick()
	while startTime - tick()<length do
		obj[propName] = (startTime - tick())/length
		wait(1/30)
	end
	obj[propName] = enda	
end

--[[Constants]]--

--[[Workspace Variables]]--
local animation = WaitForChild(script,'Animation')
local animator = WaitForChild(script,'animator')
--[[Script Variables]]--

--[[Script Functions]]--

--[[Running Logic]]--

local anitrack = animator.Value:LoadAnimation(animation)
anitrack:Play()
wait(10)
script:Destroy()