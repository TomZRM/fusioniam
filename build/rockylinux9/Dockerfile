FROM docker.io/library/rockylinux:9-minimal

LABEL app=fusioniam

COPY run.sh /

RUN bash /run.sh ;\
    chmod g=u /etc/passwd /etc/group

COPY run-playbook.sh ./

COPY ansible/ ./

RUN bash ./run-playbook.sh ./install.yaml

COPY run-ct.sh /

ENTRYPOINT ["/usr/bin/tini", "--"]

CMD [ "/bin/bash", "/run-ct.sh"]
