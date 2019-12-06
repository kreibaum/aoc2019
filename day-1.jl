
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

println("\nSolutions for Day 5")
inputDay5 = parse.(Int, split(read("input-05", String), ","))
vm5 = ElfVM(copy(inputDay5))
push!(vm5.stdin, 1)
run(vm5)
@assert [0, 0, 0, 0, 0, 0, 0, 0, 0, 13818007] == @show vm5.stdout

inputDay5 = parse.(Int, split(read("input-05", String), ","))
vm5_b = ElfVM(copy(inputDay5))
push!(vm5_b.stdin, 5)
run(vm5_b)
@assert 3176266 == @show vm5_b.stdout[1]


println("\nSolutions for Day 6")
orbitMap = OrbitMap(readlines(open("input-06")))
@assert 271151 == @show sum(values(orbitMap.depth))
@assert 388 == @show distance(orbitMap, orbitMap.centers["YOU"], orbitMap.centers["SAN"])