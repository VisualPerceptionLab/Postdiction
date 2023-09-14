% latency for second beep
% mydata{1}.startAudioTime(ver3,2) - mydata{1}.presentationTime(ver3,3)

results_path = "D:\Documents\MATLAB\Postdiction_git\Experiment\Results";
path = fullfile(results_path, "Doug_behav\results_mainexp_2023_9_12_15_41_55");
data_file = load(path);
results = data_file.data;

pitchres = results([1,5]);
paramres = results([1,2,3,4]);

% pitch analysis
conf2000 = pitchres{1}.confAnswer;
conf4000 = pitchres{2}.confAnswer;

% is confidence higher for 4k AV?

% % find conditions AV is correct
% ill2000 = find(pitchres{1}.condition==2 & pitchres{1}.flashAnswer==3);
% ill4000 = find(pitchres{2}.condition==2 & pitchres{2}.flashAnswer==3);
% AVconf2000 = conf2000(ill2000);
% AVconf2000 = mean(AVconf2000(AVconf2000>9))
% AVconf4000 = conf4000(ill4000);
% AVconf4000 = mean(AVconf4000(AVconf4000>9))
% % find 
% % 
% % % is confidence in AV higher for paramres?
% 
% baseline = paramres{1}.confAnswer(find(paramres{1}.condition==2 & paramres{1}.flashAnswer==3));
% baseline = mean(baseline(baseline>9))
% size15dis1 = paramres{1}.confAnswer(find(paramres{4}.condition==2 & paramres{2}.flashAnswer==3));
% size15dis1 = mean(size15dis1(size15dis1>9))
% size15dis15 = paramres{1}.confAnswer(find(paramres{3}.condition==2 & paramres{3}.flashAnswer==3));
% size15dis15 = mean(size15dis15(size15dis15>9))
% size1dis15 = paramres{1}.confAnswer(find(paramres{2}.condition==2 & paramres{4}.flashAnswer==3));
% size1dis15 = mean(size1dis15(size1dis15>9))


%%%%%%%%% Invisible
%is confidence higher for 4k IV?

% find conditions AV is correct
% ill2000 = find(pitchres{1}.condition==3 & pitchres{1}.flashAnswer==2);
% ill4000 = find(pitchres{2}.condition==3 & pitchres{2}.flashAnswer==2);
% IVconf2000 = conf2000(ill2000);
% IVconf2000 = mean(IVconf2000(IVconf2000>9))
% IVconf4000 = conf4000(ill4000);
% IVconf4000 = mean(IVconf4000(IVconf4000>9))
% 
% baseline = paramres{1}.confAnswer(find(paramres{1}.condition==3 & paramres{1}.flashAnswer==2));
% baseline = mean(baseline(baseline>9))
% size15dis1 = paramres{1}.confAnswer(find(paramres{4}.condition==3 & paramres{2}.flashAnswer==2));
% size15dis1 = mean(size15dis1(size15dis1>9))
% size15dis15 = paramres{1}.confAnswer(find(paramres{3}.condition==3 & paramres{3}.flashAnswer==2));
% size15dis15 = mean(size15dis15(size15dis15>9))
% size1dis15 = paramres{1}.confAnswer(find(paramres{2}.condition==3 & paramres{4}.flashAnswer==2));
% size1dis15 = mean(size1dis15(size1dis15>9))
% 
% % %%%%%%%%% Ver 2
% % % is confidence higher for 4k ver2?
% 
% % find conditions AV is correct
ill2000 = find(pitchres{1}.condition==4 & pitchres{1}.flashAnswer==3);
ill4000 = find(pitchres{2}.condition==4 & pitchres{2}.flashAnswer==3);
ver2conf2000 = conf2000(ill2000);
ver2conf2000 = mean(ver2conf2000(ver2conf2000>9))
ver2conf4000 = conf4000(ill4000);
ver2conf4000 = mean(ver2conf4000(ver2conf4000>9))

% % is confidence in ver2 higher for paramres?
% 
baseline = paramres{1}.confAnswer(find(paramres{1}.condition==1 & paramres{1}.flashAnswer==2));
baseline = mean(baseline(baseline>9))
size15dis1 = paramres{1}.confAnswer(find(paramres{4}.condition==1 & paramres{2}.flashAnswer==2));
size15dis1 = mean(size15dis1(size15dis1>9))
size15dis15 = paramres{1}.confAnswer(find(paramres{3}.condition==1 & paramres{3}.flashAnswer==2));
size15dis15 = mean(size15dis15(size15dis15>9))
size1dis15 = paramres{1}.confAnswer(find(paramres{2}.condition==1 & paramres{4}.flashAnswer==2));
size1dis15 = mean(size1dis15(size1dis15>9))

% Ver3 confidence
ill2000 = find(pitchres{1}.condition==4 & pitchres{1}.flashAnswer==3);
ill4000 = find(pitchres{2}.condition==4 & pitchres{2}.flashAnswer==3);
ver3conf2000 = conf2000(ill2000);
ver3conf2000 = mean(ver3conf2000(ver3conf2000>9))
ver3conf4000 = conf4000(ill4000);
ver3conf4000 = mean(ver3conf4000(ver3conf4000>9))

% is confidence in ver3 higher for paramres?
baseline = paramres{1}.confAnswer(find(paramres{1}.condition==4 & paramres{1}.flashAnswer==3));
baseline = mean(baseline(baseline>9))
size15dis1 = paramres{1}.confAnswer(find(paramres{4}.condition==4 & paramres{2}.flashAnswer==3));
size15dis1 = mean(size15dis1(size15dis1>9))
size15dis15 = paramres{1}.confAnswer(find(paramres{3}.condition==4 & paramres{3}.flashAnswer==3));
size15dis15 = mean(size15dis15(size15dis15>9))
size1dis15 = paramres{1}.confAnswer(find(paramres{2}.condition==4 & paramres{4}.flashAnswer==3));
size1dis15 = mean(size1dis15(size1dis15>9))
