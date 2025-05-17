% فرض دیتاست قبلا بارگذاری شده: proteus_data

N = height(proteus_data);

% اگر SOH_real نداری، این خط رو برای ساخت SOH فرضی اضافه کن (اگر داری حذف کن)
%proteus_data.SOH_real = linspace(1, 0.8, N)';

% ورودی‌ها: جریان، ولتاژ، دما، SOC واقعی
X = [proteus_data.current_A, proteus_data.voltage_ADC_V * 10, proteus_data.temperature_C, proteus_data.soc_real]';
Y = proteus_data.SOH_real';

% ساخت شبکه عصبی
net = feedforwardnet(10);

% تقسیم داده‌ها
net.divideParam.trainRatio = 0.7;
net.divideParam.valRatio = 0.15;
net.divideParam.testRatio = 0.15;

% آموزش
[net,tr] = train(net,X,Y);

% پیش‌بینی
SOH_pred = net(X);

% رسم نمودار
figure;
plot(proteus_data.time_s, Y, 'b-', 'LineWidth', 1.5); hold on;
plot(proteus_data.time_s, SOH_pred, 'r--', 'LineWidth', 1.5);
xlabel('زمان (ثانیه)');
ylabel('SOH');
legend('SOH واقعی', 'SOH پیش‌بینی شده');
title('پیش‌بینی SOH با ANN بر اساس دیتاست پروتئوس');
grid on;
