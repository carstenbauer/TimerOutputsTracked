using TimerOutputsTracked
using Test

const TOT = TimerOutputsTracked
const TEST_IO = (stdout, devnull)[1]  # select `devnull` if we have a lot of tests

module MyModule
    export foo, bar
    foo() = 1
    bar() = 2 + foo()
    baz() = 3 + bar()  # unexported
end

mysum(x, y) = x + y

@testset "Basics" begin
    @testset "Tracking (bookkeeping)" begin
        @test isnothing(TOT.tracked(TEST_IO))
        @test isnothing(TOT.track(sin))
        @test TOT.istracked(sin)
        @test isnothing(TOT.untrack(sin))
        @test !TOT.istracked(sin)
        @test isnothing(TOT.track(sin, cos))
        @test isnothing(TOT.track([tan, exp]))
        @test isnothing(TOT.untrackall())
        @test isempty(TOT.gettracked())
    end
    @testset "Single argument" begin
        TOT.reset()
        @test timetracked(sin, 3) == sin(3)
        @test !TOT.hastimings()
        @test isnothing(TOT.track(sin))
        @test timetracked(sin, 3) == sin(3)
        @test TOT.hastimings()
        @test isnothing(TOT.timings_tracked(TEST_IO))
        @test isnothing(timings_tracked(TEST_IO))  # exported

        # macro
        TOT.reset()
        TOT.track(sin)
        @test !TOT.hastimings()
        res = @timetracked sin(3)
        @test res == sin(3)
        @test TOT.hastimings()
    end
    @testset "Multi-argument" begin
        TOT.reset()
        @test timetracked(+, 3, 4) == 7
        @test !TOT.hastimings()
        @test isnothing(TOT.track(+))
        @test timetracked(+, 3, 4) == 7
        @test TOT.hastimings()

        # macro
        TOT.reset()
        TOT.track(+)
        @test !TOT.hastimings()
        @test @timetracked(+(3, 4)) == 7
        @test TOT.hastimings()
        timings_tracked(TEST_IO)
    end
    @testset "Positional arguments" begin
        TOT.reset()
        TOT.track(mysum)
        @test @timetracked(mysum(1, 2)) == 3
    end
    @testset "Track exported methods from Module" begin
        TOT.reset()
        TOT.track(MyModule)
        @test TOT.istracked(MyModule.foo)
        @test TOT.istracked(MyModule.bar)
    end
    @testset "Track all Module methods" begin
        TOT.reset()
        TOT.track(MyModule; all = true)
        @test TOT.istracked(MyModule.foo)
        @test TOT.istracked(MyModule.bar)
        @test TOT.istracked(MyModule.baz)  # track unexported method
        @test @timetracked(MyModule.baz()) == 6
        timings_tracked(TEST_IO)
    end
    @testset "Options" begin
        TOT.reset()
        TOT.track(mysum)
        @test @timetracked(mysum(2, 3.0), functionloc=true, argtypes=true) == 5.0
        timings_tracked(TEST_IO)
    end
end
