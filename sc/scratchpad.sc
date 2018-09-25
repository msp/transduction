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