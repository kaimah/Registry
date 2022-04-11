return function()
    local Test = require(script.Parent.registry);
    
    describe("simpleLookup", function()
        it("should return 34", function()
            local value = Test:SimpleLookup();
            expect(value == 34).to.be.ok();
        end)
    end);

    describe("intermediateSearch", function()
        local value = Test:IntermediateSearch();

        it("should return a table", function()
            expect(type(value) == "table").to.be.ok();
        end)

        it("should have a key 'name' equal to 'log'", function()
            local value = Test:IntermediateSearch();
            expect(value.name == "log").to.be.ok();
        end)

        it("should have a key 'quantity' equal to 34", function()
            expect(value.quantity == 34).to.be.ok();
        end)
    end);
    
end