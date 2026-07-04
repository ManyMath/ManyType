# ManyType.com

ManyType.com combines two web surfaces in one static distribution:

- `/` is the public ManyType ecosystem site.
- `/home/` is the ManyType Flutter application.

The site uses a current application screenshot from the reviewed ManyType UI.
The application build stays self-contained and serves its Drift worker and
SQLite WebAssembly runtime beneath `/home/`.

## Build and verify

From the ManyType repository root:

```sh
./apps/ManyType.com/tool/build_web.sh
./apps/ManyType.com/tool/verify_web_dist.sh
```

The build is assembled at `apps/ManyType.com/build/dist`. To inspect that exact
artifact locally:

```sh
python3 -m http.server 8080 --directory apps/ManyType.com/build/dist
```

Open `http://127.0.0.1:8080/` for the public site and
`http://127.0.0.1:8080/home/` for the application.

## Deployment requirements

Serve the distribution as literal static files. In particular:

- Do not rewrite missing JavaScript, worker, or WASM paths to an HTML entry point.
- Serve `.wasm` files as `application/wasm` and JavaScript workers as JavaScript.
- Keep the application at `/home/`; its base href and local database runtime
  paths are built for that location.
- Prefer cross-origin isolation headers when the host supports them so Drift
  can select the strongest available browser storage implementation.

The verification script checks the composed routes, file signatures, runtime
asset paths, and missing-asset behavior with a local static server.
