local FileSystemService = game:GetService("FileSystemService")
local ProcessService = game:GetService("ProcessService")

local root = script.Parent

local args = ProcessService:GetCommandLineArgs()
local filename = args[1]

local model = root:FindFirstChildWhichIsA("Tool")
assert(model, "no Tool found")

local path = `gear/{filename}`
print("Writing to", path)
FileSystemService:WriteInstances(path, { model })
