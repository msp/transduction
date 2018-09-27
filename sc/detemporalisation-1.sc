// a synth def that has 4 partials
(
SynthDef(\mspKlank, { arg out=0, i_freq, pan = 0.5;
    var klank, harm, amp, ring;

    // harmonics
    harm = Control.names([\harm]).ir(Array.series(4, 1, 1));
    // amplitudes
    amp = Control.names([\amp]).ir(Array.fill(4, 0.05));
    // ring times
    ring = Control.names([\ring]).ir(Array.fill(4, 1));

    klank = Klank.ar(`[harm, amp, ring], { ClipNoise.ar(0.01) }.dup, i_freq);

    OffsetOut.ar(out, DirtPan.ar(klank, ~dirt.numChannels, pan))
}).add;
)

y = []

(
a = Synth(\mspKlank, [\i_freq, 40, \pan, 1.0.rand]);
y = y.add(a)
)

(
a = Synth(\mspKlank, [\i_freq, 300, \harm, [1, 3.3, 4.5, 7.8], \pan, 1.0.rand]);
y = y.add(a)
)

(
a = Synth(\mspKlank, [\i_freq, 300, \harm, [2, 3, 4, 8], \pan, 1.0.rand]);
y = y.add(a)
)

(
if (y.size > 0, {
    y.size.postln;
    z = y.removeAt(y.size.rand);
    z.free;
    y.size.postln;
})
)


(
SynthDef(\mspSines, { arg out=0, pan = 0.5;
    var sines, control, numsines, env;
    numsines = 20;
    control = Control.names(\array).kr(Array.rand(numsines, 400.0, 1000.0));
    sines = Mix(SinOsc.ar(control, 0, numsines.reciprocal)) ;
    env = EnvGen.kr(Env.adsr(0.8, 0.3, 0.5, 1));
    sines = sines * 0.2 * env;

    OffsetOut.ar(out, DirtPan.ar(sines ! 2, ~dirt.numChannels, pan))
}).add
)


z = []

(
c = Synth(\mspSines, [\pan, 1.0.rand]);
z = z.add(c)
)

c.setn(\array, Array.rand(20, 200, 1600));
c.setn(\array, Array.rand(20, 200, 1600));

(
if (z.size > 0, {
    z.size.postln;
    w = z.removeAt(z.size.rand);
    w.free;
    z.size.postln;
})
)

(
SynthDef(\mspDynKlank, { arg out=0, freq = 440, pan = 0.5;
    var klank, harm, amp, ring;

    // harmonics
    harm = Control.names(\harm).kr(Array.series(4, 1, 1));
    // amplitudes
    amp = Control.names(\amp).kr(Array.fill(4, 0.05));
    // ring times
    ring = Control.names(\ring).kr(Array.fill(4, 1));
    klank = DynKlank.ar(`[harm, amp, ring], {ClipNoise.ar(0.003)}.dup, freq);

    OffsetOut.ar(out, DirtPan.ar(klank, ~dirt.numChannels, pan))
}).add
)

x = []

(
a = Synth(\mspDynKlank, [\freq, 361, \pan, 1.0.rand]);
x = x.add(a)
)

a.set(\pan, 1)

a.free

(
b = Synth(\mspDynKlank, [\freq, 447, \pan, 1.0.rand]);
x = x.add(b)
)

(
if (x.size > 0, {
    x.size.postln;
    z = x.removeAt(x.size.rand);
    z.free;
    x.size.postln;
})
)


a.setn(\harm,   Array.rand(4, 1.0, 4.7))
a.setn(\amp, Array.rand(4, 0.005, 0.1))
a.setn(\ring, Array.rand(4, 0.005, 1.0))

b.setn(\harm,   Array.rand(4, 1.0, 4.7))
b.setn(\amp, Array.rand(4, 0.005, 0.1))
b.setn(\ring, Array.rand(4, 0.005, 1.0))

