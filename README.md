# avrdude docker #

avrdude packaged into docker for CI deployment of programming stations targeting AVR platforms, most importantly arduino. 

Use just like avrdude, but map stuff via docker, also provides a ENVAR configuration mechanism with a few goodies


```sh
# get device info from atmega 328 arduino's using usbtiny
$ docker run --rm akshmakov/avrdude -c usbtiny -p m328p
```


Images availables:

 - `latest` `amd64` default image
 - `arm32v6` arm32v6 image for RPI1 (2/3 compat.)
 - `arm32v7` arm32v7 image for RPI2/3

## Usage - Docker

avrdude usage information is reproduced below

```sh
Usage: avrdude [options]
Options:
-p <partno>                Required. Specify AVR device.
-b <baudrate>              Override RS-232 baud rate.
-B <bitclock>              Specify JTAG/STK500v2 bit clock period (us).
-C <config-file>           Specify location of configuration file.
-c <programmer>            Specify programmer type.
-D                         Disable auto erase for flash memory
-i <delay>                 ISP Clock Delay [in microseconds]
-P <port>                  Specify connection port.
-F                         Override invalid signature check.
-e                         Perform a chip erase.
-O                         Perform RC oscillator calibration (see AVR053).
-U <memtype>:r|w|v:<filename>[:format]
Memory operation specification.
Multiple -U options are allowed, each request
is performed in the order specified.
-n                         Do not write anything to the device.
-V                         Do not verify.
-u                         Disable safemode, default when running from a script.
-s                         Silent safemode operation, will not ask you if
fuses should be changed back.
-t                         Enter terminal mode.
-E <exitspec>[,<exitspec>] List programmer exit specifications.
-x <extended_param>        Pass <extended_param> to programmer.
-y                         Count # erase cycles in EEPROM.
-Y <number>                Initialize erase cycle # in EEPROM.
-v                         Verbose output. -v -v for more.
-q                         Quell progress output. -q -q for less.
-l logfile                 Use logfile rather than stderr for diagnostics.
-?                         Display this usage.
```

Any option that can be passed to avrdude can be passed to the container directly.

The following argument options have environment variables that can be used to set them when starting the container

 - `AVRDUDE_BIN`        - avrdude binary (default is system avr)
 - `AVRDUDE_CFG`        - `-C` configuration file ( relative to /workspace/ )
 - `AVRDUDE_PORT`       - `-P` device port       (e.g. usb  )
 - `AVRDUDE_DEVICE`     - `-c` device type       (e.g. m386p)
 - `AVRDUDE_PROGRAMMER` - `-c` Programmer Device (e.g. usbtiny)
 - `AVRDUDE_OPTS`       - Extra Options (e.g. -l) useful for docker-compose
 - `AVRDUDE_VERBOSE`    - `-v` run avrdude in verbose mode, overriden by $AVRDUD_OPTS

The following Extra Envars control the default options

 - `ARDUINO_MODE`       - Run using config from arduino ide instead of system default 
 - `__DEBUG`            - Do not run avrdude, just echo what will be run



### Files/folder/logs

The docker container executes avrdude in the working director `/workdir/` if you wish to persist the result of a read command, logs, or share an output bin with the container you may choose to mount a volume in the container at this location. This is easily managed with docker-compose (see below) but can still easily be done with just `docker`


For example, mount a binary directory and log directory, assuming that `bootloader.bin` exists in bin directory, program and atmega328 (arduino)

```sh
$ docker run --rm \
             -v "$(pwd)/bins:/workdir/bins" \
	     -v "$(pwd)/logs:/workdir/logs" \
	     --device "/dev/bus/usb:/dev/bus/usb" \
	     akshmakov/avrdude \
	     -c usbtiny \
	     -p m328p   \
	     -P usb     \
	     -U flash:w:bins/bootloader.bin
```


	     




## Usage - docker-compose

`docker-compose` can be used to construct pre-determined avrdude operations, useful for Manufacturing and Operations CI/CD (devops)



a sample docker-compose file for a raspberry pi based programmer 

```docker-compose.yml
version: '2'
services:
  base:
    image: akshmakov/avrdude:arm32v6
    devices:
      - "/dev/bus/usb:/dev/bus/usb"
    volumes:
      - "./logs/:
    environment:
      AVRDUDE_DEVICE: m328p
      AVRDUDE_PROGRAMMER: usbtiny
      AVRDUDE_PORT: usb
      AVRDUDE_OPTS: " -l logs/$(date +"%Y%m%d-%H%M%S").log "

  verify:
    extends: base
    command: -U flash:v:bins/bootloader.bin

  program:
    extends: base
    command: -U flash:w:bins/bootloader.bin

```

to execute a programming then verify step

```sh
$ docker-compose run program
$ docker-compose run verify
```




