% بارگذاری داده‌ها
data = readtable('kalman_ready_battery_dataset.csv');
time = data.time_s;
I = data.current_A;
V = data.voltage_ADC_V * 10;
dt = 1;  % گام زمانی

% پارامترهای باتری
C = 12 * 3600;       % ظرفیت باتری (کولن)
Rint = 0.15;         % مقاومت داخلی (اهم)

% تابع OCV اصلاح‌شده (خطی‌تر و شیب‌دارتر)
OCV = @(soc) 3.0 + 1.2 * soc - 0.1 * soc.^2;

% مشتق OCV نسبت به SOC
dOCV = @(soc) 1.2 - 0.2 * soc;

% مقداردهی اولیه
n = length(time);
x = 0.95;       % SOC اولیه اصلاح‌شده
P = 1e-4;
Q = 1e-5;
R = 1e-3;

soc_est = zeros(n,1);
soc_est(1) = x;

for k = 2:n
    Ik = I(k);

    % پیش‌بینی
    x_pred = x - (Ik * dt) / C;
    x_pred = max(0.001, min(1, x_pred));  % محدودسازی

    P_pred = P + Q;

    % ولتاژ پیش‌بینی‌شده
    V_pred = OCV(x_pred) - Rint * Ik;

    % ماتریس ژاکوبی
    H = dOCV(x_pred);

    % نوآوری
    y = V(k) - V_pred;

    % سود کالمن
    S = H * P_pred * H' + R;
    K = P_pred * H' / S;

    % به‌روزرسانی
    x = x_pred + K * y;
    P = (1 - K * H) * P_pred;

    x = max(0, min(1, x));
    soc_est(k) = x;
end

% رسم نمودار
figure;
plot(time, data.soc_real, 'k--', 'LineWidth', 1.5); hold on;
plot(time, soc_est, 'b', 'LineWidth', 1.5);
xlabel('Time (s)');
ylabel('SOC');
legend('Real SOC', 'EKF Estimated SOC');
title('SOC Estimation with Modified Rint Model (EKF)');
grid on;
