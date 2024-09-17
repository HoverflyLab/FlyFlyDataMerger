function dataBlock = getDataBlock(fileName, blockNo, channel) %#ok<INUSD> Used in an eval statement, so is ok 

eval(['load(fileName, "data_block' num2str(blockNo) '");']);
%for sampsamp
% if blockNo<10,
%     
%     
%     dataBlock = eval(['data_block000' num2str(blockNo) '(' num2str(channel) ',:)']);
%     
% elseif blockNo<100,
%     
%     dataBlock = eval(['data_block00' num2str(blockNo) '(' num2str(channel) ',:)']);
%     
% elseif blockNo<1000,
%     
%     dataBlock = eval(['data_block0' num2str(blockNo) '(' num2str(channel) ',:)']);
% 
% else
%         
%     dataBlock = eval(['data_block' num2str(blockNo) '(' num2str(channel) ',:)']);
%     
% end

% Testing if there are sting header cells used
cellTest = eval(['iscell(data_block' num2str(blockNo) ');']);

% Shouldn't need to check for if is cell or not, but good to stay safe
if cellTest
    stringTest = eval(['isstring(data_block' num2str(blockNo) '{1,1});']);
else
    stringTest = eval(['isstring(data_block' num2str(blockNo) '(1,1));']);
end
if stringTest
    channel = channel + 1;
end

dataBlock = eval(['data_block' num2str(blockNo) '(' num2str(channel) ',:)']);
    
% Data can come from a lot of different places, so force it into a
% particular format first to prevent errors
if iscell(dataBlock)
    dataBlock = cell2mat(dataBlock);
end

%for frankfrank
%dataBlock = eval(['data_block' num2str(blockNo,'%04.0f') '(' num2str(channel) ',:)']);
dataBlock = dataBlock(~isnan(dataBlock)); %remove NaN