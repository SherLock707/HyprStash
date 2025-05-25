# 🗂️ HyprStash

A versatile window stashing manager for Hyprland that can turn any application into a toggleable stashed window.

## ✨ Features

- **Universal**: Works with any application, not just terminals
- **Customizable sizing**: Support for both pixel and percentage-based dimensions
- **Flexible positioning**: Top, bottom, left, right, or center positioning
- **Smart toggling**: Automatically shows/stashes windows with proper workspace management
- **Window pinning**: Keeps stashed windows visible across workspaces when active
- **Special workspace integration**: Uses Hyprland's special workspace for stashed state

## 📦 Installation

1. Clone the repository:
```bash
git clone https://github.com/SherLock707/HyprStash.git
cd hyprstash
```

2. Make the script executable:
```bash
chmod +x hyprstash.sh
```

3. (Optional) Add to your PATH:
```bash
sudo cp hyprstash.sh /usr/local/bin/hyprstash
```

## 🎯 Usage

### Basic Syntax
```bash
./hyprstash.sh [OPTIONS] -- COMMAND
```

### Options

| Option | Description | Default |
|--------|-------------|---------|
| `-s, --size` | Window size (WIDTHxHEIGHT or WIDTH%xHEIGHT%) | `50x50` |
| `-p, --position` | Spawn position (top/bottom/left/right/center) | `top` |
| `-c, --class` | Window class name for identification | *Required* |
| `-h, --help` | Show help message | - |
| `--` | Separator between options and command | *Required* |

### Examples

#### Stashed Terminal (Foot)
```bash
./hyprstash.sh -s 70x60 -p top -c foot-drop -- foot --app-id foot-drop
```

#### Stashed Terminal with Zellij Session
```bash
./hyprstash.sh -s 60x40 -p top -c foot-drop -- foot --app-id foot-drop -e zellij attach --create scratchpad
```

#### Stashed File Manager
```bash
./hyprstash.sh -s 80x70 -p center -c nemo-drop -- nemo --class nemo-drop
```

#### Stashed Calculator
```bash
./hyprstash.sh -s 400x500 -p right -c calc-drop -- gnome-calculator --class calc-drop
```

#### Stashed Code Editor
```bash
./hyprstash.sh -s 90x80 -p center -c code-drop -- code --class code-drop
```

## ⚙️ Hyprland Configuration

Add keybindings to your `hyprland.conf`:

```conf
# Stashed terminal
bind = SUPER, grave, exec, /path/to/hyprstash.sh -s 70x60 -p top -c foot-drop -- foot --app-id foot-drop

# Stashed file manager  
bind = SUPER SHIFT, E, exec, /path/to/hyprstash.sh -s 80x70 -p center -c nemo-drop -- nemo --class nemo-drop

# Stashed calculator
bind = SUPER, C, exec, /path/to/hyprstash.sh -s 400x500 -p right -c calc-drop -- gnome-calculator --class calc-drop
```

## 🔧 Size and Position Options

### Size Format
- **Pixels**: `800x600`, `1200x800`
- **Percentages**: `50%x40%`, `80%x70%`
- **Mixed**: `800x50%`, `60%x600`

### Position Options
- `top`: Upper area of screen
- `bottom`: Lower area of screen  
- `left`: Left side of screen
- `right`: Right side of screen
- `center`: Center of screen

## 🎛️ How It Works

1. **First call**: Creates the application window, pins it, and shows it on current workspace
2. **Second call**: Unpins the window and stashes it to special workspace (hidden)
3. **Subsequent calls**: Toggles between visible (pinned on current workspace) and stashed (in special workspace)

## 🐛 Troubleshooting

### Window doesn't appear
- Verify the application command works independently
- Check that the class name matches what the application uses
- Use `hyprctl clients` to see actual window classes

### Window appears but script doesn't manage it
- Ensure the class name in the script matches the actual window class
- Some applications need specific flags to set window class (e.g., `--class`, `--app-id`)

### Multiple instances
- Each unique class name creates a separate stashed window instance
- Use different class names for different stashed applications

## 📋 Requirements

- **Hyprland** (Window Manager)
- **jq** (JSON processor)
- **Bash 4.0+**

Install dependencies on Arch Linux:
```bash
sudo pacman -S jq
```

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- [Hyprland](https://hyprland.org/) - Amazing Wayland compositor
- Inspired by stash/scratchpad functionality in tiling window managers

---