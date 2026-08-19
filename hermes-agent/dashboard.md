# Hermes dashboard

Run the optional Hermes dashboard and open it from your laptop through an SSH tunnel.

## Start the dashboard

> **Run as:** `hermes` on the VPS

Once the dashboard dependencies are installed, you can start the Hermes dashboard with:

```sh
hermes dashboard
```

By default, Hermes serves the dashboard at:

```text
http://127.0.0.1:9119
```

## Open it through SSH

For this repo's VPS setup, the most direct way to open the dashboard from your laptop is an SSH tunnel through your existing `hermes` SSH alias.

On the VPS:

```sh
hermes dashboard
```

On your local machine, in another terminal:

```sh
ssh -N -L 9119:127.0.0.1:9119 hermes
```

Then open:

```text
http://127.0.0.1:9119
```

This keeps the dashboard bound to localhost on the VPS.
