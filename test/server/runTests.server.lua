local ReplicatedStorage = game:GetService("ReplicatedStorage")
local testez = require(ReplicatedStorage.DevPackages.testez);

local tests = testez.TestBootstrap:run(
    script.Parent:GetChildren()
)