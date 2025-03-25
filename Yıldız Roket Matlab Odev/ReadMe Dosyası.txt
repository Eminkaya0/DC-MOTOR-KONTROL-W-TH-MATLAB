Deneme2 Sadece simulink ile dc motor simüle etmeye çalıştığım bir çalışmadır. 

A dosyası main dc motor pwm ile kontrolü için tasarlanan simscape modelidir pwm değiştirerek kontrol edilebilir motor

A explained :

H-Bridge, dört anahtardan (genellikle transistör) oluşan ve motorun yönünü kontrol etmeyi sağlayan bir devre yapısıdır. "H" harfine benzeyen yapısından adını alır.

Modelimizdeki H-Bridge:

PWM, REF, REV, BRK terminalleri bulunur
PWM: Pulse genişlik modülasyonu sinyalini alır
REF: Referans yön (ileri)
REV: Ters yön
BRK: Frenleme (motorun kısa devre yapılması)

--------------------------------------------------------
Motorun özellikleri:

Armature inductance: 0.01 H (motor sargısının endüktansı)
No-load speed: 4000 rpm (yüksüz çalışma hızı)
Rated speed: 2500 rpm (nominal çalışma hızı)
Rated load: 10 W (nominal güç)
Rated DC supply voltage: 12 V (nominal çalışma gerilimi)
Rotor inertia: 0.0002 kg·m² (motorun dönme kütlesi)
Rotor damping: 0.5e-5 N·m·s/rad (sürtünme etkisi)

-----------------------------------------------------
Rotor Inertia (Eylemsizlik Momenti)
Bu değer, motoru döndürmek için gereken enerjiyi etkiler:

Düşük değer: Motor hızlı tepki verir ama kararlılığı azalır
Yüksek değer: Motor daha yavaş tepki verir ama daha kararlı çalışır

Örneğin, inertia değerini 0.0002'den 0.0004'e çıkardığımızda, motor hızlanması yavaşlar ancak hız dalgalanmaları azalır.

-----------------------------------------------------------
%%------------- TRANSFER FONKSİYON KLASÖRÜ ------------------


Ne Yapmaya Çalıştım?

Bu projede G(s) = 1/(s² + 10s + 5) transfer fonksiyonu için bir PID kontrolcü tasarlamaya çalıştım. Hocamızın istediği yerleşme süresi en fazla 10 saniye ve aşma miktarı en fazla %10 olacak şekilde ayarlar yapmam gerekiyordu.

----------------------------------------------------

NASIL YAPTIM?

İki farklı yöntem denedim:

1. PID Tuner ile Deneme

İlk başta işi kolay yoldan halletmeye çalıştım. Simulink'te bir model kurdum ve PID Controller bloğuna çift tıklayıp "Tune..." butonunu kullandım. Buradaki sürgülerle biraz oynadım ve sistemi hızlandırmaya çalıştım, ama %10'dan fazla aşma oluyordu sürekli. Biraz daha kurcalayınca aşmayı azaltabildim ama bu sefer de yerleşme süresi 10 saniyeyi geçti. Bayağı uğraştım ama tam istediğim değerleri bulamadım.

2. MATLAB Script ile Parametre Taraması

Sonra dedim ki "ya bu işi düzgün yapalım", bir MATLAB script'i yazdım. Bunu yaparken baya zorlandım çünkü çok fazla parametre kombinasyonu denemek gerekiyordu. Kp, Ki ve Kd değerlerini değiştirerek binlerce farklı kombinasyon test ettim.
Script'te şöyle bir mantık kurdum:

Kp değerlerini 40'tan 70'e kadar 5'er 5'er artırdım
Ki değerlerini 20'den 40'a kadar 5'er 5'er artırdım
Kd değerlerini 5'ten 20'ye kadar 2'şer 2'şer artırdım

Bu biraz zaman aldı tabii, bilgisayar tüm kombinasyonları hesaplarken baya beklettirdi beni. Ama sonunda işe yaradı.

---------------------------------------------------------

NE OLDU?

Parametre taraması sonucunda birkaç iyi değer seti buldum. En iyisi Kp=55, Ki=25, Kd=12 gibi değerlerdi. Bunları Simulink modelime girdim ve çalıştırdım.
İlk başta kontrol edilmemiş sistemi inceledim - baya kötüydü. Yani yerleşme süresi uzun, tepkisi yavaştı. PID ekleyince bayağı iyileşti.

Sonuçta:

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

Yerleşme süresi: 8.3 saniye (10 saniyeden az, yani iyi)
Aşma miktarı: %9.2 (10%'dan az, yani iyi)

İstenen kriterleri karşıladım yani!

----------------------------------------------

ZORLUKLAR

En çok zorlandığım şey parametre değerlerini bulmaktı. Bazen Kp değerini artırınca sistem hızlanıyor ama çok fazla aşma yapıyordu. Kd değerini artırınca aşma azalıyor ama sistem yavaşlıyordu. Bu üç parametreyi dengeli bir şekilde ayarlamak bayağı uğraştırdı beni.
Bir de Simulink modelinde PID bloğunu ayarlarken, Filter coefficient (N) değerinin ne olması gerektiğine karar veremedim ilk başta. Sonra default değer olan 100'ü kullandım ve iyi sonuç verdi.

ÖĞRENDİKLERİM

Bu proje sayesinde PID kontrolcü parametrelerinin sistem davranışını nasıl etkilediğini daha iyi anladım:

Kp artınca sistem daha hızlı tepki veriyor ama daha fazla aşma yapıyor
Ki kalıcı hatayı azaltıyor ama fazlası sistemi kararsız yapıyor
Kd aşmayı azaltıyor ama gürültüyü artırıyor

Bir de parametre değerlerini bulurken sistematik yaklaşımın önemini gördüm. Deneme yanılma ile uğraşacağıma bir script yazıp tüm kombinasyonları denemek çok daha etkili oldu.

-------------------------------------------------------

Not: Script'i çalıştırırken bazen "Kriterleri karşılayan parametre seti bulunamadı" mesajı alıyordum. Bu durumda arama aralığını değiştirip tekrar çalıştırdım. Sonunda iyi çalışan değerler bulabildim.