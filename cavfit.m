clear all; close all; format long;

sys_prm = model_init();
freq_range = -2e4:0.25:2e4;
w = 2*pi*freq_range;

noisegain = 1.5e9;

fo_true = - 1e3;
QL_true = 4.12e7;

Hc = cavity_model(sys_prm, QL_true, 2*pi*fo_true, w);
Hc_noise=Hc+noisegain*(randn(size(Hc))+1j*randn(size(Hc)));

% Optimization Options (number of iterations etc)
opts = optimset('TolX', 1e-8, 'TolFun', 1e-8);
opts = optimset(opts, 'DiffMaxChange', 1e-5, ...
    'MaxFunEvals', 3e3, 'MaxIter', 1e3);
% Turn 'off' 'iter' at final version (for display purposes only)
opts = optimset(opts,'Display', 'off');

x0 = [3e7 -1e4];

% Use function fit_TF_pi to calculate the error function
cav_error_wrapper = @(x) cavity_error(sys_prm, x, w, Hc_noise);
x_final = fminunc(cav_error_wrapper, x0, opts)
x_error_pct = 100 * ((x_final - [QL_true fo_true]) ./ [QL_true fo_true])

Hc_final = cavity_model(sys_prm, x_final(1), x_final(2), w);

figure;
plot(freq_range, Hc_noise, '-r', freq_range, Hc, '-b', freq_range, Hc_final, '-g');

