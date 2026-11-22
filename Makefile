# apt-n900: a friendly `apt` command over apt-get/apt-cache (a shell script). Targets and conventions: ../../mk/app.mk
override APP     := apt-n900
VERSION ?= 0.2
RUN_CMD := apt --help
REV     ?= 1maemo3
include ../../mk/app.mk
