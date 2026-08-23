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

    // Floating dropdown anchored under a pill. Click-away closes it via a
    // Hyprland focus grab. Content items land in the inner ColumnLayout.
    component BarPopup: PopupWindow {
        id: popup
        default property alias content: col.data

        anchor.edges: Edges.Bottom
        anchor.gravity: Edges.Bottom
        implicitWidth: col.implicitWidth + 24
        implicitHeight: col.implicitHeight + 24
        color: "transparent"

        HyprlandFocusGrab {
            active: popup.visible
            windows: [popup]
            onCleared: popup.visible = false
        }

        Rectangle {
            anchors.fill: parent
            radius: 10
            color: root.pillBg

            ColumnLayout {
                id: col
                anchors.centerIn: parent
                spacing: 8
            }
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
                            id: trayIcon
                            required property var modelData
                            source: modelData.icon
                            implicitSize: 18

                            // Native SNI/DBus menu (blueman, nm-applet, …)
                            QsMenuAnchor {
                                id: trayMenu
                                menu: trayIcon.modelData.menu
                                anchor.item: trayIcon
                                anchor.edges: Edges.Bottom
                                anchor.gravity: Edges.Bottom
                            }

                            MouseArea {
                                anchors.fill: parent
                                acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton
                                onClicked: mouse => {
                                    if (mouse.button === Qt.RightButton || trayIcon.modelData.onlyMenu) {
                                        if (trayIcon.modelData.hasMenu)
                                            trayMenu.open();
                                    } else if (mouse.button === Qt.LeftButton) {
                                        trayIcon.modelData.activate();
                                    } else {
                                        trayIcon.modelData.secondaryActivate();
                                    }
                                }
                            }
                        }
                    }
                }

                Pill {
                    id: orPill
                    visible: root.orUsage !== null
                    clickable: true
                    onPillClicked: orPopup.visible = !orPopup.visible

                    BarPopup {
                        id: orPopup
                        anchor.item: orPill
                        // opening doubles as refresh
                        onVisibleChanged: if (visible) orUsageProc.running = true

                        PillText {
                            text: "OpenRouter"
                            font.bold: true
                            color: root.accent
                        }
                        PillText {
                            text: root.orUsage ? "Balance:   $" + root.orUsage.remaining.toFixed(2) : ""
                        }
                        PillText {
                            text: root.orUsage ? "Today:     $" + root.orUsage.day.toFixed(2) : ""
                        }
                        PillText {
                            text: root.orUsage ? "Last 7d:   $" + root.orUsage.week.toFixed(2) + "  (budget $" + root.orWeeklyBudget + ")" : ""
                        }
                        PillText {
                            text: "openrouter.ai/activity ↗"
                            color: "#7b88a1"
                            font.pixelSize: 12

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    Quickshell.execDetached(["xdg-open", "https://openrouter.ai/activity"]);
                                    orPopup.visible = false;
                                }
                            }
                        }
                    }

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
                    id: aiPill
                    visible: root.aiLimits.length > 0
                    clickable: true
                    onPillClicked: aiPopup.visible = !aiPopup.visible

                    BarPopup {
                        id: aiPopup
                        anchor.item: aiPill
                        // opening doubles as refresh
                        onVisibleChanged: if (visible) aiUsageProc.running = true

                        PillText {
                            text: "Claude usage"
                            font.bold: true
                            color: root.accent
                        }
                        Repeater {
                            model: root.aiLimits
                            Meter {
                                required property var modelData
                                label: modelData.label
                                frac: modelData.pct / 100
                                value: Math.round(modelData.pct) + "%"
                                extra: "resets " + Qt.formatDateTime(new Date(modelData.resets), "ddd HH:mm")
                                barColor: root.usageColor(modelData.pct)
                            }
                        }
                        PillText {
                            text: "claude.ai/settings/usage ↗"
                            color: "#7b88a1"
                            font.pixelSize: 12

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    Quickshell.execDetached(["xdg-open", "https://claude.ai/settings/usage"]);
                                    aiPopup.visible = false;
                                }
                            }
                        }
                    }

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
                    id: cpuPill
                    clickable: true
                    onPillClicked: cpuPopup.visible = !cpuPopup.visible
                    PillText {
                        text: "🎞️"
                        color: root.accent
                    }
                    PillText {
                        text: root.cpuUsage + "%"
                    }

                    BarPopup {
                        id: cpuPopup
                        anchor.item: cpuPill
                        property string procs: "…"
                        onVisibleChanged: if (visible) cpuTop.running = true

                        Process {
                            id: cpuTop
                            command: ["sh", "-c", "ps axch -o comm:24,pcpu --sort=-pcpu | head -8"]
                            stdout: StdioCollector {
                                onStreamFinished: cpuPopup.procs = this.text.trimEnd()
                            }
                        }

                        PillText {
                            text: "Top CPU"
                            font.bold: true
                            color: root.accent
                        }
                        PillText {
                            text: cpuPopup.procs
                        }
                    }
                }

                Pill {
                    id: memPill
                    clickable: true
                    onPillClicked: memPopup.visible = !memPopup.visible
                    PillText {
                        text: "🖥"
                        color: root.accent
                    }
                    PillText {
                        text: root.memUsage + "GiB"
                    }

                    BarPopup {
                        id: memPopup
                        anchor.item: memPill
                        property string procs: "…"
                        onVisibleChanged: if (visible) memTop.running = true

                        Process {
                            id: memTop
                            command: ["sh", "-c", "ps axch -o comm:24,pmem --sort=-pmem | head -8"]
                            stdout: StdioCollector {
                                onStreamFinished: memPopup.procs = this.text.trimEnd()
                            }
                        }

                        PillText {
                            text: "Top memory"
                            font.bold: true
                            color: root.accent
                        }
                        PillText {
                            text: memPopup.procs
                        }
                    }
                }

                Pill {
                    id: volumePill
                    clickable: true
                    // Left: inline volume popup. Right: full mixer.
                    onPillClicked: mouse => {
                        if (mouse.button === Qt.RightButton)
                            Quickshell.execDetached(["pavucontrol"]);
                        else
                            volumePopup.visible = !volumePopup.visible;
                    }
                    PillText {
                        text: (Pipewire.defaultAudioSink?.audio.muted ?? false) ? "" : "󰕾"
                        color: root.accent
                    }
                    PillText {
                        text: Pipewire.defaultAudioSink?.audio ? Math.round(Pipewire.defaultAudioSink.audio.volume * 100) + "%" : "–"
                    }

                    BarPopup {
                        id: volumePopup
                        anchor.item: volumePill

                        RowLayout {
                            spacing: 10

                            PillText {
                                text: (Pipewire.defaultAudioSink?.audio.muted ?? false) ? "" : "󰕾"
                                color: root.accent

                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: {
                                        const a = Pipewire.defaultAudioSink?.audio;
                                        if (a)
                                            a.muted = !a.muted;
                                    }
                                }
                            }

                            Item {
                                id: volSlider
                                implicitWidth: 180
                                implicitHeight: 20
                                property real vol: Pipewire.defaultAudioSink?.audio.volume ?? 0

                                Rectangle {
                                    anchors.verticalCenter: parent.verticalCenter
                                    width: parent.width
                                    height: 6
                                    radius: 3
                                    color: "#434c5e"
                                }
                                Rectangle {
                                    anchors.verticalCenter: parent.verticalCenter
                                    width: parent.width * Math.min(1, volSlider.vol)
                                    height: 6
                                    radius: 3
                                    color: root.accent
                                }
                                Rectangle {
                                    anchors.verticalCenter: parent.verticalCenter
                                    x: Math.max(0, parent.width * Math.min(1, volSlider.vol) - width / 2)
                                    width: 12
                                    height: 12
                                    radius: 6
                                    color: root.fg
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    function setVol(x) {
                                        const a = Pipewire.defaultAudioSink?.audio;
                                        if (a)
                                            a.volume = Math.max(0, Math.min(1, x / volSlider.width));
                                    }
                                    onPressed: mouse => setVol(mouse.x)
                                    onPositionChanged: mouse => {
                                        if (pressed)
                                            setVol(mouse.x);
                                    }
                                }
                            }

                            PillText {
                                text: Math.round((Pipewire.defaultAudioSink?.audio.volume ?? 0) * 100) + "%"
                            }
                        }
                    }
                }

                Pill {
                    id: clockPill
                    clickable: true
                    onPillClicked: calendarPopup.visible = !calendarPopup.visible
                    PillText {
                        text: ""
                        color: root.accent
                    }
                    PillText {
                        text: Qt.formatDateTime(clock.date, "dd:MM:yy  HH:mm")
                    }

                    BarPopup {
                        id: calendarPopup
                        anchor.item: clockPill

                        property date today: new Date()
                        property date shownMonth: new Date()
                        onVisibleChanged: if (visible) {
                            today = new Date();
                            shownMonth = new Date();
                        }

                        function addMonths(d) {
                            shownMonth = new Date(shownMonth.getFullYear(), shownMonth.getMonth() + d, 1);
                        }
                        function sameDay(a, b) {
                            return a.getFullYear() === b.getFullYear() && a.getMonth() === b.getMonth() && a.getDate() === b.getDate();
                        }
                        // 6 fixed weeks, Monday-first, spilling into adjacent months
                        function monthCells() {
                            const y = shownMonth.getFullYear(), m = shownMonth.getMonth();
                            const lead = (new Date(y, m, 1).getDay() + 6) % 7;
                            const cells = [];
                            for (let i = 0; i < 42; i++)
                                cells.push(new Date(y, m, 1 - lead + i));
                            return cells;
                        }

                        RowLayout {
                            Layout.fillWidth: true

                            PillText {
                                text: "‹"
                                leftPadding: 6
                                rightPadding: 6
                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: calendarPopup.addMonths(-1)
                                }
                            }
                            PillText {
                                Layout.fillWidth: true
                                horizontalAlignment: Text.AlignHCenter
                                font.bold: true
                                text: Qt.formatDate(calendarPopup.shownMonth, "MMMM yyyy")
                            }
                            PillText {
                                text: "›"
                                leftPadding: 6
                                rightPadding: 6
                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: calendarPopup.addMonths(1)
                                }
                            }
                        }

                        Grid {
                            columns: 7
                            Repeater {
                                model: ["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"]
                                Text {
                                    required property string modelData
                                    width: 30
                                    height: 22
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                    font.family: root.fontFamily
                                    font.pixelSize: 13
                                    font.bold: true
                                    color: "#7b88a1"
                                    text: modelData
                                }
                            }
                        }

                        Grid {
                            columns: 7
                            Repeater {
                                model: calendarPopup.monthCells()
                                Text {
                                    required property var modelData
                                    width: 30
                                    height: 24
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                    font.family: root.fontFamily
                                    font.pixelSize: 14
                                    font.bold: calendarPopup.sameDay(modelData, calendarPopup.today)
                                    color: calendarPopup.sameDay(modelData, calendarPopup.today) ? root.accent : modelData.getMonth() === calendarPopup.shownMonth.getMonth() ? root.fg : "#616e88"
                                    text: modelData.getDate()
                                }
                            }
                        }
                    }
                }

                Pill {
                    id: batteryPill
                    visible: UPower.displayDevice?.isLaptopBattery ?? false
                    clickable: true
                    onPillClicked: batteryPopup.visible = !batteryPopup.visible
                    PillText {
                        text: "🔋"
                        color: root.accent
                    }
                    PillText {
                        text: UPower.displayDevice ? Math.round(UPower.displayDevice.percentage * 100) + "%" : ""
                    }

                    BarPopup {
                        id: batteryPopup
                        anchor.item: batteryPill

                        function fmtTime(s) {
                            return Math.floor(s / 3600) + "h " + Math.round((s % 3600) / 60) + "m";
                        }

                        PillText {
                            text: "Battery"
                            font.bold: true
                            color: root.accent
                        }
                        PillText {
                            text: {
                                const d = UPower.displayDevice;
                                return d ? Math.round(d.percentage * 100) + "%  ·  " + d.energyRate.toFixed(1) + " W" : "";
                            }
                        }
                        PillText {
                            visible: text !== ""
                            text: {
                                const d = UPower.displayDevice;
                                if (!d)
                                    return "";
                                if (d.timeToEmpty > 0)
                                    return "Empty in " + batteryPopup.fmtTime(d.timeToEmpty);
                                if (d.timeToFull > 0)
                                    return "Full in " + batteryPopup.fmtTime(d.timeToFull);
                                return "";
                            }
                        }
                    }
                }
            }
        }
    }
}
