
[soundData, freq] = audioread('The Rabbit Illusion_soundbite.wav');
soundData(soundData<0) = -1;
soundData(soundData>0) = 1;
sound(soundData, freq)
audioDeviceID = [];
InitializePsychSound;
pahandle = PsychPortAudio('Open', audioDeviceID, [], 2, 44100, 1);
PsychPortAudio('Close', pahandle);
% loads data into buffer
%PsychPortAudio('FillBuffer', pahandle, soundData');
%[soundData, sampleRate] = MakeBeep(toneFreqs, toneDur, sampleRate);
