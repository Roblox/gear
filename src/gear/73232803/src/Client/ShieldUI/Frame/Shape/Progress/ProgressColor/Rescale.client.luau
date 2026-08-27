local Main = script.Parent
local ScaleRep = script.Parent.Parent.Parent

ScaleRep:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()

	Main.Size = UDim2.new(0,ScaleRep.AbsoluteSize.X,0,ScaleRep.AbsoluteSize.Y+1)
	
end)