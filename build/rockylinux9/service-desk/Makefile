FVERSION=../../VERSION
FDEPEND=DEPENDENCY

CTN=`which podman >/dev/null 2>&1 && echo podman || echo docker`
IMAGENAME="fusioniam-service-desk"
VDEPEND=`cat $(FDEPEND)`
VVERSION=`cat $(FVERSION)`


all: 
	make -B servicedesk

clean:
	$(CTN) rmi -f $(IMAGENAME):$(VVERSION)

servicedesk:
	$(CTN) build --build-arg DEPEND="$(VDEPEND)" --build-arg VERSION="$(VVERSION)" -t $(IMAGENAME):$(VVERSION) .

