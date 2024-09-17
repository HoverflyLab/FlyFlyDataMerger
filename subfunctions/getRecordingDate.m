function date = getRecordingDate(fileName)

load(fileName, "ticktimes_block1");

date = char(datetime(ticktimes_block1, 'convertfrom', 'posixtime', 'Format', 'dd-MMM-uuuu'));
date = date(1:11);