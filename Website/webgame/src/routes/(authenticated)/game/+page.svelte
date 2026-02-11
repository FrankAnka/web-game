<script>
    import { onMount } from 'svelte';

    export let data;
    $: user = data.user;
</script>



<h1>Farm Game</h1>
<h3>{user.maxScore}</h3>
<div class="game-container">
    
    <iframe 
        src="/game/Farm Game.html" 
        title="Godot Game"
        width="1024" 
        height="600"
        allow="cross-origin-isolated">
    </iframe>
</div>

<style>
    .game-container { display: flex; justify-content: center; }
    iframe { border: none; }
</style>