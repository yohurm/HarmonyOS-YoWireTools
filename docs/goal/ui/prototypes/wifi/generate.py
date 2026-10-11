#!/usr/bin/env python3
"""Render YoWireTools network-module prototypes (SVG).

Artboards follow HarmonyOS breakpoints:
- phone 360 x 800
- md    800 x 640  (600–839: list + canvas, lens becomes sub-tabs)
- lg   1280 x 800  (840+: lens rail + object list + canvas + inspector)
"""

from __future__ import annotations

import os

FONT = "Noto Sans CJK SC, Noto Sans CJK JP, sans-serif"
MONO = "WenQuanYi Micro Hei Mono, Noto Sans Mono, monospace"

LIGHT = dict(
    bg="#F1F3F5",
    surface="#FFFFFF",
    text="#1A1A1A",
    secondary="#666666",
    tertiary="#8E8E93",
    disabled="#C4C4C8",
    primary="#0A59F7",
    on_primary="#FFFFFF",
    success="#3D8B37",
    warning="#C25512",
    error="#C4311A",
    chip="#E6E7EB",
    selected="#E7F0FE",
    success_bg="#E5F5E3",
    warning_bg="#FDE8DC",
    error_bg="#FDECEA",
    info_bg="#E7F0FE",
    track="#E1E2E6",
    line="#E4E5E9",
    scrim="#66000000",
)

DARK = dict(
    bg="#191A1C",
    surface="#202224",
    text="#F2F2F2",
    secondary="#C8C8C8",
    tertiary="#9A9AA0",
    disabled="#5C5C60",
    primary="#317AF7",
    on_primary="#FFFFFF",
    success="#8FCB88",
    warning="#E0926A",
    error="#E07A6C",
    chip="#2E3033",
    selected="#243044",
    success_bg="#1C2A1C",
    warning_bg="#2C221C",
    error_bg="#2C1C1C",
    info_bg="#1C2433",
    track="#2E3033",
    line="#2A2C2E",
    scrim="#99000000",
)


def esc(value: str) -> str:
    return (
        value.replace("&", "&amp;")
        .replace("<", "&lt;")
        .replace(">", "&gt;")
    )


class Svg:
    def __init__(self, w: int, h: int, theme: dict):
        self.w = w
        self.h = h
        self.t = theme
        self.buf: list[str] = []

    def add(self, fragment: str) -> None:
        self.buf.append(fragment)

    def rect(self, x, y, w, h, fill, rx=0, stroke=None, sw=1, op=1) -> None:
        extra = ""
        if stroke:
            extra += f' stroke="{stroke}" stroke-width="{sw}"'
        if op != 1:
            extra += f' fill-opacity="{op}"'
        self.add(
            f'<rect x="{x}" y="{y}" width="{w}" height="{h}" rx="{rx}" '
            f'fill="{fill}"{extra}/>'
        )

    def line(self, x1, y1, x2, y2, stroke, sw=1) -> None:
        self.add(
            f'<line x1="{x1}" y1="{y1}" x2="{x2}" y2="{y2}" '
            f'stroke="{stroke}" stroke-width="{sw}"/>'
        )

    def circle(self, cx, cy, r, fill, stroke=None, sw=2) -> None:
        extra = f' stroke="{stroke}" stroke-width="{sw}"' if stroke else ""
        self.add(f'<circle cx="{cx}" cy="{cy}" r="{r}" fill="{fill}"{extra}/>')

    def path(self, d: str, fill="none", stroke=None, sw=1.5, op=1) -> None:
        extra = ""
        if stroke:
            extra += f' stroke="{stroke}" stroke-width="{sw}"'
        if op != 1:
            extra += f' fill-opacity="{op}"'
        self.add(
            f'<path d="{d}" fill="{fill}" stroke-linejoin="round" '
            f'stroke-linecap="round"{extra}/>'
        )

    def text(self, x, y, value, size=14, fill=None, weight=400, anchor="start", family=None) -> None:
        fill = fill or self.t["text"]
        family = family or FONT
        self.add(
            f'<text x="{x}" y="{y}" font-size="{size}" fill="{fill}" '
            f'font-weight="{weight}" text-anchor="{anchor}" font-family="{family}" '
            f'dominant-baseline="middle">{esc(value)}</text>'
        )

    def dump(self) -> str:
        body = "\n".join(self.buf)
        return (
            '<?xml version="1.0" encoding="UTF-8"?>\n'
            f'<svg xmlns="http://www.w3.org/2000/svg" width="{self.w}" height="{self.h}" '
            f'viewBox="0 0 {self.w} {self.h}">\n'
            f'<rect width="{self.w}" height="{self.h}" fill="{self.t["bg"]}"/>\n'
            f"{body}\n</svg>\n"
        )


def chevron(s: Svg, x, y, color) -> None:
    s.path(f"M{x+8} {y-6} L{x} {y} L{x+8} {y+6}", stroke=color, sw=1.8)


def bars(s: Svg, x, y, level: int, active: str) -> None:
    for i in range(4):
        bh = 5 + i * 4
        fill = active if i < level else s.t["track"]
        s.rect(x + i * 5, y + 16 - bh, 3, bh, fill, rx=1)


def level_of(rssi: int) -> int:
    if rssi >= -55:
        return 4
    if rssi >= -67:
        return 3
    if rssi >= -78:
        return 2
    return 1


def pill(s: Svg, x, y, label, bg, fg) -> float:
    width = 12 + 12 * len(label)
    s.rect(x, y, width, 18, bg, rx=9)
    s.text(x + width / 2, y + 9, label, 10, fg, 700, "middle")
    return width


def status_icons(s: Svg, y: int) -> None:
    color = s.t["text"]
    right = s.w - 16
    s.rect(right - 24, y - 6, 18, 11, "none", rx=2, stroke=color, sw=1.2)
    s.rect(right - 21, y - 3, 10, 5, color, rx=1)
    s.rect(right - 5, y - 3, 1.6, 5, color, rx=0.6)
    # cellular
    base = right - 46
    for i, h in enumerate((4, 7, 10)):
        s.rect(base + i * 5, y + 4 - h, 3, h, color, rx=0.6)


def phone_chrome(s: Svg, title: str, tab, back=False, action=None, action_color=None) -> int:
    s.rect(0, 0, 360, 40, s.t["surface"])
    s.text(16, 20, "9:41", 15, s.t["text"], 700)
    status_icons(s, 20)
    s.rect(0, 40, 360, 56, s.t["surface"])
    if back:
        chevron(s, 18, 68, s.t["text"])
        s.text(40, 68, title, 18, weight=700)
    else:
        s.text(16, 68, title, 20, weight=700)
    if action:
        s.text(344, 68, action, 14, action_color or s.t["primary"], 700, "end")
    if tab is None:
        s.line(0, 96, 360, 96, s.t["line"])
        return 112
    s.rect(0, 96, 360, 48, s.t["surface"])
    names = ["链路", "空口", "主机", "会话"]
    for i, name in enumerate(names):
        cx = 45 + i * 90
        selected = i == tab
        s.text(
            cx,
            116,
            name,
            14,
            s.t["primary"] if selected else s.t["secondary"],
            700 if selected else 400,
            "middle",
        )
        if selected:
            s.rect(cx - 14, 132, 28, 3, s.t["primary"], rx=1.5)
    s.line(0, 144, 360, 144, s.t["line"])
    return 156


def nav_pill(s: Svg) -> None:
    s.rect(s.w / 2 - 52, s.h - 14, 104, 4, s.t["text"], rx=2, op=0.28)


def banner(s: Svg, x, y, w, lines, tone) -> int:
    bg = {"info": s.t["info_bg"], "warn": s.t["warning_bg"], "err": s.t["error_bg"], "ok": s.t["success_bg"]}[tone]
    fg = {"info": s.t["primary"], "warn": s.t["warning"], "err": s.t["error"], "ok": s.t["success"]}[tone]
    h = 14 + 18 * len(lines)
    s.rect(x, y, w, h, bg, rx=12)
    for i, line in enumerate(lines):
        s.text(x + 12, y + 16 + i * 18, line, 12, fg)
    return y + h


def button(s: Svg, x, y, w, label, kind="primary") -> int:
    h = 40
    if kind == "primary":
        s.rect(x, y, w, h, s.t["primary"], rx=20)
        s.text(x + w / 2, y + 20, label, 14, s.t["on_primary"], 700, "middle")
    elif kind == "warning":
        s.rect(x, y, w, h, s.t["warning"], rx=20)
        s.text(x + w / 2, y + 20, label, 14, "#FFFFFF", 700, "middle")
    elif kind == "disabled":
        s.rect(x, y, w, h, s.t["disabled"], rx=20)
        s.text(x + w / 2, y + 20, label, 14, "#FFFFFF", 700, "middle")
    else:
        s.rect(x, y, w, h, s.t["surface"], rx=20, stroke=s.t["line"], sw=1)
        s.text(x + w / 2, y + 20, label, 14, s.t["primary"], 700, "middle")
    return y + h


def kv(s: Svg, x, y, w, key, value, color=None) -> int:
    s.text(x, y, key, 13, s.t["secondary"])
    s.text(x + w, y, value, 13, color or s.t["text"], 700, "end")
    return y + 26


def chips(s: Svg, x, y, items, selected) -> int:
    cursor = x
    for i, name in enumerate(items):
        width = 16 + 12 * len(name)
        on = i == selected
        s.rect(cursor, y, width, 28, s.t["primary"] if on else s.t["surface"], rx=14)
        s.text(
            cursor + width / 2,
            y + 14,
            name,
            12,
            s.t["on_primary"] if on else s.t["secondary"],
            700 if on else 400,
            "middle",
        )
        cursor += width + 8
    return y + 40


def empty_block(s: Svg, y, title, lines, action) -> None:
    cx = 180
    s.circle(cx, y + 36, 28, s.t["info_bg"])
    s.circle(cx, y + 36, 10, "none", s.t["primary"], 2)
    s.circle(cx, y + 36, 3, s.t["primary"])
    s.text(cx, y + 84, title, 16, s.t["text"], 700, "middle")
    for i, line in enumerate(lines):
        s.text(cx, y + 110 + i * 20, line, 12, s.t["secondary"], 400, "middle")
    button(s, 48, y + 128 + 20 * len(lines), 264, action, "primary")


TONE = {
    "ok": "success",
    "run": "primary",
    "wait": "tertiary",
    "bad": "error",
    "off": "disabled",
    "warn": "warning",
}


def path_card(s: Svg, x, y, w, nodes) -> int:
    h = 132
    s.rect(x, y, w, h, s.t["surface"], rx=16)
    n = len(nodes)
    slot = w / n
    y_line = y + 46
    s.line(x + slot * 0.5, y_line, x + w - slot * 0.5, y_line, s.t["track"], 2)
    for i, (label, value, state) in enumerate(nodes):
        cx = x + slot * (i + 0.5)
        key = TONE[state]
        color = s.t[key]
        s.circle(cx, y_line, 11, s.t["surface"], color, 2)
        if state == "run":
            s.circle(cx, y_line, 4, color)
        elif state == "ok":
            s.path(f"M{cx-4} {y_line} L{cx-1} {y_line+3} L{cx+4} {y_line-3}", stroke=color, sw=1.6)
        elif state in ("bad", "off"):
            s.path(f"M{cx-3} {y_line-3} L{cx+3} {y_line+3} M{cx+3} {y_line-3} L{cx-3} {y_line+3}", stroke=color, sw=1.6)
        elif state == "warn":
            s.text(cx, y_line + 1, "!", 12, color, 700, "middle")
        s.text(cx, y + 78, label, 11, s.t["secondary"], 400, "middle")
        s.text(cx, y + 98, value, 11, color, 700, "middle")
    return y + h


def section(s: Svg, x, y, title) -> int:
    s.text(x, y, title, 13, s.t["secondary"], 700)
    return y + 18


APS = [
    ("YoLab-5G", "WPA3", "5 GHz", 36, -42, True, False),
    ("YoLab", "WPA2", "2.4 GHz", 6, -58, False, False),
    ("Guest", "开放", "2.4 GHz", 11, -67, False, False),
    ("隐藏网络", "WPA2", "5 GHz", 44, -71, False, True),
    ("IoT-Setup", "WPA2", "2.4 GHz", 1, -82, False, False),
]


def ap_row(s: Svg, x, y, w, ap, selected=False) -> int:
    ssid, sec, band, ch, rssi, current, hidden = ap
    h = 64
    s.rect(x, y, w, h, s.t["selected"] if selected else s.t["surface"], rx=14)
    if selected:
        s.rect(x, y + 12, 3, h - 24, s.t["primary"], rx=1.5)
    color = s.t["primary"] if current else s.t["secondary"]
    bars(s, x + 14, y + 24, level_of(rssi), color)
    s.text(x + 42, y + 22, ssid, 15, s.t["text"], 700)
    marks = []
    if current:
        marks.append("当前")
    if hidden:
        marks.append("隐藏")
    marks.append(f"{sec} · {band} · {ch}")
    s.text(x + 42, y + 44, " · ".join(marks), 12, s.t["success"] if current else s.t["secondary"])
    s.text(x + w - 12, y + 22, f"{rssi}", 15, color, 700, "end")
    s.text(x + w - 12, y + 42, "dBm", 10, s.t["tertiary"], 400, "end")
    return y + h + 8


def view_switch(s: Svg, y, items, selected) -> int:
    x = 16
    w = 328
    s.rect(x, y, w, 32, s.t["chip"], rx=16)
    slot = w / len(items)
    for i, name in enumerate(items):
        if i == selected:
            s.rect(x + 2 + i * slot, y + 2, slot - 4, 28, s.t["surface"], rx=14)
        s.text(
            x + slot * (i + 0.5),
            y + 16,
            name,
            12,
            s.t["primary"] if i == selected else s.t["secondary"],
            700 if i == selected else 400,
            "middle",
        )
    return y + 44


def channel_plot(s: Svg, x, y, w, h, band: str) -> None:
    s.rect(x, y, w, h, s.t["surface"], rx=16)
    left, right, top, bottom = x + 36, x + w - 16, y + 36, y + h - 28
    plot_h = bottom - top
    for rssi, label in ((-40, "-40"), (-70, "-70"), (-90, "-90")):
        py = top + ((-30 - rssi) / 70) * plot_h
        s.line(left, py, right, py, s.t["line"], 1)
        s.text(x + 8, py, label, 10, s.t["tertiary"])
    if band == "2.4":
        channels = list(range(1, 14))
        series = [
            (1, -82, 1, s.t["tertiary"], False, "IoT"),
            (6, -58, 2, s.t["primary"], False, "YoLab"),
            (11, -67, 1, s.t["warning"], False, "Guest"),
        ]
    elif band == "6":
        channels = [1, 5, 9, 13, 17, 21, 25, 29]
        series = [(5, -55, 4, s.t["primary"], True, "Lab-6E")]
    else:
        channels = [36, 40, 44, 48, 52, 56, 60, 64]
        series = [
            (44, -71, 2, s.t["tertiary"], False, "隐藏"),
            (36, -42, 4, s.t["primary"], True, "YoLab-5G"),
        ]
    span = max(len(channels) - 1, 1)
    inset = min(36, (right - left) / 8)
    slot = (right - left - inset * 2) / span

    def cx_of(ch):
        idx = channels.index(ch) if ch in channels else 0
        return left + inset + idx * slot

    def y_of(rssi):
        t = max(0.0, min(1.0, (-30 - rssi) / 70))
        return top + t * plot_h

    for ch, rssi, width_ch, color, selected, _name in series:
        cx = cx_of(ch)
        half = max(12, slot * width_ch / 2)
        base_l = max(left, cx - half)
        base_r = min(right, cx + half)
        top_half = max(8, (base_r - base_l) * 0.16)
        y_top = y_of(rssi)
        d = (
            f"M{base_l:.1f} {bottom:.1f} L{cx - top_half:.1f} {y_top:.1f} "
            f"L{cx + top_half:.1f} {y_top:.1f} L{base_r:.1f} {bottom:.1f} Z"
        )
        s.path(d, fill=color, op=0.35 if not selected else 0.5, stroke=color, sw=2)
    for i, ch in enumerate(channels):
        if band == "2.4" and ch not in (1, 6, 11):
            continue
        s.text(cx_of(ch), bottom + 14, str(ch), 10, s.t["tertiary"], 400, "middle")


def rssi_plot(s: Svg, x, y, w, h) -> None:
    s.rect(x, y, w, h, s.t["surface"], rx=16)
    left, right, top, bottom = x + 28, x + w - 12, y + 20, y + h - 24
    for i in range(4):
        py = top + i * (bottom - top) / 3
        s.line(left, py, right, py, s.t["line"], 1)
    # two polylines, 8 samples
    a = [-48, -46, -52, -44, -61, -43, -45, -42]
    b = [-70, -68, -74, -66, -80, -72, -69, -71]

    def poly(samples, color):
        pts = []
        for i, rssi in enumerate(samples):
            px = left + i * (right - left) / (len(samples) - 1)
            py = top + ((-30 - rssi) / 70) * (bottom - top)
            pts.append(f"{px:.1f},{py:.1f}")
        s.add(
            f'<polyline points="{" ".join(pts)}" fill="none" stroke="{color}" '
            f'stroke-width="2" stroke-linejoin="round" stroke-linecap="round"/>'
        )

    poly(b, s.t["tertiary"])
    poly(a, s.t["primary"])
    s.text(left, bottom + 12, "0s", 10, s.t["tertiary"])
    s.text(right, bottom + 12, "60s", 10, s.t["tertiary"], 400, "end")


def step_list(s: Svg, x, y, w, steps) -> int:
    s.rect(x, y, w, 28 * len(steps) + 12, s.t["surface"], rx=16)
    for i, (name, state, detail) in enumerate(steps):
        yy = y + 20 + i * 28
        color = s.t[{"ok": "success", "run": "primary", "wait": "tertiary", "bad": "error", "skip": "tertiary"}[state]]
        s.circle(x + 16, yy, 4, color)
        s.text(x + 30, yy, name, 13, s.t["text"], 700)
        s.text(x + w - 12, yy, detail, 12, color, 400, "end")
    return y + 28 * len(steps) + 12


def link_nodes(kind: str):
    if kind == "ready":
        return [
            ("射频", "开启", "ok"),
            ("关联", "-42", "ok"),
            ("地址", ".42", "ok"),
            ("网关", "1ms", "ok"),
            ("解析", "正常", "ok"),
            ("出口", "可达", "ok"),
        ]
    if kind == "off":
        return [
            ("射频", "关闭", "off"),
            ("关联", "无", "off"),
            ("地址", "—", "off"),
            ("网关", "—", "off"),
            ("解析", "—", "wait"),
            ("出口", "蜂窝", "warn"),
        ]
    if kind == "perm":
        return [
            ("射频", "未知", "wait"),
            ("关联", "不可读", "bad"),
            ("地址", "—", "wait"),
            ("网关", "—", "wait"),
            ("解析", "可测", "ok"),
            ("出口", "可测", "ok"),
        ]
    if kind == "portal":
        return [
            ("射频", "开启", "ok"),
            ("关联", "-42", "ok"),
            ("地址", ".42", "ok"),
            ("网关", "通", "ok"),
            ("解析", "拦截", "warn"),
            ("出口", "门户", "warn"),
        ]
    if kind == "run":
        return [
            ("射频", "开启", "ok"),
            ("关联", "-42", "ok"),
            ("地址", ".42", "ok"),
            ("网关", "探测", "run"),
            ("解析", "等待", "wait"),
            ("出口", "等待", "wait"),
        ]
    return [
        ("射频", "开启", "ok"),
        ("关联", "-42", "ok"),
        ("地址", ".42", "ok"),
        ("网关", "1ms", "ok"),
        ("解析", "失败", "bad"),
        ("出口", "中断", "bad"),
    ]


def screen_link(kind: str, dark=False) -> Svg:
    s = Svg(360, 800, DARK if dark else LIGHT)
    y = phone_chrome(s, "网络", 0, action="检查")
    y = path_card(s, 16, y, 328, link_nodes(kind)) + 12
    if kind == "ready":
        s.rect(16, y, 328, 108, s.t["surface"], rx=16)
        s.text(32, y + 22, "当前关联", 12, s.t["secondary"])
        s.text(32, y + 46, "YoLab-5G", 18, weight=700)
        s.text(32, y + 72, "5 GHz · 信道 36 · 192.168.1.42", 12, s.t["secondary"])
        s.text(32, y + 90, "BSSID 受权限掩蔽", 12, s.t["tertiary"])
        y += 120
        y = section(s, 16, y, "这条链路上的下一步")
        button(s, 16, y, 158, "测这条路径", "primary")
        button(s, 186, y, 158, "看空口", "secondary")
        y += 56
        y = section(s, 16, y, "最近一次路径检查")
        s.rect(16, y, 328, 64, s.t["surface"], rx=16)
        s.text(32, y + 22, "example.com", 14, weight=700)
        s.text(32, y + 44, "4 步通过 · 86 ms · 今天 09:12", 12, s.t["secondary"])
    elif kind == "off":
        y = banner(s, 16, y, 328, ["WLAN 已关闭。空口分析不可用。", "默认网络若是蜂窝，诊断和会话仍可进行。"], "warn") + 16
        button(s, 16, y, 328, "打开系统 WLAN", "primary")
        button(s, 16, y + 52, 328, "改为诊断蜂窝网络", "secondary")
    elif kind == "perm":
        y = banner(
            s, 16, y, 328,
            ["缺少读取 WLAN 信息的权限。", "需要 GET_WIFI_INFO。诊断仍可用默认网络。"],
            "err",
        ) + 16
        button(s, 16, y, 328, "去授权", "primary")
        button(s, 16, y + 52, 328, "仍诊断默认网络", "secondary")
    elif kind == "portal":
        y = banner(
            s, 16, y, 328,
            ["出口被门户拦截。本应用不代填认证页。", "请在系统浏览器完成认证后再检查。"],
            "warn",
        ) + 16
        button(s, 16, y, 328, "复制网关地址", "primary")
        button(s, 16, y + 52, 328, "打开系统 WLAN", "secondary")
    elif kind == "run":
        y = step_list(
            s, 16, y, 328,
            [
                ("网络状态", "ok", "WLAN 已关联"),
                ("域名解析", "run", "example.com"),
                ("TCP 连接", "wait", "等待"),
                ("HTTP 探测", "wait", "等待"),
            ],
        ) + 16
        button(s, 16, y, 328, "停止检查", "secondary")
    else:
        y = banner(s, 16, y, 328, ["解析失败，后面的步骤已跳过。", "YW-NET-1001 · 可更换目标或重试。"], "err") + 12
        y = step_list(
            s, 16, y, 328,
            [
                ("网络状态", "ok", "已关联"),
                ("域名解析", "bad", "YW-NET-1001"),
                ("TCP 连接", "skip", "已跳过"),
                ("HTTP 探测", "skip", "已跳过"),
            ],
        ) + 16
        button(s, 16, y, 328, "重试这条路径", "primary")
    nav_pill(s)
    return s


def screen_air_list(mode: str) -> Svg:
    s = Svg(360, 800, LIGHT)
    action = {"list": "扫描", "scan": "停止", "throttle": "48s", "empty": None}[mode]
    color = s.t["disabled"] if mode == "throttle" else s.t["primary"]
    y = phone_chrome(s, "网络", 1, action=action, action_color=color)
    if mode == "empty":
        empty_block(
            s, 220,
            "还没有接入点",
            ["WLAN 已开启，系统缓存是空的。", "前台主动扫描每 2 分钟最多 4 次。"],
            "开始扫描",
        )
        nav_pill(s)
        return s
    if mode == "scan":
        s.rect(16, y, 328, 3, s.t["track"], rx=1.5)
        s.rect(16, y, 180, 3, s.t["primary"], rx=1.5)
        y += 14
        y = banner(s, 16, y, 328, ["正在向系统请求扫描。已有结果保持可见。"], "info") + 10
    elif mode == "throttle":
        y = banner(
            s, 16, y, 328,
            ["主动扫描冷却中，列表来自 12 秒前的缓存。", "YW-WIFI-1002 · 冷却结束后可再扫描。"],
            "warn",
        ) + 10
    else:
        s.text(16, y + 8, "5 个接入点 · 缓存 12 秒前", 12, s.t["secondary"])
        y += 24
    y = chips(s, 16, y, ["全部", "2.4G", "5G", "6G", "当前"], 0)
    rows = APS if mode != "scan" else APS[:4]
    for i, ap in enumerate(rows):
        y = ap_row(s, 16, y, 328, ap, selected=(mode == "list" and i == 0))
    nav_pill(s)
    return s


def screen_air_chart(kind: str) -> Svg:
    s = Svg(360, 800, LIGHT)
    y = phone_chrome(s, "网络", 1, action="暂停")
    y = view_switch(s, y, ["列表", "信道", "时间"], 1 if kind == "channel" else 2)
    if kind == "channel":
        y = chips(s, 16, y, ["2.4 GHz", "5 GHz", "6 GHz"], 1)
        channel_plot(s, 16, y, 328, 360, "5")
        y += 372
        s.rect(16, y, 328, 56, s.t["surface"], rx=14)
        s.text(32, y + 20, "YoLab-5G", 14, weight=700)
        s.text(32, y + 40, "信道 36 · -42 dBm · 宽度未返回，图按 80 MHz 示意", 11, s.t["secondary"])
    else:
        y = chips(s, 16, y, ["30 秒", "1 分钟", "5 分钟"], 1)
        rssi_plot(s, 16, y, 328, 320)
        y += 332
        s.rect(16, y, 328, 72, s.t["surface"], rx=14)
        s.rect(32, y + 18, 10, 10, s.t["primary"], rx=2)
        s.text(50, y + 23, "YoLab-5G", 13, weight=700)
        s.text(150, y + 23, "当前", 11, s.t["success"])
        s.rect(32, y + 44, 10, 10, s.t["tertiary"], rx=2)
        s.text(50, y + 49, "隐藏网络", 13, s.t["secondary"])
        s.text(32, y + 64, "", 1)
    nav_pill(s)
    return s


def detail_rows(s: Svg, y: int) -> int:
    rows = [
        ("BSSID", "掩蔽 · 无 PEERS_MAC", s.t["warning"]),
        ("RSSI", "-42 dBm · 4 格", s.t["text"]),
        ("频段 / 频率", "5 GHz · 5180 MHz", s.t["text"]),
        ("信道", "36", s.t["text"]),
        ("信道宽度", "系统未返回", s.t["tertiary"]),
        ("安全", "WPA3-SAE", s.t["text"]),
        ("标准", "系统未返回", s.t["tertiary"]),
        ("来源", "缓存 · 12 秒前", s.t["text"]),
        ("厂商", "需要真实 BSSID", s.t["tertiary"]),
    ]
    s.rect(16, y, 328, 26 * len(rows) + 16, s.t["surface"], rx=16)
    yy = y + 22
    for key, value, color in rows:
        yy = kv(s, 32, yy, 296, key, value, color)
    return y + 26 * len(rows) + 16


def screen_ap_detail() -> Svg:
    s = Svg(360, 800, LIGHT)
    y = phone_chrome(s, "接入点", None, back=True, action="收藏")
    s.rect(16, y, 328, 88, s.t["surface"], rx=16)
    bars(s, 32, y + 28, 4, s.t["primary"])
    s.text(64, y + 30, "YoLab-5G", 18, weight=700)
    pill(s, 200, y + 21, "当前", s.t["success_bg"], s.t["success"])
    s.text(64, y + 58, "点进信道图时，这台 AP 会保持选中。", 12, s.t["secondary"])
    y += 100
    detail_rows(s, y)
    s.rect(0, 688, 360, 112, s.t["surface"])
    s.line(0, 688, 360, 688, s.t["line"])
    button(s, 16, 704, 328, "交给系统连接", "primary")
    nav_pill(s)
    return s


def sheet(s: Svg, top: int) -> int:
    s.rect(0, 0, 360, 800, "#000000", op=0.45)
    s.rect(0, top, 360, 800 - top, s.t["surface"], rx=24)
    s.rect(0, top + 24, 360, 800 - top - 24, s.t["surface"])
    s.rect(168, top + 10, 24, 4, s.t["track"], rx=2)
    return top + 28


def screen_assoc(blocked: bool) -> Svg:
    s = screen_air_list("list")
    y = sheet(s, 390 if not blocked else 360)
    s.text(24, y + 16, "交给系统连接", 18, weight=700)
    lines = (
        ["普通应用不能直接关联指定 WLAN。", "下一步打开系统设置，由系统完成连接。", "本页不收集密码。"]
        if not blocked
        else ["当前身份没有 SET_WIFI_INFO。", "不能打开系统连接流程。", "可复制 SSID，到系统 WLAN 里手动查找。"]
    )
    yy = y + 44
    for line in lines:
        s.text(24, yy, line, 13, s.t["secondary"])
        yy += 22
    s.rect(24, yy + 6, 312, 64, s.t["bg"], rx=12)
    s.text(40, yy + 28, "YoLab-5G", 15, weight=700)
    s.text(40, yy + 50, "WPA3-SAE · 5 GHz · 信道 36", 12, s.t["secondary"])
    if blocked:
        button(s, 24, 700, 312, "打开系统 WLAN", "disabled")
        s.text(180, 756, "改为复制 SSID", 13, s.t["primary"], 700, "middle")
    else:
        button(s, 24, 700, 312, "打开系统 WLAN", "primary")
        s.text(180, 756, "取消", 13, s.t["secondary"], 400, "middle")
    return s


def host_row(s: Svg, x, y, w, ip, meta, state) -> int:
    s.rect(x, y, w, 64, s.t["surface"], rx=14)
    color = s.t[{"alive": "success", "unknown": "warning", "down": "tertiary"}[state]]
    s.circle(x + 22, y + 32, 5, color)
    s.text(x + 40, y + 24, ip, 15, weight=700)
    s.text(x + 40, y + 46, meta, 12, s.t["secondary"])
    return y + 72


def screen_hosts(mode: str) -> Svg:
    s = Svg(360, 800, LIGHT)
    y = phone_chrome(s, "网络", 2, action="停止" if mode == "scan" else "扫描")
    s.rect(16, y, 328, 48, s.t["surface"], rx=14)
    s.text(32, y + 18, "192.168.1.0/24", 14, weight=700)
    s.text(32, y + 36, "由当前地址推断 · 仅限私网", 11, s.t["tertiary"])
    s.text(328, y + 24, "修改", 13, s.t["primary"], 700, "end")
    y += 60
    if mode == "empty":
        empty_block(
            s, 230,
            "这个网段没有响应",
            ["已探测 192.168.1.0/24。", "设备可能禁 ping，或你正在用蜂窝网。"],
            "改为手动网段",
        )
        nav_pill(s)
        return s
    if mode == "scan":
        y = banner(s, 16, y, 328, ["正在探测 64/254 · 可随时停止。", "只访问私网地址。"], "info") + 12
    hosts = [
        ("192.168.1.1", "1 ms · 网关 · 80 开放", "alive"),
        ("192.168.1.20", "4 ms · 22 / 1883 开放", "alive"),
        ("192.168.1.33", "超时 · 状态未知", "unknown"),
    ]
    if mode == "scan":
        hosts = hosts[:2]
    for ip, meta, state in hosts:
        y = host_row(s, 16, y, 328, ip, meta, state)
    nav_pill(s)
    return s


def screen_host_ports() -> Svg:
    s = Svg(360, 800, LIGHT)
    y = phone_chrome(s, "192.168.1.20", None, back=True, action="扫端口")
    s.rect(16, y, 328, 72, s.t["surface"], rx=16)
    s.circle(36, y + 36, 6, s.t["success"])
    s.text(54, y + 26, "有响应", 16, weight=700)
    s.text(54, y + 48, "4 ms · 厂商需真实 MAC，当前未知", 12, s.t["secondary"])
    y += 84
    y = section(s, 16, y, "已开放的端口")
    ports = [
        ("22", "TCP", "SSH", "可开会话"),
        ("1883", "TCP", "MQTT", "建议协议"),
        ("5353", "UDP", "mDNS", "实验发现"),
    ]
    for port, proto, name, hint in ports:
        s.rect(16, y, 328, 60, s.t["surface"], rx=14)
        s.text(32, y + 22, port, 16, weight=700)
        s.text(78, y + 22, f"{proto} · {name}", 13, s.t["secondary"])
        s.text(32, y + 42, hint, 12, s.t["tertiary"])
        s.text(328, y + 30, "打开", 13, s.t["primary"], 700, "end")
        y += 68
    nav_pill(s)
    return s


def screen_port_confirm() -> Svg:
    s = screen_host_ports()
    s.rect(0, 0, 360, 800, "#000000", op=0.45)
    s.rect(36, 250, 288, 220, s.t["surface"], rx=20)
    s.text(180, 286, "扫描 256 个端口", 17, weight=700, anchor="middle")
    s.text(180, 318, "将向 192.168.1.20 发起大量探测。", 12, s.t["secondary"], 400, "middle")
    s.text(180, 338, "仅用于你有权诊断的局域网。", 12, s.t["secondary"], 400, "middle")
    s.text(180, 358, "YW-NET-2201 以上范围会被拒绝。", 12, s.t["tertiary"], 400, "middle")
    button(s, 52, 386, 120, "取消", "secondary")
    button(s, 184, 386, 120, "开始扫描", "warning")
    return s


def screen_sessions() -> Svg:
    s = Svg(360, 800, LIGHT)
    y = phone_chrome(s, "网络", 3, action="新建")
    items = [
        ("TCP", "192.168.1.20:1883", "已连接 · 12 条报文", "ok"),
        ("HTTP", "GET example.com", "200 · 86 ms", "ok"),
        ("MQTT", "lab.local:1883", "订阅 lab/tele", "run"),
        ("UDP", "0.0.0.0:5683", "未绑定 · YW-NET-2101", "bad"),
    ]
    for proto, title, meta, state in items:
        s.rect(16, y, 328, 68, s.t["surface"], rx=14)
        tone = {"ok": s.t["success"], "run": s.t["primary"], "bad": s.t["error"]}[state]
        bg = {"ok": s.t["success_bg"], "run": s.t["info_bg"], "bad": s.t["error_bg"]}[state]
        pill(s, 28, y + 14, proto, bg, tone)
        s.text(92, y + 24, title, 14, weight=700)
        s.text(28, y + 48, meta, 12, s.t["secondary"])
        y += 76
    nav_pill(s)
    return s


def composer(s: Svg, y, mode="HEX") -> None:
    s.rect(0, y, 360, 800 - y, s.t["surface"])
    s.line(0, y, 360, y, s.t["line"])
    s.rect(16, y + 12, 88, 28, s.t["chip"], rx=14)
    for i, name in enumerate(["文本", "HEX"]):
        if name == mode:
            s.rect(18 + i * 42, y + 14, 40, 24, s.t["surface"], rx=12)
        s.text(38 + i * 42, y + 26, name, 11, s.t["primary"] if name == mode else s.t["secondary"], 700, "middle")
    s.rect(112, y + 12, 160, 28, s.t["bg"], rx=14)
    s.text(124, y + 26, "10 4D 51 54 54" if mode == "HEX" else "hello", 12, s.t["text"], family=MONO)
    button(s, 280, y + 10, 64, "发送", "primary")


def screen_terminal(lost=False) -> Svg:
    s = Svg(360, 800, LIGHT)
    phone_chrome(s, "TCP 1883", None, back=True, action="断开", action_color=s.t["error"])
    y = 112
    if lost:
        y = banner(s, 16, y, 328, ["回到前台后套接字已断开。", "YW-NET-2104 · 需要重新建立会话。"], "err") + 8
    else:
        s.rect(16, y, 328, 28, s.t["success_bg"], rx=8)
        s.text(28, y + 14, "已连接 192.168.1.20:1883 · 本机 :48122", 11, s.t["success"])
        y += 36
    lines = [
        ("09:12:01", "SYS", "连接建立"),
        ("09:12:01", "TX", "10 4D 51 54 54 04 C0 00"),
        ("09:12:01", "RX", "20 02 00 00"),
        ("09:12:06", "TX", "82 0A 00 08 6C 61 62"),
        ("09:12:06", "RX", "90 03 00 01 00"),
        ("09:12:11", "RX", "30 12 6C 61 62 2F 74"),
        ("09:12:18", "TX", "32 07 73 74 61 74 75"),
        ("09:12:18", "RX", "40 02 00 00"),
        ("09:13:02", "SYS", "空闲 44 秒"),
        ("09:14:10", "RX", "31 04 70 69 6E 67"),
    ]
    if lost:
        lines.append(("09:18:22", "SYS", "后台断开 YW-NET-2104"))
    s.rect(16, y, 328, 28 * len(lines) + 16, s.t["surface"], rx=14)
    for i, (ts, kind, payload) in enumerate(lines):
        yy = y + 18 + i * 28
        color = {"TX": s.t["primary"], "RX": s.t["success"], "SYS": s.t["warning"]}[kind]
        s.text(28, yy, ts, 11, s.t["tertiary"], family=MONO)
        s.text(96, yy, kind, 11, color, 700, family=MONO)
        s.text(132, yy, payload, 11, s.t["text"], family=MONO)
    composer(s, 700)
    nav_pill(s)
    return s


def screen_connect_sheet() -> Svg:
    s = screen_sessions()
    y = sheet(s, 250)
    s.text(24, y + 12, "新建会话", 18, weight=700)
    y = chips(s, 24, y + 36, ["TCP", "UDP", "HTTP", "WS", "MQTT"], 0)
    fields = [("主机", "192.168.1.20"), ("端口", "1883"), ("超时", "10 秒")]
    for label, value in fields:
        s.text(24, y + 8, label, 12, s.t["secondary"])
        s.rect(24, y + 20, 312, 36, s.t["bg"], rx=10)
        s.text(36, y + 38, value, 14, s.t["text"])
        y += 64
    s.text(24, y + 4, "来源：主机 192.168.1.20 的端口 1883", 11, s.t["tertiary"])
    button(s, 24, 730, 312, "连接", "primary")
    return s


def screen_http() -> Svg:
    s = Svg(360, 800, LIGHT)
    y = phone_chrome(s, "HTTP", None, back=True, action="发送")
    s.rect(16, y, 64, 32, s.t["primary"], rx=10)
    s.text(48, y + 16, "GET", 13, s.t["on_primary"], 700, "middle")
    s.rect(88, y, 256, 32, s.t["surface"], rx=10)
    s.text(100, y + 16, "https://example.com", 12, s.t["text"], family=MONO)
    y += 44
    s.rect(16, y, 328, 36, s.t["success_bg"], rx=10)
    s.text(28, y + 18, "200  OK  ·  86 ms  ·  1.2 KB", 13, s.t["success"], 700)
    y += 48
    y = section(s, 16, y, "响应体")
    s.rect(16, y, 328, 180, s.t["surface"], rx=14)
    body = ['{', '  "ok": true,', '  "path": "reachable"', '}']
    for i, line in enumerate(body):
        s.text(28, y + 24 + i * 22, line, 13, s.t["text"], family=MONO)
    y += 196
    y = section(s, 16, y, "这次请求已写入会话")
    s.text(16, y, "收藏为命令留在会话菜单，不单独做协议首页。", 12, s.t["secondary"])
    nav_pill(s)
    return s


def screen_mqtt() -> Svg:
    s = Svg(360, 800, LIGHT)
    y = phone_chrome(s, "MQTT", None, back=True, action="断开", action_color=s.t["error"])
    s.rect(16, y, 328, 56, s.t["surface"], rx=14)
    s.text(32, y + 20, "lab.local:1883", 14, weight=700)
    s.text(32, y + 40, "已连接 · QoS 0 · 未启用 TLS", 12, s.t["secondary"])
    y += 68
    y = section(s, 16, y, "订阅")
    y = chips(s, 16, y, ["lab/tele", "lab/cmd", "+ 主题"], 0)
    s.rect(16, y, 328, 120, s.t["surface"], rx=14)
    s.text(32, y + 24, "lab/tele", 12, s.t["primary"], 700)
    s.text(32, y + 48, '{"temp":21.4}', 13, s.t["text"], family=MONO)
    s.text(32, y + 76, "lab/cmd", 12, s.t["tertiary"], 700)
    s.text(32, y + 98, "ping", 13, s.t["secondary"], family=MONO)
    y += 136
    s.rect(16, y, 328, 72, s.t["surface"], rx=14)
    s.text(32, y + 22, "发布到 lab/cmd", 12, s.t["secondary"])
    s.rect(32, y + 34, 200, 28, s.t["bg"], rx=8)
    s.text(40, y + 48, "status", 13, s.t["text"], family=MONO)
    button(s, 244, y + 32, 84, "发布", "primary")
    nav_pill(s)
    return s


def wide_shell(s: Svg, lens: int) -> int:
    s.rect(0, 0, s.w, 48, s.t["surface"])
    s.text(16, 24, "9:41", 14, weight=700)
    s.text(64, 24, "网络", 16, weight=700)
    s.text(s.w - 16, 24, "模块内分栏 · 不替换应用工作台", 12, s.t["tertiary"], 400, "end")
    s.line(0, 48, s.w, 48, s.t["line"])
    if s.w < 1000:
        return 48
    s.rect(0, 48, 180, s.h - 48, s.t["surface"])
    s.line(180, 48, 180, s.h, s.t["line"])
    names = [("链路", "当前路径"), ("空口", "接入点"), ("主机", "局域网"), ("会话", "协议")]
    for i, (name, hint) in enumerate(names):
        yy = 68 + i * 72
        if i == lens:
            s.rect(12, yy, 156, 56, s.t["selected"], rx=12)
            s.rect(12, yy + 12, 3, 32, s.t["primary"], rx=1)
        s.text(28, yy + 20, name, 16, s.t["primary"] if i == lens else s.t["text"], 700 if i == lens else 400)
        s.text(28, yy + 40, hint, 11, s.t["tertiary"])
    s.text(16, s.h - 28, "透镜随对象走", 11, s.t["tertiary"])
    return 180


def screen_wide_air() -> Svg:
    s = Svg(1280, 800, LIGHT)
    wide_shell(s, 1)
    s.rect(180, 48, 300, 752, s.t["bg"])
    s.line(480, 48, 480, 800, s.t["line"])
    s.text(196, 76, "接入点 · 5", 14, weight=700)
    s.text(460, 76, "扫描", 13, s.t["primary"], 700, "end")
    chips(s, 196, 92, ["5G", "当前"], 0)
    y = 140
    for i, ap in enumerate(APS):
        ap_row(s, 196, y, 268, ap, selected=i == 0)
        y += 72
    channel_plot(s, 496, 64, 460, 520, "5")
    s.text(496, 48 + 20, "", 1)
    s.rect(972, 64, 292, 640, s.t["surface"], rx=16)
    s.text(988, 92, "检查器", 12, s.t["tertiary"])
    s.text(988, 118, "YoLab-5G", 18, weight=700)
    pill(s, 1110, 109, "当前", s.t["success_bg"], s.t["success"])
    yy = 156
    for key, value in [
        ("信道", "36 · 画布已高亮"),
        ("RSSI", "-42 dBm"),
        ("安全", "WPA3-SAE"),
        ("BSSID", "掩蔽"),
        ("宽度", "系统未返回"),
    ]:
        yy = kv(s, 988, yy, 252, key, value)
    s.text(988, yy + 8, "选中关系与左侧列表、中间信道图同步。", 12, s.t["secondary"])
    button(s, 988, 620, 260, "交给系统连接", "primary")
    return s


def screen_wide_link() -> Svg:
    s = Svg(1280, 800, LIGHT)
    wide_shell(s, 0)
    s.text(200, 78, "路径检查", 14, weight=700)
    runs = [
        ("example.com", "进行中 · 解析", True),
        ("192.168.1.1", "通过 · 1 ms", False),
        ("lab.local", "失败 · YW-NET-1001", False),
    ]
    y = 100
    for title, meta, on in runs:
        s.rect(196, y, 268, 64, s.t["selected"] if on else s.t["surface"], rx=12)
        s.text(212, y + 24, title, 14, weight=700)
        s.text(212, y + 46, meta, 12, s.t["primary"] if on else s.t["secondary"])
        y += 74
    button(s, 196, y + 8, 268, "新建检查", "secondary")
    # canvas: large path
    s.rect(496, 64, 460, 300, s.t["surface"], rx=16)
    s.text(516, 92, "example.com 的路径", 14, weight=700)
    path_card(s, 512, 112, 428, link_nodes("run"))
    s.rect(496, 380, 460, 360, s.t["surface"], rx=16)
    s.text(516, 408, "步骤", 13, s.t["secondary"], 700)
    step_list(
        s, 512, 424, 428,
        [
            ("网络状态", "ok", "WLAN"),
            ("域名解析", "run", "example.com"),
            ("TCP 443", "wait", "等待"),
            ("HTTP 探测", "wait", "等待"),
        ],
    )
    s.rect(972, 64, 292, 676, s.t["surface"], rx=16)
    s.text(988, 96, "选中的一跳", 12, s.t["tertiary"])
    s.text(988, 124, "域名解析", 18, weight=700)
    yy = 160
    for k, v in [("目标", "example.com"), ("类型", "A / AAAA"), ("网络", "默认 NetHandle"), ("状态", "进行中")]:
        yy = kv(s, 988, yy, 252, k, v, s.t["primary"] if k == "状态" else None)
    s.text(988, yy + 12, "Whois 不在这一跳。", 12, s.t["secondary"])
    s.text(988, yy + 32, "它只用于公网对象，且需要互联网。", 12, s.t["secondary"])
    button(s, 988, 668, 260, "停止检查", "secondary")
    return s


def screen_wide_host() -> Svg:
    s = Svg(1280, 800, LIGHT)
    wide_shell(s, 2)
    s.text(200, 76, "192.168.1.0/24", 14, weight=700)
    s.text(460, 76, "扫描中", 12, s.t["primary"], 700, "end")
    y = 100
    for ip, meta, state, on in [
        ("192.168.1.1", "网关 · 80", "alive", False),
        ("192.168.1.20", "22 / 1883", "alive", True),
        ("192.168.1.33", "未知", "unknown", False),
    ]:
        host_row(s, 196, y, 268, ip, meta, state)
        if on:
            s.rect(196, y, 3, 64, s.t["primary"], rx=1)
        y += 72
    s.rect(496, 64, 460, 676, s.t["surface"], rx=16)
    s.text(516, 96, "192.168.1.20", 18, weight=700)
    s.text(516, 122, "4 ms · 仅局域网诊断", 12, s.t["secondary"])
    ports = [("22", "SSH", "TCP 开放"), ("1883", "MQTT", "TCP 开放"), ("5353", "mDNS", "UDP 可见")]
    yy = 150
    for port, name, meta in ports:
        s.rect(516, yy, 420, 52, s.t["bg"], rx=10)
        s.text(532, yy + 20, port, 16, weight=700)
        s.text(590, yy + 20, name, 14, s.t["text"])
        s.text(532, yy + 38, meta, 12, s.t["secondary"])
        yy += 62
    s.text(516, yy + 16, "大范围端口扫描会先确认，超过阈值直接拒绝。", 12, s.t["tertiary"])
    s.rect(972, 64, 292, 676, s.t["surface"], rx=16)
    s.text(988, 96, "用此端口开会话", 12, s.t["tertiary"])
    s.text(988, 122, "MQTT", 18, weight=700)
    yy = 156
    for label, value in [("主机", "192.168.1.20"), ("端口", "1883"), ("Client ID", "yowire"), ("QoS", "0")]:
        s.text(988, yy, label, 12, s.t["secondary"])
        s.rect(988, yy + 12, 252, 32, s.t["bg"], rx=8)
        s.text(1000, yy + 28, value, 13, s.t["text"])
        yy += 56
    button(s, 988, 668, 252, "连接", "primary")
    return s


def screen_wide_session() -> Svg:
    s = Svg(1280, 800, LIGHT)
    wide_shell(s, 3)
    s.text(200, 76, "会话", 14, weight=700)
    s.text(460, 76, "新建", 13, s.t["primary"], 700, "end")
    items = [
        ("TCP", "192.168.1.20:1883", True),
        ("HTTP", "example.com", False),
        ("MQTT", "lab.local", False),
    ]
    y = 100
    for proto, title, on in items:
        s.rect(196, y, 268, 64, s.t["selected"] if on else s.t["surface"], rx=12)
        s.text(212, y + 24, title, 14, weight=700)
        s.text(212, y + 46, proto, 12, s.t["primary"] if on else s.t["secondary"])
        y += 74
    s.rect(496, 64, 460, 620, s.t["surface"], rx=16)
    s.text(516, 92, "报文", 13, s.t["secondary"], 700)
    lines = [
        ("TX", "10 4D 51 54 54 04"),
        ("RX", "20 02 00 00"),
        ("TX", "82 0A 6C 61 62"),
        ("RX", "90 03 00 01"),
    ]
    for i, (kind, payload) in enumerate(lines):
        yy = 120 + i * 28
        s.text(516, yy, kind, 12, s.t["primary"] if kind == "TX" else s.t["success"], 700, family=MONO)
        s.text(556, yy, payload, 13, s.t["text"], family=MONO)
    s.rect(512, 620, 428, 40, s.t["bg"], rx=10)
    s.text(524, 640, "文本", 12, s.t["primary"], 700)
    s.text(570, 640, "要发送的内容", 12, s.t["tertiary"])
    s.rect(972, 64, 292, 676, s.t["surface"], rx=16)
    s.text(988, 96, "连接参数", 12, s.t["tertiary"])
    s.text(988, 124, "TCP 客户端", 18, weight=700)
    yy = 164
    for k, v in [("远端", "192.168.1.20:1883"), ("本地端口", "48122"), ("编码", "HEX"), ("自动重连", "关闭")]:
        yy = kv(s, 988, yy, 252, k, v)
    s.text(988, yy + 8, "参数改动只影响下一次连接。", 12, s.t["secondary"])
    button(s, 988, 668, 252, "断开", "secondary")
    return s


def screen_wide_md() -> Svg:
    s = Svg(800, 640, LIGHT)
    s.rect(0, 0, 800, 48, s.t["surface"])
    s.text(16, 24, "网络", 18, weight=700)
    s.text(784, 24, "中屏不放透镜轨", 12, s.t["tertiary"], 400, "end")
    names = ["链路", "空口", "主机", "会话"]
    for i, name in enumerate(names):
        cx = 70 + i * 90
        s.text(cx, 78, name, 14, s.t["primary"] if i == 1 else s.t["secondary"], 700 if i == 1 else 400, "middle")
        if i == 1:
            s.rect(cx - 16, 92, 32, 3, s.t["primary"], rx=1)
    s.line(0, 104, 800, 104, s.t["line"])
    s.text(16, 128, "接入点", 13, s.t["secondary"], 700)
    y = 146
    for i, ap in enumerate(APS[:4]):
        ap_row(s, 16, y, 300, ap, selected=i == 0)
        y += 72
    channel_plot(s, 336, 120, 448, 420, "5")
    s.rect(0, 576, 800, 64, s.t["surface"])
    s.line(0, 576, 800, 576, s.t["line"])
    s.text(16, 600, "YoLab-5G", 14, weight=700)
    s.text(16, 622, "5 GHz · 信道 36 · -42 dBm · 与信道图同步", 12, s.t["secondary"])
    button(s, 560, 592, 112, "详情", "secondary")
    button(s, 680, 592, 104, "连接", "primary")
    return s


def main() -> None:
    root = os.path.dirname(os.path.abspath(__file__))
    out = os.path.join(root, "svg")
    os.makedirs(out, exist_ok=True)
    screens = {
        "01-link-ready": screen_link("ready"),
        "02-link-wifi-off": screen_link("off"),
        "03-link-permission": screen_link("perm"),
        "04-link-portal": screen_link("portal"),
        "05-link-diagnose-running": screen_link("run"),
        "06-link-diagnose-partial": screen_link("partial"),
        "07-air-list": screen_air_list("list"),
        "08-air-scanning": screen_air_list("scan"),
        "09-air-empty": screen_air_list("empty"),
        "10-air-throttled": screen_air_list("throttle"),
        "11-air-channel": screen_air_chart("channel"),
        "12-air-rssi": screen_air_chart("rssi"),
        "13-ap-detail": screen_ap_detail(),
        "14-assoc-sheet": screen_assoc(False),
        "15-assoc-blocked": screen_assoc(True),
        "16-hosts-scanning": screen_hosts("scan"),
        "17-hosts-list": screen_hosts("list"),
        "18-hosts-empty": screen_hosts("empty"),
        "19-host-ports": screen_host_ports(),
        "20-session-list": screen_sessions(),
        "21-session-terminal": screen_terminal(False),
        "22-session-connect": screen_connect_sheet(),
        "23-session-http": screen_http(),
        "24-session-mqtt": screen_mqtt(),
        "25-session-lost": screen_terminal(True),
        "26-link-ready-dark": screen_link("ready", dark=True),
        "27-port-scan-confirm": screen_port_confirm(),
        "28-wide-lg-air": screen_wide_air(),
        "29-wide-lg-link": screen_wide_link(),
        "30-wide-lg-host": screen_wide_host(),
        "31-wide-lg-session": screen_wide_session(),
        "32-wide-md-air": screen_wide_md(),
    }
    for name, canvas in screens.items():
        path = os.path.join(out, f"{name}.svg")
        with open(path, "w", encoding="utf-8") as handle:
            handle.write(canvas.dump())
        print(path)


if __name__ == "__main__":
    main()
