% Color Tester

clear all;

brick = ConnectBrick('EV3PP');
brick.beep();

colorPort = 2;
brick.SetColorMode(colorPort,2);

%% MODE 4
while 0
    colors = brick.ColorRGB(colorPort);
    fprintf('R: %d  G: %d  B: %d \n', colors(1), colors(2), colors(3));
end

%% MODE 4
%%Wood: 208, 117, 87
%%Yellow: 225, 220, 50
%%Green: 2, 30, 5
%%Blue: 47, 85, 165
%%Red: 260, 50, 30
%%White: 140, 179, 103

%% MODE 2
colorNames = ["Black", "Blue", "Green", "Yellow", "Red", "White", "Brown", "N/A"];
while 1
    color = brick.ColorCode(colorPort);
    if color==0 
        color=8; 
    end 
    
    fprintf('%s\n',colorNames(color));
    
end
%{
1 Black 
2 Blue 
3 Green 
4 Yellow 
5 Red 
6 White 
7 Brown
%}