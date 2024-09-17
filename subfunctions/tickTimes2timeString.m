function x = tickTimes2timeString(fileName) %#ok<INUSD> Used in an eval statement
% Inform the user of warning message
disp("A warning will come up as part of this script, please ignore it as it's intentional")

% Make an array with the starting times of all blocks
n = 1;
while true
    try
        eval(['load(fileName, "ticktimes_block' num2str(n) '");']);
        timeBlock = ['ticktimes_block' num2str(n)];
        x(n) = eval(timeBlock);
    catch
        break;
    end
    n = n+1;
end

x = x'; %x is number of seconds since 1 jan 1970

offset = datenum('01-Jan-1970'); %number of seconds up til 1 jan 1970

x = x/(24*60*60) + offset; %current time in seconds
