local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Registry = require(ReplicatedStorage.Registry);

local RegistryTests = {}

function RegistryTests:SimpleLookup()
    local registry = Registry.new("PlayerData", {
        kyrethia = {
            money = 5;
            level = 3;
            xp = 2;

            inventory = {
                stoneAxe = 1
            }
        }
    })

    local stoneAxeData = registry:lookup("kyrethia/inventory/stoneAxe");
    
    return stoneAxeData;
end

function RegistryTests:IntermediateSearch()
    local registry = Registry.new("PlayerData2", {
        kyrethia = {
            money = 5;
            level = 3;
            xp = 2;

            inventory = {
                { name = "stoneAxe", quantity = 1 }
            }
        }
    })

    local stoneAxeData = registry:search("kyrethia/inventory"):with({ name = "stoneAxe" }):get()[1];
    return stoneAxeData;
end

function RegistryTests:AdvancedLookup()
    
end

return RegistryTests