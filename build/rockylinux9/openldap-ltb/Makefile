FVERSION=../../VERSION
FDEPEND=DEPENDENCY

CTN=`which podman >/dev/null 2>&1 && echo podman || echo docker`
IMAGENAME="fusioniam-openldap-ltb"
VDEPEND=`cat $(FDEPEND)`
VVERSION=`cat $(FVERSION)`


all: 
	make -B openldap

clean:
	$(CTN) rmi -f $(IMAGENAME):$(VVERSION)

openldap:
	$(CTN) build --build-arg DEPEND="$(VDEPEND)" --build-arg VERSION="$(VVERSION)" -t $(IMAGENAME):$(VVERSION) .

