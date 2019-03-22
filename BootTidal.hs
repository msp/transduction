-- Doctored from https://github.com/tidalcycles/Tidal/blob/master/BootTidal.hs
-- doesn't seem to parse multi-line input!

:set -XOverloadedStrings
:set prompt ""
:set prompt-cont ""

import Sound.Tidal.Context


latency = 0.1

supercolliderTarget = superdirtTarget {oLatency = latency, oAddress = "127.0.0.1"}

processingTarget = OSCTarget {oName = "Processing Target", oAddress = "10.10.7.192", oPort = 1818, oPath = "/play2", oShape = Nothing, oLatency = latency, oPreamble = [], oTimestamp = NoStamp }

-- rpiTarget = OSCTarget {oName = "RPI Target", oAddress = "192.168.0.103", oPort = 5005, oPath = "/play2", oShape = Nothing, oLatency = latency, oPreamble = [], oTimestamp = NoStamp }
-- rpiTarget = OSCTarget {oName = "RPI2 Target", oAddress = "192.168.0.104", oPort = 5005, oPath = "/play2", oShape = Nothing, oLatency = latency, oPreamble = [], oTimestamp = NoStamp }
-- rpiTarget = OSCTarget {oName = "RPI3 Target", oAddress = "192.168.0.105", oPort = 5005, oPath = "/play2", oShape = Nothing, oLatency = latency, oPreamble = [], oTimestamp = NoStamp }
-- rpiTarget = OSCTarget {oName = "RPI4 Target", oAddress = "192.168.0.106", oPort = 5005, oPath = "/play2", oShape = Nothing, oLatency = latency, oPreamble = [], oTimestamp = NoStamp }

targets = [supercolliderTarget,processingTarget]
-- targets = [supercolliderTarget,processingTarget, rpiTarget, rpi2Target, rpi3Target, rpi4Target]

-- total latency = oLatency + cFrameTimespan
-- tidal <- startTidal (superdirtTarget {oLatency = 0.1, oAddress = "127.0.0.1", oPort = 57120}) (defaultConfig {cFrameTimespan = 1/20})
tidal <- startMulti targets (defaultConfig {cFrameTimespan = 1/20})

let p = streamReplace tidal
let hush = streamHush tidal
let list = streamList tidal
let mute = streamMute tidal
let unmute = streamUnmute tidal
let solo = streamSolo tidal
let unsolo = streamUnsolo tidal
let once = streamOnce tidal False
let asap = streamOnce tidal True
let nudgeAll = streamNudgeAll tidal
let all = streamAll tidal
let resetCycles = streamResetCycles tidal
let setcps = asap . cps
let xfade i = transition tidal (Sound.Tidal.Transition.xfadeIn 4) i
let xfadeIn i t = transition tidal (Sound.Tidal.Transition.xfadeIn t) i
let histpan i t = transition tidal (Sound.Tidal.Transition.histpan t) i
let wait i t = transition tidal (Sound.Tidal.Transition.wait t) i
let waitT i f t = transition tidal (Sound.Tidal.Transition.waitT f t) i
let jump i = transition tidal (Sound.Tidal.Transition.jump) i
let jumpIn i t = transition tidal (Sound.Tidal.Transition.jumpIn t) i
let jumpIn' i t = transition tidal (Sound.Tidal.Transition.jumpIn' t) i
let jumpMod i t = transition tidal (Sound.Tidal.Transition.jumpMod t) i
let mortal i lifespan release = transition tidal (Sound.Tidal.Transition.mortal lifespan release) i
let interpolate i = transition tidal (Sound.Tidal.Transition.interpolate) i
let interpolateIn i t = transition tidal (Sound.Tidal.Transition.interpolateIn t) i
let clutch i = transition tidal (Sound.Tidal.Transition.clutch) i
let clutchIn i t = transition tidal (Sound.Tidal.Transition.clutchIn t) i
let anticipate i = transition tidal (Sound.Tidal.Transition.anticipate) i
let anticipateIn i t = transition tidal (Sound.Tidal.Transition.anticipateIn t) i
let d1 = p 1
let d2 = p 2
let d3 = p 3
let d4 = p 4
let d5 = p 5
let d6 = p 6
let d7 = p 7
let d8 = p 8
let d9 = p 9
let d10 = p 10
let d11 = p 11
let d12 = p 12
let d13 = p 13
let d14 = p 14
let d15 = p 15
let d16 = p 16

let p1 = p 17
let p2 = p 18
let p3 = p 19
let p4 = p 20
let p5 = p 21
let p6 = p 22
let p7 = p 23
let p8 = p 24

let r1 = p 25
let r2 = p 26
let r3 = p 27
let r4 = p 28
let r5 = p 29
let r6 = p 30
let r7 = p 31
let r8 = p 32

let rate = 128

:set prompt "tidal> "
