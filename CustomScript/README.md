# CustomScript

# clone_archive1.sh = script untuk mengambil data thread yang akan di archive dari masing2 shards (bukan melalui mongos) dengan method clone (priority low). data yang diambil langsung berupa DB / coll di server tujuan sehingga bisa langsung diakses.
# converter.sh = script untuk merubah format GeoIPCountry menjadi format 1.1.2.0/23 :127.0.0.156:cn
# counter_length_pm.sh = script request dr team product, untuk mengambil rata2 panjang text PM yg dikirim oleh user
# delete_post_archive.sh = script untuk delete post dari thread yg akan di archive dengan mengirim request keseluruh WS secara paralel dengan jumlah instance yg ditentukan.
# delete_thread_archive.sh = script untuk delete thread yg akan diarchive dari server production.
# delete_trxid.sh = script reporting, delete transaksi kaskus donatur yang sudah terproses di report sebelumnya.
# donatur_paket_location.sh = script request dari team marketing untuk mengambil data donatur (total,based on location,grouped per package,seller / active seller, execute manually / system and more *custom request)
# dump_archive1.sh = script pengambilan data archive thread & post dari list thread yg akan diarchive dengan method export/dump
# dump_data_archive.sh = script yg sama dump_archive1.sh, hanya berbeda directory.
# get_engine.sh = script buat ngecek table yg engine-nya innodb di setiap DB pada suatu server.
# get_replies.sh = script untuk menghitung total reply pada suatu thread dalam range waktu tertentu format get_replies.sh 20150101(tanggalstart):7(jamstart) <space> 20150102(tanggalend):7(jamend) <space> threadid
