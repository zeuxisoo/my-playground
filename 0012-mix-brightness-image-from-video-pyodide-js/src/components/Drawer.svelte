<script>
import DrawerMenu from './DrawerMenu.svelte';
import DrawerNavbar from './DrawerNavbar.svelte';

export let hiddenButton;
</script>

<div class="drawer h-screen drawer-end">
    <input id="my-drawer" type="checkbox" class="drawer-toggle" />
    <div class="drawer-content">
        <DrawerNavbar title="MaxOne" hiddenButton="{hiddenButton}" />
        <div class="container mx-auto px-4 pt-2">
            <slot></slot>
        </div>
    </div>
    <div class="drawer-side">
        <label for="my-drawer" class="drawer-overlay"></label>
        <DrawerMenu />
    </div>
</div>
