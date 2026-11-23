# apt-n900: a friendly `apt` command over apt-get/apt-cache (a shell script). Targets and conventions: ../../mk/app.mk
override APP     := apt-n900
VERSION ?= 0.3
RUN_CMD := apt --help
REV     ?= 1maemo1
include ../../mk/app.mk
