classdef dataHandler <handle

%     columns         index
%     trials          1
%     p1choice        2
%     p1guess         3
%     p2choice        4
%     p2guess         5
%     realsum         6
%     p1IsRight       7
%     p2IsRight       8
%     winner          9
%     p1score         10
%     p2score         11
%     p1events        12
%     p2events        13
    
    
    properties
        player1ID
        player2ID
        rule
        totalTrial
        result
        gain
        
        %columns        index
        trials          =1
        p1choice        =2
        p1guess         =3
        p2choice        =4
        p2guess         =5
        realSum         =6
        p1IsRight       =7
        p2IsRight       =8
        winner          =9
        p1score         =10
        p2score         =11
        p1events        =12
        p2events        =13
    end
    
    methods
        
        %-----Constructor-----%
        function obj = dataHandler(ID1,ID2,rule,trials,gain)
            if strcmp(rule,'player1')
                obj.player1ID = ID1;
                obj.player2ID = ID2;
            else
                obj.player1ID = ID2;
                obj.player2ID = ID1;
            end
            
            obj.rule = rule;
            obj.totalTrial = trials;
            obj.result = cell(trials,13);
            obj.gain = gain;
        end
        
        %----- Updating Data -----%
        function makeSense = resMakeSense(obj, choice, guess)
            if(choice == 0 || guess == 0)
                makeSense = 0;
            else
                if(choice == 1 && guess <=4 && guess >=2)
                   makeSense = 1;
                elseif (choice == 2 && guess <=5 && guess >=3)
                   makeSense = 1;
                elseif (choice == 3 && guess <=6 && guess >=4)
                    makeSense = 1;
                else
                    makeSense = 0;
                end
            end
        end
        
        
        function updateData(obj,myRes,oppRes,trial)
          
            obj.result{trial,1} = trial;
            
            % p1 p2 choice guess
            if strcmp(obj.rule , 'player1')
                obj.result{trial,2} = myRes.choice;
                obj.result{trial,3} = myRes.guess;
                obj.result{trial,4} = oppRes.choice;
                obj.result{trial,5} = oppRes.guess;
                obj.result{trial,12} = myRes.events;
                obj.result{trial,13} = oppRes.events;
            end
            
            if strcmp(obj.rule , 'player2')
                obj.result{trial,2} = oppRes.choice;
                obj.result{trial,3} = oppRes.guess;
                obj.result{trial,4} = myRes.choice;
                obj.result{trial,5} = myRes.guess;
                obj.result{trial,12} = oppRes.events;
                obj.result{trial,13} = myRes.events;
            end
            
            %real sum
            obj.result{trial,6} = obj.result{trial,2} + obj.result{trial,4};
            
            
            WRONG   = 1;
            RIGHT   = 2;
            NONSENSE = 3;
            
            %p1 is right
            if(~obj.resMakeSense(obj.result{trial,obj.p1choice}, obj.result{trial,obj.p1guess}))
                obj.result{trial,obj.p1IsRight} = NONSENSE;
            elseif(obj.result{trial,obj.realSum} == obj.result{trial,obj.p1guess})
                obj.result{trial,obj.p1IsRight} = RIGHT;
            else
                obj.result{trial,obj.p1IsRight} = WRONG;
            end
            
            %p2 is right
            if(~obj.resMakeSense(obj.result{trial,obj.p2choice}, obj.result{trial,obj.p2guess}))
                obj.result{trial,obj.p2IsRight} = NONSENSE;
            elseif(obj.result{trial,obj.realSum} == obj.result{trial,obj.p2guess})
                obj.result{trial,obj.p2IsRight} = RIGHT;
            else
                obj.result{trial,obj.p2IsRight} = WRONG;
            end
            
            % set winner
            
                                %x  %o  %? player2
            GET_WINNER    = [   0   2   1; %x player1
                                1   0   1; %o
                                2   2   0];%?
            
            obj.result{trial,9} = GET_WINNER(obj.result{trial,7},obj.result{trial,8});
            
            % update score
            if(trial == 1)
                obj.result{trial,10} = 0;
                obj.result{trial,11} = 0;
            else
                obj.result{trial,10} = obj.result{trial-1,10};
                obj.result{trial,11} = obj.result{trial-1,11};
            end
            
            
            if( obj.result{trial,9} == 1) % p1 win
                obj.result{trial,10} = obj.result{trial,10} + obj.gain;
            end
            
            if( obj.result{trial,9} == 2) % p2 win
                obj.result{trial,11} = obj.result{trial,11} + obj.gain;
            end
            
        end
        
        function data = getResult(obj,trial)
            if strcmp(obj.rule , 'player1')
                data.yourChoice = obj.result{trial,2};
                data.yourGuess  = obj.result{trial,3};
                data.oppChoice  = obj.result{trial,4};
                data.oppGuess   = obj.result{trial,5};
                data.realSum    = obj.result{trial,6};
                data.winner     = obj.result{trial,9};
                data.yourScore  = obj.result{trial,10};
                data.oppScore   = obj.result{trial,11};
            end
            
            if strcmp(obj.rule , 'player2')
                data.yourChoice = obj.result{trial,4};
                data.yourGuess  = obj.result{trial,5};
                data.oppChoice  = obj.result{trial,1};
                data.oppGuess   = obj.result{trial,3};
                data.realSum    = obj.result{trial,6};
                data.winner     = obj.result{trial,9};
                data.yourScore  = obj.result{trial,11};
                data.oppScore   = obj.result{trial,10};
            end
        end
        
        function logStatus(obj,trial)
            fprintf('=================================================\n');
            fprintf('Trial          %d\n',trial);
            
            if strcmp(obj.rule , 'player1')
                fprintf('YourChoice  YourGuess\n');
                fprintf('%d          %d      \n',obj.result{trial,2},obj.result{trial,3});
                fprintf('OppChoice   oppGuess\n');
                fprintf('%d          %d      \n',obj.result{trial,4},obj.result{trial,5});
                if(obj.result{trial,9} == 0) fprintf('Result: draw\n'); end
                if(obj.result{trial,9} == 1) fprintf('Result: win\n'); end
                if(obj.result{trial,9} == 2) fprintf('Result: lose\n'); end
                fprintf('Result:')
                fprintf('Your Score: %d\n',obj.result{trial,10});
                fprintf('Opp Score: %d\n',obj.result{trial,11});
            end
            
            if strcmp(obj.rule , 'player2')
                fprintf('YourChoice  YourGuess\n');
                fprintf('%d          %d      \n',obj.result{trial,4},obj.result{trial,5});
                fprintf('OppChoice   oppGuess\n');
                fprintf('%d          %d      \n',obj.result{trial,2},obj.result{trial,3});
                if(obj.result{trial,9} == 0) fprintf('Result: draw\n'); end
                if(obj.result{trial,9} == 1) fprintf('Result: lose\n'); end
                if(obj.result{trial,9} == 2) fprintf('Result: win\n'); end
                fprintf('Your Score: %d\n',obj.result{trial,11});
                fprintf('Opp Score: %d\n',obj.result{trial,10});
            end
        end
        
        
        %----- Writing and Loading -----%
        function saveToFile(obj)
            result = obj;
            filename = strcat('./RawData/CDG',datestr(now,'YYmmDD'),'_',datestr(now,'hhMM'),'_',obj.player1ID,'.mat');
            save(filename,'result');
            fprintf('Data saved to file.\n');
        end
        
        function data = loadData(obj,filename)
            rawData = load(filename);
            data = rawData.result;
        end
        
    end
    
end

