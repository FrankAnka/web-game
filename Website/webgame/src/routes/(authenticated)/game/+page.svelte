<script>
    import { onMount } from 'svelte';

    export let data;
    $: user = data.user;
</script>



<div class="game-container">
    
    <iframe 
        src="/game/Farm Game.html" 
        title="Godot Game"
        width="2400" 
        height="800"
        allow="cross-origin-isolated">
    </iframe>
</div>

<style>
    .game-container { display: flex; justify-content: center; }
    iframe { border: none; }
</style>