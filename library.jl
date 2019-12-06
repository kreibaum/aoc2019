

################################################################################
# Fuel requirements ############################################################
################################################################################

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
    memory::Vector{Int}
    instructionPointer::Int
    stdin::Vector{Int}
    stdout::Vector{Int}
end

function ElfVM(memory)
    ElfVM(memory, 0, [], [])
end

function Base.copy(vm::ElfVM)::ElfVM
    ElfVM(copy(vm.memory), vm.instructionPointer, copy(vm.stdin), copy(vm.stdout))
end

function set!(vm::ElfVM, i, v)
    vm.memory[i + 1] = v
end

get(vm::ElfVM, i) = vm.memory[i + 1]

current_instruction(vm) = get(vm, vm.instructionPointer)

params3(vm) = (get(vm, vm.instructionPointer + 1),
    get(vm, vm.instructionPointer + 2), 
    get(vm, vm.instructionPointer + 3))

"""Decodes an instruction into a tuple (opcode, parameter_modes)"""
parse_instruction(with_parameter_modes::Int) =  (with_parameter_modes % 100, digits(with_parameter_modes ÷ 100))

"""Reads a parameter of the instruction, given a relative offset.
Can differentiate between different read modes. (position/immediate)
Missing read modes are assumed to be position mode."""
function read_param(vm::ElfVM, i::Int, parameter_modes::Vector{Int})::Int
    mode = i <= length(parameter_modes) ? parameter_modes[i] : 0 
    value = get(vm, vm.instructionPointer + i)
    if mode == 0
        # position mode
        return get(vm, value)
    elseif mode == 1
        # immediate mode
        return value
    end
    end

"""Writes the value to the register given as the i-th parameter of
the current operation."""
function write_param!(vm::ElfVM, i::Int, value)
    target = get(vm, vm.instructionPointer + i)
    set!(vm, target, value)
end

"""Executes one instruction on the ElfVM and returns whether it is still active.
"""
function tick!(vm::ElfVM)::Bool
    (opcode, parameter_modes) = parse_instruction(current_instruction(vm))
    if opcode == 1
        # Addition
        a = read_param(vm, 1, parameter_modes)
        b = read_param(vm, 2, parameter_modes)
        c = a + b
        write_param!(vm, 3, c)
        step!(vm, 4)
        true
    elseif opcode == 2
        # Multiplication
        a = read_param(vm, 1, parameter_modes)
        b = read_param(vm, 2, parameter_modes)
        c = a * b
        write_param!(vm, 3, c)
        step!(vm, 4)
        true
    elseif opcode == 3
        # Read from stdin
        a = popfirst!(vm.stdin)
        write_param!(vm, 1, a)
        step!(vm, 2)
        true
    elseif opcode == 4
        # Write to stdout
        a = read_param(vm, 1, parameter_modes)
        push!(vm.stdout, a)
        step!(vm, 2)
        true
    elseif opcode == 5
        # jump-if-true
        a = read_param(vm, 1, parameter_modes)
        if a != 0
            b = read_param(vm, 2, parameter_modes)
            vm.instructionPointer = b
        else
            step!(vm, 3)
        end
        true
    elseif opcode == 6
        # jump-if-false
        a = read_param(vm, 1, parameter_modes)
        if a == 0
            b = read_param(vm, 2, parameter_modes)
            vm.instructionPointer = b
        else
            step!(vm, 3)
        end
        true
    elseif opcode == 7
        # less than
        a = read_param(vm, 1, parameter_modes)
        b = read_param(vm, 2, parameter_modes)
        c = a < b ? 1 : 0
        write_param!(vm, 3, c)
        step!(vm, 4)
        true
    elseif opcode == 8
        # equals
        a = read_param(vm, 1, parameter_modes)
        b = read_param(vm, 2, parameter_modes)
        c = a == b ? 1 : 0
        write_param!(vm, 3, c)
        step!(vm, 4)
        true
    elseif opcode == 99
        false
    end
end

function step!(vm, n)
    vm.instructionPointer += n
end

function run(vm::ElfVM)
    while tick!(vm) end
end

function runWithArguments(vm, noun, verb)
    set!(vm, 1, noun)
    set!(vm, 2, verb)
    run(vm)
    get(vm, 0)
end

function findArguments(vm, output)
    for i in 0:99, j in 0:99
        if runWithArguments(copy(vm2), i, j) == output
            return (i, j)
        end
    end
end



################################################################################
# Wire pannels #################################################################
################################################################################


struct HorizontalWire
    x1::Int
    x2::Int
    y::Int
    offset::Int
end

struct VerticalWire
    x::Int
    y1::Int
    y2::Int
    offset::Int
end

@enum Direction begin
    Up = 1
    Left = 2
    Down = 3
    Right = 4
end

direction_keys = Dict('U' => Up, 'L' => Left, 'D' => Down, 'R' => Right)

function Direction(str::SubString)
    dir = direction_keys[str[1]]
    len = parse(Int, str[2:end])
    (dir, len)
end

parseDirectionString(str::String) = Direction.(split(str, ","))

function createWires(directions)
    wires = Vector{Any}(undef, length(directions))
    x = 0
    y = 0
    offset = 0
    for i in 1:length(directions)
        (d, l) = directions[i]
        if d == Up
            y1 = y
            y += l
            wires[i] = VerticalWire(x, y1, y, offset)
        elseif d == Down
            y1 = y
            y -= l
            wires[i] = VerticalWire(x, y1, y, offset)
        elseif d == Right
            x1 = x
            x += l
            wires[i] = HorizontalWire(x1, x, y, offset)
        elseif d == Left
            x1 = x
            x -= l
            wires[i] = HorizontalWire(x1, x, y, offset)
        end
        offset += l
    end
    wires
    end

intersect(w1::HorizontalWire, w2::HorizontalWire) = Nothing
intersect(w1::VerticalWire, w2::VerticalWire) = Nothing
intersect(w1::VerticalWire, w2::HorizontalWire) = intersect(w2, w1)
function intersect(w1::HorizontalWire, w2::VerticalWire)
    if w1.x1 < w2.x < w1.x2 || w1.x1 > w2.x > w1.x2
        if w2.y1 < w1.y < w2.y2 || w2.y1 > w1.y > w2.y2 
            signalTime = w1.offset + w2.offset
            signalTime += abs(w1.x1 - w2.x)
            signalTime += abs(w2.y1 - w1.y)
            return (w2.x, w1.y, signalTime)
        end
    end
    Nothing
end

function intersections(wires1, wires2)
    result = []
    for w1 in wires1, w2 in wires2
        intersection = intersect(w1, w2)
        if intersection != Nothing
            push!(result, intersection)
        end
    end
    result
end

intersection_offset((_, _, offset)) = offset

manhattan((x, y, _)) = abs(x) + abs(y)



################################################################################
# Password Check ###############################################################
################################################################################


"""However, they do remember a few key facts about the password:

* It is a six-digit number.
* The value is within the range given in your puzzle input.
* Two adjacent digits are the same (like 22 in 122345).
* Going from left to right, the digits never decrease; they only ever increase or stay the same (like 111123 or 135679).
"""
function check_password(number)
    dgts = digits(number)[end:-1:1]
    pairFound = false
    for i in 2:6
        pairFound = pairFound || dgts[i - 1] == dgts[i]
        if dgts[i] < dgts[i - 1]
            return false
        end
    end
    pairFound
end

"""An Elf just remembered one more important detail:
the two adjacent matching digits are not part of a larger group of matching digits.
"""
function check_password_stronger(number)
    dgts = digits(number)[end:-1:1]
    pairFound = false
    seqCount = 1
    for i in 2:6
        if dgts[i - 1] == dgts[i]
            seqCount += 1
        else
            if seqCount == 2
                pairFound = true
            end
            seqCount = 1
        end
        if dgts[i] < dgts[i - 1]
            return false
        end
        end

    if seqCount == 2
        pairFound = true
    end

    pairFound
end


################################################################################
# Orbit Maps ###################################################################
################################################################################


mutable struct OrbitMap
    centers::Dict{String,String}
    depth::Dict{String,Int}
end

"""Takes a string like "XQQ)W94" and outputs the tuple ("XQQ", "W94").
This indicates, that XQQ (e.g. Sun) is orbited by W94 (e.g. Planet).
"""
orbitRelationship(str::String) = (str[1:3], str[5:7])

function cacheOrbitDepth(om::OrbitMap, object::String)::Int
    if object in keys(om.depth)
        om.depth[object]
    else
        depth = 1 + cacheOrbitDepth(om, om.centers[object])
        om.depth[object] = depth
    end
end

"""Builds an OrbitMap from a readlines input."""
function OrbitMap(lines::Vector{String})::OrbitMap
    orbitMap = OrbitMap(Dict(), Dict("COM" => 0))
    for (inside, outside) in orbitRelationship.(lines)
        orbitMap.centers[outside] = inside
    end
    
    for (outside, _) in orbitMap.centers
        cacheOrbitDepth(orbitMap, outside)
    end
    orbitMap
end

"""Determine the distance, using the property that we are on a tree."""
function distance(om::OrbitMap, a::String, b::String)::Int
    if a == b
        0
    elseif om.depth[a] > om.depth[b]
        1 + distance(om, om.centers[a], b)
    elseif om.depth[a] < om.depth[b]
        1 + distance(om, a, om.centers[b])
    else
        2 + distance(om, om.centers[a], om.centers[b])
    end
end