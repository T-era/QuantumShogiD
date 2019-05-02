PROGRAM = qss

$(PROGRAM):
	dub build

run: $(PROGRAM)
	cd /var/service/
	dub run

install:
	mkdir -p -m 755 /var/service/qss/
	cp qss /var/service/qss/
	cp -r public/ /var/service/qss/public
	cp qss_start.sh /var/service/qss/
	chmod a+x /var/service/qss/qss_start.sh
	cp misc/systemd/qss.service /etc/systemd/system/qss.service
