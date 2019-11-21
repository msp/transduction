// ************************************
// Frequency Modulation Fun (GUI)
// Patch 3 - Using Envelopes
// Bruno Ruviaro, 2013-08-12
// ************************************

/*

Experiment with frequency modulation by specifying
contours for Carrier Frequency, Modulator Frequency,
Modulation Index, and Amplitude Envelope.
You can also choose duration of a "note".

Select all (ctrl + A), then evaluate (ctrl + period).

*/

s.waitForBoot({

	var numberOfPoints, scaleEnv, scaleLevels, win, subwin, evCarrFreq, evModFreq, evModIndex, evAmp, font, font2, labelColor, windowColor, timeScale, volumeSlider, durationSlider, printEnvData, adjustEnv, masterOut, presetArray, presetButtons, tmpAmpEnvLevels, tmpAmpEnvTimes, tmpEnvLevels, tmpEnvTimes, p5;

    // p5 = NetAddr.new("127.0.0.1", 1818);
    // p5 = NetAddr.new("192.168.0.1", 1818);
    // p5 = NetAddr.new("192.168.1.33", 1818);
    p5 = NetAddr.new("127.0.0.1", 1818);


	timeScale = 3; // total duration of a "note"
	numberOfPoints = 8; // how many points in the breakpoint envelopes
	presetArray = Array.newClear(12); // number of presets

	font = Font("Verdana", 16, bold: true);
	font2 = Font("Verdana", 84);
	labelColor = Color.white;
	windowColor = Color.grey(0.1);

    tmpEnvLevels = {1.0.rand}!numberOfPoints;
    tmpEnvTimes = ({1.0.rand}!(numberOfPoints-1)).normalizeSum;

    ~sndBus = Bus.audio(s, 2);

    ~carrFreqEnvLevels = Bus.control(s, numberOfPoints);
    ~carrFreqEnvTimes = Bus.control(s, numberOfPoints-1);

	~carrFreqEnv = Env.new(
		levels: tmpEnvLevels,
		times: tmpEnvTimes
	);

    ~modFreqEnvLevels = Bus.control(s, numberOfPoints);
    ~modFreqEnvTimes = Bus.control(s, numberOfPoints-1);

    ~modFreqEnv = Env.new(
		levels: tmpEnvLevels,
		times: tmpEnvTimes
	);

    ~modIndexEnvLevels = Bus.control(s, numberOfPoints);
    ~modIndexEnvTimes = Bus.control(s, numberOfPoints-1);

	~modIndexEnv = Env.new(
		levels: tmpEnvLevels,
		times: tmpEnvTimes
	);

    ~ampEnvLevels = Bus.control(s, numberOfPoints);
    ~ampEnvTimes = Bus.control(s, numberOfPoints-1);
    ~ampEnvDuration = Bus.control(s, 1);

    // using 'put' to make sure first and last are 0.0
    tmpAmpEnvLevels = ({1.0.rand}!numberOfPoints).put(0, 0).put(numberOfPoints-1, 0);
    tmpAmpEnvTimes = ({1.0.rand}!(numberOfPoints-1)).normalizeSum;

    ~ampEnvLevels.setn(tmpAmpEnvLevels);
    ~ampEnvTimes.setn(tmpAmpEnvTimes);

    ~ampEnv = Env.new(
        levels: tmpAmpEnvLevels,
        times: tmpAmpEnvTimes
    );
	/*
	carrFreqEnv = Env.new([0.5, 0.5, 0.4, 0.5], [0.3, 0.3, 0.3, 0.1]);
	modFreqEnv = Env.new([0.25, 0.25, 0.25, 0.25], [0.3, 0.3 ,0.4]);
	modIndexEnv = Env.new([0, 0.3, 0.7, 1], [0.25, 0.25, 0.5]);
	*/


    // Window.closeAll;

	win = Window.new("Frequency Modulation Fun",
        Rect(300, Window.screenBounds.height, 915, 400), resizable: false);
	win.front;
	win.background = windowColor;
	win.alpha = 0.95;
	win.onClose = {s.freeAll};
	CmdPeriod.doOnce({Window.closeAll});

	subwin = FlowView.new(
		parent: win,
		bounds: Rect(710, 230, 185, 150),
		margin: 10@10,
		gap: 10@10;
	);

	///////////////////////////////
	// Envelope Sliders (3)
	///////////////////////////////

	// carrFreq
	Slider(win, Rect(20, 21, 20, 148))
	.action_({arg slider;
		var v = slider.value;
		~carrFreqEnv = Env.new(
			levels: v!numberOfPoints, // straight line
			times: (0.1!(numberOfPoints-1)).normalizeSum);
		evCarrFreq.setEnv(~carrFreqEnv);
		evCarrFreq.action.value(evCarrFreq); // does all the stuff
	});

	// modFreq
	Slider(win, Rect(360, 21, 20, 148))
	.action_({arg slider;
		var v = slider.value;
		~modFreqEnv = Env.new(
			levels: v!numberOfPoints, // straight line
			times: (0.1!(numberOfPoints-1)).normalizeSum);
		evModFreq.setEnv(~modFreqEnv);
		evModFreq.action.value(evModFreq); // does all the stuff
	});

	// modIndex
	// Slider(win, Rect(20, 210, 20, 148));
	Slider(win, Rect(20, 210, 20, 148))
	.action_({arg slider;
		var v = slider.value;
		~modIndexEnv = Env.new(
			levels: v!numberOfPoints, // straight line
			times: (0.1!(numberOfPoints-1)).normalizeSum);
		evModIndex.setEnv(~modIndexEnv);
		evModIndex.action.value(evModIndex); // does all the stuff
	});

	///////////////////////////////
	// EnvelopeViews (4)
	///////////////////////////////

	evCarrFreq = EnvelopeView(win, Rect(40, 20, 300, 150))
	// .thumbWidth_(30.0)
	// .thumbHeight_(15.0)
	.setEnv(~carrFreqEnv)
	.drawLines_(true)
	.selectionColor_(Color.red)
	.drawRects_(true)
	.step_(0.01)
	.keepHorizontalOrder_(true)
	.action_({arg b;
        ~carrFreqEnvLevels.setn(scaleLevels.value(b.value[1], 50, 1000));
        ~carrFreqEnvTimes.setn(b.value[0].differentiate.drop(1));
		~carrFreqEnv.levels = scaleLevels.value(b.value[1], 50, 1000);
		~carrFreqEnv.times = b.value[0].differentiate.drop(1);
	})
	.thumbSize_(18);

	evModFreq = EnvelopeView(win, Rect(380, 20, 300, 150))
	.setEnv(~modFreqEnv)
	.drawLines_(true)
	.selectionColor_(Color.red)
	.drawRects_(true)
	.step_(0.01)
	.keepHorizontalOrder_(true)
	.action_({arg b;
        ~modFreqEnvLevels.setn(scaleLevels.value(b.value[1], 50, 1000));
        ~modFreqEnvTimes.setn(b.value[0].differentiate.drop(1));
		~modFreqEnv.levels = scaleLevels.value(b.value[1], 50, 1000);
		~modFreqEnv.times = b.value[0].differentiate.drop(1);
	})
	.thumbSize_(18);

	evModIndex = EnvelopeView(win, Rect(40, 210, 300, 150))
	.setEnv(~modIndexEnv)
	.drawLines_(true)
	.selectionColor_(Color.red)
	.drawRects_(true)
	.step_(0.01)
	.keepHorizontalOrder_(true)
	.action_({arg b;
        ~modIndexEnvLevels.setn(scaleLevels.value(b.value[1], 0, 10));
        ~modIndexEnvTimes.setn(b.value[0].differentiate.drop(1));
		~modIndexEnv.levels = scaleLevels.value(b.value[1], 0, 10);
		~modIndexEnv.times = b.value[0].differentiate.drop(1);
	})
	.thumbSize_(18);

	evAmp = EnvelopeView(win, Rect(360, 210, 320, 150))
	.setEnv(~ampEnv)
	.drawLines_(true)
	.selectionColor_(Color.red)
	.drawRects_(true)
	.step_(0.01)
	.keepHorizontalOrder_(true)
	.action_({arg b;
        "send OSC message to P5!".postln;
        ~msg = ["/amp/env"] ++ b.value[1];
        p5.sendMsg(*~msg);
        ~ampEnvLevels.setn(b.value[1]);
        ~ampEnvTimes.setn(b.value[0].differentiate.drop(1));
        ~ampEnvDuration.set(timeScale);

		~ampEnv.levels = b.value[1];
		~ampEnv.times = b.value[0].differentiate.drop(1);
	})
	.thumbSize_(18);

	/////////////////////////////////////
	// Volume and Duration EZSliders (2)
	/////////////////////////////////////

	volumeSlider = EZSlider(
		parent: win,
		bounds: Rect(830, 10, 50, 170),
		label: "volume",
		controlSpec: ControlSpec(-60, 0, \lin, 1, -40, "dB"),
		action: {|ez| masterOut.set(\amp, ez.value.dbamp)},
		unitWidth: 30,
		labelWidth: 80,
		layout: 'vert')
	.setColors(
		stringColor: labelColor,
		// sliderBackground: Color.grey,
		numNormalColor: Color.black);

	volumeSlider.numberView.align = \center;
	volumeSlider.unitView.align = \center;

	durationSlider = EZSlider(
		parent: win,
		bounds: Rect(665, 184, 240, 40),
		label: "dur",
		controlSpec: ControlSpec(0.1, 13, \lin, 0.1, timeScale, "sec"),
		action: {|ez|
			timeScale = ez.value;
			evCarrFreq.action.value(evCarrFreq);
			evModFreq.action.value(evModFreq);
			evModIndex.action.value(evModIndex);
			evAmp.action.value(evAmp);

            "send OSC meesage to P5!".postln;
           ~msg = ["/amp/env/sustain"] ++ ez.value;
           p5.sendMsg(*~msg);
        },
		numberWidth: 35,
		unitWidth: 30,
		layout: 'horz')
	.setColors(
		stringColor: labelColor,
		// sliderBackground: Color.grey,
		numNormalColor: Color.black);

	durationSlider.numberView.align = \center;

	///////////////////////////////
	// Static Texts (4)
	///////////////////////////////

	StaticText(win, Rect(20, 165, 200, 40))
	.string_("Carrier Frequency")
	.font_(font)
	.stringColor = labelColor;

	StaticText(win, Rect(360, 165, 250, 40))
	.string_("Modulator Frequency")
	.font_(font)
	.stringColor = labelColor;

	StaticText(win, Rect(20, 355, 250, 40))
	.string_("Modulation Index")
	.font_(font)
	.stringColor = labelColor;

	StaticText(win, Rect(360, 355, 250, 40))
	.string_("Amplitude Envelope")
	.font_(font)
	.stringColor = labelColor;

	///////////////////////////////
	// Buttons
	///////////////////////////////

	// Play
	Button(win, Rect(710, 21, 100, 147))
	.states_([["PLAY", Color.black]])
	.action_({
		Synth.new("mspFM", [\sustain, 1
		]);
	})
	.font_(Font("Verdana", 20));

	// Presets
	presetButtons = Array.fill(12, {arg i;
		Button(subwin, 30@30)
		.states_([[i.asString]])
		.action_({presetArray[i].value; "Preset % recalled".postf(i); "".postln});
	});

	// Print current settings
	Button(subwin, 150@20)
	.states_([["print current settings"]])
	.action_({
		"**************************".postln;
		"**************************".postln;
		"To save the settings below as a Preset,".postln;
		"copy all lines and paste them into".postln;
		"one of the existing preset functions".postln;
		"For instance,".postln;
		"".postln;
		"presetArray[9] = { <copy settings here> };".postln;
		"".postln;
		"**************************".postln;
		printEnvData.value;
		"**************************".postln;
	});

	/*

	After hitting the "print current settings" button, you can copy the entire result from the Post window and overwrite an existing preset with it.
	Simply paste all the contents into one of the preset functions like

	presetArray[9] = { <copy settings here> };

	*/


	//////////////////////////////////////////
	// General functions to scale envelopes
	//////////////////////////////////////////

	// This simple custom function just scales an Envelope
	// to desired ranges (levels, times) so that it is
	// ready to go when a Synth uses them.

	scaleEnv = {arg thisEnv, minVal, maxVal;

		thisEnv.levels = thisEnv.levels.linlin(0, 1, minVal, maxVal);
		thisEnv.duration_(timeScale);
		thisEnv.duration_(timeScale);
		// "scaling done!".postln;
	};

	scaleLevels = {
        arg levelsArray, minVal, maxVal;
		levelsArray.linlin(0, 1, minVal, maxVal);
	};

	// Ugly
	adjustEnv = {arg anEnv, inMin = 50, inMax = 1000;
		var anotherEnv = Env.newClear(numberOfPoints);
		anotherEnv.levels = anEnv.levels.linlin(inMin, inMax, 0, 1);
		anotherEnv.times = anEnv.times;
	};

	// Initialize very first envelopes (at time of first eval)
	evCarrFreq.action.value(evCarrFreq);
	evModFreq.action.value(evModFreq);
	evModIndex.action.value(evModIndex);
	evAmp.action.value(evAmp);


	////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// SynthDefs
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	{

		SynthDef("mspFM", {
            arg out, sustain;
			var carrFreq, carrFreqEnv, modFreq, modFreqEnv, modIndex, modIndexEnv, carrier, modulator, amp, ampEnv;

            var pan = 0.5;

            var ampEnvLevels = ~ampEnvLevels.kr;
            var ampEnvTimes = ~ampEnvTimes.kr;

            var carrFreqEnvLevels = ~carrFreqEnvLevels.kr;
            var carrFreqEnvTimes = ~carrFreqEnvTimes.kr;

            var modFreqEnvLevels = ~modFreqEnvLevels.kr;
            var modFreqEnvTimes = ~modFreqEnvTimes.kr;

            var modIndexEnvLevels = ~modIndexEnvLevels.kr;
            var modIndexEnvTimes = ~modIndexEnvTimes.kr;

            var envDuration = sustain * ~ampEnvDuration.kr;

			carrFreqEnv = Env.new(carrFreqEnvLevels, carrFreqEnvTimes);
            carrFreqEnv.duration_(envDuration);
            carrFreq = EnvGen.kr(carrFreqEnv);

			modFreqEnv = Env.new(modFreqEnvLevels, modFreqEnvTimes);
            modFreqEnv.duration_(envDuration);
			modFreq = EnvGen.kr(modFreqEnv);

			modIndexEnv = Env.new(modIndexEnvLevels, modIndexEnvTimes);
			modIndexEnv.duration_(envDuration);
			modIndex = EnvGen.kr(modIndexEnv);

            ampEnv = Env.new(ampEnvLevels, ampEnvTimes);
            ampEnv.duration_(envDuration);
            amp = EnvGen.kr(ampEnv, doneAction: Done.freeSelf);

			modulator = SinOsc.ar(freq: modFreq, mul: modIndex * modFreq);
            carrier = SinOsc.ar(freq: carrFreq + modulator, mul: amp);

            OffsetOut.ar(out,
                DirtPan.ar([carrier, carrier] , ~dirt.numChannels, pan)
            );

		}).add;


		SynthDef(\amp, {arg out=0, inbus=0, amp = 0.1, pan = 0.5, t_gate=1;
            var env, sound = In.ar(~sndBus, 2);

            env = EnvGen.ar(Env.adsr, t_gate, doneAction: Done.freeSelf);

            // ReplaceOut.ar(inbus, sound * amp);
            OffsetOut.ar(out,
                DirtPan.ar(sound * amp, ~dirt.numChannels, pan, env)
            );
        }).add;

		// Wait for SynthDefs to be added...
		s.sync;

		// Now call the Master Out Synth:
        // "Adding amp synth to server".postln;
        masterOut = Synth("amp", [\amp, volumeSlider.value.dbamp], addAction: \addToTail);

	}.fork;


	///////////////////////////
	//////// 12 PRESETS ///////
	///////////////////////////

	presetArray[0] = {

		~carrFreqEnv = Env.new([ 50, 50, 50, 50, 50, 50, 50, 50 ],[ 0.14, 0.15, 0.14, 0.14, 0.14, 0.15, 0.14 ]);
		~modFreqEnv = Env.new([ 192.5, 192.5, 192.5, 192.5, 192.5, 192.5, 192.5, 192.5 ],[ 0.14, 0.15, 0.14, 0.14, 0.14, 0.15, 0.14 ]);
		~modIndexEnv = Env.new([ 0, 6.8, 10, 9.4, 6.5, 4.1, 2.3, 0 ],[ 0.12244897959184, 0.14285714285714, 0.18367346938776, 0.14285714285714, 0.14285714285714, 0.081632653061225, 0.18367346938776 ]);
		~ampEnv = Env.new([ 0, 1, 1, 0.92, 0.53, 0.27, 0.08, 0 ],[ 0, 0.11, 0.21, 0.16, 0.17, 0.19, 0.16 ]);
		evCarrFreq.setEnv(adjustEnv.value(~carrFreqEnv));
		evModFreq.setEnv(adjustEnv.value(~modFreqEnv));
		evModIndex.setEnv(adjustEnv.value(~modIndexEnv, 0, 10));
		evAmp.setEnv(~ampEnv);

        timeScale = 1;
		durationSlider.value = 1;

        ~carrFreqEnvLevels.setn(~carrFreqEnv.levels);
        ~carrFreqEnvTimes.setn(~carrFreqEnv.times);

        ~modFreqEnvLevels.setn(~modFreqEnv.levels);
        ~modFreqEnvTimes.setn(~modFreqEnv.times);

        ~modIndexEnvLevels.setn(~modIndexEnv.levels);
        ~modIndexEnvTimes.setn(~modIndexEnv.times);

        ~ampEnvLevels.setn(~ampEnv.levels);
        ~ampEnvTimes.setn(~ampEnv.times);
        ~ampEnvDuration.set(timeScale);
	};

	presetArray[1] = {

		~carrFreqEnv = Env.new([ 895.5, 895.5, 895.5, 895.5, 895.5, 895.5, 895.5, 895.5 ],[ 0.14, 0.15, 0.14, 0.14, 0.14, 0.15, 0.14 ]);
		~modFreqEnv = Env.new([ 876.5, 876.5, 876.5, 876.5, 876.5, 876.5, 876.5, 876.5 ],[ 0.14, 0.15, 0.14, 0.14, 0.14, 0.15, 0.14 ]);
		~modIndexEnv = Env.new([ 0, 5.2, 5.7, 5.9, 5.2, 4.1, 2.3, 0 ],[ 0.12, 0.2, 0.16, 0.17, 0.08, 0.09, 0.18 ]);
		~ampEnv = Env.new([ 0, 0.51, 0.55, 0.5, 0.53, 0.27, 0.08, 0 ],[ 0.03, 0.14, 0.19, 0.12, 0.17, 0.19, 0.16 ]);
		evCarrFreq.setEnv(adjustEnv.value(~carrFreqEnv));
		evModFreq.setEnv(adjustEnv.value(~modFreqEnv));
		evModIndex.setEnv(adjustEnv.value(~modIndexEnv, 0, 10));
		evAmp.setEnv(~ampEnv);
		timeScale = 1;
		durationSlider.value = 1;

        ~carrFreqEnvLevels.setn(~carrFreqEnv.levels);
        ~carrFreqEnvTimes.setn(~carrFreqEnv.times);

        ~modFreqEnvLevels.setn(~modFreqEnv.levels);
        ~modFreqEnvTimes.setn(~modFreqEnv.times);

        ~modIndexEnvLevels.setn(~modIndexEnv.levels);
        ~modIndexEnvTimes.setn(~modIndexEnv.times);

        ~ampEnvLevels.setn(~ampEnv.levels);
        ~ampEnvTimes.setn(~ampEnv.times);
        ~ampEnvDuration.set(timeScale);
	};

	presetArray[2] = {

		~carrFreqEnv = Env.new([ 962, 962, 962, 962, 962, 962, 962, 962 ],[ 0.644, 0.69, 0.644, 0.644, 0.644, 0.69, 0.644 ]);
		~modFreqEnv = Env.new([ 857.5, 857.5, 857.5, 857.5, 857.5, 857.5, 857.5, 857.5 ],[ 0.644, 0.69, 0.644, 0.644, 0.644, 0.69, 0.644 ]);
		~modIndexEnv = Env.new([ 0, 1.6, 4.3, 7.3, 3.5, 4.1, 2.3, 0 ],[ 0.79795918367347, 0.46938775510204, 0.84489795918367, 0.61020408163265, 0.65714285714286, 0.37551020408163, 0.84489795918367 ]);
		~ampEnv = Env.new([ 0, 0.31, 0.4, 0.3, 0.32, 0.27, 0.14, 0 ],[ 0.23, 0.506, 0.414, 0.92, 0.92, 1.058, 0.552 ]);
		evCarrFreq.setEnv(adjustEnv.value(~carrFreqEnv));
		evModFreq.setEnv(adjustEnv.value(~modFreqEnv));
		evModIndex.setEnv(adjustEnv.value(~modIndexEnv, 0, 10));
		evAmp.setEnv(~ampEnv);
		timeScale = 4.6;
		durationSlider.value = 4.6;

        ~carrFreqEnvLevels.setn(~carrFreqEnv.levels);
        ~carrFreqEnvTimes.setn(~carrFreqEnv.times);

        ~modFreqEnvLevels.setn(~modFreqEnv.levels);
        ~modFreqEnvTimes.setn(~modFreqEnv.times);

        ~modIndexEnvLevels.setn(~modIndexEnv.levels);
        ~modIndexEnvTimes.setn(~modIndexEnv.times);

        ~ampEnvLevels.setn(~ampEnv.levels);
        ~ampEnvTimes.setn(~ampEnv.times);
        ~ampEnvDuration.set(timeScale);
	};

	presetArray[3] = {

		~carrFreqEnv = Env.new([ 173.5, 154.5, 173.5, 202, 173.5, 173.5, 154.5, 126 ],[ 0.196, 0.21, 0.21, 0.182, 0.196, 0.21, 0.196 ]);
		~modFreqEnv = Env.new([ 420.5, 563, 620, 658, 857.5, 857.5, 819.5, 743.5 ],[ 0.14, 0.308, 0.196, 0.154, 0.196, 0.21, 0.196 ]);
		~modIndexEnv = Env.new([ 0, 3.5, 4.9, 4.2, 3.5, 4.8, 2.3, 0 ],[ 0.21428571428571, 0.22857142857143, 0.15714285714286, 0.22857142857143, 0.22857142857143, 0.085714285714286, 0.25714285714286 ]);
		~ampEnv = Env.new([ 0, 0.31, 1, 0.61, 0.91, 0.36, 0.14, 0 ],[ 0.07, 0.126, 0.098, 0.126, 0.042, 0.77, 0.168 ]);
		evCarrFreq.setEnv(adjustEnv.value(~carrFreqEnv));
		evModFreq.setEnv(adjustEnv.value(~modFreqEnv));
		evModIndex.setEnv(adjustEnv.value(~modIndexEnv, 0, 10));
		evAmp.setEnv(~ampEnv);
		timeScale = 1.4;
		durationSlider.value = 1.4;

        ~carrFreqEnvLevels.setn(~carrFreqEnv.levels);
        ~carrFreqEnvTimes.setn(~carrFreqEnv.times);

        ~modFreqEnvLevels.setn(~modFreqEnv.levels);
        ~modFreqEnvTimes.setn(~modFreqEnv.times);

        ~modIndexEnvLevels.setn(~modIndexEnv.levels);
        ~modIndexEnvTimes.setn(~modIndexEnv.times);

        ~ampEnvLevels.setn(~ampEnv.levels);
        ~ampEnvTimes.setn(~ampEnv.times);
        ~ampEnvDuration.set(timeScale);
	};

	presetArray[4] = {

		~carrFreqEnv = Env.new([ 69, 69, 69, 69, 69, 69, 69, 69 ],[ 0.154, 0.165, 0.154, 0.154, 0.154, 0.165, 0.154 ]);
		~modFreqEnv = Env.new([ 905, 905, 905, 905, 905, 905, 905, 905 ],[ 0.154, 0.165, 0.154, 0.154, 0.154, 0.165, 0.154 ]);
		~modIndexEnv = Env.new([ 0, 7.1, 4.9, 6.2, 6.6, 6.6, 4.7, 0 ],[ 0.165, 0.176, 0.154, 0.143, 0.176, 0.088, 0.198 ]);
		~ampEnv = Env.new([ 0, 0.31, 0.75, 0.61, 0.91, 0.36, 0.14, 0 ],[ 0.055, 0.066, 0.11, 0.099, 0.033, 0.605, 0.132 ]);
		evCarrFreq.setEnv(adjustEnv.value(~carrFreqEnv));
		evModFreq.setEnv(adjustEnv.value(~modFreqEnv));
		evModIndex.setEnv(adjustEnv.value(~modIndexEnv, 0, 10));
		evAmp.setEnv(~ampEnv);
		timeScale = 1.1;
		durationSlider.value = 1.1;

        ~carrFreqEnvLevels.setn(~carrFreqEnv.levels);
        ~carrFreqEnvTimes.setn(~carrFreqEnv.times);

        ~modFreqEnvLevels.setn(~modFreqEnv.levels);
        ~modFreqEnvTimes.setn(~modFreqEnv.times);

        ~modIndexEnvLevels.setn(~modIndexEnv.levels);
        ~modIndexEnvTimes.setn(~modIndexEnv.times);

        ~ampEnvLevels.setn(~ampEnv.levels);
        ~ampEnvTimes.setn(~ampEnv.times);
        ~ampEnvDuration.set(timeScale);
	};

	presetArray[5] = {

		~carrFreqEnv = Env.new([ 50, 50, 50, 50, 50, 50, 50, 50 ],[ 1.022, 1.095, 1.022, 1.022, 1.022, 1.095, 1.022 ]);
		~modFreqEnv = Env.new([ 50, 50, 50, 50, 50, 50, 50, 50 ],[ 1.022, 1.095, 1.022, 1.022, 1.022, 1.095, 1.022 ]);
		~modIndexEnv = Env.new([ 0, 7.1, 10, 8.1, 7.1, 5.7, 3.9, 2.5 ],[ 1.095, 2.044, 0.949, 0.73, 0.657, 0.876, 0.949 ]);
		~ampEnv = Env.new([ 0, 0.31, 0.75, 0.81, 0.91, 0.53, 0.14, 0 ],[ 0.365, 0.438, 0.876, 0.511, 2.482, 1.752, 0.876 ]);
		evCarrFreq.setEnv(adjustEnv.value(~carrFreqEnv));
		evModFreq.setEnv(adjustEnv.value(~modFreqEnv));
		evModIndex.setEnv(adjustEnv.value(~modIndexEnv, 0, 10));
		evAmp.setEnv(~ampEnv);
		timeScale = 7.3;
		durationSlider.value = 7.3;

        ~carrFreqEnvLevels.setn(~carrFreqEnv.levels);
        ~carrFreqEnvTimes.setn(~carrFreqEnv.times);

        ~modFreqEnvLevels.setn(~modFreqEnv.levels);
        ~modFreqEnvTimes.setn(~modFreqEnv.times);

        ~modIndexEnvLevels.setn(~modIndexEnv.levels);
        ~modIndexEnvTimes.setn(~modIndexEnv.times);

        ~ampEnvLevels.setn(~ampEnv.levels);
        ~ampEnvTimes.setn(~ampEnv.times);
        ~ampEnvDuration.set(timeScale);
	};

	presetArray[6] = {

		~carrFreqEnv = Env.new([ 506, 506, 506, 506, 506, 506, 515.5, 373 ],[ 0.196, 0.21, 0.196, 0.196, 0.196, 0.14, 0.266 ]);
		~modFreqEnv = Env.new([ 221, 221, 221, 221, 221, 221, 221, 221 ],[ 0.196, 0.21, 0.196, 0.196, 0.196, 0.21, 0.196 ]);
		~modIndexEnv = Env.new([ 0, 4.7, 2.8, 4.1, 6.2, 5.7, 3.9, 2.5 ],[ 0.224, 0.28, 0.224, 0.168, 0.154, 0.168, 0.182 ]);
		~ampEnv = Env.new([ 0, 0.31, 0.75, 0.81, 0.91, 0.53, 0.14, 0 ],[ 0.07, 0.084, 0.168, 0.098, 0.476, 0.336, 0.168 ]);
		evCarrFreq.setEnv(adjustEnv.value(~carrFreqEnv));
		evModFreq.setEnv(adjustEnv.value(~modFreqEnv));
		evModIndex.setEnv(adjustEnv.value(~modIndexEnv, 0, 10));
		evAmp.setEnv(~ampEnv);
		timeScale = 1.4;
		durationSlider.value = 1.4;

        ~carrFreqEnvLevels.setn(~carrFreqEnv.levels);
        ~carrFreqEnvTimes.setn(~carrFreqEnv.times);

        ~modFreqEnvLevels.setn(~modFreqEnv.levels);
        ~modFreqEnvTimes.setn(~modFreqEnv.times);

        ~modIndexEnvLevels.setn(~modIndexEnv.levels);
        ~modIndexEnvTimes.setn(~modIndexEnv.times);

        ~ampEnvLevels.setn(~ampEnv.levels);
        ~ampEnvTimes.setn(~ampEnv.times);
        ~ampEnvDuration.set(timeScale);
	};

	presetArray[7] = {

		~carrFreqEnv = Env.new([ 838.5, 838.5, 838.5, 838.5, 838.5, 838.5, 838.5, 857.5 ],[ 1.230303030303, 1.3181818181818, 1.230303030303, 1.230303030303, 1.230303030303, 1.3181818181818, 1.1424242424242 ]);
		~modFreqEnv = Env.new([ 230.5, 230.5, 230.5, 230.5, 211.5, 202, 183, 211.5 ],[ 1.218, 1.305, 1.218, 1.131, 1.131, 1.479, 1.218 ]);
		~modIndexEnv = Env.new([ 8.5, 7.8, 5, 4.1, 7, 2.8, 9, 2.7 ],[ 1.914, 1.479, 1.131, 0.783, 1.392, 0.957, 1.044 ]);
		~ampEnv = Env.new([ 0, 1, 0.55, 0.29, 0.24, 0.19, 0.09, 0 ],[ 0, 1.044, 1.131, 1.74, 1.653, 1.044, 2.088 ]);
		evCarrFreq.setEnv(adjustEnv.value(~carrFreqEnv));
		evModFreq.setEnv(adjustEnv.value(~modFreqEnv));
		evModIndex.setEnv(adjustEnv.value(~modIndexEnv, 0, 10));
		evAmp.setEnv(~ampEnv);
		timeScale = 8.7;
		durationSlider.value = 8.7;

        ~carrFreqEnvLevels.setn(~carrFreqEnv.levels);
        ~carrFreqEnvTimes.setn(~carrFreqEnv.times);

        ~modFreqEnvLevels.setn(~modFreqEnv.levels);
        ~modFreqEnvTimes.setn(~modFreqEnv.times);

        ~modIndexEnvLevels.setn(~modIndexEnv.levels);
        ~modIndexEnvTimes.setn(~modIndexEnv.times);

        ~ampEnvLevels.setn(~ampEnv.levels);
        ~ampEnvTimes.setn(~ampEnv.times);
        ~ampEnvDuration.set(timeScale);
	};

	presetArray[8] = {

		~carrFreqEnv = Env.new([ 268.5, 268.5, 268.5, 268.5, 268.5, 268.5, 268.5, 268.5 ],[ 0.336, 0.36, 0.336, 0.336, 0.336, 0.36, 0.336 ]);
		~modFreqEnv = Env.new([ 876.5, 838.5, 895.5, 876.5, 876.5, 876.5, 876.5, 876.5 ],[ 0.264, 0.24, 0.528, 0.336, 0.336, 0.36, 0.336 ]);
		~modIndexEnv = Env.new([ 1.1, 2.2, 1.4, 2.8, 1.6, 1.1, 1.9, 0.4 ],[ 0.12, 0.096, 0.072, 0.096, 1.68, 0.144, 0.192 ]);
		~ampEnv = Env.new([ 1, 0.36, 0.55, 0.34, 0.5, 0.3, 0.14, 0 ],[ 0.072, 0.12, 0.024, 0.144, 1.08, 0.672, 0.288 ]);
		evCarrFreq.setEnv(adjustEnv.value(~carrFreqEnv));
		evModFreq.setEnv(adjustEnv.value(~modFreqEnv));
		evModIndex.setEnv(adjustEnv.value(~modIndexEnv, 0, 10));
		evAmp.setEnv(~ampEnv);
		timeScale = 2.4;
		durationSlider.value = 2.4;

        ~carrFreqEnvLevels.setn(~carrFreqEnv.levels);
        ~carrFreqEnvTimes.setn(~carrFreqEnv.times);

        ~modFreqEnvLevels.setn(~modFreqEnv.levels);
        ~modFreqEnvTimes.setn(~modFreqEnv.times);

        ~modIndexEnvLevels.setn(~modIndexEnv.levels);
        ~modIndexEnvTimes.setn(~modIndexEnv.times);

        ~ampEnvLevels.setn(~ampEnv.levels);
        ~ampEnvTimes.setn(~ampEnv.times);
        ~ampEnvDuration.set(timeScale);
    };

	presetArray[9] = {
		~carrFreqEnv = Env.new([ 1000, 50, 50, 50, 50, 50, 50, 553.5 ],[ 0.182, 0.195, 0.182, 0.182, 0.182, 0.195, 0.182 ]);
		~modFreqEnv = Env.new([ 1000, 287.5, 50, 50, 50, 50, 50, 50 ],[ 0.065, 0.312, 0.182, 0.182, 0.182, 0.195, 0.182 ]);
		~modIndexEnv = Env.new([ 0, 6.8, 10, 9.4, 6.5, 4.1, 2.3, 0 ],[ 0.156, 0.195, 0.234, 0.182, 0.182, 0.117, 0.234 ]);
		~ampEnv = Env.new([ 0, 1, 1, 0.92, 0.53, 0.27, 0.08, 0.08 ],[ 0, 0.143, 0.273, 0.208, 0.221, 0.247, 0.208 ]);
		evCarrFreq.setEnv(adjustEnv.value(~carrFreqEnv));
		evModFreq.setEnv(adjustEnv.value(~modFreqEnv));
		evModIndex.setEnv(adjustEnv.value(~modIndexEnv, 0, 10));
		evAmp.setEnv(~ampEnv);
		timeScale = 1.3;
		durationSlider.value = 1.3;

        ~carrFreqEnvLevels.setn(~carrFreqEnv.levels);
        ~carrFreqEnvTimes.setn(~carrFreqEnv.times);

        ~modFreqEnvLevels.setn(~modFreqEnv.levels);
        ~modFreqEnvTimes.setn(~modFreqEnv.times);

        ~modIndexEnvLevels.setn(~modIndexEnv.levels);
        ~modIndexEnvTimes.setn(~modIndexEnv.times);

        ~ampEnvLevels.setn(~ampEnv.levels);
        ~ampEnvTimes.setn(~ampEnv.times);
        ~ampEnvDuration.set(timeScale);
	};

	presetArray[10] = {
		~carrFreqEnv = Env.new([ 240, 240, 240, 240, 240, 240, 240, 240 ],[ 0.35, 0.375, 0.35, 0.35, 0.35, 0.375, 0.35 ]);
		~modFreqEnv = Env.new([ 563, 563, 563, 563, 563, 563, 563, 563 ],[ 0.35, 0.375, 0.35, 0.35, 0.35, 0.375, 0.35 ]);
		~modIndexEnv = Env.new([ 9.7, 8.9, 8.6, 7.9, 7.3, 7.2, 7.1, 6.3 ],[ 0.050505050505051, 0.65656565656566, 0.47979797979798, 0.45454545454545, 0.4040404040404, 0.25252525252525, 0.2020202020202 ]);
		~ampEnv = Env.new([ 1, 0.73, 0.49, 0.29, 0.18, 0.1, 0.04, 0 ],[ 0.05, 0.125, 0.35, 0.55, 0.4, 0.425, 0.6 ]);
		evCarrFreq.setEnv(adjustEnv.value(~carrFreqEnv));
		evModFreq.setEnv(adjustEnv.value(~modFreqEnv));
		evModIndex.setEnv(adjustEnv.value(~modIndexEnv, 0, 10));
		evAmp.setEnv(~ampEnv);
		timeScale = 2.5;
		durationSlider.value = 2.5;

        ~carrFreqEnvLevels.setn(~carrFreqEnv.levels);
        ~carrFreqEnvTimes.setn(~carrFreqEnv.times);

        ~modFreqEnvLevels.setn(~modFreqEnv.levels);
        ~modFreqEnvTimes.setn(~modFreqEnv.times);

        ~modIndexEnvLevels.setn(~modIndexEnv.levels);
        ~modIndexEnvTimes.setn(~modIndexEnv.times);

        ~ampEnvLevels.setn(~ampEnv.levels);
        ~ampEnvTimes.setn(~ampEnv.times);
        ~ampEnvDuration.set(timeScale);
	};

	presetArray[11] = {
        ~carrFreqEnv = Env.new([ 1000, 183, 173.5, 173.5, 173.5, 192.5, 173.5, 173.5 ],[ 0.12, 0.17, 0.14, 0.14, 0.16, 0.13, 0.14 ]);
        ~modFreqEnv = Env.new([ 1000, 240, 867, 259, 325.5, 344.5, 325.5, 325.5 ],[ 0.06, 0.07, 0.05, 0.39, 0.18, 0.11, 0.14 ]);
        ~modIndexEnv = Env.new([ 10, 6.2, 4.8, 3.2, 3.2, 1.7, 3.2, 3.2 ],[ 0.05, 0.26, 0.12, 0.14, 0.14, 0.15, 0.14 ]);
        ~ampEnv = Env.new([ 1, 0.68, 0.29, 0.2, 0, 0, 0, 0.23 ],[ 0.22, 0.03, 0.09, 0.07, 0.11, 0.32, 0.15 ]);
        evCarrFreq.setEnv(adjustEnv.value(~carrFreqEnv));
        evModFreq.setEnv(adjustEnv.value(~modFreqEnv));
        evModIndex.setEnv(adjustEnv.value(~modIndexEnv, 0, 10));
        evAmp.setEnv(~ampEnv);
        timeScale = 1;
        durationSlider.value = 1;
        ~carrFreqEnvLevels.setn([ 1000, 183, 173.5, 173.5, 173.5, 192.5, 173.5, 173.5 ]);
        ~carrFreqEnvTimes.setn([ 0.12, 0.17, 0.14, 0.14, 0.16, 0.13, 0.14 ]);
        ~modFreqEnvLevels.setn([ 1000, 240, 867, 259, 325.5, 344.5, 325.5, 325.5 ]);
        ~modFreqEnvTimes.setn([ 0.06, 0.07, 0.05, 0.39, 0.18, 0.11, 0.14 ]);
        ~modIndexEnvLevels.setn([ 10, 6.2, 4.8, 3.2, 3.2, 1.7, 3.2, 3.2 ]);
        ~modIndexEnvTimes.setn([ 0.05, 0.26, 0.12, 0.14, 0.14, 0.15, 0.14 ]);
        ~ampEnvLevels.setn([ 1, 0.68, 0.29, 0.2, 0, 0, 0, 0.23 ]);
        ~ampEnvTimes.setn([ 0.22, 0.03, 0.09, 0.07, 0.11, 0.32, 0.15 ]);
        ~ampEnvDuration.set(1);
	};


	/////////////////////////////////////////////
	// Function: "Print Current Settings" ///////
	/////////////////////////////////////////////

	printEnvData = {

		("~carrFreqEnv = Env.new(" ++ ~carrFreqEnv.levels ++ "," ++ ~carrFreqEnv.times ++ ");").postln;

		("~modFreqEnv = Env.new(" ++ ~modFreqEnv.levels ++ "," ++ ~modFreqEnv.times ++ ");").postln;

		("~modIndexEnv = Env.new(" ++ ~modIndexEnv.levels ++ "," ++ ~modIndexEnv.times ++ ");").postln;

		("~ampEnv = Env.new(" ++ ~ampEnv.levels ++ "," ++ ~ampEnv.times ++ ");").postln;

		"evCarrFreq.setEnv(adjustEnv.value(~carrFreqEnv));".postln;
		"evModFreq.setEnv(adjustEnv.value(~modFreqEnv));".postln;
		"evModIndex.setEnv(adjustEnv.value(~modIndexEnv, 0, 10));".postln;
		"evAmp.setEnv(~ampEnv);".postln;
		("timeScale = " ++ timeScale ++ ";").postln;
		("durationSlider.value = " ++ timeScale ++ ";").postln;

        ("~carrFreqEnvLevels.setn(" ++ ~carrFreqEnv.levels ++ ");").postln;
        ("~carrFreqEnvTimes.setn(" ++ ~carrFreqEnv.times ++ ");").postln;

        ("~modFreqEnvLevels.setn(" ++ ~modFreqEnv.levels ++ ");").postln;
        ("~modFreqEnvTimes.setn(" ++ ~modFreqEnv.times ++ ");").postln;

        ("~modIndexEnvLevels.setn(" ++ ~modIndexEnv.levels  ++ ");").postln;
        ("~modIndexEnvTimes.setn(" ++ ~modIndexEnv.times  ++ ");").postln;

        ("~ampEnvLevels.setn(" ++ ~ampEnv.levels  ++ ");").postln;
        ("~ampEnvTimes.setn(" ++ ~ampEnv.times  ++ ");").postln;
        ("~ampEnvDuration.set(" ++ timeScale  ++ ");").postln;
	};
}); // end of block
