
include("library.jl")

f = open("input-01-a")
lines = parse.(Int, readlines(f))

println("\nSolutions for Day 1")
@assert (@show sum(fuelForModule.(lines))) == 3380880
@assert (@show sum(rocketEqFuel.(lines))) == 5068454

println("\nSolutions for Day 2")

inputDay2 = parse.(Int, split(read("input-02", String), ","))
vm2 = ElfVM(inputDay2)
@assert 3654868 == @show runWithArguments(copy(vm2), 12, 2)
@assert (70, 14) == @show findArguments(copy(vm2), 19690720)

println("\nSolutions for Day 3")

# Puzzle
wires = createWires.(parseDirectionString.(readlines(open("input-03"))))
intersections_puzzle = intersections(wires[1], wires[2])
@assert 352 == @show minimum(manhattan.(intersections_puzzle))
@assert 43848 == @show minimum(intersection_offset.(intersections_puzzle))

println("\nSolutions for Day 4")

@assert 1019 == @show length(filter(check_password, 248345:746315))
@assert 660 == @show length(filter(check_password_stronger, 248345:746315))
