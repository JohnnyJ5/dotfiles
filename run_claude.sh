#!/usr/bin/env bash

# Resolve the dotfiles directory from the script's own location so this script
# works when invoked from any project directory.
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_REPO="git@github.com:JohnnyJ5/dotfiles.git"
CLAUDE_CONFIG_DIR="$HOME/.config"

# Derive a per-project container/image name from the current directory so the
# same script can manage independent containers for different repositories.
PROJECT_NAME="$(basename "$(pwd)")"
CONTAINER_NAME="claude-${PROJECT_NAME}"
IMAGE_NAME="claude-cli-env-${PROJECT_NAME}"

# Use a project-local Dockerfile.claude if one exists; otherwise fall back to
# the generic one shipped with this dotfiles repo.
if [ -f "$(pwd)/Dockerfile.claude" ]; then
    DOCKERFILE="$(pwd)/Dockerfile.claude"
    BUILD_CONTEXT="$(pwd)"
    # entrypoint.sh must be available in the build context.  Copy it from
    # dotfiles if the project hasn't supplied its own copy.
    if [ ! -f "$(pwd)/entrypoint.sh" ]; then
        cp "${DOTFILES_DIR}/entrypoint.sh" "$(pwd)/entrypoint.sh"
        COPIED_ENTRYPOINT=1
    fi
else
    DOCKERFILE="${DOTFILES_DIR}/Dockerfile.claude"
    BUILD_CONTEXT="${DOTFILES_DIR}"
fi

DOCKER_COMMON=(
    # -e HOME=/app/.claude_workspace_env
    -e GIT_SSH_COMMAND="ssh -i /home/claude/.ssh/claude_github -o StrictHostKeyChecking=no -o IdentitiesOnly=yes"
    -e HOST_UID="$(id -u)"
    -e HOST_GID="$(id -g)"
    -v "$(pwd)":/app
    -v "$HOME/.ssh/claude_github:/home/claude/.ssh/claude_github:ro"
)

##token expires in one year
setup_gh_token() {
if [ -f "$CLAUDE_CONFIG_DIR/gh/claude_gh_token" ]; then
    GH_TOKEN_VALUE=$(cat "$CLAUDE_CONFIG_DIR/gh/claude_gh_token")
elif [ -n "${GH_TOKEN:-}" ]; then
    GH_TOKEN_VALUE="$GH_TOKEN"
else
    echo "WARNING: No GH_TOKEN found. gh commands will not be authenticated."
    echo "  Fix: echo 'ghp_yourtoken' > ~/.config/gh/claude_gh_token && chmod 600 ~/.config/gh/claude_gh_token"
    GH_TOKEN_VALUE=""
fi

DOCKER_COMMON+=(
    -e GH_TOKEN="${GH_TOKEN_VALUE}"
)

}

setup_ssh_config() {

if [ ! -f "$HOME/.ssh/claude_github" ]; then
    echo "ERROR: SSH key not found at ~/.ssh/claude_github"
    exit 1
fi

SSH_CONFIG_FILE="$HOME/.ssh/claude_ssh_config"
cat > "${SSH_CONFIG_FILE}" <<'EOF'
Host github.com
    HostName github.com
    User git
    IdentityFile ~/.ssh/claude_github
    IdentitiesOnly yes
    StrictHostKeyChecking no
EOF
chmod 600 "${SSH_CONFIG_FILE}"

DOCKER_COMMON+=(
    -v "${SSH_CONFIG_FILE}:/home/claude/.ssh/config:ro"
)

}

cleanup_copied_entrypoint() {
    if [ "${COPIED_ENTRYPOINT:-0}" = "1" ]; then
        rm -f "$(pwd)/entrypoint.sh"
    fi
}

# Main execution
if [ "$(docker ps -q -f name=^${CONTAINER_NAME}$)" ]; then
    echo "Container '${CONTAINER_NAME}' is already running"
    echo "Logging you into bash..."
    docker exec -it -u claude ${CONTAINER_NAME} bash
else
    echo "Starting container '${CONTAINER_NAME}' for project '${PROJECT_NAME}'"
    setup_gh_token
    setup_ssh_config

    # docker build --no-cache --pull -t "${IMAGE_NAME}" -f "${DOCKERFILE}" "${BUILD_CONTEXT}"
    docker build -t "${IMAGE_NAME}" -f "${DOCKERFILE}" "${BUILD_CONTEXT}"
    trap cleanup_copied_entrypoint EXIT

    docker run --rm -it --name "${CONTAINER_NAME}" "${DOCKER_COMMON[@]}" "${IMAGE_NAME}" bash  -c "
            if [ ! -d /home/claude/dotfiles ]; then
                echo 'Cloning dotfiles...'
                git clone ${DOTFILES_REPO} /home/claude/dotfiles
            fi
            cd /home/claude/dotfiles &&
            git pull origin main &&
            ./install.sh && cd /app && exec bash
            "

fi
