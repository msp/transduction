////////////////////////////////////////////////////////////////////////////////
//
// SUPERDIRT SAMPLER
//
// Sampler and synthesizer
// https://github.com/musikinformatik/SuperDirt
//
//
//
// We run the SETUP to define the audio system and load the SEQUENCES.
//
// The CONTROL section allows us to start/stop each sequence.
// Multiple sequences can be played together for layering.
//
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
// (1) SETUP - ensure the path to sample folder is correct
////////////////////////////////////////////////////////////////////////////////

(
// place cursor below this line and execute CMD + enter to execute the section

var enginePath;

// Pdef.removeAll;
// Pbindef.removeAll;

SuperDirt.default = ~dirt;

// The samples need to exist on your computer!
// ~dirt.loadSoundFiles("/Users/Sally/Dropbox/oily-cart-awu-samples/*");
~dirt.loadSoundFiles("/Dropbox-shared/oily-cart-awu-samples/*");


// Run to test to check we have sound. You should hear a cymbal
(type:\dirt, orbit: ~out1_2, s: \cr, n: 0, speed: 1.0, pan: 0.25, gain: 0.6).play;
(type:\dirt, orbit: ~out1_2, s: \cr, n: 0, speed: 0.3, pan: 0.75, gain: 0.6).play;


// configure the audio outputs
~out1_2 = 0;
~out3_4 = 1;
~out5_6 = 2;
~out7_8 = 3;


enginePath = PathName.new(thisProcess.nowExecutingPath.dirname+/+"engine/");
enginePath.entries;

enginePath.files.do{|aFile|
    "loading >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>".postln;
    aFile.fullPath.postln;
    load(aFile.fullPath);
};

)