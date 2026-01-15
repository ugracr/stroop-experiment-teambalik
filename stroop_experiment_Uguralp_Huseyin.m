%% stroop_gef2_15min_clean.m

clear; clc; close all;

colors = {'Rot','Grün','Blau','Gelb'};
colorRGB = {[1 0 0],[0 1 0],[0 0 1],[1 1 0]};
colorKeys = {'a','s','d','f'};
nTrialsTotal = 240;
nBlocks = 2;
trialsPerBlock = nTrialsTotal / nBlocks;
ISI = 2.5;
practiceTrials = 12;
shortPauseEvery = 60;
shortPauseDur = 15;
blockBreakDur = 60;
rng('shuffle');

nPerCondition = nTrialsTotal / (length(colors)*2);
if mod(nPerCondition,1) ~= 0
    stimuli = cell(nTrialsTotal,1);
    stimColorIdx = zeros(nTrialsTotal,1);
    condition = cell(nTrialsTotal,1);
    i = 1;
    while i <= nTrialsTotal
        wordIdx = randi(4);
        if rand < 0.5
            colorIdx = wordIdx; cond = 'kongruent';
        else
            possible = setdiff(1:4, wordIdx);
            colorIdx = possible(randi(length(possible))); cond = 'inkongruent';
        end
        stimuli{i} = upper(colors{wordIdx});
        stimColorIdx(i) = colorIdx;
        condition{i} = cond;
        i = i + 1;
    end
else
    stimuli = {}; stimColorIdx = []; condition = {};
    for c = 1:4
        for k = 1:nPerCondition
            stimuli{end+1,1} = upper(colors{c});
            stimColorIdx(end+1,1) = c;
            condition{end+1,1} = 'kongruent';
            other = setdiff(1:4,c);
            stimuli{end+1,1} = upper(colors{c});
            stimColorIdx(end+1,1) = other(randi(3));
            condition{end+1,1} = 'inkongruent';
        end
    end
    stimuli = stimuli(1:nTrialsTotal);
    stimColorIdx = stimColorIdx(1:nTrialsTotal);
    condition = condition(1:nTrialsTotal);
end

perm = randperm(nTrialsTotal);
stimuli = stimuli(perm);
stimColorIdx = stimColorIdx(perm);
condition = condition(perm);

fig = figure('Name','Stroop (GEF2)','Color','black','MenuBar','none','ToolBar','none','NumberTitle','off','WindowState','maximized');
set(fig,'KeyPressFcn',[]);
ax = axes('Parent',fig,'Color','black','XColor','none','YColor','none');
axis(ax,'off');

instr = {'===== STROOP-TEST (GEF2) =====','','Benennen Sie die FARBE der Schrift (nicht das Wort).','','Tasten:','A = Rot    S = Grün    D = Blau    F = Gelb','','Drücken Sie eine beliebige Taste, um zu beginnen...'};
text(0.5,0.5,instr,'Color','white','HorizontalAlignment','center','FontSize',20);
drawnow;
waitforbuttonpress;

clf(ax);
text(0.5,0.5,'Übungsphase','Color','white','HorizontalAlignment','center','FontSize',28);
drawnow;
pause(1.0);

for t = 1:practiceTrials
    if ~isvalid(fig); return; end
    wordIdx = randi(4);
    colorIdx = randi(4);
    cla(ax);
    text(0.5,0.55,upper(colors{wordIdx}),'Color',colorRGB{colorIdx},'FontSize',64,'HorizontalAlignment','center','Parent',ax);
    text(0.5,0.15,'A=Rot  S=Grün  D=Blau  F=Gelb','Color',[0.8 0.8 0.8],'HorizontalAlignment','center','FontSize',14,'Parent',ax);
    drawnow;
    keyPressed = [];
    while isempty(keyPressed)
        if ~isvalid(fig); return; end
        k = waitforbuttonpress;
        if k
            keyPressed = lower(get(fig,'CurrentCharacter'));
        end
    end
    cla(ax);
    pause(0.5);
end

results = table('Size',[nTrialsTotal 6],'VariableTypes',{'double','string','string','string','double','double'},'VariableNames',{'Trial','Wort','Farbe','Bedingung','RT','Korrekt'});
trialIdx = 0;

for b = 1:nBlocks
    blockTrials = ((b-1)*trialsPerBlock + 1):(b*trialsPerBlock);
    for tRel = 1:length(blockTrials)
        t = blockTrials(tRel);
        trialIdx = trialIdx + 1;
        if ~isvalid(fig); break; end
        cla(ax);
        thisWord = stimuli{t};
        thisColorIdx = stimColorIdx(t);
        text(0.5,0.55,thisWord,'Color',colorRGB{thisColorIdx},'FontSize',72,'HorizontalAlignment','center','Parent',ax);
        text(0.5,0.15,'A=Rot  S=Grün  D=Blau  F=Gelb','Color',[0.8 0.8 0.8],'HorizontalAlignment','center','FontSize',14,'Parent',ax);
        drawnow;
        startRT = tic;
        keyPressed = [];
        while isempty(keyPressed)
            if ~isvalid(fig); break; end
            k = waitforbuttonpress;
            if k
                keyPressed = lower(get(fig,'CurrentCharacter'));
            end
        end
        RT = toc(startRT);
        correct = 0;
        for kk = 1:4
            if strcmp(keyPressed, colorKeys{kk})
                if kk == thisColorIdx
                    correct = 1;
                else
                    correct = 0;
                end
            end
        end
        results.Trial(trialIdx) = trialIdx;
        results.Wort(trialIdx) = thisWord;
        results.Farbe(trialIdx) = colors{thisColorIdx};
        results.Bedingung(trialIdx) = condition{t};
        results.RT(trialIdx) = RT;
        results.Korrekt(trialIdx) = correct;
        cla(ax);
        pause(ISI);

        if mod(trialIdx, shortPauseEvery) == 0 && trialIdx < nTrialsTotal
            cla(ax);
            text(0.5,0.5,sprintf('Kurze Pause (%d s)...', shortPauseDur),'Color','white','HorizontalAlignment','center','FontSize',20,'Parent',ax);
            drawnow;
            pause(shortPauseDur);
        end
    end

    if ~isvalid(fig); break; end

    if b < nBlocks
        cla(ax);
        text(0.5,0.5,sprintf('Block %d von %d abgeschlossen.\nKurze Erholung: %d s\nDrücken Sie danach eine Taste, um weiterzufahren.',b,nBlocks,blockBreakDur),'Color','white','HorizontalAlignment','center','FontSize',18,'Parent',ax);
        drawnow;
        pause(blockBreakDur);
        text(0.5,0.3,'Drücken Sie eine beliebige Taste, um weiterzumachen.','Color','white','HorizontalAlignment','center','FontSize',14,'Parent',ax);
        drawnow;
        waitforbuttonpress;
    end
end

if isvalid(fig)
    close(fig);
end

validRows = results.Trial ~= 0;
results = results(validRows,:);
ts = datestr(now,'yyyy-mm-dd_HH-MM-SS');
fname = sprintf('stroop_results_%s.csv', ts);
writetable(results, fname);
fprintf('Daten gespeichert: %s\n', fname);

congruentIdx = strcmp(results.Bedingung,'kongruent') & results.Korrekt==1;
incongruentIdx = strcmp(results.Bedingung,'inkongruent') & results.Korrekt==1;
meanRT_cong = mean(results.RT(congruentIdx));
meanRT_incong = mean(results.RT(incongruentIdx));
acc_cong = mean(results.Korrekt(strcmp(results.Bedingung,'kongruent'))) * 100;
acc_incong = mean(results.Korrekt(strcmp(results.Bedingung,'inkongruent'))) * 100;

fprintf('\n--- Auswertung ---\n');
fprintf('Mittlere RT (kongruent, korrekt):   %.3f s\n', meanRT_cong);
fprintf('Mittlere RT (inkongruent, korrekt): %.3f s\n', meanRT_incong);
fprintf('Genauigkeit (kongruent): %.1f %%\n', acc_cong);
fprintf('Genauigkeit (inkongruent): %.1f %%\n', acc_incong);

