(

~rbus = Bus.audio(s,2);

// Scale.directory
~scale = Scale.ritusen;

//// tester ////////////////////////////////////////////////////////////////////
SynthDef(\simpleSine,
    {|freq = 80, out| Out.ar(out, SinOsc.ar(freq, 0, 0.2)) }
).add;


//// gamaBell //////////////////////////////////////////////////////////////////
SynthDef(\gamaBell,
    {|out = 0, freqs = #[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
        rings = #[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], atk = 5, sus = 8, rel = 5, pan = 0, amp = 0.5|
        var e = EnvGen.kr(Env.linen(atk, sus, rel, 1, 4), doneAction: Done.freeSelf);
        var i = Decay.ar(Impulse.ar(Rand(0.8, 2.2)), 0.03, ClipNoise.ar(0.01));
        var z = Klank.ar(
            `[freqs, nil, rings],     // specs
            i                    // input
        );
        var sound = z*e * amp;
        // Out.ar(out, Pan2.ar(z*e, pan));
        OffsetOut.ar(out, DirtPan.ar(sound, ~dirt.numChannels, pan))
}).add;


SynthDef(\hauntedSine, {
    arg freq=440, atk=0.005, rel=0.3, sustain=1, amp=1, pan=0, out=0;
    var sig, env;
    sig = SinOsc.ar(freq);
    env = EnvGen.kr(Env.new([0,1,0], [atk, rel], [1 -1]), timeScale:sustain, doneAction:2);
    sig = Pan2.ar(sig, pan, amp);
    sig = sig * env;
    // Out.ar(out, sig);
    OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan))
}).add;

////////////////////////////////////////////////////////////////////////////////
//
// AMBIENT
//
//
// Based up Eli Fieldsteel's excellent wavetable synthesis lessons:
// https://www.youtube.com/watch?v=8EK9sq_9gFI
//
////////////////////////////////////////////////////////////////////////////////

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

SynthDef(\osc, {
    arg buf=0, freq=200, detune=0.2,
    amp=0.2, pan=0, out=0, rout=0, rsend=(-20),
    atk=0.01, sus=1, rel=0.01, c0=1, c1=(-1);
    var sig, env, detuneCtrl;
    env = EnvGen.ar(
        Env([0,1,1,0],[atk,sus,rel],[c0,0,c1]),
        doneAction:2
    );

    //array of eight Oscs with uniquely detune frequencies
    //and unique initial phase offsets
    detuneCtrl = LFNoise1.kr(0.1!8).bipolar(detune).midiratio;
    sig = Osc.ar(buf, freq * detuneCtrl, {Rand(0,2pi)}!8);

    sig = Splay.ar(sig); //spread 8 signals over stereo field
    sig = LeakDC.ar(sig); //remove DC bias
    sig = Balance2.ar(sig[0], sig[1], pan, amp); //L/R balance (pan)
    sig = sig * env;
    Out.ar(out, sig);
    Out.ar(rout, sig * rsend.dbamp); //"post-fader" send to reverb
}).add;

SynthDef(\reverb, {
    arg in=0, out=0, dec=4, lpf=1500;
    var sig;
    sig = In.ar(in, 2).sum;
    sig = DelayN.ar(sig, 0.03, 0.03);
    sig = CombN.ar(sig, 0.1, {Rand(0.01,0.099)}!32, dec);
    sig = SplayAz.ar(2, sig);
    sig = LPF.ar(sig, lpf);
    5.do{sig = AllpassN.ar(sig, 0.1, {Rand(0.01,0.099)}!2, 3)};
    sig = LPF.ar(sig, lpf);
    sig = LeakDC.ar(sig);
    Out.ar(out, sig);
}).add;

// s.sync;

//instantiate reverb and re-instantiate when cmd-period is pressed
~add_reverb = {Synth(\reverb, [\in, ~rbus])};
ServerTree.add(~add_reverb);
s.freeAll;

////////////////////////////////////////////////////////////////////////////////
//
// PRAYER BELLS
//
//
// Based up this:
// https://sccode.org/1-4VL
//
////////////////////////////////////////////////////////////////////////////////

SynthDef(\prayer_bell, { |out, t_trig = 1, sing_switch = 0, freq = 2434, amp = 0.5, decayscale = 1, lag = 10, i_doneAction = 0, pan = 0.5|
    var sig, input, first, freqscale, mallet, sing;
    freqscale = freq / 2434;
    freqscale = Lag3.kr(freqscale, lag);
    decayscale = Lag3.kr(decayscale, lag);

    mallet = LPF.ar(Trig.ar(t_trig, SampleDur.ir)!2, 10000 * freqscale);
    sing = LPF.ar(
        LPF.ar(
            {
                PinkNoise.ar * Integrator.kr(sing_switch * 0.001, 0.999).linexp(0, 1, 0.01, 1) * amp
            } ! 2,
            2434 * freqscale
        ) + Dust.ar(0.1), 10000 * freqscale
    ) * LFNoise1.kr(0.5).range(-45, -30).dbamp;
    input = mallet + (sing_switch.clip(0, 1) * sing);


    sig = DynKlank.ar(`[
        [
            (first = LFNoise1.kr(0.5).range(2424, 2444)) + Line.kr(20, 0, 0.5),
            first + LFNoise1.kr(0.5).range(1,3),
            LFNoise1.kr(1.5).range(5435, 5440) - Line.kr(35, 0, 1),
            LFNoise1.kr(1.5).range(5480, 5485) - Line.kr(10, 0, 0.5),
            LFNoise1.kr(2).range(8435, 8445) + Line.kr(15, 0, 0.05),
            LFNoise1.kr(2).range(8665, 8670),
            LFNoise1.kr(2).range(8704, 8709),
            LFNoise1.kr(2).range(8807, 8817),
            LFNoise1.kr(2).range(9570, 9607),
            LFNoise1.kr(2).range(10567, 10572) - Line.kr(20, 0, 0.05),
            LFNoise1.kr(2).range(10627, 10636) + Line.kr(35, 0, 0.05),
            LFNoise1.kr(2).range(14689, 14697) - Line.kr(10, 0, 0.05)
        ],
        [
            LFNoise1.kr(1).range(-10, -5).dbamp,
            LFNoise1.kr(1).range(-20, -10).dbamp,
            LFNoise1.kr(1).range(-12, -6).dbamp,
            LFNoise1.kr(1).range(-12, -6).dbamp,
            -20.dbamp,
            -20.dbamp,
            -20.dbamp,
            -25.dbamp,
            -10.dbamp,
            -20.dbamp,
            -20.dbamp,
            -25.dbamp
        ],
        [
            20 * freqscale.pow(0.2),
            20 * freqscale.pow(0.2),
            5,
            5,
            0.6,
            0.5,
            0.3,
            0.25,
            0.4,
            0.5,
            0.4,
            0.6
        ] * freqscale.reciprocal.pow(0.5)
    ], input, freqscale, 0, decayscale);
    DetectSilence.ar(sig, doneAction: i_doneAction);
    // Out.ar(out, sig);
    OffsetOut.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan))
}).add;

// A vaguely 808-ish kick drum
// "n" controls the chirp frequency, "sustain" the overall timescale, "rate" the filter sweep speed,
// and "voice" the sinewave feedback

SynthDef(\super808, {|out, rate=1, sustain=1, pan, voice=0, n |
    var env, sound, freq;
    n = ((n>0)*n) + ((n<1)*3);
    freq = (n*10).midicps;
    env = EnvGen.ar(Env.linen(0.01, 0, 1, 1, -3), timeScale:sustain, doneAction:2);
    sound = LPF.ar(SinOscFB.ar(XLine.ar(freq.expexp(10, 2000, 1000, 8000), freq, 0.025/rate), voice), 9000);
    OffsetOut.ar(out, DirtPan.ar(sound, ~dirt.numChannels, pan, env))
}).add;


/*(
// test-er the-er laser synth-er
var sustain = 1;
var accelerate = 0;
var decay = 0.4;
var voice = 1;
var freq = 440;
var att=0.01;

var freqlist =[1.000,  2.081,  3.414,  3.893,  4.995,  5.954,  6.819,  8.280,  8.722,  8.882, 10.868, 11.180, 11.754,
13.710, 13.715, 15.057, 15.484, 16.469, 16.817, 18.628]**1.0;

var tscale = 100.0 / freq / (freqlist**(2-clip(decay,0,2)));
var ascale =freqlist**clip(voice,0,4);

// "--------------------------------------".postln;
// tscale.postln;
// ascale.postln;


)*/

//
// based on supergong!
//

SynthDef(\mspLaser,{
    arg out, sustain=1, pan, accelerate, freq, voice=0,
    mAttackTime = 0.01,
    mDecayTime = 1,
    mDecayLevel = 0.5,
    // mHoldTime = 0.95,
    // mHoldLevel = 0.5,
    mReleaseTime = 1;

    // lowest modes for clamped circular plate

    var freqlist =[1.000,  2.081,  3.414,  3.893,  4.995,  5.954,  6.819,  8.280,  8.722,  8.882, 10.868, 11.180, 11.754,
        13.710, 13.715, 15.057, 15.484, 16.469, 16.817, 18.628]**1.0;

    var tscale = 100.0 / freq / (freqlist**(2-clip(mDecayTime,0,2)));

    var ascale =freqlist**clip(voice,0,4);

    var partials = freqlist.size;
    // var partials =8;
    // var partials = numPartials;

    var sound = Mix.arFill(partials, {
        arg i;

        // var envShape = Env.pairs([
        //     [0,0],
        //     [mAttackTime*tscale[i],1],
        //     [mDecayTime, mDecayLevel],
        //     [mHoldTime,mHoldLevel*ascale[i]],
        // [mReleaseTime*tscale[i],0]], -1);

        var envShape = Env.perc(mAttackTime*tscale[i], (mReleaseTime/2)*tscale[i], 0.2*ascale[i] );

        // EnvGen.ar(Env.perc(att*tscale[i], 0.5*tscale[i], 0.2*ascale[i] ), timeScale:sustain*5)
        // * SinOsc.ar(freq * freqlist[i] * Line.kr(1, 1+accelerate, sustain))

        EnvGen.ar(envShape, timeScale:sustain*5)
        * SinOsc.ar(freq * freqlist[i] * Line.kr(1, 1+accelerate, sustain))
    });

    OffsetOut.ar(out, DirtPan.ar(sound, ~dirt.numChannels, pan))
}).add;

// orig!
SynthDef(\mspsupergong,{|out, sustain=1, pan, accelerate, freq, voice=0, decay=1, att=0.01 |
    // lowest modes for clamped circular plate
    var freqlist =[1.000,  2.081,  3.414,  3.893,  4.995,  5.954,  6.819,  8.280,  8.722,  8.882, 10.868, 11.180, 11.754,
        13.710, 13.715, 15.057, 15.484, 16.469, 16.817, 18.628]**1.0;
    var tscale = 100.0 / freq / (freqlist**(2-clip(decay,0,2)));
    var ascale =freqlist**clip(voice,0,4);


    var sound = Mix.arFill(15, {arg i; EnvGen.ar(Env.perc(att*tscale[i], 0.5*tscale[i], 0.2*ascale[i] ), timeScale:sustain*5)
        * SinOsc.ar(freq * freqlist[i] * Line.kr(1, 1+accelerate, sustain))});


    OffsetOut.ar(out, DirtPan.ar(sound, ~dirt.numChannels, pan))
}).add;



SynthDef(\mspplucklead, {
    |out, sustain = 1, freq = 440, speed = 1, begin=0, end=1, pan, offset|

    var line = Line.ar(begin, end, sustain, doneAction:2);
    var env = Env([0, 1, 0.333, 0],[5, 70, 1000]);

    var envGen = IEnvGen.ar(env, line*env.times.sum*abs(speed));
    // var envGen = EnvGen.ar(Env.adsr);
    var speedFreq = freq*abs(speed);

    var pulseLfo = SinOsc.ar(Rand(-1,1));

    var sound = Pulse.ar([speedFreq*Rand(0.99,1.01)*2,speedFreq*Rand(0.99,1.01)*2]);
    // sound = RLPF.ar(sound, (20000*(envGen**2.8))+DC.ar(10), 0.5);
    // sound = RLPF.ar(sound, (2500*(envGen**4.8))+DC.ar(10), 0.2);


    // var filterEnv = (2500*(envGen**4.8))+DC.ar(10);
    var filterEnv = XLine.kr(2500, 10, 0.3, 1);
    sound = RLPF.ar(sound, filterEnv, 0.5);
    // sound = Resonz.ar(sound, filterEnv, 2, 3);

    Out.ar(out, DirtPan.ar(sound, ~dirt.numChannels, pan, envGen));
}).add;


SynthDef(\msp808, {|out, speed=1, sustain=1, pan, voice=0, att = 0.01, n |
    var env, sound, kick, synth, freq, freqCurve;
    n = ((n>0)*n) + ((n<1)*3);
    freq = (n*10).midicps;

    env = EnvGen.ar(Env.linen(att, 0, 1, 1, -3), timeScale:sustain, doneAction:2);

    // sound = LPF.ar(SinOscFB.ar(XLine.ar(freq.expexp(10, 2000, 1000, 8000), freq, 0.025/speed), voice), 9000);


    freqCurve = XLine.ar(freq.expexp(10, 2000, 1000, 8000), freq, 0.025/speed);

    kick = LPF.ar(SinOscFB.ar(freqCurve, voice), 9000);

    // synth = DynKlank.ar(`[[800, 1071, 1353, 3723], nil, [0.1, 0.1, 0.1, 1]], PinkNoise.ar([0.007, 0.007])) * 0.6;

    // sound = Mix.new([ kick, synth ]);
    sound = kick;

    OffsetOut.ar(out, DirtPan.ar(sound, ~dirt.numChannels, pan, env))
}).add;

// Hi-hat using Rumble-San's implementation as a starting point
// http://blog.rumblesan.com/post/53271713518/drum-sounds-in-supercollider-part-1
// using "n" in a weird way to provide some variation on the frequency
// "sustain" affects the overall envelope rate, "accelerate" sweeps the filter
(
SynthDef(\mspSuperHat, {|out, sustain=1, pan, accelerate, n |
    var env, sound, accel, freq;
    env = EnvGen.ar(Env.linen(0.01, 0, 0.3, 1, -3), timeScale:sustain, doneAction:2);
    accel = Line.kr(1, 1+accelerate, 0.2*sustain);
    freq = 2000*accel*(n/5 + 1).wrap(0.5,2);
    sound = HPF.ar(LPF.ar(WhiteNoise.ar(1), 3*freq), freq);
    OffsetOut.ar(out, DirtPan.ar(sound, ~dirt.numChannels, pan, env))
}).add
);

SynthDef(\mspSuperzow, {
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



)
