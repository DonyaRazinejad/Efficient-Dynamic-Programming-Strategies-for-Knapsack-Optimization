using Random

# Define a struct to represent the data
struct Data
    c::Vector{Int64}
    w::Vector{Int64}
    u::Vector{Int64}
end

# Function implementing the tabulation-based dynamic programming method for Q3
function tabulation_method_Q3(data::Data)
    nperiods = length(data.c)
    inventory = -sum(data.w):data.u[end] * nperiods
    tabulation = zeros(Float64, length(inventory), nperiods + 1)

    # Initialize the last column of the tabulation matrix
    tabulation[mapping(data, 0), nperiods + 1] = 0
    for y in inventory
        # Initialize the last row of the tabulation matrix
        tabulation[mapping(data, y), nperiods + 1] = ifelse(y == 0, 0, 1000000)
    end

    # Fill in the tabulation matrix using bottom-up approach
    for r in nperiods:-1:1
        for (idx, y) in enumerate(inventory)
            tmp = zeros(length(data.u))
            for (j, h) in enumerate(data.u)
                # Check if the inventory state is valid
                if y + h - data.w[r] in inventory
                    vec = tabulation[mapping(data, y + h - data.w[r]), r + 1]
                    tmp[j] = data.c[r] * h + vec
                end
            end
            # Choose the minimum cost for the current state
            tabulation[mapping(data, y), r] = minimum(tmp)
        end
    end

    # Print the tabulation matrix
    println("Tabulation Matrix:")
    display(tabulation)

    return tabulation[mapping(data, 0), 1]
end

# Function representing the recursive function for Q3
function G(data::Data, x::Int64, k::Int64)
    nperiods = length(data.c)
    if k == nperiods + 1
        if x == 0 return 0
        else return 1000000
        end
    else
        cxu = zeros(length(data.u))
        for (i, u) in enumerate(data.u)
            # Recursive call
            g = G(data, x + u - data.w[k], k + 1)
            cxu[i] = data.c[k] * u + g
        end
        # Return the minimum cost
        return minimum(cxu)
    end
end

# Function representing the memoization-based dynamic programming method for Q3
function G(data::Data, x::Int64, k::Int64, memory::Matrix{Int64})
    nperiods = length(data.c)
    if k == nperiods + 1
        if x == 0 return 0
        else return 1000000
        end
    else
        cxu = zeros(length(data.u))
        for (i, u) in enumerate(data.u)
            if memory[mapping(data, x + u - data.w[k]), k + 1] == -1
                # Recursive call with memoization
                g = G(data, x + u - data.w[k], k + 1, memory)
                memory[mapping(data, x + u - data.w[k]), k + 1] = g
                cxu[i] = data.c[k] * u + g
            else
                # Use memoized value if available
                cxu[i] = data.c[k] * u + memory[mapping(data, x + u - data.w[k]), k + 1]
            end
        end
        # Return the minimum cost
        return minimum(cxu)
    end
end

# Function for mapping the inventory state to a positive index
function mapping(data::Data, x::Int64)
    return x + sum(data.w) + 1
end

# Function for the recursive dynamic programming approach
function recursive_dp_function_Q3(data::Data)
    return G(data, 0, 1)
end

# Function for the memoization-based dynamic programming approach
function memoization_dp_function_Q3(data::Data)
    nperiods = length(data.c)
    memory = -ones(Int64, data.u[end] * nperiods + sum(data.w) + 1, nperiods + 1)
    return G(data, 0, 1, memory)
end

# For a fixed seed, solve the DP using memoization, recursive DP, and tabulation DP,
# and print the total CPU time and memory taken
let
    seed = 1
    rng = MersenneTwister(seed)

    nperiods = 12

    # Generate random data
    c = rand(rng, 5:10, nperiods)
    w = rand(rng, 1:5, nperiods)
    u = collect(0:5)

    println("Generated Data:")
    println("c =", c)
    println("w =", w)
    println("u =", u)

    data = Data(c, w, u)

    # Measure the CPU time for each method
    @time optval_memoization = memoization_dp_function_Q3(data)
    @time optval_recursive = recursive_dp_function_Q3(data)
    @time optval_tabulation = tabulation_method_Q3(data)

    # Print the optimal values
    println("Optimal values: $optval_memoization, $optval_recursive, $optval_tabulation")
end
