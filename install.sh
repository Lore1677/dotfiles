#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Dotfiles directory
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.config-backup-$(date +%Y%m%d-%H%M%S)"

echo -e "${BLUE}================================${NC}"
echo -e "${BLUE}  Dotfiles Installation Script  ${NC}"
echo -e "${BLUE}================================${NC}\n"

# Function to print colored messages
print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_info() {
    echo -e "${BLUE}➜${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

# Function to backup existing configs
backup_config() {
    local file=$1
    if [ -e "$file" ]; then
        mkdir -p "$BACKUP_DIR"
        cp -r "$file" "$BACKUP_DIR/"
        print_warning "Backed up existing $(basename $file) to $BACKUP_DIR"
    fi
}

# Check if running on Arch Linux
if [ ! -f /etc/arch-release ]; then
    print_warning "This script is designed for Arch Linux. Proceeding anyway..."
fi

# Ask for confirmation
echo -e "\nThis script will:"
echo "  • Backup existing configs to $BACKUP_DIR"
echo "  • Install dotfiles from $DOTFILES_DIR"
echo "  • Create necessary symlinks"
echo ""
read -p "Continue? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    print_error "Installation cancelled"
    exit 1
fi

# Create backup directory
mkdir -p "$BACKUP_DIR"
print_success "Created backup directory: $BACKUP_DIR"

# Backup and install .config files
print_info "Installing .config files..."
for config in "$DOTFILES_DIR/.config"/*; do
    if [ -d "$config" ]; then
        config_name=$(basename "$config")
        backup_config "$HOME/.config/$config_name"
        
        # Create symlink or copy
        if [ -L "$HOME/.config/$config_name" ]; then
            rm "$HOME/.config/$config_name"
        fi
        
        ln -sf "$config" "$HOME/.config/$config_name"
        print_success "Installed $config_name"
    fi
done

# Install home directory dotfiles
print_info "\nInstalling home directory dotfiles..."
for dotfile in "$DOTFILES_DIR"/.zshrc "$DOTFILES_DIR"/.bashrc "$DOTFILES_DIR"/.Xresources; do
    if [ -f "$dotfile" ]; then
        dotfile_name=$(basename "$dotfile")
        backup_config "$HOME/$dotfile_name"
        ln -sf "$dotfile" "$HOME/$dotfile_name"
        print_success "Installed $dotfile_name"
    fi
done

# Optional: Install packages
echo ""
read -p "Install required packages? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    print_info "Installing packages..."
    
    # Essential packages
    PACKAGES=(
        "hyprland"
        "waybar"
        "rofi"
        "kitty"
        "cava"
        "swaync"
        "hyprlock"
        "hypridle"
        "matugen"
        "zsh"
        "git"
        "swww"
        "htop"
        "nvim"
        "nano"
        "curl"
        "swayimg"
        "pavucontrol"
        "networkmanager"
        "flatpak"
        "grim"
        "yazi"
        "tree"
        "zip"
        "unzip"
        "ark"
    )
    
    sudo pacman -S --needed "${PACKAGES[@]}"
    print_success "Packages installed"
    
    # Optional AUR packages
   read -p "Install AUR packages? (requires yay) (y/N): " -n 1 -r
echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        if command -v yay &> /dev/null; then
            # AUR packages list
            AUR_PACKAGES=(
                "hyprpicker-git"
                "swww"
                "hyprshot"
                # Aggiungi qui i tuoi pacchetti
                # "nome-pacchetto1"
                # "nome-pacchetto2"
            )
            
            print_info "Installing AUR packages..."
            yay -S --needed "${AUR_PACKAGES[@]}"
            print_success "AUR packages installed"
        else
            print_error "yay not found. Install it first."
        fi
    fi
fi

# Set Zsh as default shell
if command -v zsh &> /dev/null; then
    if [ "$SHELL" != "$(which zsh)" ]; then
        read -p "Set Zsh as default shell? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            chsh -s "$(which zsh)"
            print_success "Zsh set as default shell (restart required)"
        fi
    fi
fi

# Reload Hyprland config
if pgrep -x "Hyprland" > /dev/null; then
    read -p "Reload Hyprland config? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        hyprctl reload
        print_success "Hyprland config reloaded"
    fi
fi

echo -e "\n${GREEN}================================${NC}"
echo -e "${GREEN}  Installation Complete! 🎉${NC}"
echo -e "${GREEN}================================${NC}"
echo -e "\nBackups saved to: $BACKUP_DIR"
echo -e "To restore, copy files from backup directory back to their original locations.\n"
print_info "You may need to restart your session for all changes to take effect."