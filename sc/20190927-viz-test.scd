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


// Env.adsr(0.02, 0.2, 0.25, 1, 1, -4).test(2).plot;

// MSP TEST VERSION!
(
SynthDef(\testsuperzow, {
    arg out,
    pan,
    accelerate,
    freq = 261,
    sustain = 2,
    // mAttackTime = 0.01,
    mAttackTime = 0.3,
    // mDecayTime = 0.2,
    mDecayTime = 0.1,
    mDecayLevel = 0.5,
    // mHoldTime = 0.95,
    mHoldTime = 0.2,
    mHoldLevel = 0.5,
    mReleaseTime = 1,
    slide=1,
    detune=1;


    // These must be our universal shape defaults for use with Processing
    var envShape = Env.pairs([
        [0,0],
        [mAttackTime,1],
        [mDecayTime, mDecayLevel],
        [mHoldTime,mHoldLevel],
        [mReleaseTime,0]], -1);

    var env = EnvGen.kr(envShape, timeScale:sustain, doneAction:2);
    // var env = EnvGen.ar(Env.pairs([[0,0],[0.07,1],[0.2,1-decay],[0.95,1-decay],[1,0]], -1), timeScale:sustain, doneAction:2);

    // var env = EnvGen.kr(Env.adsr(mAttackTime, mDecayTime, mSustainLevel, mReleaseTime), timeScale:sustain, doneAction:2);

    // var env = EnvGen.ar(Env.perc, timeScale:sustain, doneAction:2);

    var basefreq = freq * Line.kr(1, 1+accelerate, sustain);

    var sound = VarSaw.ar(basefreq, 0, Line.ar(0,0.5,sustain*20/slide));
    var sound2 = VarSaw.ar(basefreq*(detune/100+1), 0, Line.ar(0,0.5,sustain*20/slide));
    var sound3 = VarSaw.ar(basefreq*(-1*detune/100+1), 0, Line.ar(0,0.5,sustain*20/slide));
    sound = sound - DelayN.ar(sound2,0.2, Line.ar(0,1,5*sustain/slide)/basefreq)
    + DelayN.ar(sound3,0.2, Line.ar(0,1,20*sustain/slide)/basefreq);



    OffsetOut.ar(out, DirtPan.ar(sound/2, ~dirt.numChannels, pan, env));
    // sound = sound * env; // MSP
    // Out.ar(out, sound);
}).add
);


Synth(\testsuperzow, []);

Synth(\testsuperzow, [\sustain, 2, \mReleaseTime, 1] );

// phased saws
// "decay" and "accelerate" used as in some synths above, for envelope shaping and pitch bend, respectively
// "slide" here is how fast it moves through the phase (default 1)
// "detune" is for oscillator detuning and defaults to 1
