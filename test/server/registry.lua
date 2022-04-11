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
                stoneAxe = 1,
                log = 34
            }
        }
    })
    
    local numLogs = registry:lookup("kyrethia/inventory/log");
    --print(numLogs);
    Registry.remove("PlayerData");
    
    return numLogs;
end

function RegistryTests:IntermediateSearch()
    local registry = Registry.new("PlayerData2", {
        kyrethia = {
            money = 5;
            level = 3;
            xp = 2;
    
            inventory = {
                { name = "stoneAxe", quantity = 1 },
                { name = "log", quantity = 34 }
            }
        }
    })
    
    local logData = registry:search("kyrethia/inventory"):with({name = "log"}):getFirst();
    --print(logData.quantity);
    Registry.remove("PlayerData2");
    
    return logData;
end

function RegistryTests:AdvancedSearch()
    local registry = Registry.new("PlayerData3", {
        kyrethia = {
            money = 5;
            level = 3;
            xp = 2;
    
            inventory = {
                { name = "stoneAxe", quantity = 1, metadata = { durability = 35 } },
                { name = "stonePickaxe", quantity = 1, metadata = { durability = 78 } },
                { name = "stoneSword", quantity = 1, metadata = { durability = 64 } },
    
                { name = "logs", quantity = 34 }
            }
        }
    })
    
    local itemsOverHalfDurability = registry:search("kyrethia/inventory"):forEach(function(key, value, exclude)
        if value.metadata then
            
        else
            exclude()
        end
    end):get()

    Registry.remove("PlayerData3");

    return itemsOverHalfDurability;
end

return RegistryTests