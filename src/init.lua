local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--[[ -- Types -- ]] --

--[=[
    @class RegistryModule

    The entry point for the registry system.
]=]
type RegistryModule = {
    new: (registryName: string, initial: table, immutable: boolean?) -> Registry;
    buildVirtualRegistry: (name: string, instance: Instance, recursive: boolean?) -> Registry;
    remove: (name: string) -> ();
};

--[=[
    @class Registry

    A registry created from a table, with a variety of indexing and search functions.
]=]
--- @prop name string
--- @within Registry

type Registry = {
    name: string;

    lookup: (path: string) -> any?;
    search: (path: string) -> SearchResult?;
    set: (path: string, key: RegistryKey, value: any) -> ();

    __registry: table;
    __immutable: boolean;
};

--[=[
    @class SearchResult

    A SearchResult can be chained with itself using a variety of functions for advanced indexing.
]=]
type SearchResult = {
    new: (activeDirectory: table) -> SearchResult;
    with: (searchIndex: Array<string> | Dictionary<any>) -> SearchResult;
    is: (searchValue: any) -> SearchResult;
    forEach: (key: RegistryKey, value: any) -> ();
    get: () -> {[string | number]: any}?;
    getFirst: () -> any?;

    __currentSubjects: table?;
    __directory: table;
};

--[=[
    @type SearchIndex {[string | number]: any} | {string | number}
    @within SearchResult
    A search index can be an array or a dictionary. If it is an array, it will only check if the element being searched has
    each key. If it is a dictionary, it will check if the element has both the key and if the key is equal to the value.
]=]
type SearchIndex = {
    [any]: any;
}

type RegistryKey = string | number;

--[[ -- General functions -- ]] --

local function splitPath(path: string): Array<string>
    local elements = string.split(path, "/");
    for i, element in pairs(elements) do
        if string.match(element, "^%s*$") then
            table.remove(elements, i);
        end
    end

    return elements;
end

local function getTableType(t: table): string
    if type(t) ~= "table" then return "unknown" end;

    local function isEmpty(): boolean
        return (next(t) == nil);
    end

    local function isArray(): boolean
        local count = 0
        for i in pairs(t) do
            if type(i) ~= "number" then
                return false;
            else
                count += 1;
            end
        end

        for i = 1, count do
            if not t[i] and type(t[i]) ~= "nil" then
                return false;
            end
        end

        return true;
    end

    local function isDictionary(): boolean
        return ((#t == 0) and (next(t) == nil));
    end

    local function isMixed(): boolean
        local arrayCount = 0;
        local totalCount = 0;
        for _ in ipairs(t) do arrayCount += 1 end;
        for _ in pairs(t) do totalCount += 1 end;
        return arrayCount > 0 and totalCount > arrayCount;
    end

    if isEmpty() then return "array" end;
    if isMixed() then return "mixed" end;
    if isArray() then return "array" end;
    if isDictionary() then return "dictionary" end;

    return "unknown";
end

local function deepCopy(t: table): table?
    assert(type(t) == "table", "deepCopy must be called on a table.");

	local copy = {}

	for key, value in pairs(t) do
		if type(value) == "table" then
			value = deepCopy(value)
		end
		copy[key] = value
	end

	return copy
end

--[[ -- SearchResult -- ]] --

local SearchResult = {}
SearchResult.__index = SearchResult;

--[=[
    @private
    @function new
    @within SearchResult

    @param activeDirectory table
    @return SearchResult
]=]
function SearchResult.new(activeDirectory: table): SearchResult
    local self = setmetatable({
        __directory = activeDirectory;
    }, SearchResult);

    return self;
end

--[=[
    @function with
    @within SearchResult

    @param searchIndex SearchIndex
    @return SearchResult

    Checks each element within the current search directory against SearchIndex. See the SearchIndex type for more information.

    ```lua
    local items = Registry.new("Items", {
        melee = {
            axes = {
                { name = "stoneAxe", quantity = 1 }
            }
        }
    })

    -- returns the data table for the stone axe
    local stoneAxeData = items:search("melee/axes"):with({ name = "stoneAxe" }):get()
    ```
]=]
function SearchResult:with(searchIndex: table): SearchResult
    if type(searchIndex) ~= "table" then
        return self :: SearchResult;
    else
        if (not getTableType(searchIndex) == "array") or (not getTableType(searchIndex)) then
            return self :: SearchResult;
        end
    end

    local currentSubjects = self.__currentSubjects;
    self.__currentSubjects = {};

    local function checkWith(directory)
        if type(directory) ~= "table" then return end;

        for key: RegistryKey, value: any in pairs(directory) do
            if type(value) == "table" then
                local isValid = true;
                for searchKey, searchValue in pairs(searchIndex) do
                    if getTableType(searchIndex) == "array" then
                        if not value[searchValue] then
                            isValid = false;
                            break;
                        end
                    else
                        if value[searchKey] ~= searchValue then
                            isValid = false;
                            break;
                        end
                    end
                end

                if isValid then
                    self.__currentSubjects[key] = value;
                end
            end
        end
    end

    checkWith(currentSubjects or self.__directory);

    return self :: SearchResult;
end

--[=[
    @ignore
    @function is
    @within SearchResult

    @param searchValue any
    @return SearchResult
]=]
function SearchResult:is(searchValue: any): SearchResult
    local currentSubjects = self.__currentSubjects;
    self.__currentSubjects = {};

    local function checkWith(directory)
        if type(directory) ~= "table" then return end;

        for key: RegistryKey, value: any in pairs(directory) do
            if value == searchValue then
                self.__currentSubjects[key] = value;
            end
        end
    end

    checkWith(currentSubjects or self.__directory);

    return self :: SearchResult;
end

--[=[
    @function forEach
    @within SearchResult

    @param callback (key: string | number, value: any, exclude: () -> ()) -> ()
    @return SearchResult
    
    Loops over the current search directory and runs the given callback on every element. This is especially useful for implementing your own
    logic (ex. checking if a value is greater than or less than a certain value.).

    The callback function is supplied with an `exclude` function. By default, calling forEach() will not alter the search results. Instead,
    the loop uses a blacklist that will keep all search results until you call `exclude`, which will remove the element from the results.
    See Examples for more practical usage.
]=]
function SearchResult:forEach(callback: (key: RegistryKey, value: any, exclude: () -> ()) -> ()): SearchResult
    local currentSubjects = self.__currentSubjects or self.__directory;

    for key: RegistryKey, value: any in pairs(currentSubjects) do
        local function exclude()
            if currentSubjects[key] then
                currentSubjects[key] = nil;
            end
        end

        callback(key, value, exclude);
    end

    return self :: SearchResult;
end

--[=[
    @function get
    @within SearchResult

    @return {[string | number]: any}?
    Returns the current search directory. After calling this, the search result is exhausted and can no longer be chained. This will always return
    a table of all search results.
]=]
function SearchResult:get(): {[string | number]: any}?
    local toReturn = self.__currentSubjects or self.__directory;

    return toReturn;
end

--[=[
    @function getFirst
    @within SearchResult

    @return any?
    Returns the current search directory. After calling this, the search result is exhausted and can no longer be chained. As opposed to :get(),
    this will always return only the first search result it finds.
]=]
function SearchResult:getFirst(): any?
    local get = self:get();
    if get then
        for _, value in pairs(get) do
            return value;
        end
    end
end

--[[ ----- ]] --

local RegistryModule = {};

local Registry = {}
Registry.__index = Registry;
Registry.__tostring = function(self)
    return self.name;
end

local allRegistries = {};

--[[ -- RegistryModule -- ]] --

--[=[
    @function new
    @within RegistryModule

    @param name string
    @param initial table
    @param immutable boolean?
    @return Registry
    Creates a new registry. Please note that the `initial` table may be any table so long as it has numeric or string keys.
    If `immutable` is set to true, you will not be able to modify the registry.
]=]
function RegistryModule.new(name: string, initial: table, immutable: boolean?): Registry
    assert(type(initial) == "table", "Cannot create a Registry from " .. tostring(initial) .. " - it is not a table!");
    assert(not allRegistries[name], "A Registry with the name " .. name .. " already exists!");
    --assert((getTableType(initial) ~= "mixed"), "Initial registry cannot be a mixed table.");

    local self = setmetatable({
        name = name;

        __registry = deepCopy(initial);
        __immutable = immutable or false;
    }, Registry);

    if immutable then
        table.freeze(self.__registry);
    end

    allRegistries[name] = self;

    return self;
end

--[=[
    @function get
    @within RegistryModule

    @param name string
    @return Registry?
]=]
function RegistryModule.get(name: string): Registry?
    return allRegistries[name];
end

--[=[
    @function remove
    @within RegistryModule

    @param name string
]=]
function RegistryModule.remove(name: string)
    if allRegistries[name] then
        allRegistries[name] = nil;
    end
end

--[=[
    @function buildVirtualRegistry
    @within RegistryModule

    @param name string
    @param instance Instance
    @param recursive boolean?
    @return Registry

    Builds a registry from an instance and its children. If `recursive` is set to true, it will include all of its descendants.
]=]
function RegistryModule.buildVirtualRegistry(name: string, instance: Instance, recursive: boolean?): Registry
    assert(type(name) == "string");
    assert(type(instance) == "userdata");
    
    if recursive ~= nil then
        assert(type(recursive) == "boolean");
    end

    local registry = { ref = instance };
    
    local function recurse(currentDirectory: table, target: Instance)
        for _, child in pairs(target:GetChildren()) do
            if (#child:GetChildren() > 0) and (recursive) then
                currentDirectory[child.Name] = { ref = child };
                recurse(currentDirectory[child.Name], child);
            else
                currentDirectory[child.Name] = child;
            end
        end
    end

    recurse(registry, instance);

    registry = RegistryModule.new(name, registry, false);

    return registry;
end

--[[ -- Registry -- ]] --

--[=[
    @function lookup
    @within Registry

    @param path string
    @return any?
    Paths directly to the index in the registry. and returns the first value it finds. If you include `any` in part of the path,
    the search will begin to look through all descendants from that point. Therefore, it is only recommended  to use `any` as
    the second-to-last part of the path.

    ```lua
    local items = Registry.new("Items", {
        melee = {
            axes = {
                stoneAxe = { quantity = 1 }
            },

            swords = {
                stoneSword = { quantity = 1 }
            }
        }
    })

    -- will return the stoneAxe data, but stoneSword was also considered in the search process due to the `any` tag.
    local stoneAxeData = items:lookup("melee/any/stoneAxe")
    ```
]=]
function Registry:lookup(path: string): any?
    local pathElements = if path then splitPath(path) else {};
    local forcedSearchValue;
    
    local function lookupRecurse(currentDirectory, currentPathIndex: number): any?
        local currentPathElement = pathElements[currentPathIndex];
        local nextPathElement = pathElements[currentPathIndex + 1];

        if currentPathElement == "any" then
            forcedSearchValue = nextPathElement;
        elseif currentPathElement == "__root" then
            return self.__registry;
        end

        for key, value in pairs(currentDirectory) do
            local stringKey = if getTableType(currentDirectory) == "array" then tostring(value) else tostring(key);

            if forcedSearchValue then
                if stringKey == forcedSearchValue then
                    return value;
                else
                    if type(value) == "table" then
                        local returnValue = lookupRecurse(value, currentPathIndex + 1);
                        if returnValue then return returnValue end;
                    end
                end
            else
                if stringKey == currentPathElement then
                    if currentPathIndex < #pathElements then
                        if type(value) == "table" then
                            return lookupRecurse(value, currentPathIndex + 1);
                        end
                    else
                        return value;
                    end
                end
            end
        end
    end

    if #pathElements > 0 then
        return lookupRecurse(self.__registry, 1);
    else
        return self.__registry;
    end
end

--[=[
    @function search
    @within Registry

    @param path string
    @return SearchResult

    Begins a SearchResult chain which you can use for more advanced indexing. See the SearchResult class for more information on what to do
    with this class.
]=]
function Registry:search(path: string): SearchResult
    local activeDirectory = self:lookup(path);

    if activeDirectory then
        return SearchResult.new(activeDirectory);
    end

    error("Could not find a valid directory while searching path: " .. path);
end

--[=[
    @function set
    @within Registry

    @param path string
    @param key string | number
    @param value any

    In the directory of the specified path, set `key` equal to `value` so long as the registry is mutable.
]=]
function Registry:set(path: string, key: string | number, value: any)
    if self.__immutable then
        warn("Cannot modify registry " .. self.name .. ", as it has been set to be immutable.");
        return;
    end

    local activeDirectory = self:lookup(path);

    if activeDirectory then
        if type(activeDirectory) == "table" then
            activeDirectory[key] = value;
        else
            warn("Cannot set " .. key .. " to " .. value .. " in " .. path .. ", as it is not a table.");
        end

        return;
    end

    error("Could not find a valid directory while searching path: " .. path);
end

return RegistryModule :: RegistryModule;