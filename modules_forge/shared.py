import cv2
import os
import torch

from modules.paths import models_path
from ldm_patched.modules import model_management
from ldm_patched.modules.model_patcher import ModelPatcher
from modules.modelloader import load_file_from_url
from modules_forge.forge_util import resize_image_with_pad


controlnet_dir = os.path.join(models_path, 'ControlNet')
os.makedirs(controlnet_dir, exist_ok=True)

preprocessor_dir = os.path.join(models_path, 'ControlNetPreprocessor')
os.makedirs(preprocessor_dir, exist_ok=True)

shared_preprocessors = {}


def add_preprocessor(preprocessor):
    global shared_preprocessors
    p = preprocessor()
    shared_preprocessors[p.name] = p
    return


class PreprocessorParameter:
    def __init__(self, minimum=0.0, maximum=1.0, step=0.01, label='Parameter 1', value=0.5, visible=False, **kwargs):
        self.gradio_update_kwargs = dict(
            minimum=minimum, maximum=maximum, step=step, label=label, value=value, visible=visible, **kwargs
        )


class Preprocessor:
    def __init__(self):
        self.name = 'PreprocessorBase'
        self.tag = None
        self.slider_resolution = PreprocessorParameter(label='Resolution', minimum=128, maximum=2048, value=512, step=8, visible=True)
        self.slider_1 = PreprocessorParameter()
        self.slider_2 = PreprocessorParameter()
        self.slider_3 = PreprocessorParameter()
        self.model_patcher: ModelPatcher = None
        self.show_control_mode = True
        self.do_not_need_model = False

    def setup_model_patcher(self, model, load_device=None, offload_device=None, dtype=torch.float32, **kwargs):
        if load_device is None:
            load_device = model_management.get_torch_device()

        if offload_device is None:
            offload_device = torch.device('cpu')

        if not model_management.should_use_fp16(load_device):
            dtype = torch.float32

        model.eval()
        model = model.to(device=offload_device, dtype=dtype)

        self.model_patcher = ModelPatcher(model=model, load_device=load_device, offload_device=offload_device, **kwargs)
        self.model_patcher.dtype = dtype
        return self.model_patcher

    def move_all_model_patchers_to_gpu(self):
        model_management.load_models_gpu([self.model_patcher])
        return

    def send_tensor_to_model_device(self, x):
        return x.to(device=self.model_patcher.current_device, dtype=self.model_patcher.dtype)

    def lazy_memory_management(self, model):
        # This is a lazy method to just free some memory
        # so that we can still use old codes to manage memory in a bad way
        # Ideally this should all be removed and all memory should be managed by model patcher.
        # But the workload is too big, so we just use a quick method to manage in dirty way.
        required_memory = model_management.module_size(model) + model_management.minimum_inference_memory()
        model_management.free_memory(required_memory, device=model_management.get_torch_device())
        return

    def process_before_every_sampling(self, process, cnet):
        return

    def __call__(self, input_image, resolution, slider_1=None, slider_2=None, slider_3=None, **kwargs):
        return input_image


class PreprocessorNone(Preprocessor):
    def __init__(self):
        super().__init__()
        self.name = 'None'


class PreprocessorCanny(Preprocessor):
    def __init__(self):
        super().__init__()
        self.name = 'canny'
        self.tag = 'Canny'
        self.slider_1 = PreprocessorParameter(minimum=0, maximum=256, step=1, value=100, label='Low Threshold', visible=True)
        self.slider_2 = PreprocessorParameter(minimum=0, maximum=256, step=1, value=200, label='High Threshold', visible=True)

    def __call__(self, input_image, resolution, slider_1=None, slider_2=None, slider_3=None, **kwargs):
        input_image, remove_pad = resize_image_with_pad(input_image, resolution)
        canny_image = cv2.cvtColor(cv2.Canny(input_image, int(slider_1), int(slider_2)), cv2.COLOR_GRAY2RGB)
        return remove_pad(canny_image)


add_preprocessor(PreprocessorNone)
add_preprocessor(PreprocessorCanny)
