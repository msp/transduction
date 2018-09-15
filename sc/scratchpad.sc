(
var foo = 1;

if (foo.isNil
    {"Got me a foo!".postln;} ,
    {"Wot no foo :(".postln;}
)
)


(
var x;
if (x.isNil, { x = 99 });
x.postln;
)


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