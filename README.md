# Stable Diffusion WebUI Forge

Stable Diffusion WebUI Forge is a platform on top of [Stable Diffusion WebUI](https://github.com/AUTOMATIC1111/stable-diffusion-webui) (based on [Gradio](https://www.gradio.app/) <a href='https://github.com/gradio-app/gradio'><img src='https://img.shields.io/github/stars/gradio-app/gradio'></a>) to make development easier, optimize resource management, speed up inference, and study experimental features.

The name "Forge" is inspired from "Minecraft Forge". This project is aimed at becoming SD WebUI's Forge.

Forge is currently based on SD-WebUI 1.10.1 at [this commit](https://github.com/AUTOMATIC1111/stable-diffusion-webui/commit/82a973c04367123ae98bd9abdf80d9eda9b910e2). (Because original SD-WebUI is almost static now, Forge will sync with original WebUI every 90 days, or when important fixes.)

News are moved to this link: [Click here to see the News section](https://github.com/lllyasviel/stable-diffusion-webui-forge/blob/main/NEWS.md)

# Quick List

[Gradio 4 UI Must Read (TLDR: You need to use RIGHT MOUSE BUTTON to move canvas!)](https://github.com/lllyasviel/stable-diffusion-webui-forge/discussions/853)

[Flux Tutorial (BitsandBytes Models, NF4, "GPU Weight", "Offload Location", "Offload Method", etc)](https://github.com/lllyasviel/stable-diffusion-webui-forge/discussions/981)

[Flux Tutorial 2 (Seperated Full Models, GGUF, Technically Correct Comparison between GGUF and NF4, etc)](https://github.com/lllyasviel/stable-diffusion-webui-forge/discussions/1050)

[Forge Extension List and Extension Replacement List (Temporary)](https://github.com/lllyasviel/stable-diffusion-webui-forge/discussions/1754)

[How to make LoRAs more precise on low-bit models; How to Skip" Patching LoRAs"; How to only load LoRA one time rather than each generation; How to report LoRAs that do not work](https://github.com/lllyasviel/stable-diffusion-webui-forge/discussions/1038)

[Report Flux Performance Problems (TLDR: DO NOT set "GPU Weight" too high! Lower "GPU Weight" solves 99% problems!)](https://github.com/lllyasviel/stable-diffusion-webui-forge/discussions/1181)

[How to solve "Connection errored out" / "Press anykey to continue ..." / etc](https://github.com/lllyasviel/stable-diffusion-webui-forge/discussions/1474)

[(Save Flux BitsandBytes UNet/Checkpoint)](https://github.com/lllyasviel/stable-diffusion-webui-forge/discussions/1224#discussioncomment-10384104)

[LayerDiffuse Transparent Image Editing](https://github.com/lllyasviel/stable-diffusion-webui-forge/discussions/854)

[Tell us what is missing in ControlNet Integrated](https://github.com/lllyasviel/stable-diffusion-webui-forge/discussions/932)

[(Policy) Soft Advertisement Removal Policy](https://github.com/lllyasviel/stable-diffusion-webui-forge/discussions/1286)

(Flux BNB NF4 / GGUF Q8_0/Q5_0/Q5_1/Q4_0/Q4_1 are all natively supported with GPU weight slider and Quene/Async Swap toggle and swap location toggle. All Flux BNB NF4 / GGUF Q8_0/Q5_0/Q4_0 have LoRA support.)

# Installing Forge

**Just use this one-click installation package (with git and python included).**

[>>> Click Here to Download One-Click Package (CUDA 12.1 + Pytorch 2.3.1) <<<](https://github.com/lllyasviel/stable-diffusion-webui-forge/releases/download/latest/webui_forge_cu121_torch231.7z)

Some other CUDA/Torch Versions:

[Forge with CUDA 12.1 + Pytorch 2.3.1](https://github.com/lllyasviel/stable-diffusion-webui-forge/releases/download/latest/webui_forge_cu121_torch231.7z) <- **Recommended**

[Forge with CUDA 12.4 + Pytorch 2.4](https://github.com/lllyasviel/stable-diffusion-webui-forge/releases/download/latest/webui_forge_cu124_torch24.7z) <- **Fastest**, but MSVC may be broken, xformers may not work

[Forge with CUDA 12.1 + Pytorch 2.1](https://github.com/lllyasviel/stable-diffusion-webui-forge/releases/download/latest/webui_forge_cu121_torch21.7z) <- the previously used old environments

After you download, you uncompress, use `update.bat` to update, and use `run.bat` to run.

Note that running `update.bat` is important, otherwise you may be using a previous version with potential bugs unfixed.

![image](https://github.com/lllyasviel/stable-diffusion-webui-forge/assets/19834515/c49bd60d-82bd-4086-9859-88d472582b94)

### Advanced Install

If you are proficient in Git and you want to install Forge as another branch of SD-WebUI, please see [here](https://github.com/continue-revolution/sd-webui-animatediff/blob/forge/master/docs/how-to-use.md#you-have-a1111-and-you-know-git). In this way, you can reuse all SD checkpoints and all extensions you installed previously in your OG SD-WebUI, but you should know what you are doing.

If you know what you are doing, you can also install Forge using same method as SD-WebUI. (Install Git, Python, Git Clone the forge repo `https://github.com/lllyasviel/stable-diffusion-webui-forge.git` and then run webui-user.bat).

### Previous Versions

You can download previous versions [here](https://github.com/lllyasviel/stable-diffusion-webui-forge/discussions/849).

# Docker Installation

This is a dockerized version of lllyasviel/stable-diffusion-webui-forge. It fetches lllyasviel/stable-diffusion-webui-forge source inside the container.

## Support

- Docker support is only provided for the `latest` and `v*.*.*` tags (Ex. `v1.1.2`)
- You may obtain docker related support via [catspeed-cc/sd-webui-forge-docker issue ticket](https://github.com/catspeed-cc/sd-webui-forge-docker/issues)
- You may obtain general sd-forge-webui support via [lllyasviel/stable-diffusion-webui-forge issue ticket](https://github.com/lllyasviel/stable-diffusion-webui-forge/issues)

## IMPORTANT cuda notice for v1.1.0 & onwards:

You should be able to use any cuda 12.x version (12.1->12.8) as cuda is backwards and forwards compatible at least within the major version. If you use cuda 12.8 you will need driver 535.13504.05 or higher

### Install cuda 12.8 on Debian 11
```
sudo apt-get remove --purge '^cuda.*' '^nvidia-cuda.*' && \
sudo apt-get autoremove -y && \
wget https://developer.download.nvidia.com/compute/cuda/repos/debian11/x86_64/cuda-debian11.pin && \
sudo mv cuda-debian11.pin /etc/apt/preferences.d/cuda-repository-pin-600 && \
sudo apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/debian11/x86_64/3bf863cc.pub && \
sudo add-apt-repository "deb https://developer.download.nvidia.com/compute/cuda/repos/debian11/x86_64/ /" && \
sudo apt-get update && \
sudo apt-get install -y cuda-toolkit-12-8
```

### Install cuda 12.8 on Ubuntu 22.04
```
sudo apt-get remove --purge '^cuda.*' '^nvidia-cuda.*' && \
sudo apt-get autoremove -y && \
wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-ubuntu2204.pin && \
sudo mv cuda-ubuntu2204.pin /etc/apt/preferences.d/cuda-repository-pin-600 && \
sudo apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/3bf863cc.pub && \
sudo add-apt-repository "deb https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/ /" && \
sudo apt-get update && \
sudo apt-get install -y cuda-toolkit-12-8
```

## Install Docker & nano:
- `apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin`
- `apt install -y nano`
- Test the installation worked with `docker compose version` you should get something like `Docker Compose version v2.24.5`

Models can be put in `sd-webui-forge-docker/models/` directory, organized by type - they will be mounted to the container
- If you copy models in while container running and after first start, after model copy is complete you can `docker-stop-containers.sh` and `docker-start-containers.sh` and they will be loaded quickly

Outputs are stored in `sd-webui-forge-docker/outputs/` directory

Due to the nature of Docker, an image running at shutdown _should_ start up again on boot. If this does not happen, submit a [catspeed-cc issue ticket](https://github.com/catspeed-cc/sd-webui-forge-docker/issues)

These are the current tags:
```
catspeedcc/sd-webui-forge-docker:latest - currently points to v1.1.2
catspeedcc/sd-webui-forge-docker:v1.1.2 - Menu helper script, cleaned project root more
catspeedcc/sd-webui-forge-docker:v1.1.1 - Minor update, cleaned up project root
catspeedcc/sd-webui-forge-docker:v1.1.0 - Important upgrades: smaller docker image, cuda 12.1->12.8 (see README.md, CURRENT 'LATEST')
catspeedcc/sd-webui-forge-docker:v1.0.0 - latest stable version (first release)

catspeedcc/sd-webui-forge-docker:development - (not supported, parity w/ development branch, if you use it you're on your own.)
catspeedcc/sd-webui-forge-docker:bleeding - (not supported, ephemeral, if you use it you're on your own.)
```

There are a few main config files:
```
./docker/compose_files/docker-compose.yaml # CPU-only          # Should not need configuration

./docker/compose_files/docker-compose.single-gpu.nvidia.yaml   # Single GPU only (needs config)
./docker/compose_files/docker-compose.multi-gpu.nvidia.yaml    # ONE OF MULTIPLE GPU only (needs config)

./docker/compose_files/docker-compose.combined.nvidia.yaml     # ONLY so you can copy the service into
                       							                     # a different docker-compose.yml file ;)
```

As far as I know there is no way to combine multiple GPU's on this one same task (image generation) but you can dedicate one of many GPU's to image generation and then use the other GPU's for other tasks (chat, development, etc)

## Installation from GitHub

- Clone the catspeed-cc repository `git clone https://github.com/catspeed-cc/sd-webui-forge-docker.git`
- Run the menu script `./sdf-docker-menu.sh` and select option 1 (Install Sauces to ~/.bashrc)
- From now on you may start the menu by typing `sdf-menu` from anywhere inside the project directory
- Get used to the menu options, but you can run the scripts manually - type `docker-` and press tab for a full list of the commands.

Read the rest of this section, then jump to either [CPU Only](https://github.com/catspeed-cc/sd-webui-forge-docker/README.md#cpu-only-untested), [Single GPU Only](https://github.com/catspeed-cc/sd-webui-forge-docker/README.md#single-gpu-only-untested-should-work), or [Single of Multiple GPU Only](https://github.com/catspeed-cc/sd-webui-forge-docker/README.md#single-of-multiple-gpu-only-tested)

_**Important:**_ All Docker support for now goes to [catspeed-cc issue tickets](https://github.com/catspeed-cc/sd-webui-forge-docker/issues) until and _only if_ this ever gets merged upstream.

### CPU Only (untested)

- `./docker-init-cpu-only.sh` "installs" and starts the docker container
- After install, even while running you can copy models to models/ and then after run stop/start for quick reload
- `./docker-stop-containers.sh` "stops" container(s)
- `./docker-reinstall-container-deps.sh` - reinstalls containers dependencies (requires stop/start, you should prefer to destroy/init)
- `./docker-start-containers.sh` "starts" container(s)
- `./docker-destroy-cpu-only.sh` "uninstalls" and stops the docker container
- You can uninstall/reinstall to debug / start with fresh image (image is already stored locally)

### Single GPU Only (untested, should work)

- Edit & configure `docker-compose.cpu.yaml`
- Edit & configure `docker-compose.single-gpu.nvidia.yaml`
- `./docker-init-single-gpu-only.sh` "installs" and starts the docker container
- After install, even while running you can copy models to models/ and then after run stop/start for quick reload
- `./docker-stop-containers.sh` "stops" container(s)
- `./docker-reinstall-container-deps.sh` - reinstalls containers dependencies (requires stop/start, you should prefer to destroy/init)
- `./docker-start-containers.sh` "starts" container(s)
- `./docker-destroy-single-gpu-only.sh` "uninstalls" and stops the docker container
- You can uninstall/reinstall to debug / start with fresh image (image is already stored locally)

### Single of Multiple GPU Only (tested)

- Edit & configure `docker-compose.cpu.yaml`
- Edit & configure `docker-compose.multi-gpu.nvidia.yaml`
- `./docker-init-multi-gpu-only.sh` "installs" and starts the docker container
- After install, even while running you can copy models to models/ and then after run stop/start for quick reload
- `./docker-stop-containers.sh` "stops" container(s)
- `./docker-reinstall-container-deps.sh` - reinstalls containers dependencies (requires stop/start, you should prefer to destroy/init)
- `./docker-start-containers.sh` "starts" container(s)
- `./docker-destroy-multi-gpu-only.sh` "uninstalls" and stops the docker container
- You can uninstall/reinstall to debug / start with fresh image (image is already stored locally)

## Custom / Cut-down Installation w/ sauces archive

### Customize a docker-compose.yaml from another project

Let's say you have another project - let's pick localAGI as an example. You can customize the `docker-compose.yaml` for localAGI and add in this docker service. This way when you start localAGI it will also start your image generation service.

- Open the localAGI (or other project) directory
- Download the sauces archive for your version from https://github.com/catspeed-cc/sd-webui-forge-docker/tree/master/sauces
- Extract the sauces into your localAGI (or other) project directory `tar zxvf v1.0.0-sauce.tar.gz`
- Edit & configure `docker-compose.combined.nvidia.yaml` (the menu can't help you, you must manually edit)
- Copy the lines for the service from `docker-compose.combined.nvidia.yaml`
- Paste the lines underneath one of the other services inside the localAGI (or other project) docker-compose.yaml
- All sauce helper scripts and docker-compose.yaml files should now be in your project :)
- Use the init/destroy scripts just like you would on a regular docker installation (as outlined above)
- Docker helper start/stop scripts will speed up startup when simply stopping or starting the container quickly (ex. to load new models)
- IF you need to destroy the container and recreate it for debugging/troubleshooting, then use the respective destroy script followed by `docker compose down` in the localAGI (or other project)
- Sauce scripts ONLY will init/destroy/start/stop sd-forge containers
- IF you chose to rename the container, just make sure "sd-forge" exists in the name, and the sauce scripts should still work :)

## v1.1.2 Menu script

Included in v1.1.2 is the sdf-docker-menu! To use it for the first time you must type `./sdf-docker-menu.sh` from the root, and install the sauces to ~/.bashrc (option1)

Afterwards you can call the menu with `sdf-menu`. Each time you complete a command it loops back to the main menu, where you can run a different command or quit.

You will notice the main configurations are editable via this menu (using nano) - this script is compatible with SSH.

## Sauces Archives & Start-Stop Docker Helper Scripts:
The sauces archives are basically all the docker compose files, and bash scripts required (including menu) to manage your docker installation and make it easier.

- Each version (major or minor) will have a corresponding sauce archive.
- You only need this sauce archive IF you are planning to use the `docker-compose.combined.nvidia.yaml` to customize a different docker-compose.yaml and add sd-forge as a service.
- You _could_ use sauces to run a cut down installation that is standalone - no integration with a different docker-compose.yaml - extract, edit yaml, run the menu & install/init
- Due to the sauces being hosted on GitHub, MD5SUM's are not required (we are staying on the secured, confirmed, GitHub)
- MD5SUM's will be posted inside an .MD5 file anyways as the helper script can do it automatically
- Checking MD5SUM is not required unless you are extremely paranoid

## Future Plans:

- None as of yet
- please submit suggestions to https://github.com/catspeed-cc/sd-webui-forge-docker/issues

## v1.1.0 Startup Time Warning:

The _first_ startup time takes a while, it is doing a lot for you in the background. This should become faster on multiple start/stop of the container, but if you `docker compose down` you will need to wait again on next `docker compose up`. The container appears to be obliterated when doing so.

As of v1.0.0 you have ability to `./docker-start-containers.sh` and `./docker-stop-containers.sh` and the `docker-init-*.sh` and `docker-destroy-*.sh` scripts (use only one of each) to create and destroy your container.

As of v1.1.0 you have ability to `./docker-reinstall-container-deps.sh` which reinstalls the container dependencies while running. It should be noted that if you do this it will be unsupported as the best way to do this is to just `./docker-destroy-multi-gpu.sh` and `./docker-init-multi-gpu.sh` as it will fetch and reinstall ALL dependencies and sources.

## v1.0.0 Large Image Warning:

Holy crap! The image ... YES the image is large. So is this wall of text _lol_. At least for the image it starts with the fact that we need a full Ubuntu image with cuda12 for this machine learning / AI task. Then you have the original repository being required to fetch other repositories at runtime on launch to function. When I dockerized this everything was "baked into" the image. Unfortunately I do not see any way around this, even if the _upstream developers_ used submodules, they still have to be initialized and "baked into" the image OR fetched at runtime. ML/AI related source repositories and models are _very_ large, due to the nature of the task. 

The developers know their own project better than I - and I am a noob. They can integrate it into docker better, and try to cut waste out of the image, but of course all dependencies need to be baked into the image. Otherwise the images will not work, or it would have to fetch them inside the container _every time_ you wanted to `docker compose down`. It is not the kind of image I would suggest converting to alpine to slim it down, it would be _a lot_ of work and _headache_. However I found out recently it is not even possible due to cuda being required. I was able to use a cuda/ubuntu base image though and am happy with results of v1.1.0! I am happy to help with anything, but mostly can sit and make my own mess in _my repository_ :)

Do not worry, I have _not_ loaded it with 1000's of models :P

## What do you use an image generating AI for?

Currently I use it for nothing but the plan is to use it for readme images if I ever need them, or logos and header images.

In my current setup this is auxiliary to the main task: AI development - "VIBE coding" as the kids call it, man I am getting old... - I plan to use what I learned from this, to segregate my GPU's in my host system, so that each container only accesses one GPU, so I can divide them up. I plan to use LocalAGI/LocalAI federated nodes & codellama13B and Mixtrial 8x7B MOE models which are fine tuned for development, and when my Threadripper build & 2 x SXM4 A100 GPU's arrive, I will get another model to run :)

Not only do I get a docker image, YOU get a docker image too - I feel like Oprah, look under your chair for docker images :P

On top of all that it helps me in my future LocalAGI/LocalAI endeavours! :)

## Docker Image Build Warning: (unsupported)

These are mostly for my reference. If you wish to build the image they are here for you also. Just keep in mind this is unsupported and you are on your own.

- `docker build -t myorganization/myrepository:mytag .` general build (will be cached)

**_OR_**

- `docker build --progress=plain --build-arg DUMMY=$(date +%s) -t myorganization/myrepository:mytag .` debug build - so you can debug the Dockerfile without caching certain elements

That's it! As previously mentioned, there is no support for this from this point onwards. 

These were documented for @mooleshacat (A.K.A. _future noob self_)

# Forge Status

Based on manual test one-by-one:

| Component                                           | Status                                      | Last Test    |
|-----------------------------------------------------|---------------------------------------------|--------------|
| Basic Diffusion                                     | Normal                                      | 2024 Aug 26  |
| GPU Memory Management System                        | Normal                                      | 2024 Aug 26  |
| LoRAs                                               | Normal                                      | 2024 Aug 26  |
| All Preprocessors                                   | Normal                                      | 2024 Aug 26  |
| All ControlNets                                     | Normal                                      | 2024 Aug 26  |
| All IP-Adapters                                     | Normal                                      | 2024 Aug 26  |
| All Instant-IDs                                     | Normal                                      | 2024 July 27 |
| All Reference-only Methods                          | Normal                                      | 2024 July 27 |
| All Integrated Extensions                           | Normal                                      | 2024 July 27 |
| Popular Extensions (Adetailer, etc)                 | Normal                                      | 2024 July 27 |
| Gradio 4 UIs                                        | Normal                                      | 2024 July 27 |
| Gradio 4 Forge Canvas                               | Normal                                      | 2024 Aug 26  |
| LoRA/Checkpoint Selection UI for Gradio 4           | Normal                                      | 2024 July 27 |
| Photopea/OpenposeEditor/etc for ControlNet          | Normal                                      | 2024 July 27 |
| Wacom 128 level touch pressure support for Canvas   | Normal                                      | 2024 July 15 |
| Microsoft Surface touch pressure support for Canvas | Broken, pending fix                         | 2024 July 29 |
| ControlNets (Union)                                 | Not implemented yet, pending implementation | 2024 Aug 26  |
| ControlNets (Flux)                                  | Not implemented yet, pending implementation | 2024 Aug 26  |
| API endpoints (txt2img, img2img, etc)               | Normal, but pending improved Flux support   | 2024 Aug 29  |
| OFT LoRAs                                           | Broken, pending fix                         | 2024 Sep 9   |

Feel free to open issue if anything is broken and I will take a look every several days. If I do not update this "Forge Status" then it means I cannot reproduce any problem. In that case, fresh re-install should help most.

# UnetPatcher

Below are self-supported **single file** of all codes to implement FreeU V2.

See also `extension-builtin/sd_forge_freeu/scripts/forge_freeu.py`:

```python
import torch
import gradio as gr

from modules import scripts


def Fourier_filter(x, threshold, scale):
    # FFT
    x_freq = torch.fft.fftn(x.float(), dim=(-2, -1))
    x_freq = torch.fft.fftshift(x_freq, dim=(-2, -1))

    B, C, H, W = x_freq.shape
    mask = torch.ones((B, C, H, W), device=x.device)

    crow, ccol = H // 2, W // 2
    mask[..., crow - threshold:crow + threshold, ccol - threshold:ccol + threshold] = scale
    x_freq = x_freq * mask

    # IFFT
    x_freq = torch.fft.ifftshift(x_freq, dim=(-2, -1))
    x_filtered = torch.fft.ifftn(x_freq, dim=(-2, -1)).real

    return x_filtered.to(x.dtype)


def patch_freeu_v2(unet_patcher, b1, b2, s1, s2):
    model_channels = unet_patcher.model.diffusion_model.config["model_channels"]
    scale_dict = {model_channels * 4: (b1, s1), model_channels * 2: (b2, s2)}
    on_cpu_devices = {}

    def output_block_patch(h, hsp, transformer_options):
        scale = scale_dict.get(h.shape[1], None)
        if scale is not None:
            hidden_mean = h.mean(1).unsqueeze(1)
            B = hidden_mean.shape[0]
            hidden_max, _ = torch.max(hidden_mean.view(B, -1), dim=-1, keepdim=True)
            hidden_min, _ = torch.min(hidden_mean.view(B, -1), dim=-1, keepdim=True)
            hidden_mean = (hidden_mean - hidden_min.unsqueeze(2).unsqueeze(3)) / (hidden_max - hidden_min).unsqueeze(2).unsqueeze(3)

            h[:, :h.shape[1] // 2] = h[:, :h.shape[1] // 2] * ((scale[0] - 1) * hidden_mean + 1)

            if hsp.device not in on_cpu_devices:
                try:
                    hsp = Fourier_filter(hsp, threshold=1, scale=scale[1])
                except:
                    print("Device", hsp.device, "does not support the torch.fft.")
                    on_cpu_devices[hsp.device] = True
                    hsp = Fourier_filter(hsp.cpu(), threshold=1, scale=scale[1]).to(hsp.device)
            else:
                hsp = Fourier_filter(hsp.cpu(), threshold=1, scale=scale[1]).to(hsp.device)

        return h, hsp

    m = unet_patcher.clone()
    m.set_model_output_block_patch(output_block_patch)
    return m


class FreeUForForge(scripts.Script):
    sorting_priority = 12  # It will be the 12th item on UI.

    def title(self):
        return "FreeU Integrated"

    def show(self, is_img2img):
        # make this extension visible in both txt2img and img2img tab.
        return scripts.AlwaysVisible

    def ui(self, *args, **kwargs):
        with gr.Accordion(open=False, label=self.title()):
            freeu_enabled = gr.Checkbox(label='Enabled', value=False)
            freeu_b1 = gr.Slider(label='B1', minimum=0, maximum=2, step=0.01, value=1.01)
            freeu_b2 = gr.Slider(label='B2', minimum=0, maximum=2, step=0.01, value=1.02)
            freeu_s1 = gr.Slider(label='S1', minimum=0, maximum=4, step=0.01, value=0.99)
            freeu_s2 = gr.Slider(label='S2', minimum=0, maximum=4, step=0.01, value=0.95)

        return freeu_enabled, freeu_b1, freeu_b2, freeu_s1, freeu_s2

    def process_before_every_sampling(self, p, *script_args, **kwargs):
        # This will be called before every sampling.
        # If you use highres fix, this will be called twice.

        freeu_enabled, freeu_b1, freeu_b2, freeu_s1, freeu_s2 = script_args

        if not freeu_enabled:
            return

        unet = p.sd_model.forge_objects.unet

        unet = patch_freeu_v2(unet, freeu_b1, freeu_b2, freeu_s1, freeu_s2)

        p.sd_model.forge_objects.unet = unet

        # Below codes will add some logs to the texts below the image outputs on UI.
        # The extra_generation_params does not influence results.
        p.extra_generation_params.update(dict(
            freeu_enabled=freeu_enabled,
            freeu_b1=freeu_b1,
            freeu_b2=freeu_b2,
            freeu_s1=freeu_s1,
            freeu_s2=freeu_s2,
        ))

        return
```

See also [Forge's Unet Implementation](https://github.com/lllyasviel/stable-diffusion-webui-forge/blob/main/backend/nn/unet.py).

# Under Construction

WebUI Forge is now under some constructions, and docs / UI / functionality may change with updates.
