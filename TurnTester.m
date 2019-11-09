clear all;

brick = ConnectBrick('EV3PP');
brick.beep();

global key
InitKeyboard();

lTurnTime = .672;
rTurnTime = .685;

while true
    pause(0.01);
    switch key
        
        case 'leftarrow'
            disp('left');
            leftTime(brick,lTurnTime);
            stop(brick);
            pause(1);
        case 'rightarrow'
            disp('right');
            rightTime(brick,rTurnTime);
            stop(brick);
            pause(1);
            
            
    end
end

function leftTime(brick, time)
    brick.MoveMotor('A',50);
    brick.MoveMotor('B',-50);
    pause(time);
end

function rightTime(brick, time)
    brick.MoveMotor('A',-50);
    brick.MoveMotor('B',50);
    pause(time);
end

function stop(brick)
    brick.MoveMotor('AB',0);
end