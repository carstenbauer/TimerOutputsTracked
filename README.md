# TimerOutputsTracked

TimerOutputsTracked = [TimerOutputs.jl](https://github.com/KristofferC/TimerOutputs.jl) + [Cassette.jl](https://github.com/JuliaLabs/Cassette.jl) to the end of timing all calls of "tracked" functions

### Example
```julia
julia> using TimerOutputsTracked

julia> @timetracked sin(3)
0.1411200080598672

julia> TimerOutputsTracked.hastimings()
false

julia> TimerOutputsTracked.track(sin)

julia> @timetracked sin(3)
0.1411200080598672

julia> TimerOutputsTracked.hastimings()
true

julia> timings_tracked()
 ────────────────────────────────────────────────────────────────────
                            Time                    Allocations      
                   ───────────────────────   ────────────────────────
 Tot / % measured:      4.57s /   0.0%           8.13MiB /   0.0%    

 Section   ncalls     time    %tot     avg     alloc    %tot      avg
 ────────────────────────────────────────────────────────────────────
 sin            1   5.83μs  100.0%  5.83μs     16.0B  100.0%    16.0B
 ────────────────────────────────────────────────────────────────────
```

### Nested example

```julia
julia> using TimerOutputsTracked

julia> function myfunc_outer()
           A = rand(10,10)
           B = rand(10,10)
           C = A.+B
           C .+= myfunc_inner(A, B)
           C .+= myfunc_inner(A, B)
           return C
       end;

julia> myfunc_inner(A,B) = A*B;

julia> TimerOutputsTracked.track(myfunc_outer, myfunc_inner, rand)

julia> @timetracked myfunc_outer();

julia> timings_tracked()
 ───────────────────────────────────────────────────────────────────────────
                                   Time                    Allocations      
                          ───────────────────────   ────────────────────────
     Tot / % measured:         1.16s /   6.4%            374KiB /  36.1%    

 Section          ncalls     time    %tot     avg     alloc    %tot      avg
 ───────────────────────────────────────────────────────────────────────────
 myfunc_outer          1   74.0ms  100.0%  74.0ms    135KiB  100.0%   135KiB
   rand                2   74.0ms   99.9%  37.0ms    130KiB   96.2%  64.9KiB
     rand              2   42.2ms   57.0%  21.1ms   85.5KiB   63.3%  42.8KiB
       rand            2   24.6ms   33.2%  12.3ms   59.0KiB   43.7%  29.5KiB
   myfunc_inner        2   8.13μs    0.0%  4.06μs   1.75KiB    1.3%     896B
 ───────────────────────────────────────────────────────────────────────────
```

Note that **we didn't have to augment our source code** (i.e. the definitions of `myfunc_outer` and `myfunc_inner`) with `@timeit ...` bits!
