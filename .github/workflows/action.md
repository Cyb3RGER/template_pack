# Discord Webhook Action

These are some github actions I use on my packs.

Feel free to use as you see fit.

## discord_webhook.yml

This is the discord webhook action I use to automatically post updates of my pack to discord.

Requires the Webhook URL to be placed in a repo secret on github named ``DISCORD_WEBHOOK_URL``.

## validation.yml

This is the pack validation action I use to automatically validate json against the offical PopTracker schemas.

It uses the [PopTracker pack-checker-action](https://github.com/PopTracker/pack-checker-action).

Triggers whenever a push or pull request including changes to any json file are made. Can also be run manually.