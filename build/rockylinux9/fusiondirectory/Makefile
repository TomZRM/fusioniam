FVERSION=../../VERSION
FDEPEND=DEPENDENCY

CTN=`which podman >/dev/null 2>&1 && echo podman || echo docker`
IMAGENAME="fusioniam-fusiondirectory"
VDEPEND=`cat $(FDEPEND)`
VVERSION=`cat $(FVERSION)`


all: 
	make -B fusiondirectory

clean:
	$(CTN) rmi -f $(IMAGENAME):$(VVERSION)

fusiondirectory:
	$(CTN) build --build-arg DEPEND="$(VDEPEND)" --build-arg VERSION="$(VVERSION)" -t $(IMAGENAME):$(VVERSION) .

