
using Combinatorics

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
run!(vm5)
@assert [0, 0, 0, 0, 0, 0, 0, 0, 0, 13818007] == @show vm5.stdout

inputDay5 = parse.(Int, split(read("input-05", String), ","))
vm5_b = ElfVM(copy(inputDay5))
push!(vm5_b.stdin, 5)
run!(vm5_b)
@assert 3176266 == @show vm5_b.stdout[1]

println("\nSolutions for Day 6")
orbitMap = OrbitMap(readlines(open("input-06")))
@assert 271151 == @show sum(values(orbitMap.depth))
@assert 388 == @show distance(orbitMap, orbitMap.centers["YOU"], orbitMap.centers["SAN"])

println("\nSolutions for Day 7")
# Amplifier Controller Software
inputDay7 = parse.(Int, split(read("input-07", String), ","))

function day7_vm1_runner(config::Vector)::Int
    # Set up the VM, link the threads.
    vm = MultiThreadElfVM(
        inputDay7,
        [1, 2, 3, 4, 5],
        Dict( 1 => 2, 2 => 3, 3 => 4, 4 => 5 ))
    
    # Provide the threads with input.
    map(enumerate(config)) do (pid, val) push_stdin!(vm, pid, val) end
    push_stdin!(vm, 1, 0)

    # Run and extract result.
    run!(vm)
    vm.threads[5].stdout[1]
end

@assert 116680 == @show maximum(day7_vm1_runner.(permutations([0, 1, 2, 3, 4])))

function day7_vm2_runner(config::Vector)::Int
    # Set up the VM, link the threads.
    day7_vm2 = MultiThreadElfVM(
        inputDay7,
        [1, 2, 3, 4, 5],
        Dict( 1 => 2, 2 => 3, 3 => 4, 4 => 5, 5 => 1 ))
    
    # Provide the threads with input.
    map(enumerate(config)) do (pid, val) push_stdin!(day7_vm2, pid, val) end
    push_stdin!(day7_vm2, 1, 0)

    # Run and extract result.
    run!(day7_vm2)
    day7_vm2.threads[1].stdin[1]
end

@assert 89603079 == @show maximum(day7_vm2_runner.(permutations([5, 6, 7, 9, 8])))

println("\nSolutions for Day 8")

# Read data, remove terminating newline, convert to Vector{Int}
input_8 = parse.(Int, collect(read("input-08", String)[1:end-1]))
# Convert to a Matrix{Int, 3}. Note that the julia REPL outputs x and y flipped.
image_depth = length(input_8) ÷ 25 ÷ 6
image_data = reshape(input_8, (25, 6, image_depth ))

# [..] the Elves would like you to find the layer that contains the fewest 0 digits.
layer_digit_count(data, layer, digit) = length(filter(x -> x == digit, data[:,:,layer]))
zeros = layer_digit_count.(Ref(image_data), 1:image_depth, 0)
layer_with_least_zeros = findall(zeros .== minimum(zeros))[1]

# On that layer, what is the number of 1 digits multiplied by the number of 2 digits?
@assert 1820 == @show layer_digit_count(image_data, layer_with_least_zeros, 1) * layer_digit_count(image_data, layer_with_least_zeros, 2)

# What message is produced after decoding your image?
pixel_color(data, x, y)::Int = filter(c -> c != 2, data[x, y, :])[1]
image_decoded = pixel_color.(Ref(image_data), transpose(1:25), 1:6)
# Solution read manually from image output: ZUKCJ


println("\nSolutions for Day 9")