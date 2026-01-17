#!/bin/bash
# Miro Skill Installation Script
# Usage: curl -sSL https://raw.githubusercontent.com/adachi-koichi/ai-tools/main/skills/miro/install.sh | bash

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
REPO="adachi-koichi/ai-tools"
BRANCH="main"
SKILL_DIR="skills/miro"
GITHUB_RAW_BASE="https://raw.githubusercontent.com/${REPO}/${BRANCH}/${SKILL_DIR}"
GITHUB_API_BASE="https://api.github.com/repos/${REPO}/contents/${SKILL_DIR}"

# Detect installation directories in current folder
# Returns newline-separated list of installation directories
detect_install_dirs() {
  local install_dirs=()
  local current_dir="${PWD}"
  
  # Check for .cursor directory in current folder
  if [ -d "${current_dir}/.cursor" ]; then
    install_dirs+=("${current_dir}/.cursor/skills/miro")
  fi
  
  # Check for .codex directory in current folder
  if [ -d "${current_dir}/.codex" ]; then
    install_dirs+=("${current_dir}/.codex/skills/miro")
  fi
  
  # Check for .claude directory in current folder
  if [ -d "${current_dir}/.claude" ]; then
    install_dirs+=("${current_dir}/.claude/skills/miro")
  fi
  
  # Return newline-separated list
  printf '%s\n' "${install_dirs[@]}"
}

# Print functions
print_info() {
  echo -e "${GREEN}[INFO]${NC} $1"
}

print_warn() {
  echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
  echo -e "${RED}[ERROR]${NC} $1" >&2
}

# Check dependencies
check_dependencies() {
  local missing_deps=()
  
  if ! command -v curl &> /dev/null; then
    missing_deps+=("curl")
  fi
  
  if ! command -v jq &> /dev/null; then
    print_warn "jq is not installed. Will use alternative method."
  fi
  
  if [ ${#missing_deps[@]} -gt 0 ]; then
    print_error "Missing required dependencies: ${missing_deps[*]}"
    print_error "Please install them and try again."
    exit 1
  fi
}

# Download file from GitHub
download_file() {
  local filename="$1"
  local target_path="$2"
  local url="${GITHUB_RAW_BASE}/${filename}"
  
  print_info "Downloading: ${filename}"
  
  if curl -sSLf -o "${target_path}" "${url}"; then
    # Make scripts executable
    if [[ "${filename}" == *.sh ]]; then
      chmod +x "${target_path}"
    fi
    return 0
  else
    print_error "Failed to download: ${filename}"
    return 1
  fi
}

# Download all files using GitHub API
download_with_api() {
  local install_dir="$1"
  local failed_files=()
  
  print_info "Fetching file list from GitHub..."
  
  local response=$(curl -sSL "${GITHUB_API_BASE}")
  
  if [ $? -ne 0 ]; then
    print_error "Failed to fetch file list from GitHub API"
    return 1
  fi
  
  # Use array to collect failed files (since while loop runs in subshell)
  local temp_failed="/tmp/miro_install_failed_$$"
  > "$temp_failed"
  
  echo "$response" | jq -r '.[] | select(.type == "file") | .name' | while read -r filename; do
    # Skip install.sh itself
    if [ "${filename}" == "install.sh" ]; then
      continue
    fi
    
    local target_path="${install_dir}/${filename}"
    if ! download_file "${filename}" "${target_path}"; then
      echo "${filename}" >> "$temp_failed"
    fi
  done
  
  if [ -s "$temp_failed" ]; then
    local failed_list=$(cat "$temp_failed" | tr '\n' ' ')
    print_error "Failed to download some files: ${failed_list}"
    rm -f "$temp_failed"
    return 1
  fi
  
  rm -f "$temp_failed"
  return 0
}

# Download files without jq (fallback method)
download_without_jq() {
  local install_dir="$1"
  local files=("SKILL.md" "miro.sh" ".gitignore" ".env.example")
  local failed_files=()
  
  for filename in "${files[@]}"; do
    local target_path="${install_dir}/${filename}"
    if ! download_file "${filename}" "${target_path}"; then
      failed_files+=("${filename}")
    fi
  done
  
  if [ ${#failed_files[@]} -gt 0 ]; then
    print_error "Failed to download some files: ${failed_files[*]}"
    return 1
  fi
  
  return 0
}

# Install to a specific directory
install_to_directory() {
  local install_dir="$1"
  
  print_info "Installing to: ${install_dir}"
  
  # Create installation directory
  mkdir -p "${install_dir}"
  print_info "Created directory: ${install_dir}"
  
  # Download files
  if command -v jq &> /dev/null; then
    print_info "Using GitHub API with jq..."
    if ! download_with_api "${install_dir}"; then
      print_error "Installation to ${install_dir} failed"
      return 1
    fi
  else
    print_info "Using direct download method..."
    if ! download_without_jq "${install_dir}"; then
      print_error "Installation to ${install_dir} failed"
      return 1
    fi
  fi
  
  print_info "Successfully installed to: ${install_dir}"
  return 0
}

# Main installation function
main() {
  print_info "Miro Skill Installation Script"
  print_info "================================="
  print_info "Current directory: ${PWD}"
  
  # Check dependencies
  check_dependencies
  
  # Detect installation directories in current folder
  local install_dirs_list
  install_dirs_list=$(detect_install_dirs)
  
  # Convert to array
  local install_dirs_array=()
  while IFS= read -r line; do
    [ -n "$line" ] && install_dirs_array+=("$line")
  done <<< "$install_dirs_list"
  
  # If no directories found, use fallback
  if [ ${#install_dirs_array[@]} -eq 0 ]; then
    print_warn "No .claude, .codex, or .cursor directories found in current folder"
    print_info "Creating ./skills/miro as fallback..."
    install_dirs_array=("./skills/miro")
  fi
  
  # Count installation directories
  local dir_count=${#install_dirs_array[@]}
  print_info "Found ${dir_count} installation location(s)"
  print_info ""
  
  # Install to each directory
  local success_count=0
  local fail_count=0
  
  for install_dir in "${install_dirs_array[@]}"; do
    if [ -n "$install_dir" ]; then
      print_info "----------------------------------------"
      if install_to_directory "$install_dir"; then
        success_count=$((success_count + 1))
      else
        fail_count=$((fail_count + 1))
      fi
      print_info ""
    fi
  done
  
  # Final summary
  print_info "================================="
  print_info "Installation Summary:"
  for install_dir in "${install_dirs_array[@]}"; do
    if [ -n "$install_dir" ] && [ -d "$install_dir" ]; then
      print_info "✓ ${install_dir}"
      print_info "  Installed files:"
      ls -lh "${install_dir}" 2>/dev/null | tail -n +2 | awk '{print "    - " $9 " (" $5 ")"}' || true
    fi
  done
  print_info ""
  print_info "Next steps:"
  print_info "1. Set up your Miro access token:"
  print_info "   export MIRO_ACCESS_TOKEN='your_access_token_here'"
  print_info "2. Or create .env.local file in the installation directory"
  print_info "3. Use the miro.sh script:"
  for install_dir in "${install_dirs_array[@]}"; do
    if [ -n "$install_dir" ] && [ -d "$install_dir" ]; then
      print_info "   ${install_dir}/miro.sh list-boards"
    fi
  done
}

# Run main function
main "$@"
