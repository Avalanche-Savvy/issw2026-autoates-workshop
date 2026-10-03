# Setup (please do this before 3 October)

We will not spend Saturday morning on installs, so that the day can stay
on the mapping. If you want to run the notebooks, the steps below take
about 30–45 minutes the first time and need admin rights on the laptop.
Helpers will be in the Peak Room from 08:15 with USB copies if anything
is still stuck.

> **Two ways to set up.**
>
> - **Option A — Docker (fastest):** if you have, or can install, Docker,
>   follow [DOCKER.md](DOCKER.md) instead of this page. It is one download
>   and `docker compose up`, with no conda, compiler, or extra clones.
>   You still need QGIS (section 0) to look at the maps.
> - **Option B — conda:** the steps below.

These instructions assume you may not have used conda before.

## What you are installing

| Piece | What it is | Why we use it |
|---|---|---|
| **Miniforge (conda)** | Keeps Python and GIS libraries in their own folder, so they do not conflict with other software on the machine | rasterio / GDAL are difficult to install any other way |
| **`autoates-workshop` env** | That isolated folder, with Python 3.11 and the libraries we use | The notebooks in this repo expect it |
| **Git** | Copies the three code folders from GitHub | You can also download zip files if you prefer |
| **QGIS 3** | A map window | Looking at GeoTIFFs. The models run in Python, not inside QGIS |
| **autoATES v3.0** | The mapping library (ISSW public snapshot) | PRA and the ATES classifier |
| **AvaFrame** | Contains com4FlowPy | Runout |

We clone autoATES and AvaFrame next to the workshop folder. The notebooks
add those clones to Python’s path. Do not `pip install avaframe`. That
install pulls its own pins, including `numpy<2`, and fights this conda
environment. This AvaFrame pin still needs one local compile.
`com4FlowPy` imports `DFAfunctionsCython`, and a git clone only has the
`.pyx` source until you build it. Section 3 does that build inside the
conda environment.

## What you need

- A laptop you can install software on (admin rights).
- 16 GB RAM is more comfortable; 8 GB is the practical minimum.
- About 5 GB free disk.
- Windows, macOS, or Linux. Windows is usually the fussiest because of
  GDAL. If you already use WSL2, that is a good option.
- A C/C++ compiler, for the AvaFrame build in section 3:
  - Linux: `gcc` and `g++`. On Ubuntu, Debian, or Mint:
    `sudo apt install build-essential`
  - macOS: Xcode command-line tools (`xcode-select --install`)
  - Windows: Microsoft C++ Build Tools, with the workload
    “Desktop development with C++”. Run the build from the
    **Miniforge Prompt**, not Git Bash.

If you can, put the project in a path **without spaces**:

- Works well: `C:\issw-workshop\` or `~/Documents/issw-workshop/`
- Often causes trouble: `C:\Users\Alex\My Documents\ISSW workshop\`

## 0. Three installers

Do these once, before the clones.

1. **QGIS 3** — https://qgis.org (the current long-term release is fine).
2. **Git** — https://git-scm.com (Windows: Git for Windows; the defaults are fine).
3. **Miniforge** — https://github.com/conda-forge/miniforge#miniforge3
   - Windows: run the `.exe`. When it asks, allow it to add Miniforge to PATH,
     or use the **Miniforge Prompt** from the Start menu from here on.
   - macOS / Linux: run the `.sh` installer, then open a new terminal.

You will type commands in a **terminal**:

- Windows: **Miniforge Prompt** (usually the least hassle) or Git Bash
- macOS: Terminal
- Linux: any terminal

If a command is not found, close the window and open a new one so PATH
updates.

## 1. Clone the three folders (siblings)

```bash
mkdir issw-workshop
cd issw-workshop

git clone https://github.com/AutoATES/issw2026-autoates-workshop.git
git clone https://github.com/AutoATES/autoATES-v3.0-issw.git

git clone https://github.com/OpenNHM/AvaFrame.git
cd AvaFrame
git checkout c745a2dec4a7
cd ..
```

You should now have:

```
issw-workshop/
  issw2026-autoates-workshop/   ← notebooks and Connaught data
  autoATES-v3.0-issw/           ← ISSW snapshot of the library
  AvaFrame/                     ← com4FlowPy
```

`autoATES-v3.0-issw` is the public ISSW snapshot. Default settings match
the papers. The full development tree stays private while it is still
being tested.

If you would rather not use git, download each repository as a ZIP from
GitHub (green Code button → Download ZIP), unpack, and rename the folders
to match the names above. In that case `git checkout` does not apply —
we can help at the door if the default branch is not the pin we need.

## 2. Create the conda environment

```bash
cd issw2026-autoates-workshop

conda env create -f environment.yml
conda activate autoates-workshop
```

`mamba` works in place of `conda` if that is what Miniforge gave you. The
first run downloads a few hundred MB and can take 10–20 minutes. Hotel
wifi on Saturday morning is a poor time to start that download, so please
do this before you travel if you can.

If you already have Anaconda, still install Miniforge and run these
commands in a Miniforge terminal. Anaconda’s older solver can run out of
memory on this file, and `conda activate` from an Anaconda `(base)` prompt
will not see this environment.

Windows: if `conda` is not found, open **Miniforge Prompt** and try again.
Avoid putting OSGeo4W on PATH in that same window; mixed GDAL installs
are a common source of `import rasterio` failures.

If the prompt still says `(base)`, or `conda` says the environment does
not exist or the shell is not initialized, the `conda` on your `PATH` is
still Anaconda. On macOS or Linux:

```bash
source ~/miniforge3/bin/activate
conda activate autoates-workshop
```

On Windows, close the Anaconda prompt and run the same activate command
from the **Miniforge Prompt**.

## 3. Build AvaFrame’s Flow-Py extension

Stay in the `autoates-workshop` environment. A plain clone cannot import
`com4FlowPy` until this extension is compiled. Do not run
`pip install avaframe`.

```bash
cd ../AvaFrame
python setup.py build_ext --inplace
cd ../issw2026-autoates-workshop
```

The build may print a warning about MoT-Voellmy. Saturday does not use
that module. The build worked if `avaframe/com1DFA/` contains a
`DFAfunctionsCython` file ending in `.so` (Linux, macOS) or `.pyd`
(Windows).

If the compiler is missing, install it (see “What you need” above) and
run the build commands again.

## 4. Check that it worked

Still in the `autoates-workshop` environment, from the workshop repo folder:

```bash
python check_setup.py
```

You want every line to start with `OK`. Then:

```bash
python -m ipykernel install --user --name autoates-workshop --display-name "autoATES workshop"
jupyter lab notebooks/00_orientation.ipynb
```

In JupyterLab, pick the kernel **autoATES workshop**. A kernel named only
“Python 3” is often the system Python, which does not have rasterio.

Open QGIS once to confirm it launches. You do not need a project file yet.
To look at a map: Layer → Add Raster →
`data/05_ates/outputs_reference/ATES_classification.tif`, then Layer
Properties → Symbology → Style → Load → `qgis/ates_classes.qml`.

## 5. What “done” looks like

- [ ] `conda activate autoates-workshop` works
- [ ] `python setup.py build_ext --inplace` has been run in `AvaFrame`
- [ ] `python check_setup.py` prints only `OK` lines
- [ ] JupyterLab opens `00_orientation.ipynb` with the workshop kernel
- [ ] QGIS opens
- [ ] `data/01_elevation/inputs/alos_aw3d30_connaught.tif` exists (it ships
      in the repo; you should not need a separate data download)

You do not need to run notebooks 01–05 in advance.

## If something fails

Paste the block below into ChatGPT, Claude, Copilot, Grok, or a similar
tool. Those are useful for PATH, conda, and GDAL errors. They are not a
substitute for the people in the room, and they should not be used to
change PRA or Flow-Py parameters.

```
I am setting up a conda-forge Python 3.11 environment for an ISSW workshop
on avalanche terrain mapping (autoATES, rasterio, geopandas, AvaFrame
com4FlowPy).

Operating system:
<Windows 11 / macOS version / Linux distro>

The folder layout is:
  issw-workshop/issw2026-autoates-workshop
  issw-workshop/autoATES-v3.0-issw
  issw-workshop/AvaFrame

The command I ran:
<paste the command>

The full error:
<paste>

Please help me fix the install. Prefer conda-forge packages. Avoid mixing
pip-installed GDAL/rasterio with conda GDAL. Avoid putting OSGeo4W on PATH
together with this environment. Do not pip install avaframe. If the error
is "No module named avaframe.com1DFA.DFAfunctionsCython", run
"python setup.py build_ext --inplace" in the AvaFrame clone, inside the
autoates-workshop environment. If the error is a missing module such as
deepmerge, contextily, or tabulate, install that package from conda-forge
into autoates-workshop. Do not downgrade numpy to 1.x.
```

If it is still stuck:

1. Come to the Peak Room at 08:15. Bring the error text (a screenshot is fine).
2. We will try to get you running. If we cannot before 09:00, you are
   still welcome to follow on the projector and try again at lunch. You
   can run the notebooks later from the same repo.
3. A short list of known issues is in
   [helpers/KNOWN_ISSUES.md](helpers/KNOWN_ISSUES.md).

## Pins

Reference outputs were built 16 September 2026 with:

| Package | Source | Pin |
|---|---|---|
| autoATES v3.0 (ISSW snapshot) | `github.com/AutoATES/autoATES-v3.0-issw` | `main` (from private commit `adb83f616576`) |
| AvaFrame | `github.com/OpenNHM/AvaFrame` | `c745a2dec4a7` |
| Forest product | Sentinel-2 T11UMS | summer 2024-08-31, winter 2024-03-24 |

Numba is in the environment because it makes Flow-Py much faster. If
Flow-Py falls back to the pure-Python engine, use the reference runout
rasters rather than waiting through the block.

## A few things that tend to go wrong

- Creating this environment with an old Anaconda `(base)`. Conda 22’s
  classic solver can be killed after using tens of GB of RAM. Install
  Miniforge and create the env from a Miniforge terminal.
- `pip install avaframe`, or `pip install rasterio` / `pip install gdal`
  on top of conda.
- Skipping the AvaFrame build in section 3.
  `ModuleNotFoundError: avaframe.com1DFA.DFAfunctionsCython` means that
  build has not been run. `deepmerge`, `contextily`, `tabulate`, or
  `shapefile` means the environment was created from an older
  `environment.yml`.
- Mixing this conda env, a system Python, and OSGeo4W in one terminal.
- Cloning a private development copy of autoATES instead of
  **`autoATES-v3.0-issw`**. The workshop repo is the lesson; that
  snapshot is the library.
- Downloading a new DEM or Sentinel tile for Saturday. Connaught is
  already in `data/`.
