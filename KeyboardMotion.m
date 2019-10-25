DisconnectBrick(brick);

brick = ConnectBrick('BOTTY');
brick.beep();

global key
InitKeyboard();



brick.GyroCalibrate(gyroPort);
brick.ResetMotorAngle('C');

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
        case 'p'
            disp('passenger');
            passenger(brick,1);
        case 'o'
            disp('passenger');
            passenger(brick,-1);
        case 'q'
            disp('Exit')
            break;
    end
    stop(brick);
end

stop(brick);
closeKeyboard();
DisconnectBrick(brick);
%% END OF PROGRAM


function passenger(brick, state)
    brick.MoveMotorAngleRel('C', state * 20, 90, 'Coast');
    stop(brick);
    brick.ResetMotorAngle('C');
end

%% MOVES FORWARD
function forward(brick)
    brick.MoveMotor('AB',150);
end

%% MOVES BACKWARD
function backward(brick)
    brick.MoveMotor('AB',-150);
end

%% TURNS LEFT
function left(brick)
    brick.MoveMotor('A',150);
    brick.MoveMotor('B',-150);
end

%% TURNS RIGHT
function right(brick)
    brick.MoveMotor('A',-150);
    brick.MoveMotor('B',150);
end

%% STOPS ALL MOTORS
function stop(brick)
    brick.MoveMotor('ABC',0);
end