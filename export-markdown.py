#!/usr/bin/env python3
"""Export a presentation's slides as plain Markdown: every slide's text and speaker notes.

Usage: ./export-markdown.py [<slug> ...]

Writes <slug>/slides.md from <slug>/index.html. With no slugs, exports every
presentation folder. Standard library only. The Markdown is for reading, reviewing
and searching the text; index.html stays the source of truth.
"""
import os
import re
import sys
from html import unescape
from html.parser import HTMLParser

VOID = {"br", "circle", "line", "path", "rect", "img", "meta", "link"}


class Node:
    def __init__(self, tag, attrs, parent=None):
        self.tag, self.attrs, self.parent, self.children = tag, dict(attrs), parent, []

    @property
    def cls(self):
        return set((self.attrs.get("class") or "").split())


class Builder(HTMLParser):
    def __init__(self):
        super().__init__(convert_charrefs=True)
        self.root = self.cur = Node("root", [])

    def handle_starttag(self, tag, attrs):
        n = Node(tag, attrs, self.cur)
        self.cur.children.append(n)
        if tag not in VOID:
            self.cur = n

    def handle_startendtag(self, tag, attrs):
        self.cur.children.append(Node(tag, attrs, self.cur))

    def handle_endtag(self, tag):
        n = self.cur
        while n is not None and n.tag != tag:
            n = n.parent
        if n is not None and n.parent is not None:
            self.cur = n.parent

    def handle_data(self, data):
        self.cur.children.append(data)


def find_all(node, pred):
    out = []
    for c in node.children:
        if isinstance(c, Node):
            if pred(c):
                out.append(c)
            out.extend(find_all(c, pred))
    return out


def text(node):
    return "".join(c if isinstance(c, str) else text(c) for c in node.children)


def inline(node, br=" "):
    parts = []
    for c in node.children:
        if isinstance(c, str):
            parts.append(re.sub(r"\s+", " ", c).replace("<", "\\<"))
            continue
        if c.tag == "br":
            parts.append(br)
        elif c.tag == "code":
            parts.append("`" + re.sub(r"\s+", " ", text(c)) + "`")
        elif c.tag == "strong":
            parts.append("**" + inline(c, br).strip() + "**")
        elif c.tag == "em":
            parts.append("*" + inline(c, br).strip() + "*")
        elif "pill" in c.cls:
            parts.append("[" + inline(c, br).strip() + "]")
        elif "num" in c.cls:
            parts.append(inline(c, br).strip() + ".")
        else:
            parts.append(inline(c, br))
    return re.sub(r" {2,}", " ", "".join(parts))


def cell(node):
    return inline(node, "<br>").strip().replace("|", "\\|")


def block(node, depth=0):
    """Render a block-level node to a list of Markdown lines."""
    out = []
    for c in node.children:
        if isinstance(c, str):
            if c.strip():
                out += [re.sub(r"\s+", " ", c).strip(), ""]
            continue
        t, cls = c.tag, c.cls
        if t in ("h1", "h2") or "kicker" in cls:
            continue  # used in the slide heading
        if t == "aside" and "notes" in cls:
            continue  # rendered after the slide body
        if t == "h3":
            out += ["#### " + inline(c).strip(), ""]
        elif t == "p":
            line = inline(c, "  \n").strip()
            if "callout" in cls:
                out += ["> " + line.replace("  \n", "  \n> "), ""]
            elif "muted" in cls:
                out += ["*" + line + "*" if not line.startswith("*") else line, ""]
            else:
                out += [line, ""]
        elif t in ("ul", "ol"):
            for i, li in enumerate([x for x in c.children if isinstance(x, Node) and x.tag == "li"], 1):
                bullet = f"{i}." if t == "ol" else "-"
                nested = [x for x in li.children if isinstance(x, Node) and x.tag in ("ul", "ol")]
                own = Node("li", [])
                own.children = [x for x in li.children if x not in nested]
                out.append("  " * depth + f"{bullet} " + inline(own).strip())
                for n in nested:
                    wrap = Node("div", [])
                    wrap.children = [n]
                    out += [l for l in block(wrap, depth + 1) if l]
            out.append("")
        elif t == "table":
            rows = find_all(c, lambda n: n.tag == "tr")
            if not rows:
                continue
            for i, r in enumerate(rows):
                cells = [cell(x) for x in r.children if isinstance(x, Node) and x.tag in ("th", "td")]
                out.append("| " + " | ".join(cells) + " |")
                if i == 0:
                    out.append("|" + "---|" * len(cells))
            out.append("")
        elif t == "pre":
            out += ["```", text(c).strip("\n"), "```", ""]
        elif t == "svg":
            label = c.attrs.get("aria-label", "").strip()
            labels = [re.sub(r"\s+", " ", text(x)).strip() for x in find_all(c, lambda n: n.tag == "text")]
            out.append("*Diagram:* " + label)
            if labels:
                out.append("")
                out.append("*Diagram labels:* " + " · ".join(l for l in labels if l))
            out.append("")
        elif "timeline" in cls:
            out += ["| Wave | When |", "|---|---|"]
            kids = [x for x in c.children if isinstance(x, Node)]
            for i, k in enumerate(kids):
                if "row-label" in k.cls:
                    nxt = kids[i + 1] if i + 1 < len(kids) else None
                    out.append(f"| {cell(k)} | {cell(nxt) if nxt else ''} |")
            out.append("")
        elif "placeholder" in cls:
            ph = re.sub(r" (assets/\S+)$", r" (\1)", inline(c, " ").strip())
            out += ["*[Placeholder: " + ph + "]*", ""]
        elif "card" in cls:
            label = [x for x in c.children if isinstance(x, Node) and x.tag == "p" and "muted" in x.cls]
            head = [x for x in c.children if isinstance(x, Node) and x.tag == "h3"]
            rest = Node("div", [])
            rest.children = [x for x in c.children if x not in label + head]
            rest.children = [x for x in rest.children if not (isinstance(x, Node) and "num" in x.cls)]
            title = inline(head[0]).strip() if head else ""
            prefix = f"*{inline(label[0]).strip()}*: " if label else ""
            lines = block(rest, depth)
            if find_all(rest, lambda n: n.tag in ("ul", "ol", "table", "pre")):
                out += [f"{prefix}**{title}**", ""] + lines
            else:
                body = " ".join(l for l in lines if l.strip())
                out += [f"- {prefix}**{title}**" + (f": {body}" if body else ""), ""]
        else:
            out += block(c, depth)
    return out


def export(slug):
    src, dst = os.path.join(slug, "index.html"), os.path.join(slug, "slides.md")
    b = Builder()
    b.feed(open(src, encoding="utf-8").read())
    titles = find_all(b.root, lambda n: n.tag == "title")
    title = text(titles[0]).strip() if titles else slug
    slides = find_all(b.root, lambda n: n.tag == "section" and "slide" in n.cls)
    md = [f"# {title}", "",
          f"The text of all {len(slides)} slides in `index.html`, with speaker notes. "
          f"Generated by `./export-markdown.py {slug}`; don't edit by hand.", ""]
    for i, s in enumerate(slides, 1):
        heads = find_all(s, lambda n: n.tag in ("h1", "h2"))
        kick = find_all(s, lambda n: "kicker" in n.cls)
        heading = inline(heads[0]).strip() if heads else "(untitled)"
        md += ["---", "", f"## {i}. {heading}", ""]
        if kick:
            md += [f"*{inline(kick[0]).strip()}*", ""]
        # collapse runs of blank lines
        for line in block(s):
            if line == "" and md and md[-1] == "":
                continue
            md.append(line)
        for n in find_all(s, lambda n: n.tag == "aside" and "notes" in n.cls):
            md += [f"**Speaker notes:** {inline(n).strip()}", ""]
    open(dst, "w", encoding="utf-8").write("\n".join(md).rstrip() + "\n")
    print(f"Wrote {dst} ({len(slides)} slides)")


def main(slugs):
    os.chdir(os.path.dirname(os.path.abspath(__file__)))
    if not slugs:
        slugs = sorted(d for d in os.listdir(".")
                       if not d.startswith((".", "_")) and os.path.isfile(os.path.join(d, "index.html")))
    for slug in slugs:
        slug = slug.rstrip("/")
        if not os.path.isfile(os.path.join(slug, "index.html")):
            sys.exit(f"No presentation at {slug}/index.html")
        export(slug)


if __name__ == "__main__":
    main(sys.argv[1:])
