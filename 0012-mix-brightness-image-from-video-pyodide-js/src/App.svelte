<script>
import { onMount } from 'svelte';
import { loadPyodide } from 'pyodide';
import { format, getTime } from 'date-fns';
import { themeChange } from 'theme-change';
import { defaultStore } from './stores';
import Drawer from "./components/Drawer.svelte";
import Card from "./components/Card.svelte";
import CardHero from './components/CardHero.svelte';
import FontIcon from './components/FontIcon.svelte';
import Modal from './components/Modal.svelte';
import videoPlaceHolder from './assets/placeholders/video.mp4';
import imagePlaceHolder from './assets/placeholders/image.png';

// @ts-ignore
import convertPyCode from './python/convert.py'; // load for dev only

//
let isPyodideLoaded = false;
let isImageRendered = false;
let renderStatus  = 'loading';  // loading | reading | readying | rendering | idle
let previewStatus = 'video';    // image | video

const Logger = {
	logs: [],

	add(text) {
    	Logger.logs = [...Logger.logs, text];

        const logsElement = document.querySelector('.logs');

        if (logsElement !== null) {
            // tricks enure scroll moved
            setTimeout(() => {
                logsElement.scrollTop = logsElement.scrollHeight;
            }, 0);
        }
    },

    clean() {
        Logger.logs = [];
    }
};

const Helper = {
    setPreviewStatus(name) {
        previewStatus = name;
    },

    setRenderStatus(name) {
        renderStatus = name;
    },

    getRenderStatus() {
        return renderStatus;
    },

    setIsImageRendered(status) {
        isImageRendered = status
    },

    getDateTime() {
        return format(new Date(), 'yyyy/MM/dd HH:mm:ss');
    }
}

const Store = {
    increaseSelectedCount() {
        defaultStore.increaseCount('selected');
    },

    increaseRenderedCount() {
        defaultStore.increaseCount('rendered');
    }
}

const initTheme = () => {
    const theme = localStorage.getItem('theme');

    if (theme === null || theme.length <= 0) {
        localStorage.setItem('theme', 'light');
    }

    themeChange(false);
}

const unpack = bin => {
    const bytes = [];

    for(let i=0, n=bin.length; i<n; i++) {
        const char = bin.charCodeAt(i);

        bytes.push(char >>> 8, char & 0xFF);
    }

    return bytes;
}

onMount(async () => {
    initTheme();

    Logger.add('Adding runtime');
    const runtime = await loadPyodide({
        indexURL: "https://cdn.jsdelivr.net/pyodide/v0.23.2/full/",
    });

    for(const pkg of ['numpy', 'opencv-python']) {
        Logger.add(`Adding ${pkg}`);
        await runtime.loadPackage(pkg);
    }

    Logger.add('Adding module');
    runtime.registerJsModule('js_logger', Logger);
    runtime.registerJsModule('js_helper', Helper);
    runtime.registerJsModule('js_store', Store);

    Logger.add('Adding code');
    let pythonCode = '';

    if (import.meta.env.DEV) {
        pythonCode = convertPyCode; // load code directly
    }else{
        // raw string: './assets/convert.py.bin?v='
        const urlBytes    = new Uint8Array([46, 47, 97, 115, 115, 101, 116, 115, 47, 99, 111, 110, 118, 101, 114, 116, 46, 112, 121, 46, 98, 105, 110, 63, 118, 61]);
        const textDecoder = new TextDecoder("utf-8");
        const urlValue    = textDecoder.decode(urlBytes);

        const fetchResponse = await fetch(urlValue+getTime(new Date()));
        const fetchData     = await fetchResponse.text();
        const unpackedData  = unpack(fetchData);

        pythonCode = String.fromCharCode.apply(String, unpackedData).trim().replace(/\0/g, '');
    }

    Logger.add('Adding render');
    isPyodideLoaded = true;
    await runtime.runPythonAsync(pythonCode);

    Helper.setRenderStatus('idle');
});
</script>

<Modal>
    <Drawer hiddenButton="{['loading', 'reading', 'rendering'].includes(renderStatus)}">
        {#if !isPyodideLoaded}
            <div class="grid grid-cols-1 gap-2">
                <CardHero>
                    <h1 class="text-5xl font-bold">TIPS!</h1>
                    <p class="py-6">
                        Loading the environment ...
                    </p>
                    <div class="flex justify-center">
                        <FontIcon name="loader" class="animate-spin" />
                    </div>
                    <br />
                    <ul>
                        {#each Logger.logs as log}
                            <li>{log}</li>
                        {/each}
                    </ul>
                </CardHero>
            </div>
        {/if}

        {#if isPyodideLoaded}
            <div class="grid grid-cols-1 gap-2">
                <Card title="Data Video" description="Please select video to render">
                    {#if ['loading', 'reading', 'rendering'].includes(renderStatus)}
                        <div class="alert alert-info shadow-lg">
                            <div>
                                <FontIcon name="info" />
                                {#if renderStatus === 'loading'}
                                    <span>Loading render ...</span>
                                {/if}

                                {#if renderStatus === 'reading'}
                                    <span>Reading ...</span>
                                {/if}

                                {#if renderStatus === 'rendering'}
                                    <span>Rendering ...</span>
                                {/if}
                            </div>
                        </div>
                    {/if}

                    <input
                        type="file"
                        class="file file-input file-input-bordered w-full"
                        accept=".mp4,.mov,video/*"
                        disabled="{['loading', 'reading', 'rendering'].includes(renderStatus)}" />
                    <div class="card-actions grid grid-cols-1 md:grid-cols-3">
                        <div>
                            <button
                                class="render btn btn-primary w-full"
                                disabled="{renderStatus !== 'readying'}">
                                {#if ['loading', 'reading', 'rendering'].includes(renderStatus) }
                                    <FontIcon name="loader" class="animate-spin" />
                                    <span>Waiting</span>
                                {/if}

                                {#if renderStatus === 'idle'}
                                    <span>Wait For Video</span>
                                {/if}

                                {#if renderStatus === 'readying'}
                                    <span>Render Now</span>
                                {/if}
                            </button>
                        </div>
                        <div>
                            <button
                                class="btn btn-warning w-full"
                                on:click={(e) => window.location.href="#card-preview"}
                                disabled={!isImageRendered}>Goto Preview</button>
                        </div>
                        <div>
                            <button
                                class="btn btn-secondary w-full"
                                on:click={Logger.clean}
                                disabled="{['loading', 'reading', 'rendering'].includes(renderStatus)}">Clean Log</button>
                        </div>
                    </div>
                </Card>

                <Card title="Current Status" description="The status of current process">
                    <div class="logs w-full h-40 overflow-auto">
                        {#each Logger.logs as log}
                            <p>{log}</p>
                        {/each}
                    </div>
                </Card>

                <Card title="Render Preview" description="Preview the selected video file" id="card-preview">
                    <!-- svelte-ignore a11y-missing-attribute -->
                    <!-- svelte-ignore a11y-click-events-have-key-events -->
                    <div class="tabs">
                        <a
                            class="tab tab-bordered w-2/4"
                            class:tab-active="{previewStatus === 'video'}"
                            on:click={(e) => previewStatus = 'video'}>
                            Video
                        </a>
                        <a
                            class="tab tab-bordered w-2/4"
                            class:tab-active="{previewStatus === 'image'}"
                            on:click={(e) => previewStatus = 'image'}>
                            Image
                        </a>
                    </div>

                    <div class="flex justify-center">
                        <!-- svelte-ignore a11y-media-has-caption -->
                        <video
                            class="video w-full md:w-3/5"
                            class:hidden="{previewStatus !== 'video'}"
                            controls>
                            <source src="{videoPlaceHolder}" class="video-source"/>
                        </video>

                        <!-- svelte-ignore a11y-missing-attribute -->
                        <img
                            src="{imagePlaceHolder}"
                            class="rendered w-full md:w-3/5"
                            class:hidden="{previewStatus !== 'image'}" />
                    </div>
                </Card>
            </div>
        {/if}
    </Drawer>
</Modal>
