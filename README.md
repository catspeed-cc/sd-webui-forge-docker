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

Install Docker:
- `sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin`
- Test the installation worked with `docker compose version` you should get something like `Docker Compose version v2.24.5`
- If trouble submit a [catspeed-cc issue ticket](https://github.com/catspeed-cc/sd-webui-forge-docker/issues)

Models can be put in `sd-webui-forge-docker/models/` directory, organized by type - they will be mounted to the container

Outputs are stored in `sd-webui-forge-docker/outputs/txt2img-images/` directory, organized by date

Due to the nature of Docker, an image running at shutdown _should_ start up again on boot. If this does not happen, submit a [catspeed-cc issue ticket](https://github.com/catspeed-cc/sd-webui-forge-docker/issues)

These are the current tags:
```
catspeedcc/sd-webui-forge-docker:latest - currently points to v1.0.0
catspeedcc/sd-webui-forge-docker:v1.0.0 - latest stable version (first release)

catspeedcc/sd-webui-forge-docker:development - (not supported, parity w/ development branch, if you use it you're on your own.)
catspeedcc/sd-webui-forge-docker:bleeding - (not supported, ephemeral, if you use it you're on your own.)
```

There are a few main files:
```
docker-compose.yaml # CPU-only

docker-compose.single-gpu.nvidia.yaml   # Single GPU only
docker-compose.multi-gpu.nvidia.yaml    # ONE OF MULTIPLE GPU only

docker-compose.combined.nvidia.yaml     # ONLY so you can copy the service into
                                        # a different docker-compose.yml file ;)
```

As far as I know there is no way to combine multiple GPU's on this one same task (image generation) but you can dedicate one of many GPU's to image generation and then use the other GPU's for other tasks (chat, development, etc)

- Clone the catspeed-cc repository for now `git clone https://github.com/catspeed-cc/sd-webui-forge-docker.git`
- DO NOT run the `webui-docker.sh` script ever, it is meant ONLY to be ran inside the docker containers at runtime. (automatic, ignore)
- Read the rest of this section, then jump to either [CPU Only](https://github.com/catspeed-cc/sd-webui-forge-docker/README.md#cpu-only-untested), [Single GPU Only](https://github.com/catspeed-cc/sd-webui-forge-docker/README.md#single-gpu-only-untested-should-work), or [Single of Multiple GPU Only](https://github.com/catspeed-cc/sd-webui-forge-docker/README.md#single-of-multiple-gpu-only-tested)

All Docker support for now goes to [catspeed-cc issue tickets](https://github.com/catspeed-cc/sd-webui-forge-docker/issues) until and _only if_ this ever gets merged upstream.

### CPU Only (untested)

Simply run `docker compose up` as it will select automatically the `docker-compose.yml`. There is no configuring as far as I can tell. If otherwise please submit a [catspeed-cc issue ticket](https://github.com/catspeed-cc/sd-webui-forge-docker/issues)

### Single GPU Only (untested, should work)

- Edit `docker-compose.single-gpu.nvidia.yaml` there are comments to guide you
  - You won't need to edit this on first run, unless you have issues.
  - If you plan only to have image processing, 25GB swap should suffice.
  - If you have issues edit the `docker-compose.single-gpu.nvidia.yaml` file using the comments as guidance.
  - Main lines are `#- --always-low-vram` (un comment if problems persist) and `- --vae-in-fp32` (comment if uncommenting the former - unconfirmed requirement)
- Run `docker compose -f docker-compose.yaml -f docker-compose.single-gpu.nvidia.yaml up`
- CTRL + C to close it. Do not bother removing it.
- If removal is required use `docker compose -f docker-compose.yaml -f docker-compose.single-gpu.nvidia.yaml down`

### Single of Multiple GPU Only (tested)

- There is no way to combine multiple GPU to work to the same effort that I am aware of yet.
- You can designate one GPU to this, and use the other GPU's for other tasks :)
- Run `nvidia-smi` and note the GPU index (0? 1? 2? etc.)
- Edit `docker-compose.multi-gpu.nvidia.yaml` replacing the `1` only with the index of your desired GPU
  - If you plan only to have other AI workloads on the other GPU's, 100GB (or more) swap should suffice (for offloading if model not fit on GPU VRAM)
  - If you have issues edit the `docker-compose.multi-gpu.nvidia.yaml` file using the comments as guidance.
  - Main lines are `#- --always-low-vram` (un comment if problems persist) and `- --vae-in-fp32` (comment if uncommenting the former - unconfirmed requirement)
- Run `docker compose -f docker-compose.yaml -f docker-compose.multi-gpu.nvidia.yaml up`
- CTRL + C to close it. Do not bother removing it.
- If removal is required use `docker compose -f docker-compose.yaml -f docker-compose.multi-gpu.nvidia.yaml down`

## Startup Time Warning:
The startup time takes a while, it is doing a lot for you in the background. This should become faster on multiple start/stop of the container, but if you `docker compose down` you will need to wait again on next `docker compose up`. Not sure why, maybe it gets obliterated each time.

The way to fix it and cut down startup time is to make your own shellscript that starts/stops each container instead of removing it.  If you are unsure, just wait for the container to start ... :) I might or might not do something about that for v1.0.0 ;)

## Large Image Warning:
Holy crap! The image ... YES the image is large. So is this wall of text lol. At least for the image it starts with the fact that we need a full Ubuntu image with cuda12 for this machine learning / AI task. Then you have the original repository being required to fetch other repositories at runtime on launch to function. When I dockerized this everything was "baked into" the image. Unfortunately I do not see any way around this, even if the _upstream developers_ used submodules, they still have to be initialized and "baked into" the image. ML/AI related source repositories and models are _very_ large, due to the nature of the task. 

The developers know their own project better than I - and I am a noob. They can integrate it into docker better, and try to cut waste out of the image, but of course all dependencies need to be baked into the image. Otherwise the images will not work, or it would have to fetch them inside the container _every time_ you wanted to `docker compose down`. It is not the kind of image I would suggest converting to alpine to slim it down, it would be _a lot_ of work and _headache_. I am happy to help with anything, but mostly can sit and make my own mess in _my repository_ :)

Do not worry, I have _not_ loaded it with 1000's of models :P

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
