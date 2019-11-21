


// SUPERZOW TEST PARAMS ///////////////////////////////////////////////
(

var attack = 0.5, decay = 0.5, hold = 2, release = 3;

var
sustain = 4,
// mAttackTime = 0.01,
mAttackTime = 0.4 * sustain,
// mDecayTime = 0.2,
mDecayTime = 0.1 * sustain,
mDecayLevel = 0.5,
mHoldTime = 0.1 * sustain,
mHoldLevel = 0.5,
// mReleaseTime = 1;
mReleaseTime = 1 * sustain;

// Env.linen(attack, hold, release, 1, -3).plot
// Env.linen.plot;

var env = Env.pairs([
    [0,0],
    [mAttackTime,1],
    [mDecayTime, mDecayLevel],
    [mHoldTime,mHoldLevel],
    [mReleaseTime,0]], 0);


env.duration.postln;
env.totalDuration.postln;

env.isSustained.postln;

env.plot(size: 800);



// Env.adsr(mAttackTime, mDecayTime, mSustainLevel, mReleaseTime).plot;
)





SuperDirt.default = ~dirt;


(
(type:\dirt, orbit:0, s: \bd).play;
(type:\dirt, orbit:1, s: \cr, speed:2/5).play;
)


(
Pdef(\y,
	Pbind(
		\type, \dirt,
        \s, 'form-msp1',
        // \n, Pseq([1, 0, 0, 0, 0], inf),
        // \speed, Pseq([1, 1, 0.5, 1.2], inf),
		\dur, 0.25 * Pseq([1, 1/2, 1, 2, 2, 1/2], inf),
		\gain, 0.55,
		\room, Pseq([0, 0, 0.4], inf)
	)
).play
)

(
Pdef(\x,
	Ppar([
		Pbind(
			\type, \dirt,
            // \s, Pwrand([\hh, \cr, \ho], [2, 1, 1].normalizeSum, inf),
            \s, \hh,
            // \cut, Prand([0, 1, 2], inf),
            // \n, Pseq([Prand([1, Pseq([1, 0, 5], 1), Pseq([0, 0])], 1), 0, 0, 0, 0, 0, 0, 0, 0], inf),
            // \speed, Pseq([1, 1, 0.5, 1.2], inf),
            // \dur, 0.25 * Pseq([1/2, 1/3, 2/3], inf),
            \dur, 0.3,
			\room, Pseq([0, 0, 0.4], inf)
		),
		Pbind(
			\type, \dirt,
			\s, \bd,
            \dur, Pseq([0.5, 0.25, 0.25], inf),
            // \amp, Prand([0.5, 0], inf),
            // \dur, 3,
            // \shape, 0.4,
            \distort, Pseq([0, 0, 0.6], inf),
			\room, Pseq([0, 0.5], inf)
		)
	])
).play
)

Pdef(\y).play;

Pdef(\y).stop;

Pdef(\x).play;

PdefAllGui();

(
Pdef(\x,
	Pbind(
		\type, \dirt,
		\s, \hh,
		\n, Pseq([1, 0, 0, 0, 0], inf),
		\speed, Pseq([1, 1, 0.5, 1.2], inf),
		\dur, 0.25 * Pseq([1, 1/2, Prand([1, 1/2], 1), 2, 2, 1/2], inf),
		\cutoff, Pseg(Pwhite().linexp(0, 1, 300, 10000), 3, \lin, inf),
		\resonance, 0.3,
		\room, Pseq([0, 0, 0.4, 1], inf)
	)
).play
)

(
Pdef(\x,
	Pbind(
		\type, \dirt,
		\s, \hh,
		\n, Pseries(),
		\dur, 0.25 * Pseq([1, 1/2, 1], inf)
	)
).play
)


(
Pdef(\x,
	Pbind(
		\type, \dirt,
		\s, Pseq([\bd, \hh, \bd, \hh], inf),
        \dur, 0.25 * Pseq([1, Rest(1/2), 1], inf),
		\cutoff, [1345, 1000, 400] + Prand([0, 0, 0, 0, 0, 0, -100, 200, [-100, 210]], inf),
        \resonance, 0.8
	)

).play
)

(
Pdef(\x,
	Pbind(
		\type, \dirt,
		\speed, 2,
		\sound, Pseq([\bd, \hh, \bd, \hh], inf),
		\vowel, Pn(Plazy {Pshuf([\a, \i, \o, \i, \u, [\i, \a], [\o, \u, \e]], rrand(3, 8)) }),
		\resonance, 0.7,
		\shape, Pseq([0.5, 0.8, 0.3, 0.2, 0.2], inf),
		\dur, 0.25 * Pseq([1, 1/2, 1], inf)
	)
).play
)



(
var p5 = NetAddr.new("127.0.0.1", 1818);

// p5.sendMsg(["/amp/env", "aabc", "efg"]);
// p5.sendMsg("/amp/env", "abc");
// p5.sendBundle(0.2, ["/amp/env", ["cba", "efg"]]);
~msg = ["/amp/env", 4000, "gate", 0] ++ [1,2,3];
p5.sendMsg(*~msg);
)


~partialEnvLevels[0].get
~partialEnvTimes[0].get



Dswitch1([9,8,7,6,5], 0)


(
var numberOfEnvPoints= 4;

~fooLevels = Bus.control(s, numberOfEnvPoints);
~fooTimes = Bus.control(s, numberOfEnvPoints);

~envLevels = Bus.control(s, numberOfEnvPoints);
~envTimes = Bus.control(s, numberOfEnvPoints);

~envLevels.setn([0, 0.3, 0.7, 0]);
~envTimes.setn([0.0001, 0.1, 0.1]);

~envLevels.getn
)

~envLevels.getSynchronous

(

SynthDef("testArrayIndex", {
    arg outbus, partial = 2.1, amp = 0.1, idx= 0, envLevelsBus = ~envLevels, envTimesBus = ~envTimes;
    var snd, fund, testFreqs, env, ampEnvLevels, ampEnvTimes;

    // envLevelsBus = ~fooLevels;
    // envTimesBus = ~fooTimes;

    testFreqs = [220, 440, 660];
    fund = testFreqs[1];

    ampEnvLevels = envLevelsBus.kr;
    ampEnvTimes = envTimesBus.kr;

    // env = EnvGen.kr(Env.new([0, 0.3, 0.7, 0], [0.25, 0.25, 0.5]));
    env = EnvGen.kr(Env.new(ampEnvLevels, ampEnvTimes));

    snd = SinOsc.ar(freq: fund * partial, phase: 0);
    snd = snd * env * amp;

    Out.ar(outbus, (snd)!2);
}).add;
)

x = Synth("testArrayIndex", [\envLevelsBus, ~envLevels, \envTimesBus, ~envTimes]);
x.free;


[0,1,2,3].at(4)


(
var env = Env.circle([0, 1, 0], [0.01, 1, 0.01]);

// ampEnv.duration_(1);

{ SinOsc.ar(444, 0, 0.5) * EnvGen.kr(env) }.play;

)


{ SinOsc.ar(EnvGen.kr(Env.circle([0, 1, 0], [0.01, 0.5, 0.2])) * 440 + 200) * 0.2 }.play;




(
SynthDef("testArrayIndex", {
    arg outbus, partial = 2.1, amp = 0.01, idx= 0;
    var snd, fund;
    var testFreqs = [220, 440, 660];

    fund = Demand.kr(Impulse.kr(1), 0 , Dswitch1(testFreqs, idx));

    snd = SinOsc.ar(freq: fund * partial, phase: 0);
    snd = snd * amp;

    Out.ar(outbus, (snd)!2);
}).add;
)

x = Synth(\testArrayIndex);

x.set(\idx, 3);


(
var env;

env = Env.perc;

env.asArray;
)


(
\msp = foo;
)

(
SynthDef("msp", {
    arg out, amp = 0.8, gate = 1, att = 0.9, sus = 1, rel = 1, pan = 0.5;
    var sound, env, envctl;

    sound = SinOsc.ar(440);
    // env = EnvGen.kr(Env.asr(att, sus, rel), gate);

    // make an empty 4 segment envelope
    env = Env.newClear(4);

    // create a control argument array
    envctl = \env.ar(env.asArray);

    // Out.ar(0, sound * amp * env);
    // Out.ar(out, sound * envctl);
    OffsetOut.ar(out,
        DirtPan.ar(sound, ~dirt.numChannels, pan, envctl)
    );

}).add;
)

(
// ~e = Env({ rrand(60, 70).midicps } ! 4, [1,1,1], \exp)
~e = Env.adsr(0.001, 0.2, 0.75, 1, 1).test().plot

~e.asArray

~x = Synth(\msp, [\env, ~e]);

~x.free;
)


(
(
{
    var env = Env.step([0, 3, 5, 2, 7, 3, 0, 3, 4, 0], [0.5, 0.1, 0.2, 1.0, 1.5, 2, 0.2, 0.1, 0.2, 0.1]).plot;
    var envgen = EnvGen.kr(env);
    var freq = (envgen + 60).midicps;
    SinOsc.ar(freq) * 0.1
}.play
);

)

(

[["t1", "t2", "t3"],["l1", "l2","l3"]].flop

[["t1", "t2", "t3"],["l1", "l2","l3"]].collect({
    arg item, i;
    i.postln;

    item.collect({
        arg cord, j;


    });
});
)


(
// make two control rate busses and set their values to 880 and 884.
b = Bus.control(s, 1); b.set(880);
c = Bus.control(s, 1); c.set(884);
// and make a synth with two frequency arguments
x = SynthDef("tutorial-map", { arg freq1 = 440, freq2 = 440;
    Out.ar(0, SinOsc.ar([freq1, freq2], 0, 0.1));
}).play(s);
)
// Now map freq1 and freq2 to read from the two busses
x.map(\freq1, b, \freq2, c);

// Now make a Synth to write to the one of the busses
y = {Out.kr(b, SinOsc.kr(1, 0, 50, 880))}.play(addAction: \addToHead);

// free y, and b holds its last value
y.free;

// use Bus-get to see what the value is. Watch the post window
b.get({ arg val; val.postln; f = val; });

// set the freq2, this 'unmaps' it from c
x.set(\freq2, f / 2);

// freq2 is no longer mapped, so setting c to a different value has no effect
c.set(200);

x.free; b.free; c.free;

partialArray.postln;

// View running synths
Server.local.plotTree;


// s.meter;
"Additive Synthesis Demo 2".postln;
"".postln;
)


// Mess about with the synth engine values
(
~spectrum[0].set(\amp, 0);


~spectrum[3].set(\amp, 1);
~spectrum[15].set(\amp, 0);

~spectrum[0].postln;

~spectrum[0].get(\fundamental, { arg value; ("fund is now:" + value).postln; });
~spectrum[0].get(\partial, { arg value; ("partial is now:" + value).postln; });
~spectrum[0].get(\amp, { arg value; ("amp is now:" + value).postln; });
~spectrum[7].get(\fundamental, { arg value; ("fund is now:" + value).postln; });
~spectrum[7].get(\partial, { arg value; ("partial is now:" + value).postln; });
~spectrum[7].get(\amp, { arg value; ("amp is now:" + value).postln; });
~spectrum[15].get(\fundamental, { arg value; ("fund is now:" + value).postln; });
~spectrum[15].get(\partial, { arg value; ("partial is now:" + value).postln; });
~spectrum[15].get(\amp, { arg value; ("amp is now:" + value).postln; });



~spectrum[15].trace;

)

(
var levels = ~partialEnvLevels[0].kr;
var times = ~partialEnvTimes[0].kr;

Env.new(levels, times).plot;
)

s.boot();