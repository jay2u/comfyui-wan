FROM nvidia/cuda:12.6.0-cudnn-devel-ubuntu24.04

ENV DEBIAN_FRONTEND=noninteractive PIP_PREFER_BINARY=1 PYTHONUNBUFFERED=1 CMAKE_BUILD_PARALLEL_LEVEL=8

RUN apt-get update && apt-get install -y --no-install-recommends python3.12 python3-pip ffmpeg ninja-build git git-lfs wget vim libgl1 libglib2.0-0 python3-dev build-essential gcc && ln -sf /usr/bin/python3.12 /usr/bin/python && ln -sf /usr/bin/pip3 /usr/bin/pip && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN mv /usr/lib/python3.12/EXTERNALLY-MANAGED /usr/lib/python3.12/EXTERNALLY-MANAGED.old

RUN pip install --no-cache-dir gdown packaging setuptools wheel comfy-cli jupyterlab jupyterlab-lsp     jupyter-server jupyter-server-terminals ipykernel jupyterlab_code_formatter

EXPOSE 8888

RUN /usr/bin/yes | comfy --workspace /ComfyUI install --cuda-version 12.6 --nvidia
RUN python -m pip install opencv-python

RUN for repo in \
      https://github.com/pythongosssss/ComfyUI-Custom-Scripts.git \
      https://github.com/city96/ComfyUI-GGUF.git \
      https://github.com/kijai/ComfyUI-KJNodes.git \
      https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite.git \
      https://github.com/Smirnov75/ComfyUI-mxToolkit.git \
      https://github.com/facok/ComfyUI-HunyuanVideoMultiLora.git \
      https://github.com/rgthree/rgthree-comfy.git \
      https://github.com/Fannovel16/ComfyUI-Frame-Interpolation.git \
      https://github.com/WASasquatch/was-node-suite-comfyui.git \
      https://github.com/kijai/ComfyUI-Florence2.git \
      https://github.com/yuvraj108c/ComfyUI-Upscaler-Tensorrt.git \
      https://github.com/pollockjj/ComfyUI-MultiGPU.git \
      https://github.com/ltdrdata/ComfyUI-Impact-Pack.git \
      https://github.com/yolain/ComfyUI-Easy-Use.git \
    ; do \
    echo $repo; \
        cd /ComfyUI/custom_nodes; \
        repo_dir=$(basename "$repo" .git); \
        if [ "$repo" = "https://github.com/ssitu/ComfyUI_UltimateSDUpscale.git" ]; then \
          git clone --recursive "$repo"; \
        else \
          git clone "$repo"; \
        fi; \
        if [ -f "/ComfyUI/custom_nodes/$repo_dir/requirements.txt" ]; then \
          pip install -r "/ComfyUI/custom_nodes/$repo_dir/requirements.txt"; \
        fi; \
        if [ -f "/ComfyUI/custom_nodes/$repo_dir/install.py" ]; then \
          python "/ComfyUI/custom_nodes/$repo_dir/install.py"; \
        fi; \
    done

EXPOSE 8188
CMD [ "python3", "/ComfyUI/main.py", "--listen" ]
