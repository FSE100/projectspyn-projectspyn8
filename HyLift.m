DisconnectBrick(brick);

brick = ConnectBrick('BOTTY');
brick.beep();

touchPort = 1;
colorPort = 2;
distPort  = 3; 
gyroPort  = 4;

brick.GyroCalibrate(gyroPort);
brick.ResetMotorAngle('C');

brick.SetColorMode(colorPort,4);

%% Initial Values
oldColors = brick.ColorRGB(colorPort);
oldDist = brick.UltrasonicDist(distPort);
goalAchieved = 0;

%% Tolerance Values
distChange = 50;
colorChange = 50; 
safetyTime = 5;


while ~goalAchieved
    %% GET SENSOR VALUES
    currentDist = brick.UltrasonicDist(distPort);
    %%touch = brick.TouchPressed(touchPort);
    colors = brick.ColorRGB(colorPort);
    touch = 0;
    
    distDiff = currentDist-oldDist;

    %% DISPLAY SENSOR VALUES
    %%fprintf('US: %d  Touch: %d   R: %d  G: %d  B: %d \n',currentDist, touch, colors(1), colors(2), colors(3));
    fprintf('old: %i current: %i change: %i threshold: %d \n',oldDist,currentDist,distDiff,distChange);
    
    %% WALL COLLISION
    %% Compares distance values for left and right paths
    %% Moves towards longest path
    if touch
        stop(brick);
        leftDist = brick.UltrasonicDist(distPort)   %% Get left path distance
        left(brick,180);                            %% Turn 180 degrees
        stop(brick);
        rightDist = brick.UltrasonicDist(distPort); %% Get right path distance
        
        %% Orient towards longest path
        if (rightDist > leftDist)
            left(brick,90);
        else
            right(brick,90);
        end
        
        %% Continue forwards and exit block
        forward(brick);
        pause(safetyTime);
        
    end
    
    %% COLOR RECOGNITION AND RESPONSE
    %% Calls colorReact method to handle RGB detection
    %{
    for i=1:colors.length
        if abs(colors(i)-oldColors(i)) > colorChange
           stop(brick);
           colorReact(brick,i);
        end
        oldColors(i) = colors(i);
    end
    %}
    
    %% LEFT TURN MONITOR
    %% Detects available left turns on the road
    %% Takes left turn ALWAYS
    if abs(currentDist-oldDist) > distChange
        sprintf('Left Turn Detected');
        stop(brick);
        left(brick,90); %% 90 degree turn
        forward(brick);
        pause(safetyTime);
    end
    

    %% DEFAULT STATE
    stop(brick); 
    oldDist = currentDist;
    
end

stop(brick);
DisconnectBrick(brick);
%% END OF PROGRAM

%% ACTIVATES PASSENGER MECHANISM
function passenger(brick, state)
    brick.MoveMotorAngleRel('C', state * 20, 90, 'Coast');
    stop(brick);
    brick.ResetMotorAngle('C');
end

%% REACTS TO COLOR CHANGES
function colorReact(brick,i)
    if i == 1               %% RED
        stop(brick);
        pause(4);
    elseif i == 2           %% GREEN 
        stop(brick);
        passenger(brick, 1);
        goalAchieved = true;
    else                    %% BLUE
        stop(brick);
        passenger(brick, -1);
    end
end

%% MOVES FORWARD
function forward(brick)
    brick.MoveMotor('AB',50);
end

%% MOVES BACKWARD
function backward(brick)
    brick.MoveMotor('AB',-50);
end

%% TURNS LEFT FOR GIVEN ANGLE
function left(brick, angle)
    endAngle = brick.GyroAngle(gyroPort) - angle;
    while brick.GyroAngle(gryoPort) ~= endAngle
        brick.MoveMotor('A',-50);
        brick.MoveMotor('B',50);
    end
end

%% TURNS RIGHT FOR GIVEN ANGLE
function right(brick, angle)
    endAngle = brick.GyroAngle(gyroPort) + angle;
    while brick.GyroAngle(gryoPort) ~= endAngle
        brick.MoveMotor('B',-50);
        brick.MoveMotor('A',50);
    end
end

%% STOPS ALL MOTORS
function stop(brick)
    brick.MoveMotor('ABC',0);
end