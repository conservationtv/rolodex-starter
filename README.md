# Rolodex Worker starter

Deploys the Rolodex recording processor to Cloudflare Workers. It consumes R2
object-create events through a Queue, indexes completed MediaMTX recordings,
and writes archive manifests, virtual-HLS metadata, init segments, and thumbnail
sprites back to R2.

The Worker and processing core are pinned to an exact commit of
[`conservationtv/rolodex`](https://github.com/conservationtv/rolodex).
That repository and pinned commit must be public before a fresh clone of this
starter can build.

## Deploy

Fork this repository, then:

```sh
git clone https://github.com/<you>/rolodex-starter.git
cd rolodex-starter
npm install
npx wrangler login
npx wrangler r2 bucket create rolodex-recordings
npx wrangler queues create rolodex-jobs
npx wrangler queues create rolodex-dead-letter
npm run deploy # H.264; use npm run deploy:h265 for H.265
```

Connect uploads to the Queue once:

```sh
npx wrangler r2 bucket notification create rolodex-recordings \
  --event-type object-create \
  --queue rolodex-jobs \
  --prefix "recordings/" \
  --suffix ".mp4"
```

Do not rerun the notification command without checking the bucket's existing
rules. Cloudflare rejects overlapping notification rules.

Recordings must be stored below a stream path, for example
`recordings/camera-12/2026-08-14_12-00-00.mp4`. Edit resource names, prefixes,
limits, and thumbnail settings in `wrangler.jsonc` before deployment if needed.
Recordings up to 16 MiB are fetched once and shared in memory between indexing
and thumbnail extraction; larger recordings retain bounded range reads. Adjust
`FULL_READ_THRESHOLD_BYTES` if your workload needs a different cutoff.

## Update Rolodex

Change both `rev` values in `Cargo.toml` to the same reviewed Rolodex commit,
then run `cargo update` and commit the resulting `Cargo.lock`.

## Build locally

```sh
npm install
npm run build       # H.264
npm run build:h265  # H.265
```

The build script installs a minimal Rust toolchain, the WASM target, and the
pinned `worker-build` version when they are missing.
