---
title: "dd"
date: 2020-05-31T15:25:35+03:00
tags:
  - linux 
  - cli
summary: "dd умеет читать побайтово с устройства"
---
### dd
умеет читать побайтово с устройства

#### flags 
* `if` откуда читать
* `of` куда писать
* `bs` сколько бит читать

#### example 
прочитает первые 512 бит диска /dev/sda
```
sudo dd uf=/dev/sda bs=512
```

#### How to calculate read/write speed 
* `dd if=/dev/zero of=~/test.tmp bs=500K count=1024`
* `sync; echo 3 | sudo tee /proc/sys/vm/drop_caches` reset cache
* `dd if=~/test.tmp of=/dev/null bs=500K count=1024` write

