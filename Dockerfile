# ISSW 2026 autoATES v3.0 workshop: the conda env from environment.yml, the two
# library clones (autoATES ISSW snapshot + AvaFrame at the SETUP.md pin) with
# AvaFrame's Cython extensions already built, and JupyterLab on port 8888.
#
#   docker compose up            # see DOCKER.md
#
# Multi-arch (linux/amd64, linux/arm64): Apple Silicon runs it natively.
#
# Two stages: "build" adds compilers + git to compile AvaFrame, then removes them;
# the final image copies only the resulting env and clones (~1 GB smaller).
FROM mambaorg/micromamba:2-debian12-slim AS build

# Activate the env in every RUN below (also runs conda's compiler activation scripts).
ARG MAMBA_DOCKERFILE_ACTIVATE=1

COPY --chown=$MAMBA_USER:$MAMBA_USER environment.yml /tmp/environment.yml
# The workshop env goes into micromamba's base env. Compilers + git are build-only
# extras for the AvaFrame step; they come from conda-forge, so no apt toolchain.
RUN micromamba install -y -n base -f /tmp/environment.yml && \
    micromamba install -y -n base -c conda-forge c-compiler cxx-compiler git && \
    micromamba clean --all --force-pkgs-dirs -y  # micromamba 2 keeps extracted pkgs (3.5 GB) without --force-pkgs-dirs

# Library pins (SETUP.md "Pins"). Full SHAs so a shallow fetch can get them.
ARG AUTOATES_REPO=https://github.com/AutoATES/autoATES-v3.0-issw.git
ARG AUTOATES_REF=5558c16469173cd14725576c1a5a60b7a8e14628
ARG AVAFRAME_REPO=https://github.com/OpenNHM/AvaFrame.git
ARG AVAFRAME_REF=c745a2dec4a7978ac9a8ef100068fae7f6db6d13

USER root
RUN mkdir -p /opt/autoATES-v3.0-issw /opt/AvaFrame && touch /opt/PINS && \
    chown $MAMBA_USER:$MAMBA_USER /opt/autoATES-v3.0-issw /opt/AvaFrame /opt/PINS
USER $MAMBA_USER

RUN set -e; \
    fetch() { git -C "$1" init -q && git -C "$1" fetch -q --depth 1 "$2" "$3" && \
              git -C "$1" checkout -q FETCH_HEAD && rm -rf "$1/.git"; }; \
    fetch /opt/autoATES-v3.0-issw "$AUTOATES_REPO" "$AUTOATES_REF"; \
    fetch /opt/AvaFrame "$AVAFRAME_REPO" "$AVAFRAME_REF"; \
    echo "autoATES-v3.0-issw $AUTOATES_REF" > /opt/PINS; \
    echo "AvaFrame $AVAFRAME_REF" >> /opt/PINS

# com4FlowPy imports DFAfunctionsCython, which a clone only has as .pyx source.
# The MoT-Voellmy warning during this build is expected (the workshop does not use it).
RUN cd /opt/AvaFrame && python setup.py build_ext --inplace && \
    ls avaframe/com1DFA/DFAfunctionsCython*.so && \
    rm -rf build benchmarks docs  # 200 MB of test data + docs the workshop never reads

RUN micromamba remove -y -n base c-compiler cxx-compiler git && \
    micromamba clean --all --force-pkgs-dirs -y && \
    python -c "import avaframe.com1DFA.DFAfunctionsCython" 2>/dev/null || \
    (cd /opt/AvaFrame && python -c "import sys; sys.path.insert(0, '.'); import avaframe.com1DFA.DFAfunctionsCython")

FROM mambaorg/micromamba:2-debian12-slim
COPY --from=build --chown=$MAMBA_USER:$MAMBA_USER /opt/conda /opt/conda
COPY --from=build --chown=$MAMBA_USER:$MAMBA_USER /opt/autoATES-v3.0-issw /opt/autoATES-v3.0-issw
COPY --from=build --chown=$MAMBA_USER:$MAMBA_USER /opt/AvaFrame /opt/AvaFrame
COPY --from=build /opt/PINS /opt/PINS
ARG MAMBA_DOCKERFILE_ACTIVATE=1

# notebooks/workshop.py and check_setup.py look these up before the sibling folders.
# The rest keeps Jupyter/matplotlib/numba writable when the container runs as any uid
# (docker-compose.yml can run it as the host user so bind-mounted files stay yours).
ENV AUTOATES_ROOT=/opt/autoATES-v3.0-issw \
    AVAFRAME_ROOT=/opt/AvaFrame \
    NUMBA_CACHE_DIR=/tmp/numba \
    MPLCONFIGDIR=/tmp/matplotlib \
    IPYTHONDIR=/tmp/ipython \
    JUPYTER_RUNTIME_DIR=/tmp/jupyter-runtime \
    JUPYTER_CONFIG_DIR=/tmp/jupyter-config

RUN python -m ipykernel install --sys-prefix --name autoates-workshop --display-name "autoATES workshop"

# A copy of the repo so the image works without a bind mount; docker-compose.yml
# mounts your clone over it so notebooks and outputs live on your disk.
COPY --chown=$MAMBA_USER:$MAMBA_USER . /workshop
WORKDIR /workshop

EXPOSE 8888
# No token: docker-compose.yml publishes the port on 127.0.0.1 only.
CMD ["jupyter", "lab", "--ip=0.0.0.0", "--port=8888", "--no-browser", \
     "--ServerApp.token=", "--ServerApp.password=", "--ServerApp.root_dir=/workshop"]
