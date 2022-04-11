return function()
    local Test = require(script.Parent.registry);
    
    describe("simpleLookup", function()
        it("should return 1", function()
            local value = Test:SimpleLookup();
            expect(value == 1).to.be.ok();
        end)
    end);

    describe("intermediateLookup", function()
        it("should return a table", function()
            local value = Test:IntermediateSearch();
            expect(type(value) == "table").to.be.ok();
        end)

        it("should have a key 'name' equal to 'stoneAxe'", function()
            local value = Test:IntermediateSearch();
            expect(value.name == "stoneAxe").to.be.ok();
        end)

        it("should have a key 'quantity' equal to 1", function()
            local value = Test:IntermediateSearch();
            expect(value.quantity == 1).to.be.ok();
        end)
    end);
    
end