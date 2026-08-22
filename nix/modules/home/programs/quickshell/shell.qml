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
        font.pixelSize: 13
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
                    model: Hyprland.workspaces
                    PillText {
                        required property var modelData
                        text: modelData.name
                        leftPadding: 4
                        rightPadding: 4
                        color: modelData.focused ? root.accent : root.fg
                        font.bold: modelData.focused

                        MouseArea {
                            anchors.fill: parent
                            onClicked: Hyprland.dispatch("workspace " + modelData.id)
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
