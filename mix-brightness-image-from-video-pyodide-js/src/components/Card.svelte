<script>
export let title;
export let description;
</script>

<div class="card w-full bg-base-100 shadow-xl" {...$$props}>
    <div class="card-body">
        <h2 class="card-title">{title}</h2>
        <p>{description}</p>
        <slot></slot>
    </div>
</div>
