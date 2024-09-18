# Discord Webhook Action

These are some github actions I use on my packs.

Feel free to use as you see fit.

## discord_webhook.yml

This is the discord webhook action I use to automatically post updates of my pack to discord.

Requires the Webhook URL to be placed in a repo secret on github named ``DISCORD_WEBHOOK_URL``.

## validation-lax/strict.yml

This action automatically validates JSON against official PopTracker schemas using
the [PopTracker pack-checker-action](https://github.com/PopTracker/pack-checker-action).

You can select validation with either the [lax](https://poptracker.github.io/schema/packs/)
or [strict](https://poptracker.github.io/schema/packs/strict/) schema.

It triggers on push or pull requests, and can also be run manually.
