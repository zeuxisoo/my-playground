<script>
import { Menu, Palette, Check, Loader, Info } from 'lucide-svelte';

export let name;

/*
// the icon name will be optimize/obfuscation when build for production,
// it will not get the svg component by icon name like:
// { 'menu': Menu, Palette } -> { 'ls': Menu, 'is': Palette }
const convertArrayToMap = arr => {
    return Object.fromEntries(
        new Map(
            arr.map(item => [item.name.toLowerCase(), item])
        )
    );
}

const icons = convertArrayToMap([Menu, Palette, Check, Loader, Info,]);
*/

// so, hard code for develop and production
const icons = {
    'menu'   : Menu,
    'palette': Palette,
    'check'  : Check,
    'loader' : Loader,
    'info'   : Info,
}
</script>

<svelte:component this="{icons[name]}" {...$$props} />
