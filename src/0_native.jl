function native_addi32(a::Vector{Int32}, b::Vector{Int32})
    @assert length(a) == length(b)

    sum = Int32(0)
    for idx in 1:length(a)
        sum += a[idx] + b[idx]
    end
    return sum
end
