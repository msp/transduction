(
SynthDef(\msp808, {|out, speed=1, attack = 0.01, sustain=1, release = 1 pan, voice=0, n |
    var env, sound, freq;
    n = ((n>0)*n) + ((n<1)*3);
    freq = (n*10).midicps;
    env = EnvGen.ar(Env.linen(attack, 0, release, 1, -3), timeScale:sustain, doneAction:2);
    sound = LPF.ar(SinOscFB.ar(XLine.ar(freq.expexp(10, 2000, 1000, 8000), freq, 0.025/speed), voice), 9000);
    OffsetOut.ar(out, DirtPan.ar(sound, ~dirt.numChannels, pan, env))
}).add
)

(
SynthDef(\mspSnare, {|out, attack = 0.01, decay=1, sustain=1,  release = 0.6, pan, accelerate, n |
    var env, sound, accel;
    env = EnvGen.ar(Env.linen(attack, 0, release, 1, -3), timeScale:sustain, doneAction:2);
    accel = Line.kr(1, 1+accelerate, 0.2);
    sound = LPF.ar(Pulse.ar(100*accel*(n/5+1).wrap(0.5,2)), Line.ar(1030, 30, 0.2*sustain));
    sound = sound + (BPF.ar(HPF.ar(WhiteNoise.ar(1), 500), 1500) * Line.ar(1, 0, 0.2*decay));
    OffsetOut.ar(out, DirtPan.ar(sound, ~dirt.numChannels, pan, env))
}).add
);
