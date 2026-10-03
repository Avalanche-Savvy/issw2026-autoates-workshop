# Setup with Docker (fastest)

The workshop Docker image already contains everything from
[SETUP.md](SETUP.md) sections 1–4: the conda environment, autoATES v3.0
(ISSW snapshot), AvaFrame at the workshop pin with its Flow-Py extension
built, and JupyterLab with the **autoATES workshop** kernel. You do not need
Miniforge, a compiler, or the two library clones.

What you do need:

- Docker (step 1 below)
- this repository, which holds the notebooks and the Connaught data (step 2)
- QGIS if you want to look at the maps outside the notebooks
  ([SETUP.md](SETUP.md) section 0)
- about 6 GB free disk, and 8 GB RAM or more

Plan on 15–30 minutes: most of that is the one-time ~1 GB download. Please
do it before you travel. Hotel wifi on Saturday morning is a poor time to
start.

Jump to your system:
[macOS](#1-install-docker--macos) ·
[Windows](#1-install-docker--windows) ·
[Linux](#1-install-docker--linux)

---

## 1. Install Docker — macOS

1. Check your chip:  → **About This Mac**. "Apple M1/M2/M3/M4…" is
   Apple Silicon; "Intel" is Intel.
2. Download **Docker Desktop** for that chip from
   https://www.docker.com/products/docker-desktop/ and open the `.dmg`.
3. Drag **Docker** into **Applications**, then open it from Applications.
   Accept the terms and allow the privileged helper when asked (needs your
   Mac password). You can skip signing in.
4. Wait until the whale icon in the menu bar stops animating
   ("Docker Desktop is running").
5. Give it enough memory: Docker Desktop → **Settings** (gear) →
   **Resources** → Memory **8 GB** or more, CPUs 4 or more → **Apply & restart**.
6. Open **Terminal** (Applications → Utilities) and check:

   ```bash
   docker version
   docker compose version
   ```

   Both should print version numbers with no error.

Continue at [step 2](#2-get-this-repository).

## 1. Install Docker — Windows

Windows 10 (22H2) or Windows 11, 64-bit. You need admin rights once.

1. Turn on WSL 2 (Docker uses it to run Linux). Open **PowerShell as
   Administrator** (Start → type "PowerShell" → right-click → Run as
   administrator) and run:

   ```powershell
   wsl --install
   ```

   Restart Windows when it finishes. If it says WSL is already installed,
   run `wsl --update` instead.
2. Download **Docker Desktop for Windows** from
   https://www.docker.com/products/docker-desktop/ and run the installer.
   Keep **"Use WSL 2 instead of Hyper-V"** ticked. Log out / restart if asked.
3. Start **Docker Desktop** from the Start menu. Accept the terms; you can
   skip signing in. Wait until it says **Engine running** (bottom left).
4. Memory: with WSL 2, Docker can use up to half your RAM by default, which
   is enough on a 16 GB laptop. On an 8 GB laptop, give WSL more: create the
   file `C:\Users\<you>\.wslconfig` containing

   ```ini
   [wsl2]
   memory=6GB
   ```

   then run `wsl --shutdown` in PowerShell and start Docker Desktop again.
5. Open **PowerShell** (normal, not admin) and check:

   ```powershell
   docker version
   docker compose version
   ```

   Both should print version numbers with no error.

Continue at [step 2](#2-get-this-repository).

## 1. Install Docker — Linux

Docker Engine with the compose plugin. On Ubuntu, Debian, Mint, Fedora and
most others, Docker's install script is the quickest route:

```bash
curl -fsSL https://get.docker.com | sudo sh
sudo usermod -aG docker $USER      # lets you run docker without sudo
```

**Log out and back in** (or reboot) so the group change applies. Then check:

```bash
docker version
docker compose version
docker run --rm hello-world
```

All three should work without `sudo`. If you prefer distribution packages
or the step-by-step method, see https://docs.docker.com/engine/install/.

On Linux, Docker uses your machine's memory directly; there is nothing to
configure.

---

## 2. Get this repository

The Docker setup lives on the **`docker`** branch of this repository.

**With git** (macOS Terminal, Linux terminal, or Windows PowerShell / Git Bash):

```bash
git clone -b docker https://github.com/Avalanche-Savvy/issw2026-autoates-workshop.git
cd issw2026-autoates-workshop
```

If you already have a clone: `git fetch && git switch docker`.

**Without git:** download
https://github.com/Avalanche-Savvy/issw2026-autoates-workshop/archive/refs/heads/docker.zip,
unzip it, and `cd` into the unzipped folder
(`issw2026-autoates-workshop-docker`).

Pick a folder path **without spaces**, for example
`~/Documents/issw-workshop/` or `C:\issw-workshop\`.

## 3. Download the image and start JupyterLab

From inside the repository folder:

```bash
docker compose pull
```

This downloads the prebuilt image once (~1 GB download, 3.6 GB on disk;
about 4 minutes on a fast connection). Docker picks the right version for
your chip automatically.

Then start it:

**macOS and Windows:**

```bash
docker compose up
```

**Linux** (so the files it writes belong to you, not to another user id):

```bash
HOST_UID=$(id -u) HOST_GID=$(id -g) docker compose up
```

Leave this terminal window open. Jupyter's log scrolls there while it runs.

## 4. Open the notebooks

In your web browser go to:

**http://localhost:8888**

JupyterLab opens with no password. In the file browser on the left, open
`notebooks` → `00_orientation.ipynb`. Or go straight to
http://localhost:8888/lab/tree/notebooks/00_orientation.ipynb.

If JupyterLab asks for a kernel, choose **autoATES workshop**.
Run a cell with **Shift+Enter**.

## 5. Check the setup (optional, recommended)

In a **second** terminal, in the same folder:

```bash
docker compose run --rm workshop python check_setup.py
```

Every line should start with `OK`, ending with "All checks passed".

## Stopping, restarting, updating

| To… | Do this |
|---|---|
| Stop | Press `Ctrl+C` in the terminal running `docker compose up` (or run `docker compose down` from another terminal) |
| Start again later | `cd` into the folder, `docker compose up`, open http://localhost:8888. No new download. |
| Get the latest image | `docker compose pull` |
| Remove it all afterwards | `docker compose down --rmi all` (your folder and outputs stay) |

## Where your files are

Your repository folder is shared with the container (mounted at
`/workshop`):

- notebook edits are saved in your folder;
- outputs (`outputs/`, `notebooks/work/`) appear in your folder, so you can
  open them in QGIS on your laptop as described in SETUP.md section 4.

Nothing outside that folder changes.

## If the download does not work

First try the copy on Docker Hub (same image):

- macOS / Linux: `WORKSHOP_IMAGE=docker.io/surfjedi/issw2026-autoates-workshop:latest docker compose pull`
- Windows PowerShell: `$env:WORKSHOP_IMAGE="docker.io/surfjedi/issw2026-autoates-workshop:latest"; docker compose pull`

Keep the same `WORKSHOP_IMAGE` setting when you run `docker compose up`.

Otherwise build the image yourself from the same folder (needs internet for
10–20 minutes):

```bash
docker compose build
```

Then continue with `docker compose up` as above.

## Troubleshooting

| Symptom | Fix |
|---|---|
| `Cannot connect to the Docker daemon` / `docker: command not found` | Docker Desktop is not running: start it and wait until it is ready. Linux: log out and in after `usermod`, or `sudo systemctl start docker`. |
| `port is already allocated` / `address already in use` | Something else uses port 8888 (often a Jupyter started outside Docker). Stop it, or use another port: macOS/Linux `JUPYTER_PORT=8899 docker compose up`; Windows PowerShell `$env:JUPYTER_PORT=8899; docker compose up`. Then open http://localhost:8899. |
| Browser shows "This site can't be reached" | Wait until the terminal shows `Jupyter Server … is running at`, and use `http://` (not `https://`). |
| Flow-Py cell dies / kernel restarts | Not enough memory: raise it (macOS step 5, Windows step 4). Or copy that module's `outputs_reference/` folder and carry on. |
| `Permission denied` writing outputs (Linux) | Start with `HOST_UID=$(id -u) HOST_GID=$(id -g) docker compose up` as in step 3. |
| `no configuration file provided: not found` | You are not in the repository folder, or you are on `main` instead of the `docker` branch (step 2). |
| `denied` / `unauthorized` on `docker compose pull` | Run `docker logout ghcr.io` and pull again, or use the Docker Hub copy (above). |
| `toomanyrequests` from Docker Hub | Docker Hub's limit for anonymous downloads on a shared connection. Use the default GHCR image, or `docker login` with a free Docker Hub account first. |
| Windows: `WSL 2 installation is incomplete` | Run `wsl --update` in PowerShell, then restart Docker Desktop. |
| Windows: virtualization not enabled | Enable virtualization (Intel VT-x / AMD-V, sometimes called SVM) in the BIOS/UEFI settings, then try again. |
| Very slow on Windows | Clone the repository inside WSL (`wsl`, then `cd ~` and clone there) and run `docker compose up` from that WSL shell. |

Still stuck: bring the error text (a screenshot is fine) to the Peak Room
at 08:15, or use the conda route in [SETUP.md](SETUP.md).

---

## Maintainers

- `.github/workflows/docker.yml` builds `linux/amd64` + `linux/arm64` on
  native runners, runs `check_setup.py` and a JupyterLab smoke test in each,
  and pushes `ghcr.io/avalanche-savvy/issw2026-autoates-workshop`
  (`:latest`, `:sha-…`, branch tags).
- The fork's own package cannot be made public, so the publish job mirrors
  each build to public copies:
  - `ghcr.io/surfjedi/issw2026-autoates-workshop` (the `docker-compose.yml`
    default, public): secret `GHCR_MIRROR_TOKEN` (classic PAT,
    `write:packages`) + variable `GHCR_MIRROR_OWNER`.
  - `docker.io/surfjedi/issw2026-autoates-workshop` (public backup): secret
    `DOCKERHUB_TOKEN` (Docker Hub access token, Read & Write) + variable
    `DOCKERHUB_USERNAME`. Use with
    `WORKSHOP_IMAGE=docker.io/surfjedi/issw2026-autoates-workshop:latest docker compose pull`.
    Docker Hub limits anonymous pulls per IP, so a room on one hotel
    connection should prefer GHCR.
- Library pins are build args in the `Dockerfile` (`AUTOATES_REF`,
  `AVAFRAME_REF`, full SHAs); `/opt/PINS` in the image records them.
