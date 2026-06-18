local home = os.getenv("HOME") or ("/home/" .. (os.getenv("USER") or "user"))

-- ───────────────────────────── COLOR THEMING ─────────────────────────────
-- Optional pywal integration: if ~/.cache/wal/colors-hyprland.lua exists it is
-- merged over these defaults. Out of the box, the fallback palette is used so
-- the config never fails to load on a fresh NixOS install.
local palette = {
    foreground = "rgba(d6d6d6ff)",
    background = "rgba(0d0d0fff)",
    color1  = "rgba(3a86ffff)",
    color2  = "rgba(9d4eddff)",
    color3  = "rgba(ff7096ff)",
    color4  = "rgba(3a86ffff)",
    color5  = "rgba(9d4eddff)",
    color6  = "rgba(ff7096ff)",
    color7  = "rgba(d6d6d6ff)",
    color8  = "rgba(595959ff)",
    color9  = "rgba(8ab4ffff)",
}

local ok, generated = pcall(dofile, home .. "/.cache/wal/colors-hyprland.lua")
if ok and type(generated) == "table" then
    for k, v in pairs(generated) do palette[k] = v end
end


------------------
---- MONITORS ----
------------------
-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
hl.monitor({
    output   = "eDP-1",
    mode     = "preferred", -- auto-detect the screen's native resolution
    position = "auto",
    scale    = 1.25,
})
-- hl.monitor({ output = "DP-2", mode = "1920x1080@60", position = "1536x0", scale = 1.25 })


---------------------
---- MY PROGRAMS ----
---------------------
local terminal    = "kitty"
local fileManager = "nautilus"
local menu        = "rofi -show drun -backend wayland"
local browser     = "flatpak run app.zen_browser.zen"


-------------------
---- AUTOSTART ----
-------------------
-- Kept intentionally minimal for NixOS. No uwsm, no status bar, no extra
-- daemons. Add your own here, or manage them declaratively in your NixOS /
-- Home Manager config instead.
-- See https://wiki.hypr.land/Configuring/Basics/Autostart/
hl.on("hyprland.start", function()
    -- Polkit authentication agent (so GUI apps can request privileges).
    hl.exec_cmd("systemctl --user enable --now hyprpolkitagent.service")
    -- Status bar (waybar), notifications (swaync), clipboard history
    -- (cliphist) and media control (playerctld) are managed declaratively
    -- as home-manager systemd user services in /etc/nixos/home.nix. Those
    -- services bind to graphical-session.target, so push the compositor env
    -- into the systemd/dbus user session and start the session target that
    -- activates them (hyprland-session.target is defined in home.nix).
    hl.exec_cmd("dbus-update-activation-environment --systemd --all")
    hl.exec_cmd("systemctl --user start hyprland-session.target")
    -- Restore the last wallpaper and recolor the desktop from it (wallust).
    hl.exec_cmd(home .. "/.config/hypr/scripts/theme.sh")
end)


-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------
hl.env("XCURSOR_SIZE", "15")
hl.env("HYPRCURSOR_SIZE", "15")


-----------------------
---- LOOK AND FEEL ----
-----------------------
-- See https://wiki.hypr.land/Configuring/Basics/Variables/
hl.config({
    general = {
        gaps_in  = 2,
        gaps_out = 6,

        border_size = 2,

        -- Animated pywal gradient border on the focused window.
        col = {
            active_border   = { colors = { palette.color4, palette.color5, palette.color6 }, angle = 45 },
            inactive_border = palette.color8,
        },

        resize_on_border = true,
        allow_tearing    = false,
        layout           = "dwindle",
    },

    decoration = {
        rounding       = 12,
        rounding_power = 2,

        active_opacity   = 1.0,
        inactive_opacity = 0.93,

        -- Soft floating drop shadow
        shadow = {
            enabled      = true,
            range        = 20,
            render_power = 3,
            sharp        = false,
            color        = "rgba(00000055)",
        },

        -- Frosted-glass blur
        blur = {
            enabled            = true,
            size               = 8,
            passes             = 3,
            new_optimizations  = true,
            ignore_opacity     = true,
            xray               = false,
            noise              = 0.015,
            contrast           = 1.0,
            brightness         = 1.0,
            vibrancy           = 0.18,
            vibrancy_darkness  = 0.0,
            popups             = true,
            popups_ignorealpha = 0.2,
        },
    },

    animations = {
        enabled = true,
    },

    dwindle = {
        preserve_split = true,
    },

    master = {
        new_status = "master",
    },

    input = {
        kb_layout    = "us",
        follow_mouse = 1,
        sensitivity  = 0,
        scroll_factor = 0.3,
        touchpad = {
            natural_scroll       = true,
            disable_while_typing = true,
            clickfinger_behavior = true,
            scroll_factor        = 0.3,
        },
    },

    misc = {
        force_default_wallpaper = 0,
        disable_hyprland_logo   = true,
        focus_on_activate       = true,
    },

    xwayland = {
        force_zero_scaling = true,
    },
})


------------------
-- ANIMATIONS  ---
------------------
-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Animations/
hl.curve("easeOutQuint",   { type = "bezier", points = { {0.23, 1},    {0.32, 1}  } })
hl.curve("easeInOutCubic", { type = "bezier", points = { {0.65, 0.05}, {0.36, 1}  } })
hl.curve("linear",         { type = "bezier", points = { {0, 0},       {1, 1}     } })
hl.curve("almostLinear",   { type = "bezier", points = { {0.5, 0.5},   {0.75, 1}  } })
hl.curve("quick",          { type = "bezier", points = { {0.15, 0},    {0.1, 1}   } })

-- Springs give that fluid, slightly bouncy feel
hl.curve("snappy", { type = "spring", mass = 1, stiffness = 250, dampening = 22 })
hl.curve("bouncy", { type = "spring", mass = 1, stiffness = 190, dampening = 15 })
-- Near-critically damped (dampening ~= 2*sqrt(stiffness)): glides to rest with
-- no overshoot/bounce for the smoothest window motion.
hl.curve("smooth", { type = "spring", mass = 1, stiffness = 200, dampening = 28 })

hl.animation({ leaf = "global",           enabled = true, speed = 8,  bezier = "easeOutQuint" })
hl.animation({ leaf = "windows",          enabled = true, speed = 6,  spring = "smooth", style = "popin 90%" })
hl.animation({ leaf = "windowsIn",        enabled = true, speed = 6,  spring = "smooth", style = "popin 90%" })
hl.animation({ leaf = "windowsOut",       enabled = true, speed = 5,  bezier = "easeOutQuint", style = "popin 90%" })
hl.animation({ leaf = "windowsMove",      enabled = true, speed = 7,  spring = "smooth" })
hl.animation({ leaf = "fade",             enabled = true, speed = 4,  bezier = "quick" })
hl.animation({ leaf = "fadeDim",          enabled = true, speed = 4,  bezier = "almostLinear" })
hl.animation({ leaf = "layers",           enabled = true, speed = 5,  spring = "snappy", style = "popin 90%" })
hl.animation({ leaf = "layersIn",         enabled = true, speed = 5,  spring = "bouncy", style = "popin 90%" })
hl.animation({ leaf = "layersOut",        enabled = true, speed = 4,  bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "border",           enabled = true, speed = 6,  bezier = "easeOutQuint" })
-- NOTE: `loop` continuously animates the gradient angle (looks great, but keeps
-- the GPU rendering and costs battery). Switch style to "once" to disable.
hl.animation({ leaf = "borderangle",      enabled = true, speed = 40, bezier = "linear", style = "loop" })
hl.animation({ leaf = "workspaces",       enabled = true, speed = 3,  bezier = "easeOutQuint", style = "slidefade 20%" })
hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 6,  spring = "bouncy", style = "slidefadevert 15%" })
hl.animation({ leaf = "zoomFactor",       enabled = true, speed = 7,  bezier = "quick" })


--------------------
---- GESTURES   ----
--------------------
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })

-- Per-device tweaks
hl.device({ name = "logitech-g305-1",        accel_profile = "flat", sensitivity = 0.1 })
hl.device({ name = "tpps/2-elan-trackpoint", accel_profile = "flat", sensitivity = 0 })


---------------------
---- KEYBINDINGS ----
---------------------
-- See https://wiki.hypr.land/Configuring/Basics/Binds/
local mainMod = "SUPER"

-- Launchers / apps (no uwsm prefix — run directly)
hl.bind(mainMod .. " + Return",         hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + E",              hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + SHIFT + Return", hl.dsp.exec_cmd(browser))
hl.bind(mainMod .. " + Space",          hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + W",              hl.dsp.exec_cmd(home .. "/.config/hypr/scripts/wallpaper-picker.sh"))

-- Window management
hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + M", hl.dsp.exit())
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())
hl.bind(mainMod .. " + T", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen({ mode = "maximized", action = "toggle" }))
hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit")) -- dwindle only

-- Screen lock / suspend
hl.bind(mainMod .. " + L", hl.dsp.exec_cmd("loginctl lock-session && sleep 1 && systemctl suspend"))

-- Screenshots (hyprshot)
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd("hyprshot -m region; pkill hyprpicker; pkill hyprshot"))
hl.bind(mainMod .. " + SHIFT + P", hl.dsp.exec_cmd("hyprshot -m output"))

-- Move focus with mainMod + arrow keys
hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down" }))

-- Workspaces: switch (SUPER+N) and move window (SUPER+SHIFT+N)
for i = 1, 10 do
    local key = i % 10 -- 10 maps to key 0
    hl.bind(mainMod .. " + " .. key,         hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Resize the active window with SUPER+SHIFT+arrows
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.resize({ x = 50,  y = 0,   relative = true }))
hl.bind(mainMod .. " + SHIFT + left",  hl.dsp.window.resize({ x = -50, y = 0,   relative = true }))
hl.bind(mainMod .. " + SHIFT + up",    hl.dsp.window.resize({ x = 0,   y = -50, relative = true }))
hl.bind(mainMod .. " + SHIFT + down",  hl.dsp.window.resize({ x = 0,   y = 50,  relative = true }))

-- Scroll through workspaces with mainMod + mouse wheel
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- Move/resize floating windows with mainMod + LMB/RMB drag
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Laptop multimedia & brightness keys
hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      { locked = true, repeating = true })
hl.bind("XF86AudioMute",         hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     { locked = true })
hl.bind("XF86AudioMicMute",      hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),   { locked = true })
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"),                  { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"),                  { locked = true, repeating = true })

-- Media controls (playerctl)
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })


--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------
-- See https://wiki.hypr.land/Configuring/Basics/Window-Rules/

-- Ignore maximize requests from all apps
hl.window_rule({
    name           = "suppress-maximize-events",
    match          = { class = ".*" },
    suppress_event = "maximize",
})

-- Fix some dragging issues with XWayland
hl.window_rule({
    name  = "fix-xwayland-drags",
    match = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },
    no_focus = true,
})

-- Float common dialogs / pickers
hl.window_rule({
    name  = "float-dialogs",
    match = { class = "(pavucontrol|nm-connection-editor|blueman-manager|org.gnome.Calculator|nwg-look|qt5ct|qt6ct)" },
    float = true,
})


--------------------
---- LAYER RULES ---
--------------------
-- Window blur only frosts toplevel windows; layer-shell surfaces (the bar,
-- launcher, notifications) need an explicit rule. These give the translucent
-- rofi / waybar / swaync backgrounds their liquid-glass frost.
-- See https://wiki.hypr.land/Configuring/Window-Rules/#layer-rules
hl.layer_rule({ name = "blur-rofi",   match = { namespace = "^rofi$" },   blur = true, ignore_alpha = 0.5 })
hl.layer_rule({ name = "blur-waybar", match = { namespace = "^waybar$" }, blur = true, ignore_alpha = 0.3 })
hl.layer_rule({ name = "blur-swaync", match = { namespace = "^swaync.*" }, blur = true, ignore_alpha = 0.3 })
