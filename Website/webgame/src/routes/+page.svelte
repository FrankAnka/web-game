<script>
	import { resolve } from '$app/paths';

	export let data;

	const hasUser = () => data?.user != null;
</script>

<svelte:head>
	<title>Web Game</title>
	<meta
		name="description"
		content="Play the farm game, log in to save progress, and check the leaderboard."
	/>
</svelte:head>

<section class="hero">
	<div class="hero-copy">
		<p class="eyebrow">Web Game</p>
        <h1>Farm Game</h1>
		<p class="lede">
			Jump straight into the game, sign in to save your progress, or browse the scoreboard.
		</p>

		<div class="actions">
			<a class="primary" href={resolve(hasUser() ? '/game' : '/login')}>
				{hasUser() ? 'Enter game' : 'Log in'}
			</a>
			<a class="secondary" href={resolve('/scoreboard')}>View leaderboard</a>
		</div>
	</div>

	<div class="hero-panel">
		<div class="panel-card">
			<span>Quick start</span>
			<strong>{hasUser() ? data.user.name : 'Guest player'}</strong>
			<p>
				{hasUser()
					? 'Your account is ready. Continue where you left off.'
					: 'Create an account or sign in to unlock the game.'}
			</p>
		</div>
		<div class="panel-card muted">
			<span>What you can do</span>
			<ul>
				<li>Play the farm game</li>
				<li>Save progress to your account</li>
				<li>Check the leaderboard</li>
			</ul>
		</div>
	</div>
</section>

<style>
	:global(body) {
		margin: 0;
		font-family:
			Inter,
			system-ui,
			-apple-system,
			'Segoe UI',
			Roboto,
			'Helvetica Neue',
			Arial;
		background:
			radial-gradient(circle at top left, rgba(37, 99, 235, 0.12), transparent 35%),
			linear-gradient(180deg, #f8fafc 0%, #ffffff 100%);
		color: #0f172a;
	}

	.hero {
		min-height: calc(100vh - 120px);
		display: grid;
		grid-template-columns: minmax(0, 1.15fr) minmax(280px, 0.85fr);
		gap: 2rem;
		align-items: center;
		padding: 3rem 1.5rem;
	}

	.hero-copy {
		max-width: 34rem;
	}

	.eyebrow {
		display: inline-flex;
		margin: 0 0 0.85rem;
		padding: 0.35rem 0.7rem;
		border-radius: 999px;
		background: rgba(37, 99, 235, 0.1);
		color: #1d4ed8;
		font-size: 0.82rem;
		font-weight: 700;
		text-transform: uppercase;
		letter-spacing: 0.08em;
	}

	h1 {
		margin: 0;
		font-size: clamp(2.7rem, 6vw, 5rem);
		line-height: 0.95;
		letter-spacing: -0.05em;
	}

	.lede {
		margin: 1rem 0 0;
		max-width: 32rem;
		font-size: 1.08rem;
		line-height: 1.65;
		color: #475569;
	}

	.actions {
		display: flex;
		flex-wrap: wrap;
		gap: 0.9rem;
		margin-top: 1.8rem;
	}

	.actions a {
		display: inline-flex;
		align-items: center;
		justify-content: center;
		padding: 0.9rem 1.2rem;
		border-radius: 999px;
		text-decoration: none;
		font-weight: 700;
		transition:
			transform 0.15s ease,
			box-shadow 0.15s ease,
			background 0.15s ease;
	}

	.actions a:hover {
		transform: translateY(-1px);
	}

	.primary {
		background: linear-gradient(90deg, #2563eb, #1d4ed8);
		color: #fff;
		box-shadow: 0 12px 26px rgba(37, 99, 235, 0.22);
	}

	.secondary {
		background: rgba(15, 23, 42, 0.04);
		color: #0f172a;
	}

	.hero-panel {
		display: grid;
		gap: 1rem;
	}

	.panel-card {
		padding: 1.25rem;
		border-radius: 1.25rem;
		background: rgba(255, 255, 255, 0.8);
		border: 1px solid rgba(148, 163, 184, 0.2);
		box-shadow: 0 18px 40px rgba(15, 23, 42, 0.08);
		backdrop-filter: blur(10px);
	}

	.panel-card span {
		display: block;
		font-size: 0.8rem;
		font-weight: 700;
		text-transform: uppercase;
		letter-spacing: 0.08em;
		color: #64748b;
		margin-bottom: 0.6rem;
	}

	.panel-card strong {
		display: block;
		font-size: 1.4rem;
		margin-bottom: 0.5rem;
	}

	.panel-card p,
	.panel-card li {
		margin: 0;
		color: #475569;
		line-height: 1.6;
	}

	.panel-card ul {
		margin: 0;
		padding-left: 1.15rem;
		display: grid;
		gap: 0.5rem;
	}

	.panel-card.muted {
		background: rgba(15, 23, 42, 0.03);
	}

	@media (max-width: 860px) {
		.hero {
			grid-template-columns: 1fr;
			padding-top: 2rem;
		}
	}

	@media (max-width: 640px) {
		.hero {
			padding: 1.5rem 1rem 2rem;
		}

		h1 {
			font-size: clamp(2.4rem, 12vw, 3.6rem);
		}

		.lede {
			font-size: 1rem;
		}

		.actions {
			flex-direction: column;
			align-items: stretch;
		}
	}
</style>