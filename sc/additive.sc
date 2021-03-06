(
var numharm, win, continuousOut, percussiveOut, multiSlider, volumeSlider, fundamentalSlider, modeButton, singleNoteButton, attackSlider, releaseSlider, subwin, singleNoteRoutine, att = 0.01, rel = 2, ampBus, fundamentalBus, knobArray, partialArray, envArray, numberOfEnvPoints, tmpEnvLevels, tmpEnvTimes;

numharm = 16;
numberOfEnvPoints = 4;

partialArray = Array.newClear(16);

fundamentalBus = Bus.control(s, 1);
fundamentalBus.set(110);

ampBus = Bus.control(s);
ampBus.value = 0.75;

~sndBus = Bus.audio(s, 2);

~partialEnvLevels = Array.newClear(numharm);
~partialEnvLevels.do({|env, index|
    ~partialEnvLevels[index] = Bus.control(s, numberOfEnvPoints);
});

~partialEnvTimes = Array.newClear(numharm);
~partialEnvTimes.do({|item, index|
    ~partialEnvTimes[index] = Bus.control(s, numberOfEnvPoints-1);
});

~partialEnvs = Array.newClear(numharm);
~partialEnvs.do({|item, index|

    tmpEnvLevels = {1.0.rand}!numberOfEnvPoints;
    tmpEnvTimes = ({1.0.rand}!(numberOfEnvPoints-1)).normalizeSum;

    ~partialEnvs[index] =  Env.new(
        levels: tmpEnvLevels,
        times: tmpEnvTimes
    );

    ~partialEnvLevels[index].setn(tmpEnvLevels);
    ~partialEnvTimes[index].setn(tmpEnvTimes.drop(1));
});


// Main window ///////////////////////////////////////////////////////////////////////
// Window.closeAll;
win = Window.new("Additive Synthesis", Rect(0, 0, 1320, 1340), scroll: true);
win.view.decorator = d = FlowLayout(win.view.bounds, 20@20, 10@10);
win.front;

win.onClose = {s.freeAll; "Done!".postln; "".postln};
CmdPeriod.doOnce({win.close});

// Multislider /////////////////////////////////////////////////////////////////////////
multiSlider = MultiSliderView(win, Rect(0, 0, 620, 250));
multiSlider.value = Array.fill(numharm, {0.0});
multiSlider.isFilled = true;
multiSlider.indexThumbSize = 29.0;
multiSlider.gap = 9;
multiSlider.action = {multiSlider.value.do({arg value, count;
    ~spectrum[count].set(\amp, value)})};

d.nextLine();

knobArray = Array.fill(numharm, {Knob(win, 29@29)});

knobArray.do({arg item, count;
    knobArray[count].centered = true;
    knobArray[count].value = rrand(0.4, 0.6).round(0.01); // de-centered positions (center=0.5)
    knobArray[count].action = {arg knob;
        // update array of partials
        partialArray[count] = knob.value.linlin(0, 1, -0.2, 0.2).round(0.01) + count + 1;
        // if this partial is currently playing, update its partial number (thus freq):
        if(~spectrum[count].isNil.not,
            {~spectrum[count].set(\partial, partialArray[count])})}});


d.nextLine();

// Envelopes //////////////////////////////////////////////////////////////////////////
envArray = Array.fill(numharm, {EnvelopeView(win, 300@100)});

envArray.do({|env, index|
	env.drawLines_(true);
	env.selectionColor_(Color.red);
	env.drawRects_(true);
	env.keepHorizontalOrder_(true);
    env.setEnv(~partialEnvs[index]);
	env.step_(0.01);
	env.thumbSize_(18);

	env.action_({|b|
        "levels: ".post;
        b.value[1].postln;
        "times: ".post;
        b.value[0].differentiate.drop(1).postln;

        ~partialEnvLevels[index].setn(b.value[1]);
        ~partialEnvTimes[index].setn(b.value[0].differentiate.drop(1));
	})
});


// Knobs //////////////////////////////////////////////////////////////////////////////
// Initialize array of partials with first knob values
partialArray.do({arg item, count;
    partialArray[count] = knobArray[count].value.linlin(0, 1, -0.2, 0.2).round(0.01) + count + 1});
// in the line above, "+ 0.5" adjusts for knob center = 0.5 (becomes center = 1);
// this deviation value then is multiplied by the partial number

fundamentalSlider = EZSlider(
    parent: win,
    bounds: 620 @ 40,
    label: "FREQ",
    controlSpec: ControlSpec(50, 200, \lin, 1, 110, "Hz"),
    action: {|ez| fundamentalBus.set(ez.value)},
    initVal: 110,
    unitWidth: 30)
.setColors(
    stringColor: Color.black,
    sliderBackground: Color.grey(0.9),
    numNormalColor: Color.black);

d.nextLine();

// Volume slider //////////////////////////////////////////////////////////////////////
volumeSlider = EZSlider(
    parent: win,
    bounds: 620 @ 40,
    label: "VOLUME",
    controlSpec: ControlSpec(1, 100, \lin, 1, 10, "%"),
    action: {|ez| ampBus.set(ez.value/100)},
    initVal: 75,
    unitWidth: 30)
.setColors(
    stringColor: Color.black,
    sliderBackground: Color.grey(0.9),
    numNormalColor: Color.black);

d.nextLine();

// Mode button (toggle between continuous and percussive)
modeButton = Button(win, 620 @110);
modeButton.states = [
    ["CONTINUOUS TONE (click here to switch to percussive mode)", Color.black, Color.new255(255, 255, 114)],
    ["PERCUSSIVE TONE (click here to switch to continuous mode)", Color.black, Color.new255(255, 204, 194)]
];
modeButton.action = {arg state;
    if(state.value==0,
        {
            volumeSlider.valueAction = 10;
            continuousOut.set(\gate, 1);
            "CONTINUOUS MODE ON".postln;
            singleNoteButton.states = [["perc"]];
            subwin.background = Color.grey(0.6, 0);
        },
        {
            continuousOut.set(\gate, 0);
            "PERCUSSIVE MODE ON - click on perc button".postln;
            singleNoteButton.states = [["perc", Color.black, Color.new255(255, 204, 194)]];
            subwin.background = Color.grey(0.6, 1);
        }
)};

d.nextLine();

// CompositeView (sub window)
subwin = CompositeView(win, 620@100);
subwin.background = Color.grey(0.6, 0);

// Button for triggering single percussive note
singleNoteButton = Button(subwin, Rect(10, 10, 70, 80));
singleNoteButton.states = [["perc"]];
singleNoteButton.action = {
    if(modeButton.value==1, {
        percussiveOut = Synth("mspAdd", [\inbus, ~sndBus, \att, att, \rel, rel, \amp, ampBus.asMap], addAction: \addToTail);

        "bang!".postln});
};

// Attack and Release controls for percussive notes
attackSlider = EZSlider(
    parent: subwin,
    bounds: Rect(left: 80, top: 15, width: 530, height: 30),
    label: "Attack",
    controlSpec: ControlSpec(0.01, 4.0, \exp, 0.001, 0.1, "sec"),
    action: {|ez| att = ez.value},
    initVal: 0.01,
    unitWidth: 30)
.setColors(
    stringColor: Color.black,
    sliderBackground: Color.grey(0.7),
    numNormalColor: Color.black);

d.nextLine();

releaseSlider = EZSlider(
    parent: subwin,
    bounds: Rect(80, 55, 530, 30),
    label: "Release",
    controlSpec: ControlSpec(0.3, 10, \exp, 0.01, 2, "sec"),
    action: {|ez| rel = ez.value},
    initVal: 2,
    unitWidth: 30)
.setColors(
    stringColor: Color.black,
    sliderBackground: Color.grey(0.7),
    numNormalColor: Color.black);

d.nextLine();

// Routine to add SynthDefs, wait for Server reply, then start Synths
{
    SynthDef("additive-multislider-2", {
        arg outbus, fundamental = 110, partial = 2.1, amp = 0.01, envLevelsBus, envTimesBus;

        var snd, ampEnvLevels, ampEnvTimes, envDuration, ampEnv, ampEnvCtl, loopTime, index = 0;

        loopTime = 1;

        ampEnvLevels = ~partialEnvLevels.at(0).kr;
        ampEnvTimes = ~partialEnvTimes.at(0).kr;

        envDuration = 5;

        // ampEnvCtl = EnvGen.kr(Env.circle([0, 1, 0], [0.5, 3, 0.01]));
        // ampEnvCtl = EnvGen.kr(Env.circle(ampEnvLevels, ampEnvTimes.add(loopTime)));

        ampEnv = Env.circle(ampEnvLevels, ampEnvTimes);

        ampEnvCtl = EnvGen.kr(ampEnv);
        // ampEnvCtl = EnvGen.kr(Env.circle(envLevelsBus, envTimesBus));

        snd = SinOsc.ar(freq: fundamental * partial, phase: 0);
        // snd = snd * ampEnvCtl * amp;
        snd = snd * amp;

        Out.ar(outbus, (snd)!2);
    }).add;

    SynthDef("continuousOut", {
        arg amp = 0.1, gate = 1, att = 0.1, sus = 1, rel = 1;
        var inbus, env = EnvGen.kr(Env.asr(att, sus, rel), gate);
        inbus = ~sndBus;
        Out.ar(0, In.ar(inbus, 2) * amp * env * 0.05);
    }).add;

    SynthDef("mspAdd", {
        arg out, amp = 0.1, attack = 0.01, release = 2, pan = 0, sustain = 1;
        var inbus, sound, env;
        inbus = ~sndBus;

        env = EnvGen.ar(Env.perc(attack, release), timeScale:sustain, doneAction:2);
        // sound = SinOsc.ar(440);
        sound = In.ar(inbus, 2);

        OffsetOut.ar(out,
            DirtPan.ar(sound, ~dirt.numChannels, pan, env)
        )
    }).add;

    // Wait for SynthDefs to be added...
    s.sync;

    // Now call the Synths:
    ~spectrum = Array.fill(numharm, {
        arg i;
        "spectrum: ".post;
        i.postln;
        Synth("additive-multislider-2", [\fundamental, fundamentalBus.asMap, \partial, partialArray[i], \amp, 0.0, \outbus, ~sndBus, \partialIndex, i])
    });

    continuousOut = Synth("continuousOut", [\inbus,~sndBus, \amp, ampBus.asMap], addAction: \addToTail);

}.fork;

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