<script>
import Icon from './FontIcon.svelte';
import tailwindConfig from '../../tailwind.config';

const themes = tailwindConfig.daisyui.themes;
</script>

<div class="menu p-4 w-72 sm:w-80 bg-base-200 text-base-content">
    <div class="grid grid-cols-1 gap-3 content-start">
        {#each themes as theme}
            <button class="outline-base-content overflow-hidden rounded-md text-left" data-set-theme="{theme}" data-act-class="[&_svg]:visible">
                <div data-theme="{theme}" class="bg-base-100 text-base-content w-full cursor-pointer">
                    <div class="grid grid-cols-5 grid-rows-3">
                        <div class="col-span-5 row-span-3 row-start-1 flex gap-2 py-3 px-4 items-center">
                            <Icon name="check" class="w-3 h-3 invisible" />
                            <div class="flex-grow text-sm font-bold capitalize">
                                {theme}
                            </div>
                            <div class="flex flex-shrink-0 flex-wrap gap-1 h-full">
                                <div class="bg-primary w-2 rounded"></div>
                                <div class="bg-secondary w-2 rounded"></div>
                                <div class="bg-accent w-2 rounded"></div>
                                <div class="bg-neutral w-2 rounded"></div>
                            </div>
                        </div>
                    </div>
                </div>
            </button>
        {/each}
    </div>
</div>
