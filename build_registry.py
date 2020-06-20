#!/usr/bin/env python3
import sys
from pathlib import Path

base = sys.argv[1]

pathlist = Path(base).glob('**/*.tar.gz')
registry = {
}

def build_images(name, images):
    return '{\n' + "\n".join([ f'    {name}_{tag} = {{ image = "${{{image}}}"; tag = "{name}:{tag}"; }};' for tag, image in images.items() ]) + '\n  };'

def build_registry(registry):
    return '{\n' + "\n".join([ f'  {name} = ' + build_images(name, images) for name, images in registry.items() ]) + '\n}'

def print_registry(registry):
    print(build_registry(registry))

for path in pathlist:
    name = path.parts[-2]
    image = str(path.resolve())
    tag = path.parts[-1].split('.', 1)[0]
    if name not in registry:
        registry[name] = {}
    registry[name][tag] = image
print_registry(registry)
