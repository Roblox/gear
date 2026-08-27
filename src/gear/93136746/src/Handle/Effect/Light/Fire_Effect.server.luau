local Fire = script.Parent
local Rate = 1/1000
local Amplitude = .5

while Fire do
	for i=1,3,1 do
		script.Parent.Range = script.Parent.Range + Amplitude
		wait(Rate)
	end
	for i=1,2,1 do
		script.Parent.Range = script.Parent.Range - Amplitude
		wait(Rate)
	end
	for i=1,1,1 do
		script.Parent.Range = script.Parent.Range + Amplitude
		wait(Rate)
	end
	for i=1,2,1 do
		script.Parent.Range = script.Parent.Range - Amplitude
		wait(Rate)
	end
end