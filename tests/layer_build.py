import os
import subprocess
import hashlib
import shutil

PYTHON_VERSION = "python3.10"
LAYER_BASE = "sqs_build/layer"
REQUIREMENTS = "requirements.txt"
OUTPUT_MANIFEST = "sqs_build/layer_manifest.json"

def hash_dep(dep):
    return hashlib.md5(dep.encode()).hexdigest()[:8]

layers = []
with open(REQUIREMENTS) as f:
    for dep in f:
        dep = dep.strip()
        if not dep or dep.startswith("#"):
            continue
        dep_name = dep.split("==")[0].split(">")[0].split("<")[0].strip()
        dep_hash = hash_dep(dep)
        # Lambda Layer structure: zip must contain 'python' folder at root
        layer_dir = f"sqs_build/layer/layer_{dep_name}_{dep_hash}"
        site_packages_dir = f"{layer_dir}/python/lib/{PYTHON_VERSION}/site-packages"
        os.makedirs(site_packages_dir, exist_ok=True)
        print(f"Installing {dep} to {site_packages_dir} ...")
        subprocess.run([
            "python", "-m", "pip", "install", "--no-user", dep,
            "-t", site_packages_dir
        ], check=True)
        # Zip the layer so that 'python' is at the root of the zip
        layer_zip = f"sqs_build/layer/layer_{dep_name}_{dep_hash}.zip"
        shutil.make_archive(
            base_name=os.path.splitext(layer_zip)[0],
            format="zip",
            root_dir=layer_dir,
            base_dir="python"
        )
        layers.append({"dep": dep, "zip": layer_zip})
        subprocess.run(["rm", "-rf", layer_dir])

import json
with open(OUTPUT_MANIFEST, "w") as f:
    json.dump(layers, f, indent=2)
print(f"Layer manifest written to {OUTPUT_MANIFEST}")