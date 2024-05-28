# Intelligent-Cooling-Solutions-for-Data-Center

## Introduction to the problem and the solution

Salah satu tantangan utama yang dihadapi oleh pusat data adalah bagaimana menjaga suhu operasional perangkat keras agar tetap dalam batas yang aman dan optimal. Perangkat keras yang terlalu panas dapat menyebabkan kerusakan, kehilangan data, dan downtime. Untuk mengatasi hal ini, pusat data biasanya mengandalkan sistem pendinginan konvensional yang sering kali kurang efisien dan boros energi.

Sebuah sistem pendinginan otomatis yang cerdas dan efisien diperlukan untuk mengatasi permasalahan pemborosan energi dengan cara memperhatikan variasi suhu pada lingkungan pusat data. Sistem ini akan mengukur suhu yang ada di lingkungan sekitar dan akan menentukan apakah sistem pendingin harus dinyalakan atau tidak. Selain itu akan ada tiga buah led sebagai indikator rentang suhu berapa yang sedang ada di lingkungan sekitar.

## Hardware design and implementation details

Pada proyek kali ini kami menggunakan beberapa komponen elektronik sebagai berikut :
- Arduino Uno
- Sensor DHT11
- LCD
- LED 
- Motor DC
- Kabel Jumper
- Breadboard
- Resistor
- Potentiometer

Hardware yang digunakan terdiri dari dua buah Arduino Uno yang mencakup semua pustaka dan logika yang diperlukan untuk mengontrol servo, membaca data dari sensor DHT11, dan menampilkan informasi yang diperoleh dari sensor tersebut pada layar LCD. Data dari sensor DHT11 akan menentukan apakah motor akan dihidupkan atau dimatikan. Kami juga menggunakan tiga LED yang terhubung ke Arduino Uno untuk menunjukkan keadaan sensor suhu saat ini dan berfungsi sebagai tanda fisik utama bahwa pengontrol telah beralih mode.

Dua Arduino Uno ini berfungsi sebagai master dan slave. Master mengontrol LED dan motor berdasarkan data dari sensor DHT11 serta mengirimkan data dari sensor DHT11 ke slave. Master bertugas menampilkan indikator visual berupa LED untuk menandakan rentang suhu secara real-time. Rentang suhu terbagi menjadi tiga kategori: dingin (cold), normal, dan panas (hot). Setiap kondisi diwakili oleh warna LED yang berbeda. Jika suhu yang terbaca termasuk dalam rentang dingin, LED yang menyala adalah LED warna hijau. Jika suhu yang terbaca termasuk dalam rentang normal, LED yang menyala adalah warna kuning. Jika suhu yang terbaca berada dalam rentang panas, LED yang menyala adalah warna merah. Ketiga LED ini tersambung pada PORT D pin 0, 1, dan 2 secara berurutan. Pada saat suhu berada dalam rentang panas, pin 3 dari PORT D akan mengeluarkan output untuk menyalakan motor kipas.

Data yang diterima oleh slave akan ditampilkan pada LCD. Port yang bertanggung jawab untuk mengirimkan data yang ingin ditampilkan adalah PORTD, sedangkan PORTB bertanggung jawab untuk menerima informasi SPI pada pin PB10, PB11, PB13, dan mengirimkan data command pada pin PB8 (RS) dan PB9 (EN).

![image](https://github.com/auli-aziz/Intelligent-Cooling-Solutions-for-Data-Center/assets/65178008/8efe8d3e-c544-4ff2-addc-7f99040154e0)

## Software implementation details

Software dikembangkan menggunakan Arduino IDE dalam bahasa assembly AVR yang digunakan untuk ATMega328p. Kami membuat kode untuk membaca data dari sensor DHT11, mengendalikan LED, dan motor berdasarkan kondisi suhu. Kode ini kemudian diunggah ke Arduino Uno untuk mengatur perilaku hardware sesuai dengan input yang diterima dari sensor suhu.

Program master, yang dinamakan IntelligentCoolingMaster.S, bertanggung jawab untuk membaca input dari sensor DHT11 dan mengirimkannya ke Arduino slave atau IntelligentCoolingSlave.S dengan protokol SPI. Di awal program, master akan menginisialisasi SPI dengan mengatur MOSI, SCK, dan SS sebagai output pada PORT B dan mengaktifkan SPI sebagai master dengan clock frequency fosc/8, dan SPI mode 0. Sementara itu, semua bagian PORT D dijadikan sebagai output.
Tahap berikutnya adalah memanggil delay selama 2 detik untuk menunggu DHT11 menyala. Sensor ini akan di-input ke PORT C pada pin A0. Komunikasi dengan DHT11 dimulai dengan mengirimkan sinyal start yang terdiri dari low pulse dan high pulse secara berurutan. Program kemudian akan menunggu sinyal respons dari sensor dan memanggil subroutine DHT11_reading sebanyak tiga kali untuk mengabaikan dua byte pertama. Setelah data diperoleh dari sensor, data tersebut akan dikirimkan ke slave. Data ini disimpan dalam register R18. Nilai dari register ini kemudian dibandingkan untuk menentukan rentang suhu yang terbaca saat ini.

Dalam setiap kondisinya, program akan menyalakan pin sesuai dengan rentang suhu yang terbaca. Misalnya, jika suhu yang terbaca berada dalam rentang 30 derajat Celsius ke atas, program akan mengatur PD2 dan PD3 untuk menyalakan LED merah dan menyalakan motor kipas. Selain itu, register R16 akan menyimpan nilai 1 untuk memungkinkan LED berkedip dengan memanggil subroutine blink sebanyak lima kali setelah melakukan branching ke label continue.

Di sisi lain, di bagian slave, data yang diterima dari master disimpan dalam register R18. Di slave, kami melakukan inisialisasi perangkat sebagai slave dan menginisialisasi LCD terlebih dahulu dengan memanggil subroutine command_wrt. Subroutine ini berfungsi untuk mengirimkan perintah ke LCD berdasarkan nilai yang tersimpan di R16. Semetara, subroutine yang bertanggung jawab untuk menampilkan data adalah data_wrt. Sumber datanya berasala dari register yang sama, yaitu R16. Data yang ditampilkan dari DHT11 adalah data suhu dalam bentuk desimal.

Secara keseluruhan flowchart dari program akan terlihat seperti sebagai berikut:
![image](https://github.com/auli-aziz/Intelligent-Cooling-Solutions-for-Data-Center/assets/65178008/08698ff5-898e-413e-9fc4-204da8855284)

Adapun, langkah-langkahnya adalah:
1. Inisialisasi sistem dan perangkat keras.
2. Membaca data suhu dari sensor DHT11.
3. Menampilkan data suhu pada LCD.
4. Mengendalikan LED berdasarkan kondisi suhu:
  - Jika suhu di bawah 25°C, LED hijau menyala.
  - Jika suhu antara 25°C dan 30°C, LED kuning menyala.
  - Jika suhu di atas 30°C, LED merah menyala.
5. Mengendalikan motor kipas:
  - Jika suhu di atas 30°C, motor kipas menyala.
  - Jika suhu di bawah 30°C, motor kipas mati.

## Test results and performance evaluation

Hasil pengujian menunjukkan bahwa sistem dapat mendeteksi suhu dengan baik menggunakan sensor DHT11. Suhu yang terdeteksi ditampilkan pada LCD secara real-time. LED berfungsi sebagai indikator suhu, dengan warna yang berbeda menunjukkan tingkat suhu yang berbeda. Motor DC berfungsi dengan baik untuk menjaga suhu dalam rentang yang optimal.

Sistem bekerja sesuai dengan yang diharapkan, dengan pengecualian satu acceptance criteria yang belum terpenuhi, yaitu motor yang tidak dapat berjalan saat suhu berada dalam rentang panas. Masalah ini kemungkinan disebabkan oleh tegangan yang tidak cukup tinggi yang diberikan pada port D dari Arduino. Asumsi ini terbukti benar ketika kami mencoba menyambungkan motor langsung ke ground dan sumber tegangan 5V dari Arduino, di mana motor dapat menyala dan berjalan secara normal. Hal ini menunjukkan bahwa sumber tegangan dari port D tidak cukup untuk menggerakkan motor, yang mungkin disebabkan oleh keterbatasan arus yang dapat disediakan oleh pin I/O Arduino.

![image](https://github.com/auli-aziz/Intelligent-Cooling-Solutions-for-Data-Center/assets/65178008/c54fb294-148e-42c9-980e-a5f7cb4f423b)

## Conclusion and future work

Proyek akhir ini bertujuan untuk mengembangkan solusi pendinginan cerdas bagi pusat data, dengan fokus pada efisiensi energi dan keandalan operasional. Sistem yang kami rancang menggunakan dua buah Arduino Uno yang masing-masing berfungsi sebagai master dan slave. Master bertugas untuk membaca data suhu dari sensor DHT11, mengontrol LED sebagai indikator suhu, dan mengoperasikan motor kipas saat diperlukan. Sementara itu, slave menerima data dari master dan menampilkan informasi suhu pada layar LCD.
Secara keseluruhan, sistem ini bekerja sesuai dengan yang diharapkan. Sebagian besar acceptance criteria terpenuhi. Ini menunjukkan bahwa desain dan implementasi kami sudah cukup efektif. Penggunaan dua Arduino Uno terbukti sangat efektif dalam pembagian tugas dan menangani beban kerja, memastikan bahwa setiap komponen dapat berfungsi dengan optimal tanpa ada beban kerja yang berlebihan pada salah satu unit. Selain itu, indikator visual menggunakan LED memberikan feedback yang jelas tentang kondisi suhu secara real-time.

Namun, terdapat satu acceptance criteria yang belum terpenuhi: motor kipas tidak beroperasi saat suhu berada dalam rentang panas. Analisis kami menunjukkan bahwa masalah ini disebabkan oleh tegangan yang tidak cukup tinggi yang diberikan pada port D dari Arduino. Pengujian lebih lanjut menunjukkan bahwa motor dapat berjalan dengan normal saat dihubungkan langsung ke ground dan sumber tegangan 5V dari Arduino. Untuk menyelesaikan masalah ini, kami mempertimbangkan beberapa solusi, seperti menggunakan relay atau transistor untuk meningkatkan tegangan dan arus yang diterima oleh motor. Dengan menggunakan relay atau transistor, kita dapat memastikan bahwa motor mendapatkan daya yang cukup tanpa membebani pin I/O dari Arduino. Selain itu, kami juga mempertimbangkan untuk menambahkan kapasitor untuk menstabilkan tegangan dan mengurangi fluktuasi yang mungkin terjadi saat motor dinyalakan.
