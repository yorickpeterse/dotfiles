FROM quay.io/toolbx-images/opensuse-toolbox:tumbleweed

COPY packages.txt /
RUN sudo zypper --non-interactive --quiet install --force-resolution $(<packages.txt)
RUN rm packages.txt
RUN sudo zypper clean

ENV CONTAINER_ID tumbleweed
