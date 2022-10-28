# TimerOutputsTracked

TimerOutputsTracked = [TimerOutputs.jl](https://github.com/KristofferC/TimerOutputs.jl) + [Cassette.jl](https://github.com/JuliaLabs/Cassette.jl) to the end of timing all calls of "tracked" functions

### Example

```julia
julia> using TimerOutputsTracked

julia> function A()
           return B() + C()
       end;

julia> B() = exp(rand(10,10));

julia> C() = zeros(10,10);

julia> TimerOutputsTracked.track([A, B, C, rand])

julia> @timetracked A();

julia> timings_tracked()
 ─────────────────────────────────────────────────────────────────────────
                                 Time                    Allocations      
                        ───────────────────────   ────────────────────────
    Tot / % measured:        1.93s /   0.1%            248KiB /   5.4%    

 Section        ncalls     time    %tot     avg     alloc    %tot      avg
 ─────────────────────────────────────────────────────────────────────────
 A                   1   2.32ms  100.0%  2.32ms   13.5KiB  100.0%  13.5KiB
   B                 1   2.28ms   98.3%  2.28ms   10.0KiB   73.9%  10.0KiB
     rand            1   42.0μs    1.8%  42.0μs   3.39KiB   25.1%  3.39KiB
       rand          1   35.0μs    1.5%  35.0μs   2.44KiB   18.0%  2.44KiB
         rand        1   22.6μs    1.0%  22.6μs   1.36KiB   10.1%  1.36KiB
   C                 1   5.58μs    0.2%  5.58μs      896B    6.5%     896B
 ─────────────────────────────────────────────────────────────────────────
```

Note that **we didn't have to augment our source code** (i.e. the definitions of `A`, `B`, `C`, or `rand`) with `@timeit ...` bits!

If you want the function argument types as well, you can set `TimerOutputsTracked.show_argtypes() = true`:

```julia
julia> TimerOutputsTracked.show_argtypes() = true

julia> @timetracked A();

julia> timings_tracked()
 ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
                                                                                      Time                    Allocations      
                                                                             ───────────────────────   ────────────────────────
                              Tot / % measured:                                   4.74s /  75.0%           1.33GiB / 100.0%    

 Section                                                             ncalls     time    %tot     avg     alloc    %tot      avg
 ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
 A ()                                                                     1    3.56s  100.0%   3.56s   1.33GiB  100.0%  1.33GiB
   B ()                                                                   1   42.1ms    1.2%  42.1ms    149KiB    0.0%   149KiB
     rand (Int64, Int64)                                                  1   27.5ms    0.8%  27.5ms   88.6KiB    0.0%  88.6KiB
       rand (DataType, Tuple{Int64, Int64})                               1   18.6ms    0.5%  18.6ms   58.7KiB    0.0%  58.7KiB
         rand (Random.TaskLocalRNG, DataType, Tuple{Int64, Int64})        1   9.09ms    0.3%  9.09ms   30.4KiB    0.0%  30.4KiB
   C ()                                                                   1    860μs    0.0%   860μs   1.80KiB    0.0%  1.80KiB
 ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
```
