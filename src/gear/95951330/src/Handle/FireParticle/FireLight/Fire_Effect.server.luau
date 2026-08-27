local Fire = script.Parent
local Rate = 1/1000


while Fire do
	for i=1,3,1 do
		script.Parent.Range = script.Parent.Range + 1
		wait(Rate)
	end
	for i=1,2,1 do
		script.Parent.Range = script.Parent.Range - 1
		wait(Rate)
	end
	for i=1,1,1 do
		script.Parent.Range = script.Parent.Range + 1
		wait(Rate)
	end
	for i=1,2,1 do
		script.Parent.Range = script.Parent.Range - 1
		wait(Rate)
	end
end