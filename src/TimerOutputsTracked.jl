module TimerOutputsTracked

using Cassette
using TimerOutputs
using MacroTools

const TRACKED_FUNCS = Set{Function}()
const TO = TimerOutput()

const VERBOSE = Ref(false)
const SHOW_ARGTYPES = Ref(false)

Cassette.@context TOCtx

# function Cassette.overdub(::TOCtx, f::T, args...) where T<:Function
function Cassette.overdub(ctx::TOCtx, f, args...)
    if f in TRACKED_FUNCS
        argtypes = typeof.(args)
        VERBOSE[] && println("OVERDUBBING: ", f, argtypes)
        # return @timeit TO "$f" f(args...)
        timer_groupname = if SHOW_ARGTYPES[]
            "$f $argtypes"
        else
            "$f"
        end
        return @timeit TO timer_groupname Cassette.recurse(ctx, f, args...)
    else
        return f(args...)
    end
end

function timetracked(f, args...; reset_timer=true, warn=false)
    reset_timer && TimerOutputsTracked.reset_timer()
    enable_timer!(TO)
    result = Cassette.overdub(TOCtx(), f, args...)
    disable_timer!(TO)
    if warn && !hastimings()
        @warn("No tracked functions have been called, so nothing has been timed.")
    end
    return result
end

macro timetracked(ex, reset_timer=true, warn=false)
    @capture(ex, f_(args__))
    quote
        TimerOutputsTracked.timetracked($f, $(args...); reset_timer=$reset_timer, warn=$warn)
    end |> esc
end

"""
    track(m::Module)

Track functions exported from a module.
"""
function track(m::Module; all = false)
    TimerOutputsTracked.track(filter(x -> x isa Function, getfield.(Ref(m), names(m; all)))...)
end

function track(f::Function)
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
        foreach(println, TRACKED_FUNCS)
    else
        printstyled("No functions tracked.\n"; color=:white, bold=true)
    end
    return nothing
end

istracked(f) = f in TRACKED_FUNCS

function reset_timer()
    reset_timer!(TO)
    disable_timer!(TO)
    return nothing
end
timings_tracked() = display(TO)
hastimings() = !isempty(TO.inner_timers)

function reset()
    reset_timer()
    untrackall()
end

export timetracked, @timetracked, timings_tracked

end
