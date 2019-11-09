% Calibration.m
% This script is used to calibrate several values for intended autonomous functionality
% left/right turn time
% left/right motor speed

% Clear workspace
clear all;

% Connect EV3
brickName = 'EV3';
global brick;
brick = ConnectBrick(brickName);
% Check connection to EV3
brick.beep();

% Initialize keyboard control functionality
global key;
InitKeyboard();

% Initialize sensor port connections
colorPort = 2;
distPort  = 3; 
touchPort = 4;

% Set color sensor to RGB setting
brick.SetColorMode(colorPort,4);

% Declare global variables (calibration values)
global lTurnTime;
global rTurnTime;
global lSpeed;
global rSpeed;
global rightM;
    rightM = 'A';
global leftM;
    leftM = 'B';
global collectM;
    collectM = 'C';
    brick.ResetMotorAngle(collectM);

% Calibration 
lTurnTime = .67;
rTurnTime = .682;
lSpeed = 50;
rSpeed = 50;

% Remote testing interface
while true
    pause(0.01);
    switch key
        case 't'
            disp('timed left turn');
            leftTimed();
        case 'y'
            disp('timed right turn');
            rightTimed();
        case 'uparrow'
            disp('forward');
            forward();
        case 'downarrow'
            disp('backward');
            backward();
        case 'leftarrow'
            disp('left');
            left();
        case 'rightarrow'
            disp('right');
            right();
        case 'o'
            disp('passenger');
            passenger(1);
        case 'l'
            disp('passenger');
            passenger(-1);
        case 'q'
            disp('Exit')
            break;
    end
    stop();
end

stop();
closeKeyboard();
DisconnectBrick(brick);
%% END OF PROGRAM

%% LEFT TURN - TIME-BASED
function leftTimed()
    global rSpeed;
    global lSpeed;
    global right;
    global left;
    global brick;
    global lTurnTime;
    brick.MoveMotor(right,rSpeed);
    brick.MoveMotor(left,-lSpeed);
    pause(lTurnTime);
end

%% RIGHT TURN - TIME-BASED
function rightTimed()
    global rSpeed;
    global lSpeed;
    global right;
    global left;
    global brick;
    global rTurnTime;
    brick.MoveMotor(right,rSpeed);
    brick.MoveMotor(left,-lSpeed);
    pause(rTurnTime);
end

%% FORWARD MOTION
function forward()
    global rSpeed;
    global lSpeed;
    global right;
    global left;
    global brick;
    brick.MoveMotor(right,rSpeed);
    brick.MoveMotor(left,lSpeed);
end

%% BACKWARD MOTION
function backward()
    global rSpeed;
    global lSpeed;
    global right;
    global left;
    global brick;
    brick.MoveMotor(right,-rSpeed);
    brick.MoveMotor(left,-lSpeed);
end

%% LEFT TURN - DYNAMIC
function left()
    global rSpeed;
    global lSpeed;
    global right;
    global left;
    global brick;
    brick.MoveMotor(right,rSpeed);
    brick.MoveMotor(left,-lSpeed);
end

%% RIGHT TURN - DYNAMIC
function right()
    global rSpeed;
    global lSpeed;
    global right;
    global left;
    global brick;
    brick.MoveMotor(right,-rSpeed);
    brick.MoveMotor(left,lSpeed);
end

%% STOPS ALL MOTORS
function stop()
    global brick;
    brick.MoveMotor('ABC',0);
end

%% MOVES PASSENGER COLLECTION MECHANISM
function passenger(state)
    global brick;
    global collectM;
    brick.MoveMotorAngleRel(collectM, state * 20, 90, 'Coast');
    stop();
    brick.ResetMotorAngle(collectM);
end

