(
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


)

(
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


)