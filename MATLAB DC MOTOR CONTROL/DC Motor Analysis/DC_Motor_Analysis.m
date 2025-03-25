%% DC Motor Analizi - Ana Dosya
% Modelimizden çıkarılan parametre değerleri

% Temel parametreler
L_base = 0.01;       % Armature inductance (H)
R_base = 0.5;          % Armature resistance (ohm)
Kt_base = 0.0286;    % Tork sabiti (N.m/A)
Kv_base = 0.0286;    % Hız sabiti (V/rad/s)
J_base = 0.0002;     % Rotor inertia (kg·m²)
B_base = 0.5e-5;     % Rotor damping (N·m·s/rad)

%% Transfer Fonksiyonu - Temel Model
% Baseline transfer fonksiyonu oluştur
num_base = Kt_base;
den_base = [J_base*L_base, J_base*R_base+B_base*L_base, B_base*R_base+Kt_base*Kv_base];
sys_base = tf(num_base, den_base);

% Adım cevabı
t = 0:0.001:1;
[y_base, t] = step(sys_base, t);

% Temel model sonuçlarını kaydet
results.baseline.t = t;
results.baseline.y = y_base;
results.baseline.sys = sys_base;

%% Transfer Fonksiyonu - J Değişimi
% J değerini iki katına çıkar
J_high = 2 * J_base;
num_J = Kt_base;
den_J = [J_high*L_base, J_high*R_base+B_base*L_base, B_base*R_base+Kt_base*Kv_base];
sys_J = tf(num_J, den_J);
[y_J, t] = step(sys_J, t);

% J değişimi sonuçlarını kaydet
results.J_change.t = t;
results.J_change.y = y_J;
results.J_change.sys = sys_J;
results.J_change.parameter = 'J';
results.J_change.value = J_high;

%% Transfer Fonksiyonu - B Değişimi
% B değerini on katına çıkar
B_high = 10 * B_base;
num_B = Kt_base;
den_B = [J_base*L_base, J_base*R_base+B_high*L_base, B_high*R_base+Kt_base*Kv_base];
sys_B = tf(num_B, den_B);
[y_B, t] = step(sys_B, t);

% B değişimi sonuçlarını kaydet
results.B_change.t = t;
results.B_change.y = y_B;
results.B_change.sys = sys_B;
results.B_change.parameter = 'B';
results.B_change.value = B_high;

%% Transfer Fonksiyonu - L Değişimi
% L değerini beş katına çıkar
L_high = 5 * L_base;
num_L = Kt_base;
den_L = [J_base*L_high, J_base*R_base+B_base*L_high, B_base*R_base+Kt_base*Kv_base];
sys_L = tf(num_L, den_L);
[y_L, t] = step(sys_L, t);

% L değişimi sonuçlarını kaydet
results.L_change.t = t;
results.L_change.y = y_L;
results.L_change.sys = sys_L;
results.L_change.parameter = 'L';
results.L_change.value = L_high;

%% Transfer Fonksiyonu - R Değişimi
% R değerini yarıya düşür
R_low = R_base / 2;
num_R = Kt_base;
den_R = [J_base*L_base, J_base*R_low+B_base*L_base, B_base*R_low+Kt_base*Kv_base];
sys_R = tf(num_R, den_R);
[y_R, t] = step(sys_R, t);

% R değişimi sonuçlarını kaydet
results.R_change.t = t;
results.R_change.y = y_R;
results.R_change.sys = sys_R;
results.R_change.parameter = 'R';
results.R_change.value = R_low;

%% Tüm Transfer Fonksiyonu Sonuçlarını Karşılaştırma
figure;
plot(t, y_base, 'k-', 'LineWidth', 2);
hold on;
plot(t, y_J, 'r--', 'LineWidth', 1.5);
plot(t, y_B, 'b-.', 'LineWidth', 1.5);
plot(t, y_L, 'g:', 'LineWidth', 1.5);
plot(t, y_R, 'm--', 'LineWidth', 1.5);
legend('Temel Değerler', 'J İki Katına Çıkarıldı', 'B On Katına Çıkarıldı', 'L Beş Katına Çıkarıldı', 'R Yarıya Düşürüldü');
title('DC Motor Parametrelerinin Hız Adım Cevabına Etkisi');
xlabel('Zaman (s)');
ylabel('Açısal Hız (rad/s)');
grid on;

% Grafik dosyasını kaydet
saveas(gcf, 'TF_Parameter_Comparison.png');