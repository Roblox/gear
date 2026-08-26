-- These internal services exist in the robloxdev-cli environment that runs this
-- script, but are absent from both Selene's standard library and the public
-- API dump used for analysis.
-- selene: allow(incorrect_standard_library_use)
local FileSystemService = game:GetService("FileSystemService") :: any
-- selene: allow(incorrect_standard_library_use)
local ProcessService = game:GetService("ProcessService") :: any

local root = assert(script.Parent, "script must be parented to the model")

local args = ProcessService:GetCommandLineArgs()
local filename = args[1]

local model = root:FindFirstChildWhichIsA("Tool")
assert(model, "no Tool found")

local path = `gear/{filename}`
print("Writing to", path)
FileSystemService:WriteInstances(path, { model })
