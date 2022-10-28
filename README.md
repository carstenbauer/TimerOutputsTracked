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
