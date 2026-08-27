local SoSGui = script.Parent
local Tool = SoSGui.Parent
local SoSServerScript = Tool:WaitForChild('SoSScript')
local AbilityRemoteEvent = SoSServerScript:WaitForChild('AbilityRemoteEvent')
local Frame = SoSGui:WaitForChild('Frame')
local BtnSmash = Frame:WaitForChild('BtnSmash')
local BtnSpin = Frame:WaitForChild('BtnSpin')
local cdSmash = Frame:WaitForChild('cdSmash')
local cdSpin = Frame:WaitForChild('cdSpin')

local function onButtonSpin()
	AbilityRemoteEvent:FireServer('e')
end

local function onButtonSmash()
	AbilityRemoteEvent:FireServer('q')
end

BtnSpin.MouseButton1Click:connect(onButtonSpin)
BtnSmash.MouseButton1Click:connect(onButtonSmash)
