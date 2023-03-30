clc
clear all;

% Part 2 Evaluation:

% N - Nominal
% M - Measured
% MM - Multimeter
% O - Oscilloscope
% NM - Nominal, Measured Impedance
% MN - Measured, Nominal Impedance

IsMM = pol2rect(1223.4*10^-6, 21.9);

% Measured at RLC meter
Cp = 96.57 * 10^-9;
Rp = 455.21 * 10^3;
Ls = 101.52 * 10^-3;
Rs = 393.56;
R = 1791.8;

% Measured at multimeter, Vs, Vr, and Vrl
VsMM = 3.503;
VrMM = 2.21;
VrlMM = 2.78;

% Measured at oscilloscope, Vr and Vrl
VrO = pol2rect(2.22, 21.9);
VrlO = pol2rect(2.81, 38.1);

% Frequency and angular frequency
f = 1000;
w = 2*pi*f;

%% Measured impedances
ZrM = R;
ZamM = 500;
ZlM = 1i*w*Ls + Rs;
ZcM = 1/(1i*w*Cp + 1/Rp);

show("ZrM", ZrM);


show("ZamM", ZamM);
show("ZlM", ZlM);
showrect("ZlM", ZlM);

show("ZcM", ZcM);
showrect("ZcM", ZcM);

% Total measured impedance
ZtM = ZrM + ZamM + ZlM + ZcM;

show("ZtM", ZtM);

%% Nominal Calculations With Measured Impedances

VsNM= pol2rect(10, 0);

IsNM = VsNM / ZtM;
VrNM = IsNM * ZrM;
VrlNM = IsNM * (ZrM + ZlM);
VcNM = IsNM * ZcM;
VamNM = IsNM * ZamM;
VlNM = VsNM - VamNM - VcNM - VrNM;

show("VsNM", VsNM);
show("IsNM", IsNM);
show("VrNM", VrNM);
show("VrlNM", VrlNM);
show("VlNM", VlNM);
show("VcNM", VcNM);
show("VamNM", VamNM);

%% Every component's Voltage with measured current and voltage
VsM = fromsinrms(VsMM); % The measured voltage without RMS.
VrlM = fromsinrms(VrlO); % The measured voltage over the resistance and inductor without RMS.
VrM = fromsinrms(VrO); % The measured voltage over the resistance without RMS.
IsM = fromsinrms(IsMM);
VamM = IsM * 500;

VcM = VsM - VamM - VrlM;
VlM = VsM - VamM - VcM - VrM;

show("IsM", IsM);
show("VsM", VsM);
show("VrM", VrM);
show("VrlM", VrlM);
show("VcM", VcM);
show("VlM", VlM);
show("VamM", VamM);

%% Nominal Impedances from measured voltage and current

ZrMN = VrM/IsM;
ZcMN = VcM / IsM;
ZlMN = VlM/IsM;
ZamMN = VamM/IsM;

% ZcMN = real(ZcMN) - 1i*imag(ZlMN);

show("ZrMN", ZrMN);
show("ZcMN", ZcMN);
show("ZlMN", ZlMN);
show("ZamMN", ZamMN);

showrect("ZcMN", ZcMN);
showrect("ZlMN", ZlMN);

Ca = real(ZcMN);
Cb = imag(ZcMN);

RpM = (Ca^2 + Cb^2) / Ca;
CpM  = -Cb/(w*(Ca^2 + Cb^2));

showrect("RpM", RpM);
showrect("CpM", CpM);

La = real(ZlMN);
Lb = imag(ZlMN);

RsM = La;
LsM = Lb/w;

showrect("RsM", RsM);
showrect("LsM", LsM);

%%

function [] = show(var, val)
    disp(var + ": " + rect2polstr(val) + ", RMS: " + rect2polstr(sinrms(val)))
end

function [] = showrect(var, val)
    disp(var + ": " + val + ", RMS: " + sinrms(val))
end