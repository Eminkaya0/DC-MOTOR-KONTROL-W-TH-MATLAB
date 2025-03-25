%% 1. Verilen Transfer Fonksiyonunun Analizi
% Bu bölümde, G(s) = 1/(s² + 10s + 5)  analiz ediyoruz

% Transfer fonksiyonunu oluştur
num = 1;
den = [1 10 5];
G = tf(num, den);

% Sistemin kutuplarını bul
poles = pole(G);
disp('Sistemin kutupları:');
disp(poles);

% Kontrolsüz sistem adım cevabını çiz
figure;
step(G);
title('Kontrolsüz Sistemin Adım Cevabı');
xlabel('Zaman (s)');
ylabel('Genlik');
grid on;

% Performans metriklerini hesapla
[y, t] = step(G);
info = stepinfo(y, t);
disp('Kontrolsüz sistem performans metrikleri:');
disp(info);

% Grafiği kaydet
saveas(gcf, 'Kontrolsuz_Sistem_Adim_Cevabi.png');

%% 2. PID Parametrelerinin Manuel Olarak Ayarlanması
% Çeşitli PID parametre değerlerini deneyerek performansı inceliyoruz

% Transfer fonksiyonu (önceki bölümden)
G = tf(1, [1 10 5]);

% Test edilecek PID parametreleri
PID_params = [
    % Kp,  Ki,  Kd
    50,   25,   10;  % Set 1
    60,   20,   15;  % Set 2
    40,   30,    8;  % Set 3
    55,   28,   12;  % Set 4
];

% Her parametre seti için sistemi test et
figure;
hold on;
legends = {};

for i = 1:size(PID_params, 1)
    Kp = PID_params(i, 1);
    Ki = PID_params(i, 2);
    Kd = PID_params(i, 3);
    
    % PID kontrolcü oluştur
    C = pid(Kp, Ki, Kd);
    
    % Kapalı çevrim transfer fonksiyonu
    T = feedback(C*G, 1);
    
    % Adım cevabını çiz
    [y, t] = step(T, 20); % 20 saniyelik simülasyon
    plot(t, y, 'LineWidth', 1.5);
    
    % Performans metriklerini hesapla
    info = stepinfo(y, t);
    
    % Lejant için metrikleri kaydet
    legends{i} = sprintf('Kp=%.1f, Ki=%.1f, Kd=%.1f (ts=%.2fs, OS=%.2f%%)', ...
        Kp, Ki, Kd, info.SettlingTime, info.Overshoot);
    
    % Kriterleri sağlayıp sağlamadığını kontrol et
    if info.SettlingTime <= 10 && info.Overshoot <= 10
        fprintf('Set %d: Kp=%.1f, Ki=%.1f, Kd=%.1f KRİTERLERİ KARŞILIYOR!\n', ...
            i, Kp, Ki, Kd);
        fprintf('   Yerleşme Süresi: %.2f s, Aşma: %.2f%%\n', ...
            info.SettlingTime, info.Overshoot);
    else
        fprintf('Set %d: Kp=%.1f, Ki=%.1f, Kd=%.1f kriterleri karşılamıyor.\n', ...
            i, Kp, Ki, Kd);
        fprintf('   Yerleşme Süresi: %.2f s, Aşma: %.2f%%\n', ...
            info.SettlingTime, info.Overshoot);
    end
end

% Grafik özelliklerini ayarla
legend(legends, 'Location', 'southeast');
title('Farklı PID Parametreleri için Sistem Cevabı');
xlabel('Zaman (s)');
ylabel('Çıkış');
grid on;

% Hedef kriterleri gösteren yatay çizgiler
plot([0, 20], [1.1, 1.1], 'r--', 'LineWidth', 1); % %10 aşma sınırı
text(15, 1.12, '%10 Aşma Sınırı', 'Color', 'r');

% Grafiği kaydet
saveas(gcf, 'PID_Parametre_Karsilastirma.png');

%% 3. Sistematik PID Parametre Taraması
% Geniş bir parametre aralığında tarama yaparak en iyi değerleri buluyoruz

% Taranacak parametre aralıkları
Kp_range = 40:5:70;
Ki_range = 20:5:40;
Kd_range = 5:2:20;

% Sonuçları saklamak için matris oluştur
results = [];

fprintf('\nParametre taraması başlatılıyor...\n');

% Parametre taraması
for Kp = Kp_range
    for Ki = Ki_range
        for Kd = Kd_range
            % PID kontrolcü oluştur
            C = pid(Kp, Ki, Kd);
            
            % Kapalı çevrim transfer fonksiyonu
            T = feedback(C*G, 1);
            
            % Performans metriklerini hesapla
            info = stepinfo(T);
            settling = info.SettlingTime;
            overshoot = info.Overshoot;
            
            % Sonuçları kaydet
            results = [results; Kp, Ki, Kd, settling, overshoot];
        end
    end
end

% Sonuçları tabloya dönüştür
results_table = array2table(results, 'VariableNames', {'Kp', 'Ki', 'Kd', 'SettlingTime', 'Overshoot'});

% Kriterleri karşılayan sonuçları filtrele
valid_results = results_table(results_table.SettlingTime <= 10 & results_table.Overshoot <= 10, :);

% Yerleşme süresine göre sırala
valid_results = sortrows(valid_results, 'SettlingTime');

% Kriterleri karşılayan parametre setlerini göster
if height(valid_results) > 0
    fprintf('\nKriterleri karşılayan parametre setleri bulundu!\n');
    fprintf('En iyi 5 parametre seti:\n');
    disp(valid_results(1:min(5, height(valid_results)), :));
    
    % En iyi parametre seti ile sistem cevabı
    best_row = valid_results(1, :);
    C_best = pid(best_row.Kp, best_row.Ki, best_row.Kd);
    T_best = feedback(C_best*G, 1);
    
    figure;
    step(T_best);
    title(sprintf('En İyi PID Parametreleri (Kp=%.2f, Ki=%.2f, Kd=%.2f)', ...
        best_row.Kp, best_row.Ki, best_row.Kd));
    xlabel('Zaman (s)');
    ylabel('Genlik');
    grid on;
    
    % Performans metriklerini göster
    info = stepinfo(T_best);
    text(max(info.SettlingTime)*0.6, 0.5, sprintf('Yerleşme Süresi: %.2f s\nAşma Miktarı: %.2f%%', ...
        info.SettlingTime, info.Overshoot));
    
    % Grafiği kaydet
    saveas(gcf, 'En_Iyi_PID_Parametreleri.png');
else
    fprintf('\nKriterleri karşılayan parametre seti bulunamadı.\n');
    fprintf('Kriterlere en yakın 5 parametre seti:\n');
    
    % Yerleşme süresi ve aşma miktarına göre sırala
    % (Her iki kritere göre ağırlıklı sıralama)
    results_table.Score = (results_table.SettlingTime / 10) + (results_table.Overshoot / 10);
    sorted_results = sortrows(results_table, 'Score');
    disp(sorted_results(1:5, :));
    
    % En iyi yaklaşık parametre seti ile sistem cevabı
    best_row = sorted_results(1, :);
    C_best = pid(best_row.Kp, best_row.Ki, best_row.Kd);
    T_best = feedback(C_best*G, 1);
    
    figure;
    step(T_best);
    title(sprintf('En İyi Yaklaşık PID Parametreleri (Kp=%.2f, Ki=%.2f, Kd=%.2f)', ...
        best_row.Kp, best_row.Ki, best_row.Kd));
    xlabel('Zaman (s)');
    ylabel('Genlik');
    grid on;
    
    % Performans metriklerini göster
    info = stepinfo(T_best);
    text(max(info.SettlingTime)*0.6, 0.5, sprintf('Yerleşme Süresi: %.2f s\nAşma Miktarı: %.2f%%', ...
        info.SettlingTime, info.Overshoot));
    
    % Grafiği kaydet
    saveas(gcf, 'En_Iyi_Yaklasik_PID_Parametreleri.png');
end
%% 4. Simulink Modeli Sonuçlarının Analizi
% Simulink modelinden elde edilen sonuçları analiz ediyoruz

% Simulink modelini çalıştır
sim('PID_Control_System.slx');

% Simulink sonuçlarını çiz
figure;
plot(simout.time, simout.signals.values, 'b-', 'LineWidth', 2);
title('Simulink: PID Kontrollü Sistem Adım Cevabı');
xlabel('Zaman (s)');
ylabel('Çıkış');
grid on;

% Performans metriklerini hesapla ve göster
info = stepinfo(simout.signals.values, simout.time);
fprintf('\nSimulink Modeli Performans Metrikleri:\n');
fprintf('Yerleşme Süresi: %.2f s\n', info.SettlingTime);
fprintf('Aşma Miktarı: %.2f%%\n', info.Overshoot);
fprintf('Yükselme Süresi: %.2f s\n', info.RiseTime);
fprintf('Tepe Değeri: %.4f\n', info.Peak);
fprintf('Tepe Zamanı: %.2f s\n', info.PeakTime);

% Grafiğe performans metriklerini ekle
text(max(simout.time)*0.6, 0.5, sprintf('Yerleşme Süresi: %.2f s\nAşma Miktarı: %.2f%%', ...
    info.SettlingTime, info.Overshoot));

% Grafiği kaydet
saveas(gcf, 'Simulink_PID_Kontrollu_Sistem.png');

%% 5. Sonuçların Yorumlanması ve Özetlenmesi
fprintf('\n==================================================\n');
fprintf('PID KONTROLCÜ TASARIM ÖZETİ\n');
fprintf('==================================================\n');
fprintf('Verilen Transfer Fonksiyonu: G(s) = 1/(s² + 10s + 5)\n\n');

fprintf('Kontrolsüz Sistem Performansı:\n');
fprintf('- Yerleşme Süresi: %.2f s\n', stepinfo(G).SettlingTime);
fprintf('- Aşma Miktarı: %.2f%%\n\n', stepinfo(G).Overshoot);

fprintf('En İyi PID Parametreleri:\n');
fprintf('- Kp = %.2f\n', best_row.Kp);
fprintf('- Ki = %.2f\n', best_row.Ki);
fprintf('- Kd = %.2f\n\n', best_row.Kd);

fprintf('PID Kontrollü Sistem Performansı:\n');
fprintf('- Yerleşme Süresi: %.2f s (Hedef: ≤ 10 s)\n', info.SettlingTime);
fprintf('- Aşma Miktarı: %.2f%% (Hedef: ≤ 10%%)\n\n', info.Overshoot);

if info.SettlingTime <= 10 && info.Overshoot <= 10
    fprintf('SONUÇ: Tasarlanan PID kontrolcü, belirlenen performans kriterlerini KARŞILIYOR.\n');
else
    fprintf('SONUÇ: Tasarlanan PID kontrolcü, belirlenen performans kriterlerine YAKLAŞTI ancak tam olarak karşılamıyor.\n');
    fprintf('       Daha kapsamlı bir parametre araması veya farklı bir kontrol yapısı denenebilir.\n');
end
fprintf('==================================================\n');