% Create a session for data acquisition (modify the parameters accordingly).
s = daq.createSession('ni');

% Configure the session parameters (replace with your LabQuest Mini's settings).
s.addAnalogInputChannel('Dev1', 'ai0', 'Voltage'); % Replace 'Dev1' and 'ai0' with your LabQuest Mini's device and channel IDs.
s.Rate = 1/0.01;  % Set the desired sample rate in Hz.

% Define the callback function to process the acquired data.
s.NotifyWhenDataAvailableExceeds = s.Rate / 10; % Notify every 100 ms (adjust as needed).
s.IsContinuous = true;
s.ExternalTriggerTimeout = Inf;
s.addlistener('DataAvailable', @(src, event) processLiveData(event));

% Define the callback function to process the acquired data.
function processLiveData(event)
    data = event.Data;
    % Process and analyze 'data' here.
    % Example: Display the data.
    disp(data);
end

% Start data acquisition.
startBackground(s);

% To stop data acquisition when you're done:
% stop(s);
% delete(s);
% clear s;

% To stop the infinite loop, press Ctrl+C in the MATLAB command window.
