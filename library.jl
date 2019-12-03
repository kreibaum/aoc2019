

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


mutable struct ElfVM
    memory
    instructionPointer
end

function ElfVM(memory)
    ElfVM(memory, 0)
end

function Base.copy(vm::ElfVM)::ElfVM
    ElfVM(copy(vm.memory), vm.instructionPointer)
end

function set!(vm::ElfVM, i, v)
    vm.memory[i + 1] = v
end

get(vm::ElfVM, i) = vm.memory[i + 1]

current_instruction(vm) = get(vm, vm.instructionPointer)

params3(vm) = (get(vm, vm.instructionPointer + 1),
    get(vm, vm.instructionPointer + 2), 
    get(vm, vm.instructionPointer + 3))

"""Executes one instruction on the ElfVM and returns whether it is still active.
"""
function tick!(vm)::Bool
    instr = current_instruction(vm)
    if instr == 1
        (a, b, c) = params3(vm)
        set!(vm, c, get(vm, a) + get(vm, b))
        step!(vm, 4)
        true
    elseif instr == 2
        (a, b, c) = params3(vm)
        set!(vm, c, get(vm, a) * get(vm, b))
        step!(vm, 4)
        true
    elseif instr == 99
        false
    end
end

function step!(vm, n)
    vm.instructionPointer += n
end

function runWithArguments(vm, noun, verb)
    set!(vm, 1, noun)
    set!(vm, 2, verb)
    while tick!(vm) end
    get(vm, 0)
end

function findArguments(vm, output)
    for i in 0:99, j in 0:99
        if runWithArguments(copy(vm2), i, j) == output
            return (i, j)
        end
    end
end