<script>
import { setContext } from 'svelte';

let isShow = false;

let kind; // component | default
let title;
let description;
let component;

const createComponent = (Component) => {
    return function ModalContentComponent(options) {
        return new Component({
            ...options,
            props: options.props,
        });
    };
}

const controls = {
    open(kind_, options) {
        kind   = kind_;
        isShow = true;

        switch(kind) {
            case 'component':
                component = createComponent(options.component);
                break;
            case 'default':
            default:
                title       = options.title;
                description = options.description;
                break;
        }
    },

    close() {
        isShow = false;
    }
};

setContext('modal', controls);

const handleClose = () => {
    controls.close();
}
</script>

<slot></slot>
<input type="checkbox" id="my-modal" class="modal-toggle" checked={isShow} />
<div class="modal">
    <div class="modal-box">
        {#if kind === 'component'}
            <svelte:component this={component} />
        {:else}
            <h3 class="font-bold text-lg">{title}</h3>
            <p class="py-4">{description}</p>
        {/if}
        <div class="modal-action">
            <button class="btn" on:click={handleClose}>Yay!</button>
        </div>
    </div>
</div>
