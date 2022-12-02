avra prueba.asm
rm prueba.cof
rm prueba.eep.hex
rm prueba.obj
avrdude -C/etc/avrdude.conf -v -patmega328p -carduino -P/dev/ttyUSB0 -b57600 -D -Uflash:w:prueba.hex:i
