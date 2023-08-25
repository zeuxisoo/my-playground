import sys
import base64
import asyncio
import numpy as np
import cv2 # ios14 safari load failed
from pyodide.ffi import create_proxy
from js import document, Uint8Array, URL, alert

# custom js module
from js_logger import add as addLog
from js_helper import setPreviewStatus, setRenderStatus, getRenderStatus, setIsImageRendered, getDateTime
from js_store import increaseSelectedCount, increaseRenderedCount

def dump(text):
    print(text)
    addLog(text)

dump(sys.version)

# tricks ensure ui effect up to date
async def waitSetRenderStatus(text):
    setRenderStatus(text)
    await asyncio.sleep(0.1)

async def waitSetIsImageRendered(status):
    setIsImageRendered(status)
    await asyncio.sleep(0.1)

async def waitDump(text):
    dump(text)
    await asyncio.sleep(0.1)

async def select_file(event):
    await waitSetIsImageRendered(False)
    await waitSetRenderStatus('reading')
    await waitDump('Reading file')
    await waitDump('- ' + getDateTime())

    file   = event.target.files.object_values()[0]
    data   = Uint8Array.new(await file.arrayBuffer())
    buffer = bytearray(data)

    video_source_element = document.querySelector('.video-source');
    video_source_element.setAttribute('src', URL.createObjectURL(file));

    video_element = document.querySelector('.video');
    video_element.load();

    with open("/hello.mp4", "wb") as fh:
        fh.write(buffer)

    setRenderStatus('readying')
    increaseSelectedCount()

async def render_file(event):
    if getRenderStatus() != "readying":
        alert('Please select file first')
        return False

    await waitSetIsImageRendered(False)
    await waitSetRenderStatus('rendering')
    await waitDump('Rendering file')
    await waitDump('- ' + getDateTime())

    cap = cv2.VideoCapture('/hello.mp4')

    if cap.isOpened():
        await waitDump("Reading video")
        await waitDump("-Total : {}".format(int(cap.get(cv2.CAP_PROP_FRAME_COUNT))))
        await waitDump("-Width : {}".format(cap.get(cv2.CAP_PROP_FRAME_WIDTH)))
        await waitDump("-Height: {}".format(cap.get(cv2.CAP_PROP_FRAME_HEIGHT)))

        await waitDump("Reading frames")
        frames = []
        for i in range(10):
            j = (i + 1) / 10

            ret, frame = cap.read()
            if ret:
                await waitDump(f"Reading frames ... {i}")
                frames.append(frame)
            else:
                break

        await waitDump("Maximum frames")
        max_gray_frame = np.dstack(frames)
        bgr_frame = max_gray_frame.max(axis=2)

        ret, image_buffer = cv2.imencode('.png', bgr_frame)

        document.querySelector('.rendered').src = "data:image/png;base64,{}".format(base64.b64encode(image_buffer.tobytes()).decode())

        setPreviewStatus('image')
        setIsImageRendered(True)
        increaseRenderedCount()

        dump("Rendered image")
    else:
        setIsImageRendered(False)

        dump("Error, Cannot open video file")
        alert("Cannot open video file (.mp4)")

    setRenderStatus('idle')

def main():
    print("Hello world")

    file_event = create_proxy(select_file)
    render_event = create_proxy(render_file)

    file_element = document.querySelector(".file")
    file_element.addEventListener("change", file_event, False)

    render_element = document.querySelector(".render")
    render_element.addEventListener("click", render_event, False)

main()
