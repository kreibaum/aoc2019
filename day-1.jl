
include("library.jl")

f = open("input-01-a")
lines = parse.(Int, readlines(f))

println("Solutions for Day 1")
@assert (@show sum(fuelForModule.(lines))) == 3380880
@assert (@show sum(rocketEqFuel.(lines))) == 5068454

println("Solutions for Day 2")

inputDay2 = parse.(Int, split(read("input-02", String), ","))
vm2 = ElfVM(inputDay2)
@assert 3654868 == @show runWithArguments(copy(vm2), 12, 2)
@assert (70, 14) == @show findArguments(copy(vm2), 19690720)

println("Solutions for Day 3")

# First we need to transform a wire move list into a wire section list.
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

# Puzzle
wires = createWires.(parseDirectionString.(readlines(open("input-03"))))
intersections_puzzle = intersections(wires[1], wires[2])
@assert 352 == @show minimum(manhattan.(intersections_puzzle))
@assert 43848 == @show minimum(intersection_offset.(intersections_puzzle))