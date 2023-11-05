#!/bin/false

# This file will be sourced in init.sh

# https://raw.githubusercontent.com/ai-dock/stable-diffusion-webui/main/config/provisioning/default.sh
printf "\n##############################################\n#                                            #\n#          Provisioning container            #\n#                                            #\n#         This will take some time           #\n#                                            #\n# Your container will be ready on completion #\n#                                            #\n##############################################\n\n"

function download() {
    wget -q --show-progress -e dotbytes="${3:-4M}" -O "$2" "$1"
}
disk_space=$(df --output=avail -m $WORKSPACE|tail -n1)
webui_dir=/opt/stable-diffusion-webui
models_dir=${webui_dir}/models
sd_models_dir=${models_dir}/Stable-diffusion
extensions_dir=${webui_dir}/extensions
cn_models_dir=${extensions_dir}/sd-webui-controlnet/models
vae_models_dir=${models_dir}/VAE
upscale_models_dir=${models_dir}/ESRGAN

printf "Downloading extensions..."
cd $extensions_dir

# Controlnet
printf "Setting up Controlnet...\n"
if [[ -d sd-webui-controlnet ]]; then
    (cd sd-webui-controlnet && \
        git pull && \
        micromamba run -n webui ${PIP_INSTALL} -r requirements.txt
    )
else
    (git clone https://github.com/Mikubill/sd-webui-controlnet && \
         micromamba run -n webui ${PIP_INSTALL} -r sd-webui-controlnet/requirements.txt
    )
fi

# Reactor
printf "Setting up Reactor...\n"
if [[ -d sd-webui-reactor ]]; then
    (cd sd-webui-reactor && \
        git pull && \
        micromamba run -n webui ${PIP_INSTALL} -r requirements.txt
    )
else
    (git clone https://github.com/Gourieff/sd-webui-reactor && \
         micromamba run -n webui ${PIP_INSTALL} -r sd-webui-reactor/requirements.txt
    )
fi

# SD-A1111 extensions

# CivitAI Browser+
printf "Setting up CivitAI Browser+...\n"
if [[ -d sd-civitai-browser-plus ]]; then
    (cd sd-civitai-browser-plus && git pull)
else
    git clone https://github.com/BlafKing/sd-civitai-browser-plus.git
fi

# Image browser
printf "Setting up Image browser...\n"
if [[ -d stable-diffusion-webui-images-browser ]]; then
    (cd stable-diffusion-webui-images-browser && git pull)
else
    git clone https://github.com/AlUlkesh/stable-diffusion-webui-images-browser.git
fi

# Save State
printf "Setting up Save State...\n"
if [[ -d stable-diffusion-webui-state ]]; then
    (cd stable-diffusion-webui-state && git pull)
else
    git clone https://github.com/ilian6806/stable-diffusion-webui-state
fi

# Tiled Diffusion
printf "Setting up Tiled Diffusion...\n"
if [[ -d multidiffusion-upscaler-for-automatic1111 ]]; then
    (cd multidiffusion-upscaler-for-automatic1111 && git pull)
else
    git https://github.com/pkuliyi2015/multidiffusion-upscaler-for-automatic1111
fi

# SD Models

if [[ $disk_space -ge 25000 ]]; then

    # sd_xl_base_1
    model_file=${sd_models_dir}/sd_xl_base_1.0.safetensors
    model_url=https://huggingface.co/stabilityai/stable-diffusion-xl-base-1.0/resolve/main/sd_xl_base_1.0.safetensors
    
    if [[ ! -e ${model_file} ]]; then
        printf "Downloading Stable Diffusion XL base...\n"
        download ${model_url} ${model_file} 
    fi
    
    # sd_xl_refiner_1
    model_file=${sd_models_dir}/sd_xl_refiner_1.0.safetensors
    model_url=https://huggingface.co/stabilityai/stable-diffusion-xl-refiner-1.0/resolve/main/sd_xl_refiner_1.0.safetensors
    
    if [[ ! -e ${model_file} ]]; then
        printf "Downloading Stable Diffusion XL refiner...\n"
        download ${model_url} ${model_file}
    fi

else
        printf "\nSkipping extra models (disk < 30GB)\n"
fi
printf "Downloading a few pruned controlnet models...\n"

model_file=${cn_models_dir}/control_sd15_canny-fp16.safetensors
model_url=https://huggingface.co/webui/ControlNet-modules-safetensors/resolve/main/control_canny-fp16.safetensors

if [[ ! -e ${model_file} ]]; then
    printf "Downloading Canny SD 1.5...\n"
    download ${model_url} ${model_file}
fi

#----

model_file=${cn_models_dir}/control_sdxl_canny-256lora.safetensors
model_url=https://huggingface.co/lllyasviel/sd_control_collection/resolve/main/sai_xl_canny_256lora.safetensors

if [[ ! -e ${model_file} ]]; then
    printf "Downloading Canny SDXL...\n"
    download ${model_url} ${model_file}
fi

#----

model_file=${cn_models_dir}/control_sd15_depth-fp16.safetensors
model_url=https://huggingface.co/webui/ControlNet-modules-safetensors/resolve/main/control_depth-fp16.safetensors

if [[ ! -e ${model_file} ]]; then
    printf "Downloading Depth SD 1.5...\n"
    download ${model_url} ${model_file}
fi

#----

model_file=${cn_models_dir}/control_sdxl_depth-256lora.safetensors
model_url=https://huggingface.co/lllyasviel/sd_control_collection/resolve/main/sai_xl_depth_256lora.safetensors

if [[ ! -e ${model_file} ]]; then
    printf "Downloading Depth SDXL...\n"
    download ${model_url} ${model_file}
fi

#----

model_file=${cn_models_dir}/control_sd15_openpose-fp16.safetensors
model_url=https://huggingface.co/webui/ControlNet-modules-safetensors/resolve/main/control_openpose-fp16.safetensors

if [[ ! -e ${model_file} ]]; then
    printf "Downloading Openpose SD 1.5...\n"
    download ${model_url} ${model_file}
fi

#----

model_file=${cn_models_dir}/control_sdxl_openpose-256lora.safetensors
model_url=https://huggingface.co/lllyasviel/sd_control_collection/resolve/main/thibaud_xl_openpose_256lora.safetensors

if [[ ! -e ${model_file} ]]; then
    printf "Downloading Openpose SDXL...\n"
    download ${model_url} ${model_file}
fi

#--- 

model_file=${cn_models_dir}/control_sd15_scribble-fp16.safetensors
model_url=https://huggingface.co/webui/ControlNet-modules-safetensors/resolve/main/control_scribble-fp16.safetensors

if [[ ! -e ${model_file} ]]; then
    printf "Downloading Scribble SD 1.5...\n"
    download ${model_url} ${model_file}
fi

#----

printf "Downloading VAE...\n"

model_file=${vae_models_dir}/vae-ft-ema-560000-ema-pruned.safetensors
model_url=https://huggingface.co/stabilityai/sd-vae-ft-ema-original/resolve/main/vae-ft-ema-560000-ema-pruned.safetensors

if [[ ! -e ${model_file} ]]; then
    printf "Downloading vae-ft-ema-560000-ema...\n"
    download ${model_url} ${model_file}
fi

model_file=${vae_models_dir}/vae-ft-mse-840000-ema-pruned.safetensors
model_url=https://huggingface.co/stabilityai/sd-vae-ft-mse-original/resolve/main/vae-ft-mse-840000-ema-pruned.safetensors

if [[ ! -e ${model_file} ]]; then
    printf "Downloading vae-ft-mse-840000-ema...\n"
    download ${model_url} ${model_file}
fi

model_file=${vae_models_dir}/sdxl_vae.safetensors
model_url=https://huggingface.co/stabilityai/sdxl-vae/resolve/main/sdxl_vae.safetensors

if [[ ! -e ${model_file} ]]; then
    printf "Downloading sdxl_vae...\n"
    download ${model_url} ${model_file}
fi

printf "Downloading Upscalers...\n"

model_file=${upscale_models_dir}/4x_foolhardy_Remacri.pth
model_url=https://huggingface.co/FacehugmanIII/4x_foolhardy_Remacri/resolve/main/4x_foolhardy_Remacri.pth

if [[ ! -e ${model_file} ]]; then
    printf "Downloading 4x_foolhardy_Remacri...\n"
    download ${model_url} ${model_file}
fi

model_file=${upscale_models_dir}/4x_NMKD-Siax_200k.pth
model_url=https://huggingface.co/Akumetsu971/SD_Anime_Futuristic_Armor/resolve/main/4x_NMKD-Siax_200k.pth

if [[ ! -e ${model_file} ]]; then
    printf "Downloading 4x_NMKD-Siax_200k...\n"
    download ${model_url} ${model_file}
fi

model_file=${upscale_models_dir}/RealESRGAN_x4.pth
model_url=https://huggingface.co/ai-forever/Real-ESRGAN/resolve/main/RealESRGAN_x4.pth

if [[ ! -e ${model_file} ]]; then
    printf "Downloading RealESRGAN_x4...\n"
    download ${model_url} ${model_file}
fi

printf "\nProvisioning complete:  Web UI will start now\n\n"

