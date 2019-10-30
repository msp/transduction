//////////////////////////////////////////////////////////////////////////////////////
// create and load the buffers once!
(
~wt_buf.do(_.free);


//10 wavetables with increasing complexity
~wt_sig = 10.collect({
    arg i;

    //random number of envelope segments
    var numSegs = i.linexp(0,9,4,40).round;

    Env(
        //env always begins and ends with zero
        //inner points are random from -1.0 to 1.0
        [0]++({1.0.rand}.dup(numSegs-1) * [1,-1]).scramble++[0],

        //greater segment duration variety in higher-index wavetables
        {exprand(1,i.linexp(0,9,1,50))}.dup(numSegs),

        //low-index wavetables tend to be sinusoidal
        //high index wavetables tend to have sharp angles and corners
        {[\sine,0,exprand(1,20) * [1,-1].choose].wchoose([9-i,3,i].normalizeSum)}.dup(numSegs)
    ).asSignal(1024);
});


//load into 10 buffers in wavetable format
~wt_buf = Buffer.allocConsecutive(10, s, 2048, 1, {
    arg buf, index;
    buf.setnMsg(0, ~wt_sig[index].asWavetable);
});
)

//////////////////////////////////////////////////////////////////////////////////////
// define the Wavetable synth that uses the above
(
SynthDef(\mspWaves, {
    arg buf=0, freq=200, detune=0.2,
    amp=0.2, pan=0, out=0, rout=0, rsend=(-20),
    atk=0.01, sustain=1, rel=0.01, c0=1, c1=(-1),
    mAttackTime = 0.01,
    mDecayTime = 0.2,
    mDecayLevel = 0.5,
    mHoldTime = 0.95,
    mHoldLevel = 0.5,
    mReleaseTime = 1;

    var sig, envShape, env, detuneCtrl;

    // env = EnvGen.ar(
    //     Env([0,1,1,0],[atk,sus,rel],[c0,0,c1]),
    //     // timeScale:sus, //MSP
    //     doneAction:2
    // );

    // These must be our universal shape defaults for use with Processing
    envShape = Env.pairs([
        [0,0],
        [mAttackTime,1],
        [mDecayTime, mDecayLevel],
        [mHoldTime,mHoldLevel],
        [mReleaseTime,0]], -1);

    env = EnvGen.kr(envShape, timeScale:sustain, doneAction:2);


    //array of eight Oscs with uniquely detune frequencies
    //and unique initial phase offsets
    detuneCtrl = LFNoise1.kr(0.1!8).bipolar(detune).midiratio;
    //sig = Osc.ar(buf, freq * detuneCtrl, {Rand(0,2pi)}!8);
    sig = Osc.ar(~wt_buf[5], freq * detuneCtrl, {Rand(0,2pi)}!8); // MSP

    sig = Splay.ar(sig); //spread 8 signals over stereo field
    sig = LeakDC.ar(sig); //remove DC bias
    sig = Balance2.ar(sig[0], sig[1], pan, amp); //L/R balance (pan)
    sig = sig * env;

    // Out.ar(out, sig);
    OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan, env))
}).add;

SynthDef(\mspVibSawPluck, {
    arg out, sustain = 1, freq = 440, speed = 1, begin=0, end=1, pan, accelerate, offset,
    mAttackTime = 0.01,
    mDecayTime = 0.2,
    mDecayLevel = 0.5,
    mHoldTime = 0.95,
    mHoldLevel = 0.5,
    mReleaseTime = 1;

    var envShape = Env.pairs([
        [0,0],
        [mAttackTime,1],
        [mDecayTime, mDecayLevel],
        [mHoldTime,mHoldLevel],
        [mReleaseTime,0]], -1);


    var line = Line.ar(begin, end, sustain, doneAction:2);
    // var env = Env([0, 1, 0.333, 0],[900, 70, 1000]);
    // var envGen = IEnvGen.ar(env, line*env.times.sum*abs(speed));
    var envGen = IEnvGen.ar(envShape, line*envShape.times.sum*abs(speed));
    var sound = Saw.ar(freq*abs(speed)+(SinOsc.ar(10)*(freq*0.06)*line*line));
    sound = RLPF.ar(sound, Clip.ar(envGen*freq*48, 0, 20000), 0.5);
    Out.ar(out, DirtPan.ar(sound, ~dirt.numChannels, pan, envGen));
}).add;

)



// TESTING

// Synth(\LNX_Saw1, [amp: 0.6, a1: 0.5, d1: 0.5, s1: 0.5, r1: 0.5, v1: 0.6, out: 1]);
Synth(\mspWaves, [buf: ~wt_buf[5]])

(
Pbindef(\msp_pad,
    \instrument, \msp_waves,
    \buf, ~wt_buf[0],
).play;
)

Pbindef(\msp_pad).stop;


s.avgCPU

// ORIG
(
Pbindef(\pad,
    \instrument, \msp_waves,
    \dur, Pwrand([1,4,6,9,12],[0.35,0.25,0.2,0.15,0.05],inf),
    \atk, Pexprand(3,6),
    \sus, 0,
    \rel, Pexprand(5,10),
    \c0, Pexprand(1,2),
    \c1, Pexprand(1,2).neg,
    \detune, Pfunc({rrand(0.15,0.4)}!3),
    \buf, Prand(~wt_buf[0..3], inf),
    \buf, ~wt_buf[0],
    \scale, Scale.minorPentatonic,
    \degree, Pfunc({
        (-12,-10..12).scramble[0..rrand(1,3)]
    }),
    \amp, Pexprand(0.05,0.07),
    \pan, Pwhite(-0.4,0.4),
    \out, 0,
    \rout, ~rbus,
    \rsend, -10,
).play;
)
