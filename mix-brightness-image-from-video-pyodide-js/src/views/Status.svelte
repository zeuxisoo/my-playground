<script>
import { format } from 'date-fns';
import { defaultStore } from '../stores';

const currentDate = format(new Date(), 'yyyy/MM/dd')
const currentTime = format(new Date(), 'hh:mm:ss')
</script>

<div>
    <h3 class="font-bold text-lg text-primary">Status Page</h3>
    <div class="grid grid-cols-9 py-2">
        <div class="col-span-3 md:col-span-2 font-bold text-end pe-1">Date:</div>
        <div class="col-span-6 md:col-span-7">
            {currentDate}
        </div>
    </div>
    <div class="grid grid-cols-9 py-2">
        <div class="col-span-3 md:col-span-2 font-bold text-end pe-1">Time:</div>
        <div class="col-span-6 md:col-span-7">
            {currentTime}
        </div>
    </div>
    <div class="grid grid-cols-9 py-2">
        <div class="col-span-3 md:col-span-2 font-bold text-end pe-1">Selected:</div>
        <div class="col-span-6 md:col-span-7">
            {$defaultStore.selectedCount}
        </div>
    </div>
    <div class="grid grid-cols-9 py-2">
        <div class="col-span-3 md:col-span-2 font-bold text-end pe-1">Rendered:</div>
        <div class="col-span-6 md:col-span-7">
            {$defaultStore.renderedCount}
        </div>
    </div>
</div>
