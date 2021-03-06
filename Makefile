.PHONY: build woot link usb default update
.SILENT: usb

CURR_HEAD   := $(firstword $(shell git show-ref | cut -b -6) master)
REL_DIR     := releases/${CURR_HEAD}
SCAD_FILE   := $(firstword $(shell ls *.scad))
NAME        := $(shell basename ${SCAD_FILE} .scad)
CURDIR      := $(shell pwd)
DRIVE       := UNTITLED
TIME        := $(shell date +%s)
# $(shell basename $(df -lH | grep "/Volumes/*"  | awk '{print $NF}'))

NO_COLOR=\x1b[0m
OK_COLOR=\x1b[32;01m
ERROR_COLOR=\x1b[31;01m
WARN_COLOR=\x1b[33;01m

default: build usb

build: link default.cfg
	openscad -o ${REL_DIR}/${NAME}.stl -D 'version="${CURR_HEAD}"' -D 'quality="production"' ${SCAD_FILE}
	openscad -o ${REL_DIR}/${NAME}.png -D 'version="${CURR_HEAD}"' -D 'quality="production"' ${SCAD_FILE}
	/Applications/FlashPrint.app/Contents/MacOS/engine/ffslicer.exe --model file:./current/${NAME}.stl -G ${REL_DIR}/${NAME}.gx -C default.cfg

link:
	mkdir -p ${REL_DIR}
	rm -rf current; ln -s ${REL_DIR} current

usb:
	# Prep USB
	ls /Volumes/${DRIVE} || echo "${ERROR_COLOR}Error: Cannot find USB Drive '${DRIVE}' ${NO_COLOR}"
	mkdir -p /Volumes/${DRIVE}/all
	rm -rf /Volumes/${DRIVE}/next
	mkdir -p /Volumes/${DRIVE}/next
	cp current/${NAME}.gx /Volumes/${DRIVE}/all/${NAME}_${CURR_HEAD}.gx
	cp current/${NAME}.gx /Volumes/${DRIVE}/next/${NAME}_${CURR_HEAD}.gx


default.cfg:
	wget https://gist.githubusercontent.com/nstielau/5fa94abc9920e9fbaf90ee26186f4c03/raw/5d17f5147532610b128f2861514c39bc0e822d17/default.cfg


update:
	wget https://raw.githubusercontent.com/nstielau/openscad-boilerplate/master/Makefile?${TIME} -O Makefile
	wget https://raw.githubusercontent.com/nstielau/openscad-boilerplate/master/.gitignore?${TIME} -O .gitignore
	
