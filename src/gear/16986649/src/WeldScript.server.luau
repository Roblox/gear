local basebolt = require(230095940)
basebolt.Parent = script.Parent
w2 = Instance.new("Weld")
w2.Name = "BoltWeld" 
w2.Parent = script.Parent.Handle 
w2.Part0 = script.Parent.Handle 
w2.Part1 = basebolt 
w2.C1 = CFrame.new(0,-.35,-1.6)

