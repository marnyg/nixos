// Quickshell bar — replaces waybar/polybar. Nord-ish pill styling to match
// the previous waybar theme. One bar per monitor via Variants.
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import Quickshell.Hyprland
import Quickshell.Wayland
import Quickshell.Services.SystemTray
import Quickshell.Services.Pipewire
import Quickshell.Services.UPower

ShellRoot {
    id: root

    // Palette (matches the old waybar css)
    readonly property color pillBg: "#2e3440"
    readonly property color fg: "#d8dee9"
    readonly property color accent: "#b4befe"
    readonly property string fontFamily: "Fira Code"

    property string cpuUsage: "…"
    property string memUsage: "…"

    // Anthropic subscription limits: [{label, pct, resets}]
    property var aiLimits: []

    // OpenRouter balance/spend in dollars; null until fetched successfully.
    // Bars are scaled against this self-imposed weekly budget (no API limit
    // exists on a pay-as-you-go key) — tune to taste.
    property var orUsage: null
    property real orWeeklyBudget: 20

    function usageColor(pct) {
        if (pct >= 80)
            return "#bf616a"; // nord red
        if (pct >= 50)
            return "#ebcb8b"; // nord yellow
        return root.accent;
    }

    // "2d 22h" / "4h 47m" / "47m" until the given ISO timestamp
    function fmtEta(iso, now) {
        const ms = new Date(iso) - now;
        if (isNaN(ms) || ms <= 0)
            return "";
        const mins = Math.floor(ms / 60000);
        const d = Math.floor(mins / 1440);
        const h = Math.floor((mins % 1440) / 60);
        const m = mins % 60;
        if (d > 0)
            return d + "d " + h + "h";
        if (h > 0)
            return h + "h " + m + "m";
        return m + "m";
    }

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    // Keep the default sink bound so volume/mute stay live
    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink]
    }

    Timer {
        interval: 3000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            cpuProc.running = true;
            memProc.running = true;
        }
    }

    Process {
        id: cpuProc
        command: ["sh", "-c", "c1=$(grep '^cpu ' /proc/stat); sleep 1; c2=$(grep '^cpu ' /proc/stat); printf '%s\\n%s\\n' \"$c1\" \"$c2\" | awk 'NR==1{u1=$2+$3+$4;t1=u1+$5} NR==2{u2=$2+$3+$4;t2=u2+$5; if(t2>t1) printf \"%d\", (u2-u1)*100/(t2-t1); else printf \"0\"}'"]
        stdout: StdioCollector {
            onStreamFinished: root.cpuUsage = this.text.trim()
        }
    }

    // Poll sparingly: the oauth/usage endpoint rate-limits aggressively.
    Timer {
        interval: 300000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            aiUsageProc.running = true;
            orUsageProc.running = true;
        }
    }

    Process {
        id: orUsageProc
        command: [Quickshell.env("HOME") + "/.config/quickshell/openrouter-usage.sh"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const d = JSON.parse(this.text);
                    root.orUsage = (d.remaining === undefined || d.remaining === null) ? null : d;
                } catch (e) {
                    root.orUsage = null;
                }
            }
        }
    }

    Process {
        id: aiUsageProc
        command: [Quickshell.env("HOME") + "/.config/quickshell/anthropic-usage.sh"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const d = JSON.parse(this.text);
                    root.aiLimits = Array.isArray(d.limits) ? d.limits : [];
                } catch (e) {
                    root.aiLimits = [];
                }
            }
        }
    }

    Process {
        id: memProc
        command: ["sh", "-c", "awk '/MemTotal/{t=$2} /MemAvailable/{a=$2} END{printf \"%.1f\", (t-a)/1048576}' /proc/meminfo"]
        stdout: StdioCollector {
            onStreamFinished: root.memUsage = this.text.trim()
        }
    }

    component PillText: Text {
        color: root.fg
        font.family: root.fontFamily
        font.pixelSize: 15
    }

    component Pill: Rectangle {
        id: pill
        default property alias content: row.data
        signal pillClicked(var mouse)
        property bool clickable: false

        radius: 10
        color: root.pillBg
        implicitWidth: row.implicitWidth + 20
        implicitHeight: 24

        MouseArea {
            anchors.fill: parent
            enabled: pill.clickable
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            onClicked: mouse => pill.pillClicked(mouse)
        }

        RowLayout {
            id: row
            anchors.centerIn: parent
            spacing: 6
        }
    }

    // Shared "label | progress bar | value [extra]" row used by the usage pills
    component Meter: RowLayout {
        id: meter
        property bool sep: false
        property string label
        property real frac: 0
        property string value
        property string extra: ""
        property color barColor: root.accent
        spacing: 5

        Rectangle {
            visible: meter.sep
            implicitWidth: 1
            implicitHeight: 12
            color: "#434c5e"
        }

        PillText {
            text: meter.label
            color: root.accent
            font.bold: true
        }

        Rectangle {
            implicitWidth: 44
            implicitHeight: 6
            radius: 3
            color: "#434c5e"

            Rectangle {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                height: parent.height
                radius: 3
                width: Math.max(3, parent.width * Math.min(Math.max(meter.frac, 0), 1))
                color: meter.barColor

                Behavior on width {
                    NumberAnimation {
                        duration: 300
                        easing.type: Easing.OutCubic
                    }
                }
            }
        }

        PillText {
            text: meter.value
        }

        PillText {
            visible: meter.extra !== ""
            text: meter.extra
            color: "#7b88a1"
            font.pixelSize: 11
        }
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: bar
            required property var modelData
            screen: modelData

            anchors {
                top: true
                left: true
                right: true
            }
            implicitHeight: 34
            color: "transparent"

            // Left: hyprland workspaces
            Pill {
                anchors.left: parent.left
                anchors.leftMargin: 10
                anchors.verticalCenter: parent.verticalCenter

                Repeater {
                    // Only show workspaces that live on this bar's monitor.
                    model: ScriptModel {
                        values: Hyprland.workspaces.values.filter(ws => ws.monitor === Hyprland.monitorFor(bar.screen))
                    }
                    PillText {
                        required property var modelData
                        text: modelData.name
                        leftPadding: 4
                        rightPadding: 4
                        color: modelData.focused ? root.accent : root.fg
                        font.bold: modelData.focused

                        MouseArea {
                            anchors.fill: parent
                            // Hyprland is configured in Lua mode (configType = "lua"),
                            // so IPC dispatches must use the hl.* Lua API instead of
                            // the classic "workspace N" syntax.
                            onClicked: Hyprland.dispatch("hl.dsp.focus({ workspace = " + modelData.id + " })")
                        }
                    }
                }
            }

            // Center: active window title
            Pill {
                anchors.centerIn: parent
                visible: (ToplevelManager.activeToplevel?.title ?? "") !== ""

                PillText {
                    text: ToplevelManager.activeToplevel?.title ?? ""
                    elide: Text.ElideRight
                    Layout.maximumWidth: bar.width / 3
                }
            }

            // Right: screenshot, tray, cpu, mem, volume, clock, battery
            RowLayout {
                anchors.right: parent.right
                anchors.rightMargin: 10
                anchors.verticalCenter: parent.verticalCenter
                spacing: 10

                Pill {
                    clickable: true
                    onPillClicked: mouse => {
                        if (mouse.button === Qt.LeftButton)
                            Quickshell.execDetached(["sh", "-c", "mkdir -p ~/Pictures/Screenshots && grim -g \"$(slurp)\" - | satty --filename - --output-filename ~/Pictures/Screenshots/$(date +%Y-%m-%d_%H-%M-%S).png --early-exit --copy-command wl-copy"]);
                        else
                            Quickshell.execDetached(["sh", "-c", "mkdir -p ~/Pictures/Screenshots && grim ~/Pictures/Screenshots/$(date +%Y-%m-%d_%H-%M-%S).png"]);
                    }
                    PillText {
                        text: ""
                        color: root.accent
                    }
                }

                Pill {
                    visible: SystemTray.items.values.length > 0
                    Repeater {
                        model: SystemTray.items
                        IconImage {
                            required property var modelData
                            source: modelData.icon
                            implicitSize: 18

                            MouseArea {
                                anchors.fill: parent
                                acceptedButtons: Qt.LeftButton | Qt.MiddleButton
                                onClicked: mouse => {
                                    if (mouse.button === Qt.LeftButton)
                                        modelData.activate();
                                    else
                                        modelData.secondaryActivate();
                                }
                            }
                        }
                    }
                }

                Pill {
                    visible: root.orUsage !== null
                    clickable: true
                    onPillClicked: orUsageProc.running = true

                    PillText {
                        text: "🛰"
                        color: root.accent
                    }

                    Meter {
                        label: "bal"
                        frac: root.orUsage ? root.orUsage.remaining / root.orWeeklyBudget : 0
                        value: root.orUsage ? "$" + root.orUsage.remaining.toFixed(2) : ""
                        // inverse semantics: low balance is bad
                        barColor: !root.orUsage ? root.accent : root.orUsage.remaining < 0.25 * root.orWeeklyBudget ? "#bf616a" : root.orUsage.remaining < root.orWeeklyBudget ? "#ebcb8b" : root.accent
                    }

                    Meter {
                        sep: true
                        label: "1d"
                        frac: root.orUsage ? root.orUsage.day / (root.orWeeklyBudget / 7) : 0
                        value: root.orUsage ? "$" + root.orUsage.day.toFixed(2) : ""
                        barColor: root.usageColor(frac * 100)
                    }

                    Meter {
                        sep: true
                        label: "7d"
                        frac: root.orUsage ? root.orUsage.week / root.orWeeklyBudget : 0
                        value: root.orUsage ? "$" + root.orUsage.week.toFixed(2) : ""
                        barColor: root.usageColor(frac * 100)
                    }
                }

                Pill {
                    visible: root.aiLimits.length > 0
                    clickable: true
                    onPillClicked: aiUsageProc.running = true

                    Repeater {
                        model: root.aiLimits
                        Meter {
                            required property var modelData
                            required property int index
                            sep: index > 0
                            label: modelData.label
                            frac: modelData.pct / 100
                            value: Math.round(modelData.pct) + "%"
                            extra: root.fmtEta(modelData.resets, clock.date)
                            barColor: root.usageColor(modelData.pct)
                        }
                    }
                }

                Pill {
                    PillText {
                        text: "🎞️"
                        color: root.accent
                    }
                    PillText {
                        text: root.cpuUsage + "%"
                    }
                }

                Pill {
                    PillText {
                        text: "🖥"
                        color: root.accent
                    }
                    PillText {
                        text: root.memUsage + "GiB"
                    }
                }

                Pill {
                    clickable: true
                    onPillClicked: Quickshell.execDetached(["pavucontrol"])
                    PillText {
                        text: (Pipewire.defaultAudioSink?.audio.muted ?? false) ? "" : "󰕾"
                        color: root.accent
                    }
                    PillText {
                        text: Pipewire.defaultAudioSink?.audio ? Math.round(Pipewire.defaultAudioSink.audio.volume * 100) + "%" : "–"
                    }
                }

                Pill {
                    PillText {
                        text: ""
                        color: root.accent
                    }
                    PillText {
                        text: Qt.formatDateTime(clock.date, "dd:MM:yy  HH:mm")
                    }
                }

                Pill {
                    visible: UPower.displayDevice?.isLaptopBattery ?? false
                    PillText {
                        text: "🔋"
                        color: root.accent
                    }
                    PillText {
                        text: UPower.displayDevice ? Math.round(UPower.displayDevice.percentage * 100) + "%" : ""
                    }
                }
            }
        }
    }
}
