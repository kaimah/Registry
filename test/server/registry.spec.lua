return function()
    local Test = require(script.Parent.registry);
    
    describe("simpleLookup", function()
        it("should return 34", function()
            local value = Test:SimpleLookup();
            expect(value).to.equal(34)
        end)
    end);

    describe("intermediateSearch", function()
        local value = Test:IntermediateSearch();

        it("should return a table", function()
            expect(type(value)).to.equal("table")
        end)

        it("should have a key 'name' equal to 'log'", function()
            expect(value.name).to.equal("log")
        end)

        it("should have a key 'quantity' equal to 34", function()
            expect(value.quantity).to.equal(34)
        end)
    end);
    
    describe("advancedSearch", function()
        local value = Test:AdvancedSearch();

        it("should return a table", function()
            expect(type(value)).to.equal("table")
        end)

        it("should have 3 values", function()
            expect(#value).to.equal(2)
        end)
    end);

    describe("virtualRegistry", function()
        local value = Test:VirtualRegistry();

        it("should return an instance", function()
            expect(value).to.be.a("userdata")
        end)
    end);
end