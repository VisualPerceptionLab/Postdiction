% latency for second beep
% mydata{1}.startAudioTime(ver3,2) - mydata{1}.presentationTime(ver3,3)

results_path = "D:\Documents\MATLAB\Postdiction_git\Experiment\Results";
path = fullfile(results_path, "Aaron_behav/data_mainexp_2023_9_4_15_14_47.mat");
path2 = fullfile(results_path, "Aaron_behav/data_mainexp_2023_9_4_15_30_15.mat");
data_file = load(path);
data_file2 = load(path2);
results1 = data_file.data;
results2 = data_file2.data;
results = [results1 results2];

pitchres = results([1, 2]);
paramres = results([1,3,4,5]);

% pitch analysis
conf2000 = pitchres{1}.confAnswer;
conf4000 = pitchres{2}.confAnswer;

% is confidence higher for 4k AV?

% find conditions AV is correct
ill2000 = find(pitchres{1}.condition==2 & pitchres{1}.flashAnswer==3);
ill4000 = find(pitchres{2}.condition==2 & pitchres{2}.flashAnswer==3);
AVconf2000 = conf2000(ill2000);
AVconf4000 = conf4000(ill4000);
% find 

% is confidence in AV higher for paramres?

baseline = paramres{1}.confAnswer(find(paramres{1}.condition==2 & paramres{1}.flashAnswer==3));
baseline = baseline(baseline~=3)
size15dis1 = paramres{1}.confAnswer(find(paramres{2}.condition==2 & paramres{2}.flashAnswer==3));
size15dis15 = paramres{1}.confAnswer(find(paramres{3}.condition==2 & paramres{3}.flashAnswer==3));
size1dis15 = paramres{1}.confAnswer(find(paramres{4}.condition==2 & paramres{4}.flashAnswer==3));


%%%%%%%%% Invisible
% is confidence higher for 4k IV?

% find conditions AV is correct
ill2000 = find(pitchres{1}.condition==3 & pitchres{1}.flashAnswer==2);
ill4000 = find(pitchres{2}.condition==3 & pitchres{2}.flashAnswer==2);
AVconf2000 = conf2000(ill2000);
AVconf4000 = conf4000(ill4000);
% find 

% is confidence in AV higher for paramres?

baseline = paramres{1}.confAnswer(find(paramres{1}.condition==3 & paramres{1}.flashAnswer==2));
baseline = baseline(baseline~=3)
size15dis1 = paramres{1}.confAnswer(find(paramres{2}.condition==3 & paramres{2}.flashAnswer==2));
size15dis15 = paramres{1}.confAnswer(find(paramres{3}.condition==3 & paramres{3}.flashAnswer==2));
size1dis15 = paramres{1}.confAnswer(find(paramres{4}.condition==3 & paramres{4}.flashAnswer==2));

%%%%%%%%% Ver 2
% is confidence higher for 4k ver2?

% find conditions AV is correct
ill2000 = find(pitchres{1}.condition==4 & pitchres{1}.flashAnswer==3);
ill4000 = find(pitchres{2}.condition==4 & pitchres{2}.flashAnswer==3);
AVconf2000 = conf2000(ill2000);
AVconf4000 = conf4000(ill4000);
% find 

% is confidence in ver2 higher for paramres?

baseline = paramres{1}.confAnswer(find(paramres{1}.condition==4 & paramres{1}.flashAnswer==3));
baseline = baseline(baseline>9)
size15dis1 = paramres{1}.confAnswer(find(paramres{2}.condition==4 & paramres{2}.flashAnswer==3));
size15dis1 = size15dis1(size15dis1>9);
size15dis15 = paramres{1}.confAnswer(find(paramres{3}.condition==4 & paramres{3}.flashAnswer==3));
size15dis15 = size15dis15(size15dis15>9);
size1dis15 = paramres{1}.confAnswer(find(paramres{4}.condition==4 & paramres{4}.flashAnswer==3));
size1dis15 = size1dis15(size1dis15>9)