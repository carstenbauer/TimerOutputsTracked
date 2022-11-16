using TimerOutputsTracked
using Test

const tot = TimerOutputsTracked

@testset "Basics" begin
    @testset "Tracking (bookkeeping)" begin
        @test isnothing(tot.tracked())
        @test isnothing(tot.track(sin))
        @test tot.istracked(sin)
        @test isnothing(tot.untrack(sin))
        @test !tot.istracked(sin)
        @test isnothing(tot.track(sin, cos))
        @test isnothing(tot.track([tan, exp]))
        @test isnothing(tot.untrackall())
        @test isempty(tot.gettracked())
    end
    @testset "Single argument" begin
        tot.reset()
        @test timetracked(sin, 3) == sin(3)
        @test !tot.hastimings()
        @test isnothing(tot.track(sin))
        @test timetracked(sin, 3) == sin(3)
        @test tot.hastimings()
        @test isnothing(tot.timings_tracked())
        @test isnothing(timings_tracked()) # exported

        #macro
        tot.reset()
        tot.track(sin)
        @test !tot.hastimings()
        res = @timetracked sin(3)
        @test res == sin(3)
        @test tot.hastimings()
    end
    @testset "Multi-argument" begin
        tot.reset()
        @test timetracked(+, 3, 4) == 7
        @test !tot.hastimings()
        @test isnothing(tot.track(+))
        @test timetracked(+, 3, 4) == 7
        @test tot.hastimings()
        @test isnothing(tot.timings_tracked())

        #macro
        tot.reset()
        tot.track(+)
        @test !tot.hastimings()
        res = @timetracked +(3, 4)
        @test res == 7
        @test tot.hastimings()
    end
    @testset "Arguments" begin
        func(x, y) = x + y
        @test @timetracked(func(1, 2)) == 3
    end
end
