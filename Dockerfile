FROM ubuntu:16.04

RUN apt-get update -y 
RUN apt-get upgrade -y 
RUN apt-get autoremove -y

RUN apt-get install -y --no-install-recommends \
        build-essential \
        cpio \
	wget \
        curl \
        git \
	vim \
        lsb-release \
        pciutils \
        python3.5 \
        python3.5-dev \
        python3-pip \
        python3-setuptools \
        sudo

RUN mkdir -p /openvino/

RUN mkdir -p /src/

WORKDIR /openvino

ARG vino_version=l_openvino_toolkit_p_2019.2.242

RUN wget http://pretrained-models.auth-18b62333a540498882ff446ab602528b.storage.gra5.cloud.ovh.net/software/openvino/${vino_version}.tgz

RUN tar -zxf ${vino_version}.tgz

RUN mv ${vino_version}/* /openvino

ARG INSTALL_DIR=/opt/intel/openvino 

# installing OpenVINO dependencies
RUN sh install_openvino_dependencies.sh

RUN pip3 install numpy

# installing OpenVINO itself
RUN sed -i 's/decline/accept/g' silent.cfg && \
 	./install.sh --silent silent.cfg

# Model Optimizer
RUN cd $INSTALL_DIR/deployment_tools/model_optimizer/install_prerequisites && \
    ./install_prerequisites.sh

WORKDIR /src
# clean up
RUN apt autoremove -y && \
    rm -rf /openvino /var/lib/apt/lists/*

RUN /bin/bash -c "source $INSTALL_DIR/bin/setupvars.sh"

RUN echo "source $INSTALL_DIR/bin/setupvars.sh" >> /root/.bashrc

WORKDIR /opt/intel/openvino/deployment_tools/demo
CMD ["/bin/bash"]
