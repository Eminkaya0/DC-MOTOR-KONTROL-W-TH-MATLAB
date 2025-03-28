% -------------------------     GENEL NOTLAR    --------------------
% 
% Transfer fonksiyonları için kv ve kt değerlerini hesaplamamız lazım bu dc
% motor sisteminden 
%------------------------------------------
% Kv değeri (Back-EMF sabiti), 
% Bir DC motorun her rad/s açısal hız başına ürettiği gerilim V/(rad/s).
%
% Kv = Gerilim (12V) / Yüksüz Çalışma Hızı(4000 rpm)
% 
% rpm'yi rad/s dönüştürmemiz gerekir. Mechanical için 
% 
% 4000 rpm = 4000 × (2π/60) = 418.9 rad/s
% 
% Kv = 12 V / 418.9 rad/s = 0.0286 V/(rad/s)
%------------------------------------------
% Kt değeri amper başına düşen torktur. 
% 
% Genelde Kt = Kv olarak kabul edilir. 
% 
% Kt = 0.0286 N·m/A
% 
% Transfer fonksiyon hesabı
L = 0.01;         % Armature inductance (H) - modelinizden
R = 0.5;            % Armature resistance (ohm) - varsayılan değer
Kt = 0.0286;      % Tork sabiti (N.m/A) - hesaplandı
Kv = 0.0286;      % Hız sabiti (V/rad/s) - hesaplandı
J = 0.0002;       % Rotor inertia (kg·m²) - modelinizden
B = 0.5e-5;       % Rotor damping (N·m·s/rad) - modelinizden

% Transfer Fonksiyonu (Hız/Gerilim)
num = Kt;
den = [J*L, J*R+B*L, B*R+Kt*Kv];
sys_speed = tf(num, den);

% Transfer fonksiyonu hakkında bilgi
disp('DC Motor Transfer Fonksiyonu:');
disp(sys_speed);

% Adım cevabını al
t = 0:0.001:1; % Zaman aralığı
[y, t] = step(sys_speed, t);

% Grafiği çiz
figure;
plot(t, y, 'b-', 'LineWidth', 2);
title('DC Motor Hız Adım Cevabı (Transfer Fonksiyonu)');
xlabel('Zaman (s)');
ylabel('Açısal Hız (rad/s)');
grid on;
