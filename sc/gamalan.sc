(
SynthDef("mspGamaKlank",
    {|out = 0, freqs = #[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], rings = #[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], atk = 5, sus = 8, rel = 5, pan = 0, amp = 0.5|
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

r = Routine{
    var sustain = 12, transition = 3, overlap = 4;
    var period = transition * 2 + sustain / overlap;
        0.5.wait;            // wait for the synthdef to be sent to the server
        inf.do{
                Synth("mspGamaKlank", [
                        \atk, transition,
                        \amp, 1.0.rand,
                        \sus, sustain,
                        \rel, transition,
                        \pan, 1.0.rand2,
                        \freqs, {50.0.rrand(4000)}.dup(12),
                        \rings, {0.1.rrand(2)}.dup(12)
                ]);
        "waiting for ".post;
        period.postln;
                period.wait;
        }
};
r.play;
)

// stop spawning new synths
r.stop;

(
Synth("mspGamaKlank", [
    \atk, 2,
    \sus, 2,
    \rel, 3,
    \pan, 0.9,
    // \pan, 1.0.rand2,
    \freqs, {50.0.rrand(4000)}.dup(12),
    \rings, {0.1.rrand(2)}.dup(12)
]);

)