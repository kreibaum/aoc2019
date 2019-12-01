
include("library.jl")

f = open("input-01-a")
lines = parse.(Int, readlines(f))

println("Solutions for Day 1")
@assert (@show sum(fuelForModule.(lines))) == 3380880
@assert (@show sum(rocketEqFuel.(lines))) == 5068454
