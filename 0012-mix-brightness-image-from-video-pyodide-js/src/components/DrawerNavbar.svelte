<script>
import { getContext } from 'svelte';
import FontIcon from './FontIcon.svelte';
import Status from '../views/Status.svelte';

export let title;
export let hiddenButton;

const modal = getContext('modal');

const handleStatus = () => {
    // modal.open('default', {
    //     title      : 'Hello',
    //     description: 'It is home page'
    // });
    modal.open('component', {
        'component': Status
    });
}
</script>

<div class="sticky navbar bg-base-100 bg-opacity-90 shadow-sm z-10">
    <div class="navbar-start">
        <div class="dropdown">
            <!-- svelte-ignore a11y-no-noninteractive-tabindex -->
            <!-- svelte-ignore a11y-label-has-associated-control -->
            <label tabindex="0" class="btn btn-ghost btn-circle" class:hidden={hiddenButton}>
                <FontIcon name="menu" />
            </label>
            <!-- svelte-ignore a11y-no-noninteractive-tabindex -->
            <ul tabindex="0" class="menu menu-compact dropdown-content mt-3 p-2 shadow bg-base-100 rounded-box w-52">
                <!-- svelte-ignore a11y-missing-attribute -->
                <!-- svelte-ignore a11y-click-events-have-key-events -->
                <li><a on:click={handleStatus}>Status</a></li>
            </ul>
        </div>
    </div>
    <div class="navbar-center">
        <!-- svelte-ignore a11y-missing-attribute -->
        <a class="btn btn-ghost normal-case text-xl">{title}</a>
    </div>
    <div class="navbar-end">
        <label class="btn btn-ghost btn-circle" for="my-drawer" class:hidden="{hiddenButton}">
            <FontIcon name="palette" />
        </label>
    </div>
</div>
