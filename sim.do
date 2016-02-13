set PathSeparator .

set WLFFilename sim/waveform.wlf
log -r processor_tb.*


#log -r /* 
run -all
quit
