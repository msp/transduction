Env([0, 1, 0.5, 0], [0.01, 0.2, 1]).test.plot

////////////////////////////////////////////////////////////////////////////////////////////////
// 15/09 12:16 - This works!

// But, if just split into individual synthdef args it can then be used from Tidal and UI right?

// freq
a = Bus.control(s, 2);

a.setn([1050, 750]);

// levels
b = Bus.control(s, 4);

b.setn([0, 1, 0.8, 0]);

// times
c = Bus.control(s, 3);

c.setn([0.1, 0.2, 0.1]);


// def
(
SynthDef(\rlpf, {
    arg out, rq, t1 = 0.1, t2 = 0.2, t3 = 0.1;

    var numberOfPoints = 4;
    var freqs = a.kr;
    var envLevels = b.kr;
    var envTimes = c.kr;
    // var envTimes = Array.with(t1, t2, t3);

    var ampEnv = Env.new(envLevels, envTimes);
    var env = EnvGen.kr(ampEnv, doneAction: Done.freeSelf);

    Out.ar(out, SinOsc.ar(freqs) * env)
}).add();
)


Synth(\rlpf)

// Send new bus levels above to change Env shape
//
// d1 $ s "rlpf"

// OR

// Or pass explicit params & switch out the envTimes line above
//
// (t1, _) = pF "t1" (Just 0.01)
// (t2, _) = pF "t2" (Just 0.2)
// (t3, _) = pF "t3" (Just 0.1)

// d1 $ s "rlpf"
// # t1 0.01
// # t2 0.1
// # t3 0.04























// OLD /////////////////////////////////////////////////////////////////////////
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
