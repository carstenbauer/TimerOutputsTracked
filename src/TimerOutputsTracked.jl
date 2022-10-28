module TimerOutputsTracked

using Cassette
using TimerOutputs
using MacroTools

const TRACKED_FUNCS = Set{Function}()
const TO = TimerOutput()

verbose() = false

Cassette.@context TOCtx

# function Cassette.overdub(::TOCtx, f::T, args...) where T<:Function
function Cassette.overdub(ctx::TOCtx, f, args...)
    if f in TRACKED_FUNCS
        verbose() && println("OVERDUBBING: ", f, typeof.(args))
        # return @timeit gettimer() "$f" f(args...)
        return @timeit gettimer() "$f" Cassette.recurse(ctx, f, args...)
    else
        return f(args...)
    end
end

function timetracked(f, args...; reset_timer=true, warn=false)
    reset_timer && TimerOutputsTracked.reset_timer()
    enable_timer!(gettimer())
    result = Cassette.overdub(TOCtx(), f, args...)
    disable_timer!(gettimer())
    if warn && !hastimings()
        @warn("No tracked functions have been called, so nothing has been timed.")
    end
    return result
end

macro timetracked(ex)
    @capture(ex, f_(args__))
    esc(quote
        TimerOutputsTracked.timetracked($f, $(args)...)
    end)
end

function track(f)
    if f in TRACKED_FUNCS
        @info("Already tracked.")
    else
        push!(TRACKED_FUNCS, f)
    end
    return nothing
end
track(fs...) = (track.(fs); return nothing)
track(fs::AbstractVector) = track(fs...)

function untrack(f)
    if f in TRACKED_FUNCS
        delete!(TRACKED_FUNCS, f)
    else
        @info("Not tracked, thus can't untrack.")
    end
    return nothing
end

function untrackall()
    empty!(TRACKED_FUNCS)
    return nothing
end

gettracked() = TRACKED_FUNCS

function tracked()
    if !isempty(TRACKED_FUNCS)
        printstyled("Tracked functions:\n"; color=:white, bold=true)
        for f in TRACKED_FUNCS
            println(f)
        end
    else
        printstyled("No functions tracked.\n"; color=:white, bold=true)
    end
    return nothing
end

istracked(f) = f in TRACKED_FUNCS

gettimer() = TO
function reset_timer()
    reset_timer!(gettimer())
    disable_timer!(gettimer())
    return nothing
end
timings_tracked() = show(gettimer())
hastimings() = !isempty(gettimer().inner_timers)

function reset()
    reset_timer()
    untrackall()
end

export timetracked, @timetracked, timings_tracked

end
