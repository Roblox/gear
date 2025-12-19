--!nonstrict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Jest = (require :: any)(ReplicatedStorage.Packages.Jest)

local root = ReplicatedStorage.Src

local status, result = Jest.runCLI(root, {
	verbose = false,
	ci = false,
}, { root }):awaitStatus()

if status == "Rejected" then
	print(result)
end

if status ~= "Resolved" or result.results.numFailedTestSuites > 0 or result.results.numFailedTests > 0 then
	return false
end

return true
