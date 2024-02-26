FVERSION=../../VERSION
FDEPEND=DEPENDENCY

CTN=`which podman >/dev/null 2>&1 && echo podman || echo docker`
IMAGENAME="fusioniam-lemonldap-ng"
VDEPEND=`cat $(FDEPEND)`
VVERSION=`cat $(FVERSION)`


all: 
	make -B llng

clean:
	$(CTN) rmi -f $(IMAGENAME):$(VVERSION)

llng:
	$(CTN) build --build-arg DEPEND="$(VDEPEND)" --build-arg VERSION="$(VVERSION)" -t $(IMAGENAME):$(VVERSION) .

