{ ... }:
{
  flake.modules.homeManager.workspace-osd =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      rawColors =
        if config ? lib.stylix then
          config.lib.stylix.colors.withHashtag
        else
          {
            base00 = "#272e33";
            base01 = "#2e383c";
            base02 = "#414b50";
            base03 = "#859289";
            base05 = "#d3c6aa";
            base06 = "#edeada";
            base0D = "#7fbbb3";
          };

      fontFamily =
        if config ? stylix.fonts then
          config.stylix.fonts.sansSerif.name
        else
          "DejaVu Sans";

      monoFont =
        if config ? stylix.fonts then
          config.stylix.fonts.monospace.name
        else
          "JetBrainsMono Nerd Font";

      osdScript = pkgs.writeText "workspace-osd.tsx" ''
        import { App, Astal, Gtk } from "astal/gtk3"
        import { Variable, subprocess, GLib } from "astal"

        const icons: Record<string, string> = {
            "personal": "󰄛",
            "study": "󱓷",
            "work": "󰈔",
            "comms": "󰭹",
            "games": "󰊗",
            "media": "󰝚",
            "ops": "󰒋",
            "stash": "󰆓",
        }

        const workspaceName = Variable("Workspace")
        const workspaceIcon = Variable("󰄛")
        const workspaceIdx = Variable("")
        const currentDate = Variable("")
        const currentTime = Variable("")
        const isVisible = Variable(false)

        let hideTimer: any = null

        function showPopup(name: string, idx: string) {
            workspaceName.set(name)
            workspaceIdx.set(idx)
            workspaceIcon.set(icons[name.toLowerCase()] || "󰄛")

            const now = GLib.DateTime.new_now_local()
            currentDate.set(now.format("%a %-d") || "")
            currentTime.set(now.format("%H:%M") || "")

            isVisible.set(true)

            if (hideTimer) {
                GLib.source_remove(hideTimer)
                hideTimer = null
            }

            hideTimer = GLib.timeout_add(GLib.PRIORITY_DEFAULT, 1100, () => {
                isVisible.set(false)
                hideTimer = null
                return GLib.SOURCE_REMOVE
            })
        }

        const workspaceMap = new Map<number, { name: string, idx: number }>()
        const windowMap = new Map<number, number>()
        let activeWs: { name: string, idx: number } | null = null
        let initialized = false

        subprocess(["${pkgs.niri}/bin/niri", "msg", "-j", "event-stream"], (line) => {
            try {
                const event = JSON.parse(line)

                if (event.WorkspacesChanged) {
                    for (const ws of event.WorkspacesChanged.workspaces) {
                        workspaceMap.set(ws.id, {
                            name: ws.name || `Workspace ''${ws.idx}`,
                            idx: ws.idx
                        })
                    }
                    const focused = event.WorkspacesChanged.workspaces.find((w: any) => w.is_focused)
                    if (focused) {
                        const ws = {
                            name: focused.name ? focused.name : `Workspace ''${focused.idx}`,
                            idx: focused.idx
                        }
                        activeWs = ws
                        if (initialized) {
                            showPopup(ws.name, `#''${ws.idx}`)
                        } else {
                            initialized = true
                        }
                    }
                } else if (event.WorkspaceActivated) {
                    if (event.WorkspaceActivated.focused) {
                        const ws = workspaceMap.get(event.WorkspaceActivated.id)
                        if (ws) {
                            activeWs = ws
                            if (initialized) {
                                showPopup(ws.name, `#''${ws.idx}`)
                            }
                        }
                    }
                } else if (event.WindowsChanged) {
                    for (const win of event.WindowsChanged.windows) {
                        windowMap.set(win.id, win.workspace_id)
                    }
                } else if (event.WindowOpenedOrChanged) {
                    const win = event.WindowOpenedOrChanged.window
                    windowMap.set(win.id, win.workspace_id)
                } else if (event.WindowClosed) {
                    windowMap.delete(event.WindowClosed.id)
                } else if (event.WindowFocusChanged) {
                    const winId = event.WindowFocusChanged.id
                    if (winId != null && initialized) {
                        const wsId = windowMap.get(winId)
                        const ws = wsId != null ? workspaceMap.get(wsId) : activeWs
                        if (ws) {
                            activeWs = ws
                            showPopup(ws.name, `#''${ws.idx}`)
                        }
                    }
                }
            } catch (e) {
                // ignore parsing artifacts
            }
        })

        App.start({
            instanceName: "workspace-osd",
            css: `
                window {
                    background-color: transparent;
                }

                .osd-pill {
                    background-color: rgba(46, 56, 60, 0.75);
                    border: 1px solid ${rawColors.base0D};
                    border-radius: 2px;
                    padding: 3px 10px;
                }

                .osd-icon {
                    font-family: "${monoFont}", monospace;
                    font-size: 13px;
                    color: ${rawColors.base0D};
                    margin-right: 6px;
                }

                .osd-name {
                    font-family: "${fontFamily}", sans-serif;
                    font-size: 12px;
                    font-weight: bold;
                    color: ${rawColors.base06};
                    margin-right: 6px;
                }

                .osd-idx {
                    font-family: "${monoFont}", monospace;
                    font-size: 11px;
                    font-weight: normal;
                    color: ${rawColors.base03};
                    margin-right: 6px;
                }

                .osd-sep {
                    font-family: "${fontFamily}", sans-serif;
                    font-size: 11px;
                    color: ${rawColors.base03};
                    margin-right: 6px;
                }

                .osd-date {
                    font-family: "${fontFamily}", sans-serif;
                    font-size: 12px;
                    color: ${rawColors.base05};
                    margin-right: 6px;
                }

                .osd-time {
                    font-family: "${monoFont}", monospace;
                    font-size: 12px;
                    font-weight: bold;
                    color: ${rawColors.base06};
                }
            `,
            main() {
                return (
                    <window
                        name="workspace-osd"
                        layer={Astal.Layer.OVERLAY}
                        anchor={Astal.WindowAnchor.BOTTOM | Astal.WindowAnchor.RIGHT}
                        marginRight={14}
                        marginBottom={10}
                        visible={isVisible()}
                    >
                        <box className="osd-pill" vertical={false} halign={Gtk.Align.END} valign={Gtk.Align.CENTER}>
                            <label className="osd-icon" label={workspaceIcon()} />
                            <label className="osd-name" label={workspaceName()} />
                            <label className="osd-idx" label={workspaceIdx()} />
                            <label className="osd-sep" label="·" />
                            <label className="osd-date" label={currentDate()} />
                            <label className="osd-time" label={currentTime()} />
                        </box>
                    </window>
                )
            }
        })
      '';

      osdPackage = pkgs.writeShellScriptBin "niri-workspace-osd" ''
        exec ${pkgs.ags}/bin/ags run ${osdScript} "$@"
      '';
    in
    {
      home.packages = [
        pkgs.ags
        osdPackage
      ];

      systemd.user.services.workspace-osd = {
        Unit = {
          Description = "Niri Workspace OSD popup with AGS";
          PartOf = [ "graphical-session.target" ];
          After = [ "graphical-session.target" ];
        };
        Service = {
          ExecStart = "${osdPackage}/bin/niri-workspace-osd";
          Restart = "always";
          RestartSec = 2;
        };
        Install = {
          WantedBy = [ "graphical-session.target" ];
        };
      };
    };
}
