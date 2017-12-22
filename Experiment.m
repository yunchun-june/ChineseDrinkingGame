clear all;
close all;
clc;
addpath('./Functions');
Screen('Preference', 'SkipSyncTests', 1);

try
    %===== Parameters =====%

    totalTrials         = 3;
    practiceTrials      = 15;
    
    choiceTime          = 5;
    guessSumTime        = 5;
    showResultTime      = 10;
    fixationTime        = 1;
    scorePerWin         = 10;
    
    %===== Constants =====%
    TRUE                = 1;
    FALSE               = 0;
    
    %===== IP Config for developing ===%
    myID = 'test';
    oppID = 'test';
    myIP = 'localhost';
    oppIP = 'localhost';

    rule = input('Rule(player1/player2): ','s');
    assert( strcmp(rule,'player1')|strcmp(rule,'player2'));
    if rule == 'player1'
        myPort = 5656;
        oppPort = 7878;
    else
        myPort = 7878;
        oppPort = 5656;
    end
    
%     %===== IP Config for 505 ===%
%     myID = input('This seat: ','s');
%     oppID = input('Opp seat: ','s');
%     fprintf('cmd to open terminal. "IPConfig" to get IP (the one with 172.16.10.xxx)\n');
%     myIP = input('This IP: ','s');
%     myIP = strcat('172.16.10.',myIP);
%     oppIP = input('Opp IP: ','s');
%     oppIP = strcat('172.16.10.',oppIP);
%     myPort = 5454;
%     oppPort = 5454;
%     if myID(2) == 'a' | myID(2)=='A'
%         rule = 'player1';
%     else
%         rule = 'player2';
%     end
    
    %===== Inputs =====%

    fprintf('---Starting Experiment---\n');
    inputDeviceName     = 'Mac';
    if(strcmp(rule,'player1')) displayerOn = TRUE;
    else displayerOn = FALSE;end
    screenID            = 0;
    
    %===== Initialize Componets =====%
    keyboard    = keyboardHandler(inputDeviceName);
    displayer   = displayer(max(Screen('Screens')),displayerOn);
    parser      = parser();
    
    %===== Establish Connection =====% 
    cnt = connector(rule,myID, oppID,myIP,myPort,oppIP,oppPort);
    cnt.establish(myID,oppID);
    ListenChar(2);
    HideCursor();
    
    %===== Open Screen =====% 
    fprintf('Start after 10 seconds\n');
    %WaitSecs(10);
    displayer.openScreen();
    
    displayer.writeMessage('Press space to start','');
    fprintf('Press Space to start.\n');
    keyboard.waitSpacePress();
    displayer.blackScreen();
    fprintf('Game Start.\n');

    %===== Start of real experiment =====%
    
    %displayer.writeMessage('This is the real experiment','Press space to start');
    %keyboard.waitSpacePress();
    %displayer.blackScreen();
    
    %reinitialized components
    data        = dataHandler(myID,oppID,rule,totalTrials,scorePerWin);
    
    for trial = 1:totalTrials

        %=========== Setting Up Trials ==============%
        
        %Syncing
        if(trial == 1)
            displayer.writeMessage('Waiting for Opponent.','');
            fprintf('Waiting for Opponent.\n');
            cnt.syncTrial(trial);
            displayer.blackScreen();
        else
            cnt.syncTrial(trial);
        end
        
        %response to get
        myRes.choice = 0;
        myRes.guess  = 0;
        myRes.events = cell(0,2);
        
        %=========== Fixation ==============%
        displayer.fixation(fixationTime);
       
        %========== Make Choice ===============%
    
        if strcmp(rule,'player2')
            myRes.choice = randi(3);
            myRes.guess = myRes.choice + randi(3);
        end
        
        startTime = GetSecs();
        decisionMade = FALSE;
        if strcmp(rule,'player2') decisionMade = TRUE; end
        fprintf('Make your choice.\n');
        for elapse = 1:choiceTime
            remaining = choiceTime-elapse+1;
            endOfThisSecond = startTime+elapse;
            fprintf('remaining time: %d\n',remaining);

            displayer.decideScreen('choose',myRes.choice,myRes.guess,remaining,decisionMade);
            
            while(GetSecs()<endOfThisSecond)
                if ~decisionMade
                   [keyName,timing] = keyboard.getResponse(endOfThisSecond);
                   if(strcmp(keyName,'na'))
                       continue;
                   else
                       if(strcmp(keyName,'confirm') && myRes.choice ~= 0)
                            decisionMade = TRUE;
                            fprintf('decision confirmed : %d\n',myRes.choice);
                            displayer.decideScreen('choose',myRes.choice,myRes.guess,remaining,decisionMade);
                       end
                       
                       if strcmp(keyName,'quitkey')
                            displayer.closeScreen();
                            ListenChar();
                            fprintf('---- MANUALLY STOPPED ----\n');
                            return;
                       end
                       
                       try
                          keyName = str2num(keyName);
                          if keyName >= 1 && keyName <=3
                            myRes.choice = keyName;
                            fprintf('choose %d\n',str2num(keyName));
                            displayer.decideScreen('choose',myRes.choice,myRes.guess,remaining,decisionMade);
                          end 
                       catch
                       end
                       
                       myRes.events{end+1,1} = keyName;
                       myRes.events{end,2} = num2str(timing-startTime);
                       
                   end
                end
            end
        end
        if(~decisionMade) myRes.choice = 0; end
        
        %========== Guess Sum ===============%
        startTime = GetSecs();
        decisionMade = FALSE;
        if strcmp(rule,'player2') decisionMade = TRUE; end
        fprintf('Guess total Sum.\n');
        for elapse = 1:guessSumTime
            endOfThisSecond = startTime+elapse;
            remaining = guessSumTime-elapse+1;
            displayer.decideScreen('guessSum',myRes.choice,myRes.guess,remaining,decisionMade);
            
            fprintf('remaining time: %d\n',remaining);
            while(GetSecs()<endOfThisSecond)
                if ~decisionMade
                   [keyName,timing] = keyboard.getResponse(endOfThisSecond);
                   if(strcmp(keyName,'na'))
                       continue;
                   else

                       if(strcmp(keyName,'confirm') && myRes.guess ~= 0)
                            decisionMade = TRUE;
                            fprintf('decision confirmed : %d\n',myRes.guess);
                            displayer.decideScreen('guessSum',myRes.choice,myRes.guess,remaining,decisionMade);
                       end
                       
                       if strcmp(keyName,'quitkey')
                            displayer.closeScreen();
                            ListenChar();
                            fprintf('---- MANUALLY STOPPED ----\n');
                            return;
                       end
                       
                       try
                          keyName = str2num(keyName);
                          if keyName >= 2 && keyName <=6
                            myRes.guess = keyName;
                            fprintf('%d.\n',str2num(keyName));
                            displayer.decideScreen('guessSum',myRes.choice,myRes.guess,remaining,decisionMade);
                          end 
                       catch
                       end
                       
                       myRes.events{end+1,1} = keyName;
                       myRes.events{end,2} = num2str(timing-startTime);
                   end 
                   
                end
            end
        end
        displayer.decideScreen('guessSum',myRes.choice,myRes.guess,0,1);
        if(~decisionMade) myRes.guess = 0; end
  
        %========== Exchange and Save Data ===============%
        %Get opponent's response
        oppResRaw = cnt.sendOwnResAndgetOppRes(parser.resToStr(myRes));
        oppRes = parser.strToRes(oppResRaw);
        data.updateData(myRes,oppRes,trial);
        
        %========== Show result ===============%
        resultData = data.getResult(trial);
        data.logStatus(trial);
        
        displayer.showResult(resultData);
        WaitSecs(showResultTime);
        displayer.blackScreen();
    end

    displayer.closeScreen();
    ListenChar();
    data.saveToFile();
    fprintf('----END OF EXPERIMENT----\n');
    
catch exception
    fprintf(1,'Error: %s\n',getReport(exception));
    displayer.closeScreen();
    ListenChar();
    ShowCursor();
end
