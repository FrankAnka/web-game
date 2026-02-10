<!-- Global layout -->
<script>
	import { resolve } from '$app/paths';
	import { navigating } from '$app/stores';
	export let data; // Kommer från +layout.server.ts

	const formatImageSrc = (value) => {
		if (!value) return '';
		return value.startsWith('http') ? value : `data:image/png;base64,${value}`;
	};
</script>

{#if $navigating}
	<div class="loading-overlay">
		<div class="spinner">Loading...</div>
	</div>
{/if}
<nav class="main-nav">
	<div class="nav-left">
		{#if data.user != null}
			<a class="nav-logo" href={resolve(data.user ? `/game/` : '/')}>Game</a>
		{/if}
		<a class="nav-logo" href={resolve('/scoreboard')}>Leaderboard</a>
		
	</div>

	<div class="nav-right">
		{#if data.user != null}
			<span class="welcome">Välkommen, <strong>{data.user.name}</strong>!</span>
			<!-- svelte-ignore a11y_img_redundant_alt -->
			{#if data.user.profileImage}
				<img
					src={formatImageSrc(data.user.profileImage)}
					alt="Profile Image"
					width="32"
					height="32"
					style="border-radius: 50%; object-fit: cover;"
				/>
			{/if}
			<form method="POST" action="/login?/logout" class="logout-form">
				<button class="btn-ghost" type="submit">Logga ut</button>
			</form>
		{:else}
			<a class="nav-logo" href={resolve('/login')}>Login</a>
		{/if}
	</div>
</nav>

<main class="page-content">
	<slot />
</main>

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
		background: linear-gradient(180deg, #f6f7fb 0%, #ffffff 100%);
		color: #0f172a;
	}

	.main-nav {
		display: flex;
		align-items: center;
		justify-content: space-between;
		gap: 1rem;
		padding: 0.6rem 1rem;
		border-bottom: 1px solid rgba(15, 23, 42, 0.06);
		background: rgba(255, 255, 255, 0.7);
		backdrop-filter: blur(6px);
		position: sticky;
		top: 0;
		z-index: 40;
	}

	.nav-left,
	.nav-right {
		display: flex;
		align-items: center;
		gap: 0.75rem;
	}

	.nav-logo {
		font-weight: 700;
		color: #1f2937;
		text-decoration: none;
		padding: 0.3rem 0.6rem;
		border-radius: 8px;
		background: linear-gradient(90deg, #2563eb, #4f46e5);
		color: #fff;
		box-shadow: 0 6px 18px rgba(79, 70, 229, 0.1);
		margin-right: 0.5rem;
		font-size: 0.95rem;
	}

	.welcome {
		color: #374151;
		font-size: 0.95rem;
		margin-right: 0.5rem;
	}
	.loading-overlay {
		position: fixed;
		top: 0;
		left: 0;
		right: 0;
		bottom: 0;
		background: rgba(255, 255, 255, 0.8);
		display: flex;
		align-items: center;
		justify-content: center;
		z-index: 9999;
	}

	.logout-form {
		margin: 0;
	}

	.btn-ghost {
		background: transparent;
		border: 1px solid rgba(15, 23, 42, 0.06);
		padding: 0.45rem 0.6rem;
		border-radius: 8px;
		cursor: pointer;
		color: #111827;
		font-weight: 600;
	}

	.btn-ghost:hover {
		background: #fff;
		box-shadow: 0 6px 18px rgba(12, 20, 31, 0.06);
		transform: translateY(-1px);
	}

	.page-content {
		max-width: 1100px;
		margin: 1.25rem auto;
		padding: 1rem;
		box-sizing: border-box;
		min-height: calc(100vh - 68px);
	}

	@media (max-width: 720px) {
		.main-nav {
			padding: 0.6rem;
		}
		.nav-left {
			gap: 0.5rem;
		}
		.welcome {
			display: none;
		}
		.nav-logo {
			padding: 0.25rem 0.5rem;
			font-size: 0.9rem;
		}
	}
</style>
