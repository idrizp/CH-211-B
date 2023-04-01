%% Set up the Import Options and import the data
opts = delimitedTextImportOptions("NumVariables", 5);

% Specify range and delimiter
opts.DataLines = [2, Inf];
opts.Delimiter = ",";

% Specify column names and types
opts.VariableNames = ["InputAmplitudeinV", "OutputAmplitudeinV", "PhaseinDeg", "FrequencyinHz", "AmplitudeinDB"];
opts.VariableTypes = ["double", "double", "double", "double", "double"];

% Specify file level properties
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";

% Import the data
data = readtable("Filter-Data.csv", opts);
data_bandpass = readtable("Bandpass-Data.csv", opts);

%% Clear temporary variables
clear opts;

%% Measured Values Bode Plot
clear figure
figure()

amplitudes = data.AmplitudeinDB;
frequencies = data.FrequencyinHz;
phase = arrayfun(@(x) deg2rad(x), data.PhaseinDeg);

subplot(2,1,1);
semilogx(frequencies, amplitudes, 'b--', 'LineWidth', 1);
legend('Measured Amplitude')
ylabel('Amplitude (dB)');
axis([50 10E5 -26 5])
set(gca, 'XTickLabel', {});

subplot(2,1,2);
semilogx(frequencies, phase, 'b--', 'LineWidth', 1);
xlabel('Frequency (Hz)');
ylabel('Phase (rad)');
axis([50 10E5 -1.5 0])

sgtitle("Bode Plot")
legend('Measured Phase')

%% Theoretical Values Bode Plot
clear figure
figure()

R = 22000;
C = 1.5*10^-9;

disp("f-3dB = " + 1/(2*pi*R*C));
amplitudes_calculated = arrayfun(@(x) 20*log10(1 / sqrt(1 + (2*pi*x*R*C)^2)), frequencies);
phase_calculated = arrayfun(@(x) -atan(2*pi*x*R*C), frequencies);

subplot(2,1,1);
semilogx(frequencies, amplitudes_calculated, 'r--', 'LineWidth', 2);
hold on
semilogx(frequencies, amplitudes, 'b--', 'LineWidth', 1);
ylabel('Amplitude (dB)');
axis([50 10E5 -26 5])
set(gca, 'XTickLabel', {});
legend('Calculated Amplitudes', 'Measured Amplitudes')

subplot(2,1,2);
semilogx(frequencies, phase, 'r--', 'LineWidth', 2);
hold on
semilogx(frequencies, phase_calculated, 'b--', 'LineWidth', 1);
xlabel('Frequency (Hz)');
ylabel('Phase (rad)');
axis([50 10E5 -1.5 0])

sgtitle("Bode Plot")
legend('Calculated Phase', 'Measured Phase')


%% Measured Values Bandpass Bode Plot
clear figure
figure()

amplitudes = data_bandpass.AmplitudeinDB;
frequencies = data_bandpass.FrequencyinHz;
phase = arrayfun(@(x) deg2rad(x), data_bandpass.PhaseinDeg);

subplot(2,1,1);
semilogx(frequencies, amplitudes, 'b--');
legend('Measured Amplitude')
ylabel('Amplitude (dB)');
axis([50 10E5 -18 0])
set(gca, 'XTickLabel', {});

subplot(2,1,2);
semilogx(frequencies, phase, 'b--');
legend('Measured Phase')
xlabel('Frequency (Hz)');
ylabel('Phase (rad)');
axis([50 10E5 deg2rad(-81) deg2rad(78)])
sgtitle("Bode Plot")

%% Theoretical Values Bandpass Bode Plot
clear figure
figure()

% Low pass
R1 = 8200; 
C1 = 1.5*10^-9;

% High pass
R2 = 10000;
C2 = 100*10^-9;

amplitudes = data_bandpass.AmplitudeinDB;
frequencies = data_bandpass.FrequencyinHz;
phase = deg2rad(data_bandpass.PhaseinDeg);


disp("f-3dB = " + 1/(2*pi*R*C));

% calculates the amplitude for a frequency
calculate_lo = @(x) 1/sqrt(1+(2*pi*x*R1*C1)^2);
calculate_hi = @(x) 1/sqrt((1+1/(2*pi*x*R2*C2)^2));

calculate_hi_phase = @(x) atan(1/(2*pi*x*R2*C2));
calculate_lo_phase = @(x) -atan(2*pi*x*R1*C1);

calculate_amplitude = @(x) 20*log10(calculate_lo(x) * calculate_hi(x));
calculate_phase = @(x) calculate_hi_phase(x) + calculate_lo_phase(x);

amplitudes_calculated = arrayfun(@(x) calculate_amplitude(x), frequencies);
phase_calculated = arrayfun(@(x) calculate_phase(x), frequencies);

subplot(2,1,1);
semilogx(frequencies, amplitudes_calculated, 'r--', 'LineWidth', 2);
hold on
semilogx(frequencies, amplitudes, 'b--', 'LineWidth', 1);
ylabel('Amplitude (dB)');
axis([50 10E5 -19 1])
set(gca, 'XTickLabel', {});
legend('Calculated Amplitudes', 'Measured Amplitudes')

subplot(2,1,2);
semilogx(frequencies, phase_calculated, 'r--', 'LineWidth', 2);
hold on
semilogx(frequencies, phase, 'b--', 'LineWidth', 1);
xlabel('Frequency (Hz)');
ylabel('Phase (rad)');
axis([50 10E5 -deg2rad(80.5) deg2rad(74)])

sgtitle("Bode Plot")
legend('Calculated Phase', 'Measured Phase')

%% Nyquist plot

s = tf('s');

% Low pass
R1 = 8200; 
C1 = 1.5*10^-9;

% High pass
R2 = 10000;
C2 = 100*10^-9;

H_lo = 1/(1+s*R1*C1);
H_hi = 1/(1+1/(s*R2*C2));

nyquist((H_lo * H_hi), frequencies)