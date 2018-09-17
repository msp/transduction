// a synth def that has 4 partials
(
SynthDef(\help_Control, { arg out=0, i_freq;
    var klank, harm, amp, ring;

    // harmonics
    harm = Control.names([\harm]).ir(Array.series(4, 1, 1));
    // amplitudes
    amp = Control.names([\amp]).ir(Array.fill(4, 0.05));
    // ring times
    ring = Control.names([\ring]).ir(Array.fill(4, 1));

    klank = Klank.ar(`[harm, amp, ring], { ClipNoise.ar(0.01) }.dup, i_freq);

    Out.ar(out, klank);
}).add;
)

a = Synth(\help_Control, \i_freq, 300);

a.free;

a = Synth(\help_Control, [\i_freq, 300, \harm, [1, 3.3, 4.5, 7.8]]);
a.free;
a = Synth(\help_Control, [\i_freq, 300, \harm, [2, 3, 4, 5]]);
a.free;

(
SynthDef(\help_Control_Sines, { arg out=0;
    var sines, control, numsines;
    numsines = 20;
    control = Control.names(\array).kr(Array.rand(numsines, 400.0, 1000.0));
    sines = Mix(SinOsc.ar(control, 0, numsines.reciprocal)) ;
    sines = sines * 0.2;
    Out.ar(out, sines ! 2);
}).add
)

c = Synth(\help_Control_Sines);
c.setn(\array, Array.rand(20, 200, 1600));
c.setn(\array, Array.rand(20, 200, 1600));

c.free

(
SynthDef(\help_Control_DynKlank, { arg out=0, freq = 440;
    var klank, harm, amp, ring;

    // harmonics
    harm = Control.names(\harm).kr(Array.series(4, 1, 1));
    // amplitudes
    amp = Control.names(\amp).kr(Array.fill(4, 0.05));
    // ring times
    ring = Control.names(\ring).kr(Array.fill(4, 1));
    klank = DynKlank.ar(`[harm, amp, ring], {ClipNoise.ar(0.003)}.dup, freq);
    Out.ar(out, klank);
}).add
)

x = []

(
a = Synth(\help_Control_DynKlank, [\freq, 51]);
x = x.add(a)
)

(
b = Synth(\help_Control_DynKlank, [\freq, 453]);
x = x.add(b)
)

(
x.size.postln;
z = x.removeAt(x.size.rand);
z.free;
x.size.postln;
)



a.setn(\harm,   Array.rand(4, 1.0, 4.7))
a.setn(\amp, Array.rand(4, 0.005, 0.1))
a.setn(\ring, Array.rand(4, 0.005, 1.0))

b.setn(\harm,   Array.rand(4, 1.0, 4.7))
b.setn(\amp, Array.rand(4, 0.005, 0.1))
b.setn(\ring, Array.rand(4, 0.005, 1.0))

