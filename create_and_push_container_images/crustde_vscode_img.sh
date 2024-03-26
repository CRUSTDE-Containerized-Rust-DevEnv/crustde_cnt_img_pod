#!/bin/sh

# README:

echo " "
echo "\033[0;33m    Bash script to build the docker image for development in Rust with VSCode. \033[0m"
echo "\033[0;33m    Name of the image: crustde_vscode_img \033[0m"
# repository: https://github.com/CRUSTDE-ContainerizedRustDevEnv/crustde_cnt_img_pod

echo "\033[0;33m    Container image for CRUSTDE - Containerized Rust Development Environment with VSCode. \033[0m"
echo "\033[0;33m    This is based on crustde_cross_img and adds VSCode and extensions. \033[0m"

echo " "
echo "\033[0;33m    FIRST !!! \033[0m"
echo "\033[0;33m    Search and replace in this bash script: \033[0m"
echo "\033[0;33m    Version of rustc: 1.77.0 \033[0m"
echo "\033[0;33m    Version of vscode: 1.87.2 \033[0m"
echo "\033[0;33m    Commit hash of VSCode: 863d2581ecda6849923a2118d93a088b0745d9d6 \033[0m"

echo "\033[0;33m    To build the image, run in bash with: \033[0m"
echo "\033[0;33m sh crustde_vscode_img.sh \033[0m"

# Start of script actions:

echo " "
echo "\033[0;33m    Removing container and image if exists \033[0m"
# Be careful, this container is not meant to have persistent data.
# the '|| :' in combination with 'set -e' means that 
# the error is ignored if the container does not exist.
set -e
podman rm crustde_vscode_cnt || :
buildah rm crustde_vscode_img || :
buildah rmi -f docker.io/bestiadev/crustde_vscode_img || :

echo " "
echo "\033[0;33m    Create new 'buildah container' named crustde_vscode_img from crustde_cross_img \033[0m"
set -o errexit

buildah from \
--name crustde_vscode_img \
docker.io/bestiadev/crustde_cross_img:cargo-1.77.0

buildah config \
--author=github.com/bestia-dev \
--label name=crustde_vscode_img \
--label version=vscode-1.87.2 \
--label source=github.com/CRUSTDE-ContainerizedRustDevEnv/crustde_cnt_img_pod \
crustde_vscode_img

echo " "
echo "\033[0;33m    The subsequent commands are from user rustdevuser. \033[0m"
echo "\033[0;33m    If I need, I can add '--user root' to run as root. \033[0m"

echo " "
echo "\033[0;33m    Prepare directory for public certificates. This is not a secret. \033[0m"
buildah run --user root crustde_vscode_img    mkdir -p /home/rustdevuser/.ssh
buildah run --user root crustde_vscode_img    chmod 700 /home/rustdevuser/.ssh
buildah run --user root crustde_vscode_img    chown -R rustdevuser:rustdevuser /home/rustdevuser/.ssh

echo " "
echo "\033[0;33m    install ssh server \033[0m"
buildah run --user root crustde_vscode_img    apt-get install -y openssh-server

echo " "
echo "\033[0;33m    Download vscode-server. Be sure the commit_sha of the server and client is the same: \033[0m"
echo "\033[0;33m    In VSCode client open Help-About or in the terminal 'code --version' \033[0m" 
echo "\033[0;33m    version vscode 1.87.2 \033[0m"
echo "\033[0;33m    863d2581ecda6849923a2118d93a088b0745d9d6 \033[0m"
buildah run crustde_vscode_img /bin/sh -c 'mkdir -vp ~/.vscode-server/bin/863d2581ecda6849923a2118d93a088b0745d9d6'
buildah run crustde_vscode_img /bin/sh -c 'mkdir -vp ~/.vscode-server/extensions'
buildah run crustde_vscode_img /bin/sh -c 'curl -L https://update.code.visualstudio.com/commit:863d2581ecda6849923a2118d93a088b0745d9d6/server-linux-x64/stable --output /tmp/vscode-server-linux-x64.tar.gz'
buildah run crustde_vscode_img /bin/sh -c 'tar --no-same-owner -xzv --strip-components=1 -C ~/.vscode-server/bin/863d2581ecda6849923a2118d93a088b0745d9d6 -f /tmp/vscode-server-linux-x64.tar.gz'
buildah run crustde_vscode_img /bin/sh -c 'rm /tmp/vscode-server-linux-x64.tar.gz'
buildah run crustde_vscode_img /bin/sh -c '~/.vscode-server/bin/863d2581ecda6849923a2118d93a088b0745d9d6/bin/code-server --extensions-dir ~/.vscode-server/extensions --install-extension streetsidesoftware.code-spell-checker'
buildah run crustde_vscode_img /bin/sh -c '~/.vscode-server/bin/863d2581ecda6849923a2118d93a088b0745d9d6/bin/code-server --extensions-dir ~/.vscode-server/extensions --install-extension rust-lang.rust-analyzer'
buildah run crustde_vscode_img /bin/sh -c '~/.vscode-server/bin/863d2581ecda6849923a2118d93a088b0745d9d6/bin/code-server --extensions-dir ~/.vscode-server/extensions --install-extension davidanson.vscode-markdownlint'
buildah run crustde_vscode_img /bin/sh -c '~/.vscode-server/bin/863d2581ecda6849923a2118d93a088b0745d9d6/bin/code-server --extensions-dir ~/.vscode-server/extensions --install-extension dotjoshjohnson.xml'
buildah run crustde_vscode_img /bin/sh -c '~/.vscode-server/bin/863d2581ecda6849923a2118d93a088b0745d9d6/bin/code-server --extensions-dir ~/.vscode-server/extensions --install-extension serayuzgur.crates'
buildah run crustde_vscode_img /bin/sh -c '~/.vscode-server/bin/863d2581ecda6849923a2118d93a088b0745d9d6/bin/code-server --extensions-dir ~/.vscode-server/extensions --install-extension ms-vscode.live-server'
buildah run crustde_vscode_img /bin/sh -c '~/.vscode-server/bin/863d2581ecda6849923a2118d93a088b0745d9d6/bin/code-server --extensions-dir ~/.vscode-server/extensions --install-extension mtxr.sqltools'
buildah run crustde_vscode_img /bin/sh -c '~/.vscode-server/bin/863d2581ecda6849923a2118d93a088b0745d9d6/bin/code-server --extensions-dir ~/.vscode-server/extensions --install-extension mtxr.sqltools-driver-pg'
buildah run crustde_vscode_img /bin/sh -c '~/.vscode-server/bin/863d2581ecda6849923a2118d93a088b0745d9d6/bin/code-server --extensions-dir ~/.vscode-server/extensions --install-extension znck.grammarly'

echo " "
echo "\033[0;33m    Remove unwanted files \033[0m"
buildah run --user root crustde_vscode_img    apt -y autoremove
buildah run --user root crustde_vscode_img    apt -y clean

echo " "
echo "\033[0;33m    Finally save/commit the image named crustde_vscode_img \033[0m"
buildah commit crustde_vscode_img docker.io/bestiadev/crustde_vscode_img:latest
buildah tag docker.io/bestiadev/crustde_vscode_img:latest docker.io/bestiadev/crustde_vscode_img:vscode-1.87.2
buildah tag docker.io/bestiadev/crustde_vscode_img:latest docker.io/bestiadev/crustde_vscode_img:cargo-1.77.0

echo " "
echo "\033[0;33m    Upload the new image to docker hub. \033[0m"
echo "\033[0;33m    First you need to store the credentials with: \033[0m"
echo "\033[0;32m podman login --username bestiadev docker.io \033[0m"
echo "\033[0;33m    then type docker access token. \033[0m"
echo "\033[0;32m podman push docker.io/bestiadev/crustde_vscode_img:vscode-1.87.2 \033[0m"
echo "\033[0;32m podman push docker.io/bestiadev/crustde_vscode_img:cargo-1.77.0 \033[0m"
echo "\033[0;32m podman push docker.io/bestiadev/crustde_vscode_img:latest \033[0m"

echo " "
echo "\033[0;33m    This image is used solely inside the pod 'crustde_pod'. \033[0m"
echo "\033[0;33m    The command 'sh crustde_pod_create.sh' inside the directory '~/rustprojects/crustde_cnt_img_pod/crustde_install' creates the pod. \033[0m"
echo " "