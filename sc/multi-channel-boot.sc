(
s.quit;
s.options.numOutputBusChannels = 5;
s.options.numBuffers = 1024 * 16;
s.options.memSize = 8192 * 16;


~dirt.free;

s.waitForBoot {
	~dirt = SuperDirt(5, s);
	~dirt.loadSoundFiles;

    // don't run sync if running one line at a time!
    s.sync; // wait until all soundfiles are really loaded

    // the array is the range for each orbit. In this case each one runs across all 5 physical outs e.g. 0..4
    ~dirt.start(57120, [0,0,0,0,0,0]);

}
)
