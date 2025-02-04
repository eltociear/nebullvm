ARG STARTING_IMAGE=nvidia/cuda:11.7.1-cudnn8-devel-ubuntu20.04
FROM ${STARTING_IMAGE}

# Set frontend as non-interactive
ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get -y update && apt-get -y upgrade

# Install python and pip
RUN apt-get install -y python3-opencv python3-pip && \
    python3 -m pip install --upgrade pip && \
    apt-get -y install git && \
    apt-get -y install python-is-python3

# Install other libraries
RUN apt-get install -y sudo wget

# Install pytorch
RUN pip3 install torch torchvision --extra-index-url https://download.pytorch.org/whl/cu117

# Install nebullvm
ARG NEBULLVM_VERSION=latest
RUN if [ "$NEBULLVM_VERSION" = "latest" ] ; then \
        # pip install nebullvm ; \
        pip install git+https://github.com/nebuly-ai/nebullvm.git ; \
    else \
        pip install nebullvm==${NEBULLVM_VERSION} ; \
    fi

# Install required python modules
RUN pip install cmake

# Install default deep learning compilers
ARG COMPILER=all
ENV NO_COMPILER_INSTALLATION=1
RUN if [ "$COMPILER" = "all" ] ; then \
        python3 -c "python -m nebullvm.installers.auto_installer --frameworks torch onnx tensorflow huggingface --compilers all" ; \
    elif [ "$COMPILER" = "tensorrt" ] ; then \
        python3 -c "python -m nebullvm.installers.auto_installer --frameworks torch onnx tensorflow huggingface --compilers tensorrt" ; \
    elif [ "$COMPILER" = "openvino" ] ; then \
        python3 -c "python -m nebullvm.installers.auto_installer --frameworks torch onnx tensorflow huggingface --compilers openvino" ; \
    elif [ "$COMPILER" = "onnxruntime" ] ; then \
        python3 -c "python -m nebullvm.installers.auto_installer --frameworks torch onnx tensorflow huggingface --compilers onnxruntime" ; \
    fi

# Install TVM
RUN if [ "$COMPILER" = "all" ] || [ "$COMPILER" = "tvm" ] ; then \
        python3 -c "from nebullvm.installers.installers import install_tvm; install_tvm()" ; \
        python3 -c "from tvm.runtime import Module" ; \
    fi
