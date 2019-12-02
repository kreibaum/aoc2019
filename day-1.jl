
include("library.jl")

f = open("input-01-a")
lines = parse.(Int, readlines(f))

println("Solutions for Day 1")
@assert (@show sum(fuelForModule.(lines))) == 3380880
@assert (@show sum(rocketEqFuel.(lines))) == 5068454

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

println("Solutions for Day 2")

inputDay2 = parse.(Int, split(read("input-02", String), ","))
vm2 = ElfVM(inputDay2)
@assert 3654868 == @show runWithArguments(copy(vm2), 12, 2)
@assert (70, 14) == @show findArguments(copy(vm2), 19690720)