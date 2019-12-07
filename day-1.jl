
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

function amplifier(bytecode::Vector, phase_setting::Int, input::Int)::Int
    vm = ElfVM(copy(bytecode))
    push!(vm.stdin, phase_setting)
    push!(vm.stdin, input)
    run!(vm)
    vm.stdout[1]
end

function amplifier_chain(bytecode::Vector, phase_settings::Vector, input::Int)
    flow_value = input
    for phase in phase_settings
        flow_value = amplifier(bytecode, phase, flow_value)
    end
    flow_value
end

@assert 116680 == @show maximum(amplifier_chain.(Ref(inputDay7), permutations([0, 1, 2, 3, 4]), 0))

mutable struct MultiThread
    threads::Dict{Int, ElfVM}
    forwards::Dict{Int, Int}
    state::VMState
end

function run_day_7_part_2_vm(config::Vector)
    multi_thread = MultiThread(
        Dict(
            1 => ElfVM(copy(inputDay7)), 
            2 => ElfVM(copy(inputDay7)), 
            3 => ElfVM(copy(inputDay7)), 
            4 => ElfVM(copy(inputDay7)), 
            5 => ElfVM(copy(inputDay7)) ),
        Dict( 1 => 2, 2 => 3, 3 => 4, 4 => 5, 5 => 1 ),
        Initialized
    )

    push!(multi_thread.threads[1].stdin, config[1])
    push!(multi_thread.threads[2].stdin, config[2])
    push!(multi_thread.threads[3].stdin, config[3])
    push!(multi_thread.threads[4].stdin, config[4])
    push!(multi_thread.threads[5].stdin, config[5])

    push!(multi_thread.threads[1].stdin, 0)

    run!(multi_thread)
    multi_thread.threads[1].stdin[1]
end 

"""A scheduler that runs all the VMs. The VMs act like threads in this case."""
function run!(multi_thread::MultiThread)
    # Right now, I hope that "Round Robin" is going to be good enought.
    runnable_threads::Vector{Int} = []
    suspended_threads::Set{Int} = Set()
    for (pid, thread) in multi_thread.threads
        if runnable(thread)
            push!(runnable_threads, pid)
        else
            push!(suspended_threads, pid)
        end
    end

    while length(runnable_threads) > 0
        # Pick the next runnable thread in line and do one execution
        pid = popfirst!(runnable_threads)
        thread = multi_thread.threads[pid]
        # TODO: More than one execution
        thread.state = Running
        tick!(thread)

        # Decide where this thread goes next
        if runnable(thread)
            push!(runnable_threads, pid)
        else
            push!(suspended_threads, pid)
        end

        # Take care of signal forwarding
        if length(thread.stdout) > 0 && pid in keys(multi_thread.forwards)
            target_pid = multi_thread.forwards[pid]
            target_thread = multi_thread.threads[target_pid]

            while length(thread.stdout) > 0
                push!(target_thread.stdin, popfirst!(thread.stdout))
            end

            # Check, if this wakes the target thread
            if runnable(target_thread) && target_pid in suspended_threads
                delete!(suspended_threads, target_pid)
                push!(runnable_threads, target_pid)
            end
        end
    end
end

@assert 89603079 == @show maximum(run_day_7_part_2_vm.(permutations([5, 6, 7, 9, 8])))