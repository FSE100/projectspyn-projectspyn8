clear all;

brick = ConnectBrick('EV3PP');
brick.beep();

touchPort = 4;
colorPort = 2;
distPort  = 3; 

brick.ResetMotorAngle('C');

brick.SetColorMode(colorPort,4);

%% Initial Values
oldColors = brick.ColorRGB(colorPort);
oldDist = brick.UltrasonicDist(distPort);
goalAchieved = 0;
touch = 0;

%% Tolerance Values
distChange = 10;   %% sensitivity for left-turn detection
colorChange = 50;  %% sensitivity new color detection
safetyTime = 3;    %% time to clear a block after turning
leftTurnDistance = 60;

global lTurnTime;
global rTurnTime;
global lSpeed;
global rSpeed;
lTurnTime = .67;
rTurnTime = .682;
lSpeed = 50;
rSpeed = 50;

while 1

    %% GET SENSOR VALUES
    currentDist = brick.UltrasonicDist(distPort);
    touch = brick.TouchPressed(touchPort);
    colors = brick.ColorRGB(colorPort);
    batt = brick.GetBattLevel();
    
    
    %% DISPLAY SENSOR VALUES
    fprintf('currentDist: %d  Touch: %d   R: %d  G: %d  B: %d   Batt: %d\n',currentDist, touch, colors(1), colors(2), colors(3), batt);
    
    
    %% KEEP LEFT
    if(currentDist>leftTurnDistance)
        fprintf('Turning Left\n');
        stop(brick);
        pause(2);
        forward(brick);
        pause(1);
        stop(brick);
        leftTime(brick, lTurnTime);
        stop(brick);
        forward(brick);
        pause(safetyTime);
        fprintf('Turn Complete\n');
    end
    %% WALL - RIGHT
    if touch
        fprintf('Wall Detected... Turning Right\n');
        
        backward(brick);
            pause(1);
        stop(brick);
            pause(1);
        rightTime(brick, rTurnTime);
    end
        
    
    %% WALL COLLISION
    %% Compares distance values for left and right paths
    %% Moves towards longest path
    %{
    if touch
        fprintf('Wall Detected...\n');
        stop(brick);
        backward(brick);
        pause(1);
        stop(brick);
        
        leftDist = brick.UltrasonicDist(distPort);   %% Get left path distance
        fprintf('Left Path Clearance: %d \n',leftDist);
        fprintf('Rotating 180 degrees...\n');
        left(brick,180,gyroPort);                            %% Turn 180 degrees
        stop(brick);
        rightDist = brick.UltrasonicDist(distPort); %% Get right path distance
        fprintf('Right Path Clearance: %d \n',rightDist);
        
        %% Orient towards longest path
        if (rightDist > leftDist)
            fprintf('Right Turn Chosen\n');
            left(brick,90,gyroPort);
        else
            fprintf('Left Turn Chosen\n');
            right(brick,90,gyroPort);
        end
        
        %% Continue forwards and exit block
        forward(brick);
        fprintf('Clearing block...\n');
        pause(safetyTime);
        stop(brick);
        currentDist = brick.UltrasonicDist(distPort);
    end
    %}
    %% LEFT TURN MONITOR
    %% Detects available left turns on the road
    %% Takes left turn ALWAYS
    %{
    if abs(currentDist-oldDist) > distChange
        sprintf('Left Turn Detected\n');
        stop(brick);
        left(brick,90,gyroPort); %% 90 degree turn
        forward(brick);
        sprintf('Clearing block...\n');
        pause(safetyTime);
    end
    %}
    %% COLOR RECOGNITION AND RESPONSE
    %% Calls colorReact method to handle RGB detection
    %{
    for i=1:3
        val = abs(colors(i)-oldColors(i));
        if val > colorChange
            stop(brick);
            fprintf('Color Change Detected: ');
            colorReact(brick,i);
        end
        oldColors(i) = colors(i);
    end
    %}
    

    %% DEFAULT STATE
    forward(brick);
    oldDist = currentDist;
end

stop(brick);
pause(safetyTime);
DisconnectBrick(brick);

%% END OF PROGRAM

%% TURNS LEFT FOR GIVEN TIME
function leftTime(brick, time)
    brick.MoveMotor('A',rSpeed);
    brick.MoveMotor('B',-lSpeed);
    pause(time);
end

function rightTime(brick, time)
    brick.MoveMotor('A',-rSpeed);
    brick.MoveMotor('B',lSpeed);
    pause(time);
end

%% MOVES FORWARD
function forward(brick)
    brick.MoveMotor('A',rSpeed);
    brick.MoveMotor('B',lSpeed);
end

function correctLeft(brick)
    fprintf('Correcting Left\n');
    brick.MoveMotor('A',70);
    brick.MoveMotor('B',40);
    pause(.1);
end

function correctRight(brick)
    fprintf('Correcting Right\n');
    brick.MoveMotor('A',40);
    brick.MoveMotor('B',70);
    pause(.1);
end

%% ACTIVATES PASSENGER MECHANISM
function passenger(brick, state)
    brick.MoveMotorAngleRel('C', state * 20, state * 90, 'Coast');
    stop(brick);
    brick.ResetMotorAngle('C');
end

%% REACTS TO COLOR CHANGES
function colorReact(brick,i)
    if i == 1               %% RED
        stop(brick);
        fprintf('RED\n');
        pause(4);
    elseif i == 2           %% GREEN 
        stop(brick);
        fprintf('GREEN\n');
        passenger(brick, 1);
        goalAchieved = true;
    else                    %% BLUE
        stop(brick);
        fprintf('BLUE\n');
        passenger(brick, -1);
    end
end



%% MOVES BACKWARD
function backward(brick)
    brick.MoveMotor('AB',-50);
end

%% TURNS LEFT FOR GIVEN ANGLE
function left(brick, angle, gyroPort)
    gyroAngle = brick.GyroAngle(gyroPort);
    endAngle = gyroAngle - angle;
    
    while ~((gyroAngle < endAngle+5) && (gyroAngle>endAngle-5))
        fprintf('Current Angle: %d   Goal: %d \n', gyroAngle, endAngle);
        brick.MoveMotor('A',20);
        brick.MoveMotor('B',-20);
        gyroAngle = brick.GyroAngle(gyroPort);
    end
    stop(brick);
end



%% TURNS RIGHT FOR GIVEN ANGLE
function right(brick, angle, gyroPort)
    gyroAngle = brick.GyroAngle(gyroPort);
    endAngle = gyroAngle + angle;
    
    while ~((gyroAngle < endAngle+5) && (gyroAngle>endAngle-5))
        fprintf('Current Angle: %d   Goal: %d \n', gyroAngle, endAngle);
        brick.MoveMotor('B',15);
        brick.MoveMotor('A',-15);
        gyroAngle = brick.GyroAngle(gyroPort);
    end
    stop(brick);
end

%% STOPS ALL MOTORS
function stop(brick)
    brick.MoveMotor('ABC',0);
end