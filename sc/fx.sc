(
var numChannels =  ~dirt.numChannels;

/*******************************************************************************
        WAVELOSS
*******************************************************************************/

~dirt.addModule('waveloss', { |dirtEvent|
	dirtEvent.sendSynth('waveloss' ++ ~dirt.numChannels,
		[
			drop: ~waveloss,
			out: ~out
		]
	)
}, { true });

SynthDef("waveloss" ++ numChannels, { |out, drop = 1|
	var sig;

	sig = In.ar(out, numChannels);
  sig = WaveLoss.ar(sig, drop, outof: 100, mode: 2);
	ReplaceOut.ar(out, sig)
}).add;

/*******************************************************************************
        SQUIZ
*******************************************************************************/

~dirt.addModule('squiz', { |dirtEvent|
	dirtEvent.sendSynth('squiz' ++ ~dirt.numChannels,
		[
			pitchratio: ~squiz,
			out: ~out
		]
	)
}, { true });

SynthDef("squiz" ++ numChannels, { |out, pitchratio = 1|
	var sig;
	sig = In.ar(out, numChannels);
  sig = Squiz.ar(sig, pitchratio);
	ReplaceOut.ar(out, sig)
}).add;
)

/*******************************************************************************
        WIP
*******************************************************************************/

// Programmatically control an EnvelopeView

(
// define a new env
~modFreqEnv = Env.new([ 1000, 100.5, 192.5, 192.5, 192.5, 192.5, 192.5, 192.5 ],[ 0.14, 0.15, 0.14, 0.14, 0.14, 0.15, 0.14 ]);

// set up UI
~evModFreq.setEnv(~adjustEnv.value(~modFreqEnv));

// Force the envelopes callback to update the buffers
~evModFreq.doAction;

~evModFreq.grid = Point(0.1, 0.2);
~evModFreq.gridOn_(true);
)


// WIP - can we control it from Tidal?
(
~dirt.addModule('post',	{ |dirtEvent|

    "\n------------\n".post;

    // dirtEvent.event.pairsDo { |key, val, i|
    //     "%: % ".format(key, val).post;
    //     if(i % 4 == 0) { "\n".post };
    // }

    // define a new env
    ~modFreqEnv = Env.new([ 300, 100.5, 192.5, 192.5, 192.5, 192.5, 192.5, 192.5 ],[ 0.14, 0.15, 0.14, 0.14, 0.14, 0.15, 0.14 ]);

    // Hmm, global seems not in scope.
    ~evModFreq.postln;

    // what about looking up a buffer in a registry?
    Buffer

    // set up UI
    // ~evModFreq.setEnv(~adjustEnv.value(~modFreqEnv));
    //
    // // Force the envelopes callback to update the buffers
    // ~evModFreq.doAction;
    //
    // ~evModFreq.grid = Point(0.1, 0.2);
    // ~evModFreq.gridOn_(true);
});
)

// remove it again:
~dirt.removeModule(\post);


