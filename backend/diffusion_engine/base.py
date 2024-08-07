import torch


class ForgeObjects:
    def __init__(self, unet, clip, vae, clipvision):
        self.unet = unet
        self.clip = clip
        self.vae = vae
        self.clipvision = clipvision

    def shallow_copy(self):
        return ForgeObjects(
            self.unet,
            self.clip,
            self.vae,
            self.clipvision
        )


class ForgeDiffusionEngine:
    matched_guesses = []

    def __init__(self, estimated_config, huggingface_components):
        self.model_config = estimated_config
        self.is_inpaint = estimated_config.inpaint_model()

        self.forge_objects = None
        self.forge_objects_original = None
        self.forge_objects_after_applying_lora = None

        self.current_lora_hash = str([])
        self.tiling_enabled = False

        self.first_stage_model = None  # set this so that you can change VAE in UI

        # WebUI Dirty Legacy
        self.latent_channels = 4
        self.is_sd1 = False
        self.is_sd2 = False
        self.is_sdxl = False
        self.is_sd3 = False

    def set_clip_skip(self, clip_skip):
        pass

    def get_first_stage_encoding(self, x):
        return x  # legacy code, do not change

    def get_learned_conditioning(self, prompt: list[str]):
        pass

    def encode_first_stage(self, x):
        pass

    def decode_first_stage(self, x):
        pass

    def get_prompt_lengths_on_ui(self, prompt):
        pass
