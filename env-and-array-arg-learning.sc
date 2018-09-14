Env([0, 1, 0.5, 0], [0.01, 0.2, 1]).test.plot



////////////////////////////////////////////////////////////////////////////////////////////////
// 14/09 00:52 - This works! So long as you recreate the synth def after changing the bus control

// So, we might as well just split into individual synthdef args?!

// Can then be used from Tidal and UI right?

// freq
(
a = Bus.control(s, 2).setn([700, 403]);
)

// plot
// Env([0, 1, 0.5, 0], [0.01, 0.2, 1]).test.plot

// levels
(
b = Bus.control(s, 4).setn([0, 1, 0.8, 0]);
)

// times
(
c = Bus.control(s, 3).setn([0.5, 0.2, 0.1]);
)

[9,6,7]

// def
(
SynthDef(\rlpf, {
    arg out, rq, t1 = 0.5, t2 = 0.2, t3 = 0.1;

    var numberOfPoints = 4;
    var freqs = a.kr;
    var envLevels = b.kr;
    // var envTimes = c.kr;
    var envTimes = Array.with(t1, t2, t3);

    var ampEnv = Env.new(envLevels, envTimes);
    var env = EnvGen.kr(ampEnv, doneAction: Done.freeSelf);

    Out.ar(out, SinOsc.ar(freqs) * env)
}).add();
)


// This feels like the closet path but yet doesn't work 14/09 at 12pm
(
SynthDef(\mspFoo, {
    arg out;
    var pan = 0.5;
    var numberOfPoints = 3;
    var snd = SinOsc.ar(\freqIn.kr);

    var ampEnv = Env.newClear(numberOfPoints);
    var ampCtl = \ampEnvIn.kr(ampEnv.asArray);
    var env = EnvGen.kr(ampCtl, doneAction: Done.freeSelf);

    // var env = EnvGen.ar(
    //     // Env([0, 1, 0.5, 0], Ndef.kr(\mspFooTimes)),
    //     Env([0, 1, 0.5, 0], [0.01, 0.2, 1]),
    //     doneAction: Done.freeSelf
    // );

	OffsetOut.ar(out,
		DirtPan.ar(snd, ~dirt.numChannels, pan, env)
	)

}).add
)

(
// Synth(\mspFoo, [ \ampEnvIn, Env.perc])
Synth(\mspFoo, [ \ampEnvIn, ~ampEnv])
)

(
Synth(\mspFoo, [\freqIn, 400])
)

~dirt.orbits[0].set(\gain, 0.5)
~dirt.orbits[0].set(\freqIn, 460)

~dirt.orbits[0].set(\ampEnvIn, Env.perc);
~dirt.orbits[0].set(\ampEnvIn, ~ampEnv);
~dirt.set(\ampEnvIn, Env.perc);
