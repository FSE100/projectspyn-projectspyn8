clear all;

brick = ConnectBrick('HYLIFT');
brick.beep();
q
touchPort = 4;
colorPort = 2;
distPort  = 3; 

brick.SetColorMode(colorPort,2);

%% Initial Values
touch = 0;
default = 1; %Default State 1/Forward, 0/Stop
exitProgram = 0; % 1 = program quits
global lTurnTime;
global rTurnTime;
lTurnTime = .54;
rTurnTime = .52;
colorNames = ["Black", "Blue", "Green", "Yellow", "Red", "White", "Brown", "N/A"];


%% Tolerance Values
leftTurnDistance = 60; %% sensitivity for left-turn detection
safetyTime = 2.5;      %% time to clear a block after turning

while ~exitProgram
    
    %% GET SENSOR VALUES
    currentDist = brick.UltrasonicDist(distPort);
    touch = brick.TouchPressed(touchPort);
    batt = brick.GetBattLevel();
    colorCode = brick.ColorCode(colorPort);
    % Correct color code if unidentified
    if colorCode==0 
        colorCode=8; 
    end 
    color = colorNames(colorCode);
        
    %% DISPLAY SENSOR VALUES
    fprintf('currentDist: %d  Touch: %d  RGB: %s  Batt: %d\n',currentDist, touch, color, batt);
    
    %% COLOR REACTION
    if strcmp(color,"Blue") || strcmp(color,"Green")
        disp('Blue/Green Detected\n');
        engageRemote(brick);
    elseif strcmp(color,"Red")
        disp('Stop Light Detected\n');
        stop(brick);
        pause(4);
        forward(brick);
        pause(1);
    end
    
    
    %% KEEP LEFT
    if(currentDist>leftTurnDistance)
        fprintf('Left Turn Detected\n');
        stop(brick);
        pause(.5);
        
        forward(brick);
        pause(1);
        
        stop(brick);
        pause(.5);
        fprintf('Turning Left\n');
        leftTime(brick, lTurnTime);
        stop(brick);
        
        fprintf('Clearing block...\n');
        clearBlock(brick, safetyTime, colorPort, colorNames);
        
    end
    
    %% WALL - RIGHT
    if touch
        stop(brick);
        fprintf('Wall Detected... Turning Right\n');
        
        backward(brick);
 
        pause(1);
        stop(brick);
            pause(1);
        rightTime(brick, rTurnTime);
    end
        
    
    %% DEFAULT STATE
    if default
        forward(brick);
    else
        stop(brick);
    end
end

stop(brick);
pause(safetyTime);
CloseKeyboard();
DisconnectBrick(brick);

%% END OF PROGRAM

%% CLEARS BLOCK AFTER TURN
function clearBlock(brick, safetyTime, colorPort, colorNames)
    tic;
    count_max = 1e9;
    while(toc < safetyTime && toc < count_max)
        forward(brick);
        colorCode = brick.ColorCode(colorPort);
        % Correct color code if unidentified
        if colorCode==0 
            colorCode=8; 
        end 
        color = colorNames(colorCode);
        if strcmp(color,"Red")
            disp('Stop Light Detected\n');
            stop(brick);
            pause(4);
            forward(brick);
            pause(1);
        end
    end
end


%% TURNS LEFT FOR GIVEN TIME
function leftTime(brick, time)
    fprintf('Left Turn: %d seconds \n',time);
    brick.MoveMotor('A',60);
    brick.MoveMotor('B',-60);
    pause(time);
    fprintf('Done Turn\n');
end

function rightTime(brick, time)
    fprintf('Right Turn: %d seconds\n',time);
    brick.MoveMotor('A',-60);
    brick.MoveMotor('B',60);
    pause(time);
    fprintf('Done Turn\n');
end



%% REMOTE CONTROL
function engageRemote(brick)
    global key;
    InitKeyboard();
    
    while true
        pause(0.01);
        switch key
            case 'uparrow'
                disp('forward');
                forward(brick);
            case 'downarrow'
                disp('backward');
                backward(brick);
            case 'leftarrow'
                disp('left');
                left(brick);
            case 'rightarrow'
                disp('right');
                right(brick);
            case 'u' %up 
                disp('passenger');
                passenger(brick,-1);
            case 'd' %down
                disp('passenger');
                passenger(brick,1);
            case 'q'
                disp('Exit')
                break;
        end
        % Default State
        stop(brick);
    end
    CloseKeyboard();
    disp('Returning to automated program...');
end
%% ACTIVATES PASSENGER MECHANISM
function passenger(brick, state)
    brick.MoveMotor('C',state*20);
end

%% LEFT
function left(brick)
    brick.MoveMotor('A',50);
    brick.MoveMotor('B',-50);
end

%% RIGHT
function right(brick)
    brick.MoveMotor('A',-50);
    brick.MoveMotor('B',50);
end

%% MOVES FORWARD
function forward(brick)
    brick.MoveMotor('AB',-50);
end

%% MOVES BACKWARD
function backward(brick)
    brick.MoveMotor('AB',50);
end

%% STOPS ALL MOTORS
function stop(brick)
    brick.MoveMotor('ABC',0);
end