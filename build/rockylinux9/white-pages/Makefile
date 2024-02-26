FVERSION=../../VERSION
FDEPEND=DEPENDENCY

CTN=`which podman >/dev/null 2>&1 && echo podman || echo docker`
IMAGENAME="fusioniam-white-pages"
VDEPEND=`cat $(FDEPEND)`
VVERSION=`cat $(FVERSION)`


all: 
	make -B whitepages

clean:
	$(CTN) rmi -f $(IMAGENAME):$(VVERSION)

whitepages:
	$(CTN) build --build-arg DEPEND="$(VDEPEND)" --build-arg VERSION="$(VVERSION)" -t $(IMAGENAME):$(VVERSION) .

