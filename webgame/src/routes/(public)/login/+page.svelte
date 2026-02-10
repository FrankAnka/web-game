<!-- Simple, responsive styling for the login/signup page -->
<script>
	import { enhance } from '$app/forms';
	import { resolve } from '$app/paths';

	export let form; // This receives error data from the server

	let loading = false;

	// use "_result" if you don't need the result param in enhance callbacks
</script>

<!-- where you used enhance callbacks, rename unused "result" to "_result", for example:
use:enhance={({ _result }) => { ... }} or use:enhance={{ after: (_result) => { /* no unused var */ } }}
-->

<section class="page">
	<div class="card">
		<header>
			<h1>Welcome</h1>
			<p class="lead">Create an account or log in to access the marketplace</p>
		</header>

		<div class="forms">
			<form
				class="form"
				method="POST"
				action="?/signup"
				autocomplete="on"
				novalidate
				use:enhance={() => {
					loading = true;
					return async ({ update }) => {
						loading = false;
						await update();
					};
				}}
			>
				<h2>Create account</h2>

				{#if form?.error}
					<div class="error-message">
						{form.error}
					</div>
				{/if}

				<div class="field">
					<label for="signup-username">Username</label>
					<input id="signup-username" type="text" name="name" required placeholder="Username..." />
				</div>

				<div class="field">
					<label for="signup-email">Email</label>
					<input
						id="signup-email"
						type="email"
						name="email"
						required
						placeholder="example@gmail.com"
					/>
				</div>

				<div class="field">
					<label for="signup-password">Password</label>
					<input
						id="signup-password"
						type="password"
						name="password"
						required
						placeholder="Password..."
					/>
				</div>

				<button class="btn primary" type="submit" disabled={loading}>Signup </button>
				{#if loading}
					<p>Creating account...</p>
				{/if}
			</form>

			<form
				class="form"
				method="POST"
				action="?/login"
				autocomplete="on"
				novalidate
				use:enhance={() => {
					loading = true;
					return async ({ update }) => {
						loading = false;
						await update();
					};
				}}
			>
				<h2>Log in</h2>

				<div class="field">
					<label for="login-username">Username</label>
					<input id="login-username" type="text" name="name" required placeholder="Username..." />
				</div>

				<div class="field">
					<label for="login-password">Password</label>
					<input
						id="login-password"
						type="password"
						name="password"
						required
						placeholder="Password..."
					/>
				</div>

				<div class="field">
					<label>
						<input type="checkbox" name="rememberMe" />
						Remember me
					</label>
				</div>
				<button class="btn" type="submit" disabled={loading}>Login</button>
				{#if loading}
					<p>Logging in...</p>
				{/if}
			</form>
		</div>

		<footer class="foot">
			<a class="market-link" href={resolve('/market')}>Go to Marketplace</a>
		</footer>
	</div>
</section>

<style>
	:global(body) {
		font-family:
			Inter,
			system-ui,
			-apple-system,
			'Segoe UI',
			Roboto,
			'Helvetica Neue',
			Arial;
		background: linear-gradient(180deg, #f6f7fb 0%, #ffffff 100%);
		margin: 0;
		padding: 0;
		color: #111827;
	}

	.page {
		min-height: 100vh;
		display: flex;
		align-items: center;
		justify-content: center;
		padding: 2rem;
		box-sizing: border-box;
	}

	.card {
		width: 100%;
		max-width: 980px;
		background: #fff;
		border-radius: 12px;
		box-shadow: 0 8px 30px rgba(12, 20, 31, 0.08);
		padding: 1.5rem;
		box-sizing: border-box;
	}

	header {
		text-align: center;
		margin-bottom: 1rem;
	}

	h1 {
		margin: 0;
		font-size: 1.5rem;
		letter-spacing: -0.02em;
	}

	.lead {
		margin: 0.35rem 0 0;
		color: #6b7280;
		font-size: 0.95rem;
	}

	.forms {
		display: grid;
		grid-template-columns: 1fr;
		gap: 1.25rem;
		margin-top: 1rem;
	}

	.form {
		padding: 1rem;
		border-radius: 8px;
		border: 1px solid #eef2f7;
		background: linear-gradient(180deg, rgba(250, 250, 252, 1), rgba(255, 255, 255, 0.9));
		box-sizing: border-box;
	}

	.form h2 {
		margin: 0 0 0.75rem 0;
		font-size: 1.05rem;
	}

	.field {
		display: flex;
		flex-direction: column;
		margin-bottom: 0.75rem;
	}

	label {
		font-size: 0.85rem;
		color: #374151;
		margin-bottom: 0.35rem;
	}

	input[type='text'],
	input[type='email'],
	input[type='password'] {
		padding: 0.55rem 0.65rem;
		border-radius: 8px;
		border: 1px solid #e6edf3;
		background: #ffffff;
		outline: none;
		font-size: 0.95rem;
		transition:
			box-shadow 0.12s ease,
			border-color 0.12s ease;
	}

	input:focus {
		border-color: #60a5fa;
		box-shadow: 0 4px 12px rgba(96, 165, 250, 0.08);
	}

	.btn {
		display: inline-block;
		padding: 0.6rem 0.9rem;
		border-radius: 8px;
		border: 1px solid transparent;
		background: #eff6ff;
		color: #0f172a;
		font-weight: 600;
		cursor: pointer;
		transition:
			transform 0.06s ease,
			box-shadow 0.06s ease;
	}

	.btn.primary {
		background: linear-gradient(90deg, #2563eb, #4f46e5);
		color: white;
		box-shadow: 0 8px 20px rgba(37, 99, 235, 0.12);
	}


	.btn:hover {
		transform: translateY(-1px);
	}

	.btn:disabled {
		opacity: 0.6;
		cursor: not-allowed;
		transform: none;
	}

	.foot {
		display: flex;
		justify-content: center;
		margin-top: 1rem;
	}

	.market-link {
		color: #111827;
		text-decoration: none;
		padding: 0.45rem 0.6rem;
		border-radius: 8px;
		border: 1px solid transparent;
		background: #f3f4f6;
	}

	.error-message {
		padding: 0.75rem;
		margin-bottom: 1rem;
		border-radius: 8px;
		background: #fee2e2;
		border: 1px solid #fca5a5;
		color: #991b1b;
		font-size: 0.9rem;
		line-height: 1.4;
	}

	@media (min-width: 900px) {
		.forms {
			grid-template-columns: 1fr 1fr;
		}
	}
</style>
