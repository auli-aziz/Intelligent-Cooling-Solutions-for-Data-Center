# Intelligent-Cooling-Solutions-for-Data-Center

Sebuah sistem pendinginan otomatis yang cerdas dan efisien yang dapat mengatasi permasalahan pemborosan energi dengan cara memperhatikan variasi suhu pada lingkungan pusat data. Sistem ini akan mengukur suhu yang ada di lingkungan sekitar dan akan menentukan apakah sistem pendingin harus dinyalakan atau tidak. Selain itu akan ada tiga buah led sebagai indikator rentang suhu berapa yang sedang ada di lingkungan sekitar.

# Component Used

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

# How does it works

Pertama - tama, sensor DHT11 akan melakukan pengukuran suhu yang ada di lingkungan sekitar. Setelah itu hasil pengukuran tersebut akan diolah oleh arduino. Hasil pengukuran tersebut akan di bandingkan dengan range suhu yang telah ditentukan sebelumnya untuk menentukan apakah suhu di lingkungan sekitar masuk dalam kategori panas, normal, ataupun dingin. LED yang sesuai dengan kategori tersebut akan menyala dan menjadi indikator pada level mana suhu sedang berada. Hasil pengukuran suhu tersebut juga akan ditampilkan pada LCD. Jika suhu di lingkungan sekitar masuk dalam kategori panas, motor DC juga akan otomatis menyala.

