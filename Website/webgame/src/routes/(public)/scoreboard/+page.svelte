<script>
	export let data;
</script>

<div class="leaderboard-container">
	<h1>🏆 Leaderboard</h1>
	
	<div class="leaderboard">
		{#if data.leaderboard && data.leaderboard.length > 0}
			<div class="leaderboard-header">
				<span class="rank">Rank</span>
				<span class="name">Player</span>
				<span class="score">Score</span>
			</div>
			
			{#each data.leaderboard as player, index}
				<div class="leaderboard-row" class:top-three={index < 3}>
					<span class="rank">
						{#if index === 0}🥇
						{:else if index === 1}🥈
						{:else if index === 2}🥉
						{:else}{index + 1}{/if}
					</span>
					<span class="name">{player.name || 'Anonymous'}</span>
					<span class="score">{player.maxScore.toLocaleString()}</span>
				</div>
			{/each}
		{:else}
			<div class="empty-state">
				<p>No scores yet. Be the first to play!</p>
			</div>
		{/if}
	</div>
</div>

<style>
	.leaderboard-container {
		max-width: 800px;
		margin: 2rem auto;
		padding: 0 1rem;
	}

	h1 {
		text-align: center;
		font-size: 2.5rem;
		margin-bottom: 2rem;
		color: #333;
		font-weight: bold;
	}

	.leaderboard {
		background: white;
		border-radius: 12px;
		box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
		overflow: hidden;
	}

	.leaderboard-header {
		display: grid;
		grid-template-columns: 80px 1fr 120px;
		gap: 1rem;
		padding: 1rem 1.5rem;
		background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
		color: white;
		font-weight: bold;
		font-size: 0.9rem;
		text-transform: uppercase;
		letter-spacing: 0.5px;
	}

	.leaderboard-row {
		display: grid;
		grid-template-columns: 80px 1fr 120px;
		gap: 1rem;
		padding: 1rem 1.5rem;
		border-bottom: 1px solid #eee;
		transition: background-color 0.2s ease;
		align-items: center;
	}

	.leaderboard-row:hover {
		background-color: #f8f9fa;
	}

	.leaderboard-row:last-child {
		border-bottom: none;
	}

	.leaderboard-row.top-three {
		background: linear-gradient(90deg, #fff9e6 0%, #ffffff 100%);
		font-weight: 600;
	}

	.rank {
		font-size: 1.2rem;
		font-weight: bold;
		text-align: center;
	}

	.name {
		font-size: 1.1rem;
		color: #333;
		overflow: hidden;
		text-overflow: ellipsis;
		white-space: nowrap;
	}

	.score {
		font-size: 1.1rem;
		font-weight: bold;
		color: #667eea;
		text-align: right;
	}

	.empty-state {
		padding: 3rem;
		text-align: center;
		color: #999;
	}

	.empty-state p {
		font-size: 1.1rem;
	}

	@media (max-width: 600px) {
		.leaderboard-header,
		.leaderboard-row {
			grid-template-columns: 60px 1fr 100px;
			padding: 0.75rem 1rem;
			gap: 0.5rem;
		}

		h1 {
			font-size: 2rem;
		}

		.rank {
			font-size: 1rem;
		}

		.name,
		.score {
			font-size: 0.95rem;
		}
	}
</style>
