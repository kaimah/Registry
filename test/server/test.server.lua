local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Registry = require(ReplicatedStorage.Registry);

local pharmacyRegistry = Registry.new("Pharmacy", {
	profiles = {
		kai = {
			medications = {
				{
					name = "bloxycola";
					quantity = 2;
					dateGiven = 1649673967
				}
			}
		}
	},

	appointments = {};
});

local function getMedicationGivenDate(patientName: string, medicationName: string): number?
	local medicationData = pharmacyRegistry:search(
		"profiles/" .. patientName .. "/medications"
	):with({
		name = medicationName
	}):get()[1];

	if medicationData then
		return medicationData.dateGiven;
	end
end

print(
	getMedicationGivenDate("kai", "bloxycola")
)