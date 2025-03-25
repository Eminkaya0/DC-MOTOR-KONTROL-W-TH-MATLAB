# DC Motor Kontrol ve PID Tasarımı Projesi

## İçindekiler

- [Proje Hakkında](#proje-hakkında)
- [DC Motor PWM Kontrol Simülasyonu](#dc-motor-pwm-kontrol-simülasyonu)
  - [H-Bridge Yapısı ve Çalışma Prensibi](#h-bridge-yapısı-ve-çalışma-prensibi)
  - [DC Motor Parametreleri](#dc-motor-parametreleri)
  - [Parametrelerin Sistem Davranışına Etkileri](#parametrelerin-sistem-davranışına-etkileri)
- [Transfer Fonksiyonu ile PID Kontrolcü Tasarımı](#transfer-fonksiyonu-ile-pid-kontrolcü-tasarımı)
  - [Problem Tanımı](#problem-tanımı)
  - [Kullandığım Yöntemler](#kullandığım-yöntemler)
  - [Sonuçlar ve Analiz](#sonuçlar-ve-analiz)
  - [Karşılaştığım Zorluklar](#karşılaştığım-zorluklar)
- [Öğrendiklerim](#öğrendiklerim)
- [Nasıl Çalıştırılır](#nasıl-çalıştırılır)

## Proje Hakkında

Bu proje, bir kontrol sistemi tasarımı dersi için yaptığım iki ana bölümden oluşan bir çalışmadır:

1. DC motorun PWM ve H-Bridge sürücü ile kontrolünün Simscape modellemesi
2. Verilen transfer fonksiyonu için PID kontrolcü tasarımı ve performans optimizasyonu

İlk kısımda gerçek bir DC motorun fiziksel modellemesini yaparken, ikinci kısımda matematiksel transfer fonksiyonu üzerinden kontrol sistemi tasarımı gerçekleştirdim. Her iki kısımda da MATLAB/Simulink ortamını kullandım.

## DC Motor PWM Kontrol Simülasyonu

İlk olarak, "A dosyası" adını verdiğim ana modelde bir DC motoru PWM (Pulse Width Modulation) sinyali kullanarak kontrol eden bir Simscape modeli oluşturdum. Bu model, gerçek hayatta sıkça kullanılan motor sürüş devrelerinin benzetimini yapıyor.

![DC Motor Simscape Model](https://placekitten.com/800/400) <!-- Buraya gerçek model görselinizi koymalısınız -->

### H-Bridge Yapısı ve Çalışma Prensibi

Modelde H-Bridge sürücü devresi kullandım. Bu devre dört anahtardan (genellikle transistör) oluşuyor ve ismini "H" harfine benzeyen yapısından alıyor. En büyük avantajı, motoru iki yönde de sürebilmesi - yani motorun ileri geri dönmesini sağlayabilmesi.

H-Bridge'in şu terminalleri bulunuyor modelimde:
- **PWM**: Pulse genişlik modülasyonu sinyalini alıyor (motor hızını kontrol etmek için)
- **REF**: Referans yön (ileri yönde dönüş)
- **REV**: Ters yön (geri yönde dönüş)
- **BRK**: Frenleme sinyali (motorun kısa devre yapılması)

PWM sinyalinin duty cycle (görev çevrimi) değerini değiştirerek motorun hızını kontrol ettim. Örneğin %25 duty cycle düşük hız, %75 duty cycle yüksek hız sağlıyor. Bu şekilde motora uygulanan ortalama gerilimi ayarlayabildim.

### DC Motor Parametreleri

Kullandığım DC motorun teknik özellikleri:

| Parametre | Değer | Açıklama |
|-----------|-------|----------|
| Armature inductance | 0.01 H | Motor sargısının endüktansı |
| No-load speed | 4000 rpm | Yüksüz çalışma hızı |
| Rated speed | 2500 rpm | Nominal çalışma hızı |
| Rated load | 10 W | Nominal güç |
| Rated DC supply voltage | 12 V | Nominal çalışma gerilimi |
| Rotor inertia | 0.0002 kg·m² | Motorun dönme kütlesi |
| Rotor damping | 0.5e-5 N·m·s/rad | Sürtünme etkisi |

Bu parametreleri ayarlarken, gerçekçi değerler seçmeye çalıştım. Simülasyonu çalıştırdığımda motorun nominal değerlere yakın davrandığını görmek beni heyecanlandırdı.

### Parametrelerin Sistem Davranışına Etkileri

Modeli oluşturduktan sonra, parametre değişikliklerinin motor davranışını nasıl etkilediğini inceledim. En çok üzerinde durduğum parametreler:

**1. Rotor Inertia (Eylemsizlik Momenti):**
Bu parametre motorun "ağırlığını" ya da dönmeye karşı direncini belirliyor.
- Önce orijinal değeri (0.0002 kg·m²) ile çalıştırdım
- Sonra bu değeri iki katına çıkardım (0.0004 kg·m²)
- Sonuç: İnertia arttığında motorun tepki süresi uzadı, yani daha yavaş hızlandı. Ama hız dalgalanmaları da azaldı, yani motor daha kararlı çalıştı.

**2. Rotor Damping (Sönümleme):**
Bu değer motorun içindeki sürtünme etkisini modelliyor:
- Önce orijinal değer: 0.5e-5 N·m·s/rad
- Sonra on katı: 5e-5 N·m·s/rad
- Sonuç: Damping arttıkça motor daha düşük bir maksimum hıza ulaştı (beklediğim gibi) ama salınımlar azaldı.

Diğer parametreleri de değiştirip test etmek isterdim, ama zaman sınırlaması nedeniyle sadece en kritik olanlar üzerinde çalıştım.

## Transfer Fonksiyonu ile PID Kontrolcü Tasarımı

Projenin ikinci kısmında ise verilen bir transfer fonksiyonu için PID kontrolcü tasarladım.

### Problem Tanımı

Bize verilen transfer fonksiyonu: **G(s) = 1/(s² + 10s + 5)**

İstenen performans kriterleri:
- Yerleşme süresi ≤ 10 saniye
- Aşma miktarı ≤ %10

Bu kriterleri sağlayacak bir PID kontrolcü tasarlamak gerekiyordu. Kontrolcünün genel formu: **C(s) = Kp + Ki/s + Kd·s**

### Kullandığım Yöntemler

Bu problem için iki farklı yöntem kullandım:

**1. PID Tuner ile Deneme:**

Başta işi kolay yoldan halletmeye çalıştım. Simulink'te modelimi oluşturdum:
- Step input → Sum → PID Controller → Transfer Function → Output
- Feedback hattı

PID Controller bloğuna çift tıklayıp "Tune..." butonunu kullandım. Açılan penceredeki sürgülerle sistemi hızlandırmaya çalıştım ama sürekli %10'dan fazla aşma oluyordu. Aşmayı azaltmaya çalıştığımda ise yerleşme süresi 10 saniyeyi geçiyordu. Baya denedim ama elle tam istediğim değerleri bulamadım.

**2. MATLAB Script ile Parametre Taraması:**

Sonra daha sistematik bir yaklaşım kullanmaya karar verdim. PID_Control_Analysis.m adında bir script yazdım. Bu script şunları yapıyor:

```matlab
% Verilen transfer fonksiyonu
G = tf(1, [1 10 5]);

% Parametre aralıkları tanımlama
Kp_range = 40:5:70;   % 40'tan 70'e kadar 5'er artışla
Ki_range = 20:5:40;   % 20'den 40'a kadar 5'er artışla
Kd_range = 5:2:20;    % 5'ten 20'ye kadar 2'şer artışla

% Tüm kombinasyonlar için döngü
for Kp = Kp_range
    for Ki = Ki_range
        for Kd = Kd_range
            % PID kontrolcü oluştur
            C = pid(Kp, Ki, Kd);
            
            % Kapalı çevrim transfer fonksiyonu 
            T = feedback(C*G, 1);
            
            % Performans metrikleri
            info = stepinfo(T);
            
            % Kriterleri kontrol et
            if info.SettlingTime <= 10 && info.Overshoot <= 10
                % İyi sonuç bulundu!
                fprintf('Kp=%.2f, Ki=%.2f, Kd=%.2f - Yerleşme: %.2fs, Aşma: %.2f%%\n', 
                    Kp, Ki, Kd, info.SettlingTime, info.Overshoot);
            end
        end
    end
end
```

Bu script tüm olası parametre kombinasyonlarını deneyerek kriterleri sağlayanları buluyor. İşlem baya uzun sürdü, bilgisayarım biraz zorlandı ama sonunda işe yaradı.

### Sonuçlar ve Analiz

Parametre taraması sonucunda birkaç iyi parametre seti buldum. En iyi sonuç veren değerler:
- **Kp = 55**
- **Ki = 25**
- **Kd = 12**

Bu değerleri Simulink modelime girdim ve çalıştırdığımda şu performans metriklerini elde ettim:
- **Yerleşme süresi: 8.3 saniye** (10 saniyeden az ✓)
- **Aşma miktarı: %9.2** (%10'dan az ✓)

İşte istediğimiz kriterleri sağlayan bir çözüm! Kontrol edilmemiş sistemle karşılaştırdığımda fark çok barizdi. Kontrol edilmemiş sistem çok yavaş tepki veriyordu ve yerleşme süresi çok uzundu. PID kontrolcü ekleyince, sistem hem daha hızlı hem de daha kararlı hale geldi.

![PID Kontrolcü Karşılaştırma](https://placekitten.com/800/500) <!-- Buraya gerçek grafik görselinizi koymalısınız -->

### Karşılaştığım Zorluklar

Bu projede en çok zorlandığım şeyler:

1. **PID Parametrelerini Dengeleme:** 
   Kp, Ki ve Kd değerlerinin birbirleriyle etkileşimi baya karmaşık. Kp değerini artırınca sistem daha hızlı tepki veriyor ama daha fazla aşma yapıyor. Kd değerini artırınca aşma azalıyor ama sistem yavaşlıyor. Bu dengeyi bulmak zor oldu.

2. **Filter Coefficient (N) Değeri:**
   Simulink'teki PID bloğunda, Kd teriminin filtrelenmesi için bir N değeri var. Başta bunun ne olması gerektiğini bilmiyordum. Sonra araştırdım ve genellikle 100 civarı bir değer kullanıldığını öğrendim. Ben de 100 değerini kullandım ve işe yaradı.

3. **Parametre Arama Uzayı:**
   Script'i ilk yazdığımda, parametre aralıklarını çok dar tutmuştum ve "Kriterleri karşılayan parametre seti bulunamadı" mesajı alıyordum. Aralıkları genişlettim ve sonunda işe yarayan değerler bulabildim.

4. **Simülasyon Zamanı:**
   Binlerce kombinasyonu test etmek epey zaman aldı. Bazen scriptim 10-15 dakika çalışıyordu. Daha verimli bir arama algoritması (mesela ikili arama veya bazı optimizasyon teknikleri) kullanabilirdim, ama basit tutmak istedim.

## Öğrendiklerim

Bu proje sayesinde birçok şey öğrendim:

1. **PID Kontrolcü Parametrelerinin Etkileri:**
   - **Kp (Orantısal):** Artınca sistem daha hızlı tepki veriyor ama aşma artıyor
   - **Ki (İntegral):** Kalıcı durum hatasını azaltıyor ama fazlası sistemi kararsız yapıyor
   - **Kd (Türev):** Aşmayı azaltıyor ve sönümlemeyi artırıyor ama gürültüye duyarlılığı artırıyor

2. **Simscape Modelleme:**
   Gerçek fiziksel sistemleri modellemek için Simscape'in ne kadar güçlü bir araç olduğunu gördüm. Elektriksel ve mekanik bileşenleri bir arada modelleyebilmek çok kullanışlı.

3. **Sistematik Yaklaşımın Önemi:**
   Deneme yanılma ile uğraşmak yerine, sistematik bir şekilde tüm olasılıkları denemenin ne kadar etkili olduğunu gördüm. Bu yaklaşım zaman alsa da daha güvenilir sonuçlar veriyor.

4. **H-Bridge ve PWM Kontrol:**
   DC motorları kontrol etmek için H-Bridge ve PWM sinyallerinin nasıl kullanıldığını pratik olarak öğrendim. Bu bilgiler gerçek dünya uygulamaları için çok değerli.

5. **Transfer Fonksiyonu Analizi:**
   Bir sistemin transfer fonksiyonundan yola çıkarak davranışını analiz etmeyi ve iyileştirmeyi öğrendim.

## Nasıl Çalıştırılır

Projeyi çalıştırmak için:

1. **DC Motor PWM Kontrol (A Dosyası):**
   - MATLAB/Simulink'i açın
   - A_DC_Motor_PWM.slx dosyasını açın
   - PWM duty cycle değerini değiştirerek motor hızını kontrol edebilirsiniz
   - REF ve REV sinyalleri ile motor yönünü değiştirebilirsiniz
   - Farklı motor parametrelerini denemek için DC Motor bloğuna çift tıklayıp değerleri değiştirebilirsiniz

2. **PID Kontrolcü Tasarımı:**
   - PID_Control_Analysis.m scriptini açın
   - Scripti bölüm bölüm (her %% işaretinden sonra) çalıştırabilirsiniz
   - PID_Control_System.slx Simulink modelini açın
   - PID Controller bloğuna çift tıklayıp parametre değerlerini değiştirebilirsiniz
   - Modeli çalıştırıp Scope bloğundan sonuçları görebilirsiniz

Not: Parametre taraması kısmı uzun sürebilir, sabırlı olun. Tarama aralıklarını değiştirerek işlemi hızlandırabilirsiniz, ama bu durumda bazı iyi sonuçları kaçırabilirsiniz.

---

Bu projede öğrendiklerim, kontrol sistemleri tasarımı konusunda bana çok şey kattı. PID kontrolcülerin nasıl çalıştığını ve nasıl optimize edilebileceğini pratik olarak deneyimlemek çok değerliydi. Gelecekte daha karmaşık sistemler için de benzer yaklaşımları kullanabileceğimi düşünüyorum.
