clear all, clc

filename = 'BPS.csv';

data = readtable(filename);

time=data.Latest_Time_s_; %this can vary because of the Logger Lite software

cuffPressure = data.Latest_CuffPressure_mmHg_;

[peakValuesCP, peakIndicesCP] = findpeaks(cuffPressure, 'MinPeakProminence', 0.7);

[maxPeakValue, maxPeakIndex] = max(peakValuesCP);

timeBeginning =  time(peakIndicesCP(maxPeakIndex));

timeEnd = time(end);

indexBeginning = find(time == timeBeginning+1);

indexEnd = find(time == timeEnd);

intervalTime = time(indexBeginning:indexEnd);

intervalCuffPressure = cuffPressure(indexBeginning:indexEnd);

cutoffFreq = 0.75;

samplingRate = 1/0.01;

order = 4;

[b, a] = butter(order, cutoffFreq / (samplingRate / 2), 'high');

filteredCuffPressure = filtfilt(b, a, intervalCuffPressure);

positiveFilteredCuffPressure = filteredCuffPressure - min(filteredCuffPressure);

[peakValuesFCP, peakIndicesFCP] = findpeaks(positiveFilteredCuffPressure, 'MinPeakProminence', 0.7);

[valleyValuesFCP, valleyIndicesFCP] = findpeaks(-positiveFilteredCuffPressure, 'MinPeakProminence', 0.7);

minLength = min(length(peakValuesFCP), length(valleyValuesFCP));

peakValuesFCP = peakValuesFCP(1:minLength);

peakIndicesFCP = peakIndicesFCP(1:minLength);

valleyValuesFCP = valleyValuesFCP(1:minLength);

valleyValuesFCP = abs(valleyValuesFCP);

[maxValleyValueF, maxValleyIndexF] = min(valleyValuesFCP);

valleyIndicesFCP = valleyIndicesFCP(1:minLength);

[maxPeakValueF, maxPeakIndexF] = max(peakValuesFCP);

differences = abs(peakValuesFCP - valleyValuesFCP);

[biggestDifference, biggestDifferenceIndex] = max(differences);


peakValuesFSB = peakValuesFCP(1:maxPeakIndexF-1);

peakIndicesFSB = peakIndicesFCP(1:maxPeakIndexF-1);

valleyValuesFSB = valleyValuesFCP(1:maxPeakIndexF-1);

differencesSBP = abs(peakValuesFSB - valleyValuesFSB);


peakValuesFDB = peakValuesFCP(maxPeakIndexF+1:end);

peakIndicesFDB = peakIndicesFCP(maxPeakIndexF+1:end);

valleyValuesFDB = valleyValuesFCP(maxPeakIndexF+1:end);

differencesDBP = abs(peakValuesFDB - valleyValuesFDB);

thresholdValue1 = 0.61 * biggestDifference;

thresholdValue2 = 0.74 * biggestDifference;

timeOfMaxPeak = intervalTime(peakIndicesFCP(maxPeakIndexF));

indexMAP = find(intervalTime == timeOfMaxPeak);


[x, closestIndex1] = min(abs(differencesSBP - thresholdValue1));

[y, closestIndex2] = min(abs(differencesDBP - thresholdValue2));

indexS = (positiveFilteredCuffPressure == peakValuesFSB(closestIndex1));

indexD = (positiveFilteredCuffPressure == peakValuesFDB(closestIndex2));

timeSBP =  intervalTime(indexS);

timeDBP =  intervalTime(indexD);

indexSBP = find(intervalTime == timeSBP);

indexDBP = find(intervalTime == timeDBP);

MAP = intervalCuffPressure(indexMAP)

SBP = intervalCuffPressure(indexSBP)
 
DBP = intervalCuffPressure(indexDBP)


figure(1);
%subplot(2,1,1)
plot(time, cuffPressure)
hold on

plot([0, timeSBP], [SBP, SBP], 'r', 'LineWidth', 2)
plot(timeSBP, SBP, 'x', 'MarkerSize', 7, 'LineWidth', 2, 'Color', 'red')
text(timeSBP+1, SBP, ['SBP: ' num2str(SBP)] , 'FontSize', 9, 'FontWeight', 'bold')
plot([0, timeDBP], [DBP, DBP], 'r', 'LineWidth', 2)
plot(timeDBP, DBP, 'x', 'MarkerSize', 7, 'LineWidth', 2, 'Color', 'red')
text(timeDBP+1, DBP, ['DBP: ' num2str(DBP)], 'FontSize', 9, 'FontWeight', 'bold')
plot([0, timeOfMaxPeak], [MAP, MAP], 'r', 'LineWidth', 2)
plot(timeOfMaxPeak, MAP, 'x', 'MarkerSize', 7, 'LineWidth', 2, 'Color', 'red')
text(timeOfMaxPeak+1, MAP,  ['MAP: ' num2str(MAP)], 'FontSize', 9, 'FontWeight', 'bold')
 
 
hold off
xlabel('Time');
ylabel('Cuff Pressure');
title('Cuff Pressure');
grid on


%subplot(2,1,2)
figure(2);
plot(intervalTime, positiveFilteredCuffPressure);
hold on;

plot(intervalTime(peakIndicesFCP), peakValuesFCP, 'ro');

plot(intervalTime(valleyIndicesFCP), valleyValuesFCP, 'go', 'MarkerFaceColor', 'g');

plot([timeOfMaxPeak, timeOfMaxPeak], [maxPeakValueF,valleyValuesFCP(maxPeakIndexF)], 'r--', 'LineWidth', 2)
text(timeOfMaxPeak, maxPeakValueF, 'deltaP', 'FontSize', 11, 'FontWeight', 'bold')
plot([timeSBP, timeSBP], [ peakValuesFSB(closestIndex1), valleyValuesFSB(closestIndex1)], 'r--', 'LineWidth', 2)
text(timeSBP, peakValuesFSB(closestIndex1), '0.5 * deltaP', 'FontSize', 11, 'FontWeight', 'bold')
plot([timeDBP, timeDBP], [ peakValuesFDB(closestIndex2), valleyValuesFDB(closestIndex2)], 'r--', 'LineWidth', 2)
text(timeDBP, peakValuesFDB(closestIndex2), '0.8 * deltaP', 'FontSize', 11, 'FontWeight', 'bold')

hold off
xlabel('Time');
ylabel('Filtered Cuff Pressure');
title('Cuff Pressure after High-Pass Filtering');
xlim([timeBeginning-timeBeginning, timeEnd+timeBeginning])
grid on






