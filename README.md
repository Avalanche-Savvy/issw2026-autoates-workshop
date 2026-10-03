# ISSW 2026 workshop: autoATES v3.0

A full-day tutorial on producing automated Avalanche Terrain Exposure Scale
(autoATES) maps with open-source tools.

- **When:** Saturday 3 October 2026, 09:00–16:00
- **Where:** Aava Hotel, Peak Room, Whistler, BC
- **Who:** Practitioners, researchers, and consultants. You can run the
  notebooks on a laptop, or follow the same maps on the projector.

This repository is the participant kit: notebooks, the Connaught Creek
dataset, reference outputs for each step, and the schedule. It is separate
from the research tree used to build the western Canada production maps.

**If you want to run the models:** start with [SETUP.md](SETUP.md), or
with [DOCKER.md](DOCKER.md) if you have Docker (fastest).  
**If you want the day plan:** [SCHEDULE.md](SCHEDULE.md).  
**Email to participants:** [participant/EMAIL.md](participant/EMAIL.md).

## Following along or watching

The room is set up for both. The projector shows the same maps as the
notebooks. If you are on a laptop and a step does not finish, copy that
module’s `outputs_reference/` folder and continue with the group — those
files are there so a stalled run does not put you behind.

| | On a laptop | Watching |
|---|---|---|
| Software | Python 3.11 environment + QGIS | Optional |
| During the day | Run the notebook for the current module | Same maps on the projector; questions welcome |
| If a step fails | Copy `outputs_reference/` and go on | Stay with the discussion |
| You leave with | A Connaught Creek ATES map you produced or assembled | The method, the design choices, and where to get the code |

Colleagues from SFU and BFW will be in the room to help with installs
and with the Flow-Py block.

## Live site: Connaught Creek

We will map **Connaught Creek, Rogers Pass** (13 km²). It is the held-out
comparison drainage from the ISSW talks, and small enough that Flow-Py
finishes on a laptop.

We use the production data stack, not the 5 m lidar from the multi-agency
comparison:

- ALOS AW3D30 (~30 m surface; ~21 m on this projected clip)
- Sentinel-2 forest (operational binary layer, then canopy cover and gap area)
- Typical and infrequent potential release area (PRA)
- com4FlowPy runout at alpha 30° (typical) and 18° (infrequent)
- autoATES v3.0 classifier

On a desktop with numba, the full chain on this clip takes about 5 seconds.
Laptops will be slower. Reference outputs are in
`data/<step>/outputs_reference/` if a step does not finish.

## Before Saturday

Pick one of the two setups:

- **Docker (fastest).** One download, no conda, compiler, or extra clones.
  Follow [DOCKER.md](DOCKER.md) (macOS, Windows, Linux), then run
  `docker compose run --rm workshop python check_setup.py`.
- **conda.** Follow [SETUP.md](SETUP.md): Miniforge, QGIS, three git clones,
  and `conda env create`. Then run `python check_setup.py`.

Either way, check that the lines print `OK`, and skim
[SCHEDULE.md](SCHEDULE.md). The papers are optional background.

### Docker quick start

With Docker installed and running ([DOCKER.md](DOCKER.md) step 1):

```bash
git clone -b docker https://github.com/Avalanche-Savvy/issw2026-autoates-workshop.git
cd issw2026-autoates-workshop
docker compose pull      # ~1 GB download, once
docker compose up
```

Open http://localhost:8888 and start with `notebooks/00_orientation.ipynb`
(kernel **autoATES workshop**). Outputs are written into this folder, so
QGIS on your laptop can open them.

The prebuilt image (linux/amd64 and linux/arm64, so Apple Silicon runs it
natively) is published in two places:

| Registry | Image |
|---|---|
| GitHub Container Registry (default) | `ghcr.io/surfjedi/issw2026-autoates-workshop:latest` |
| Docker Hub (backup) | `docker.io/surfjedi/issw2026-autoates-workshop:latest` |

To use the Docker Hub copy, set
`WORKSHOP_IMAGE=docker.io/surfjedi/issw2026-autoates-workshop:latest`
before `docker compose pull` and `up`. If neither download works,
`docker compose build` builds the same image locally (10–20 minutes).

If the install is still giving you trouble, please still come. You will
see every step on the projector, and you can run the notebooks later from
this repository. SETUP.md includes a prompt you can paste into ChatGPT,
Claude, Copilot, or Grok for PATH / conda / GDAL errors. Helpers will be
in the Peak Room from 08:15, and we will have USB copies of the folders.

Conference networks are often slow with a few dozen people downloading
the same packages. Please get the three folders onto disk before you
travel if you can. With Docker, run `docker compose pull` before you travel.

## Repository layout

```
check_setup.py             environment check
SETUP.md                   install, including a short conda walkthrough
DOCKER.md                  Docker setup for macOS / Windows / Linux
Dockerfile, docker-compose.yml   the workshop image and how to run it
SCHEDULE.md                Saturday timetable
notebooks/                 00–06, run in order
data/<step>/inputs/        what that step needs
data/<step>/outputs_reference/   known-good result if you skip or stall
config/                    workshop autoATES + Flow-Py settings
qgis/                      ATES colour ramp + day-of load order
slides/                    observer / projector deck (pptx + pdf)
participant/               email to send
helpers/                   notes for instructors
```

## Citation

See [CITING.md](CITING.md). Maps produced in this workshop are a tutorial
product, not an operational ATES map.
