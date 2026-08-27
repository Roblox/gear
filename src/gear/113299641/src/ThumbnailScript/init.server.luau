local Tool = script.Parent
local ToolHandle = Tool:WaitForChild('Handle')
local ToolScript = Tool:WaitForChild('HeadJetsScript')

ToolHandle.Transparency = 0
for _, child in pairs(script:GetChildren()) do
	child:Destroy()
end

ToolScript.Disabled = false
script:Destroy()
