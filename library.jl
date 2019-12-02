

"""Fuel required to launch a given module is based on its mass.
Specifically, to find the fuel required for a module, take its mass,
divide by three, round down, and subtract 2.
"""
fuelForModule(mass) = max(0, (mass ÷ 3) - 2)

"""Fuel itself requires fuel just like a module.
However, that fuel also requires fuel, and that fuel requires fuel, and so on.
"""
function rocketEqFuel(mass)
    totalFuel = 0
    additionalFuel = fuelForModule(mass)
    while additionalFuel > 0
        totalFuel += additionalFuel
        additionalFuel = fuelForModule(additionalFuel)
    end
    totalFuel
end

################################################################################
# Elf Virtual Machine (Intcode computer) #######################################
################################################################################