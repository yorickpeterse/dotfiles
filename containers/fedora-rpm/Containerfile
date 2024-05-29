FROM registry.fedoraproject.org/fedora-toolbox:40

RUN echo 'max_parallel_downloads=10' | sudo tee --append /etc/dnf/dnf.conf
RUN sudo dnf install fish dnf5 dnf5-plugins --assumeyes --quiet
RUN sudo dnf5 update --assumeyes --quiet

COPY coprs.txt /
RUN for repo in $(<coprs.txt); \
    do \
        sudo dnf5 copr enable --assumeyes --quiet \
            "copr.fedorainfracloud.org/$repo"; \
    done
RUN rm coprs.txt

COPY packages.txt /
RUN sudo dnf5 install --assumeyes --quiet $(<packages.txt)
RUN rm packages.txt

RUN dnf5 clean all

ENV CONTAINER_ID fedora-rpm
