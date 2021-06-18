import io
import os
import statistics
import subprocess
import sys
import time
from typing import List, Optional

from PIL import Image, ImageDraw, ImageFont, ImageStat

import requests


class Link:
    def __init__(self):
        self.title: str = None
        self.url: str = None
        self.filename: str = None

    def __str__(self):
        return ', '.join([self.title, self.url, self.filename])


SUBREDDITS = [
    "earthporn",
]


def get_links() -> Optional[List[Link]]:
    list_url = f"http://www.reddit.com/r/{'+'.join(SUBREDDITS)}.json?limit=20"

    print(f"Get List: '{list_url}'")

    r = None
    retry = 3
    wait = 5
    while retry > 0:
        try:
            r = requests.get(list_url, headers={
                'User-agent': 'reddit-kabegami'})
        except Exception:
            pass

        if r and r.status_code == requests.codes.ok:
            break

        print(f"fail ({r.status_code if r else 'unknown'})")
        time.sleep(wait)
        r = None
        retry -= 1

    if retry == 0:
        return None

    data = r.json() if r else None

    KIND_LINK = 't3'
    DOT_EXTS = (
        '.jpg',
        '.jpeg',
        '.png',
    )
    posts = [x['data'] for x in data['data']['children']
             if x['kind'] == KIND_LINK]
    links = []
    for p in posts:
        dot_ext = os.path.splitext(p['url'])[1]
        is_image = any([dot_ext == x for x in DOT_EXTS])
        is_nsfw = p['over_18']
        if is_image and not is_nsfw:
            link = Link()
            link.title = p['title']
            link.url = p['url']
            link.filename = f"{p['subreddit']}_{p['name']}{dot_ext}"
            links.append(link)

    return links


def save_images(links: List[Link]) -> List[str]:
    SAVE_DIRPATH = os.path.expanduser("~/Pictures/Wallpapers/reddit")

    paths = []
    for link in links:
        print(f"Save Image: '{link.url}'")

        path = os.path.join(SAVE_DIRPATH, link.filename)
        if not os.path.isfile(path):
            r = requests.get(link.url)
            if r.status_code != requests.codes.ok:
                print(f"fail ({r.status_code})")
                continue

            img = Image.open(io.BytesIO(r.content))
            img = modify_image(img, link)

            os.makedirs(SAVE_DIRPATH, exist_ok=True)
            img.save(path)
        paths.append(path)

    return paths


def modify_image(img: Image.Image, link: Link) -> Image.Image:
    SCALE = 0.8
    W = 3840 * SCALE
    H = 2160 * SCALE

    TEXT = link.title
    FONT_FILE = ('/usr/share/fonts/TTF/'
                 'Ricty-Discord-Regular-Nerd-Font-Complete.ttf')
    FONT_SIZE = 24
    FONT_OFFSET = (10, 10)
    if W or H:
        r = max(img.width / W, img.height / H)
        if r > 1:
            img = img.resize([int(x / r) for x in img.size])

    if TEXT:
        # find nice color
        median = tuple(ImageStat.Stat(img).median)
        is_dark_bg = True
        bg_color = "#333333"
        if median and len(median) == 3:
            r, g, b = median
            bg_color = "rgb(%s, %s, %s)" % (r, g, b)
            is_dark_bg = statistics.mean(median) < 112
        fg_color = "#dddddd" if is_dark_bg else "#222222"

        font = ImageFont.truetype(FONT_FILE, FONT_SIZE)
        draw = ImageDraw.Draw(img)
        draw.line((0, 0, img.width, 0),
                  fill=bg_color,
                  width=int((FONT_SIZE + FONT_OFFSET[1]) * 2.5))
        draw.text(FONT_OFFSET, TEXT, fill=fg_color, font=font)

    return img


def create_symlinks(spaths: List[str]):
    i = 0
    for spath in spaths:
        dpath = os.path.expanduser("~/default_wallpaper" + str(i))
        subprocess.run(["ln", "-s", "--force", spath, dpath])
        print(f"Create Symlink: '{spath}' -> '{dpath}'")
        i += 1


def run(n=1) -> int:
    links = get_links()

    if not links or len(links) < n:
        print("no link")
        return 1

    paths = save_images(links[:n])
    if not paths or len(paths) < n:
        print("no paths")
        return 1

    create_symlinks(paths)
    return 0


if __name__ == '__main__':
    n = int(sys.argv[1]) if len(sys.argv) > 1 else 1
    SUBREDDITS = ([x.strip() for x in sys.argv[2].split(",")]
                  if len(sys.argv) > 2 else SUBREDDITS)
    ret = run(n)
    sys.exit(ret)
