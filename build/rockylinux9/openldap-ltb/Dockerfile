ARG DEPEND
ARG VERSION

FROM $DEPEND:$VERSION

EXPOSE 33389 33636

COPY ansible/ ./

RUN bash ./run-playbook.sh install.yaml &&\
    rm -f install.yaml

USER fusioniam
