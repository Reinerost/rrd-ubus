# rrd-ubus

Native rpcd/ubus plugin for exporting RRDtool time-series data on OpenWrt.

## Overview

`rrd-ubus` provides an ubus interface to RRDtool's `rrd_xport()` functionality through `librrd`.

It allows LuCI applications to retrieve time-series data directly, without invoking the `rrdtool` command-line utility or generating server-side graph images.

The plugin was developed as part of a proof of concept for replacing RRDtool-generated graphs in `luci-app-statistics` with client-side SVG plotting.

## Architecture

```text
LuCI application
       |
       | ubus RPC
       v
rpcd / rrd.xport
       |
       v
librrd / rrd_xport()
       |
       v
RRD database files
       |
       v
JSON response
       |
       v
Client-side plotting
```

## Features

- Native rpcd plugin written in C
- ubus object `rrd`, method `xport`
- Supports `DEF`, `CDEF` and `XPORT` definitions
- Exports timestamps, legends and numerical data
- Represents non-finite values as JSON `null`
- Reads the RRD data directory from the existing `luci_statistics` UCI configuration
- Restricts RRD file access to the configured data directory
- No external `rrdtool` process required

## ubus Interface

The `rrd.xport` method accepts:

| Parameter | Type | Description |
|---|---|---|
| `start` | integer | Start timestamp (Unix time) |
| `end` | integer | End timestamp (Unix time) |
| `step` | integer | Requested resolution in seconds |
| `definitions` | array of strings | RRDtool DEF, CDEF and XPORT expressions |

Example:

```sh
ubus call rrd xport '{
  "start": 1792951260,
  "end": 1792951860,
  "step": 60,
  "definitions": [
    "DEF:cpu=/tmp/OpenWrt/cpu-0/percent-user.rrd:value:AVERAGE",
    "XPORT:cpu:User"
  ]
}'
```

The example assumes the referenced RRD file exists and is located within the configured RRD data directory.

The response contains:

- `start` — first timestamp
- `end` — end timestamp
- `step` — effective resolution
- `legend` — exported series names
- `data` — rows of numerical values, with `null` for unavailable values

## Dependencies

- OpenWrt
- `rpcd`
- `libubox`
- `libuci`
- `librrd` with support for `rrd_xport()`

### RRDtool dependency

The current proof of concept uses a locally maintained version of RRDtool 1.11, available in the [rrd_hl repository](https://github.com/Reinerost/rrd_hl).

This version provides the required RRD export functionality without depending on the graphics libraries used for server-side graph generation.

The custom version is used as a temporary solution while waiting for the necessary corrections to be incorporated into an official, up-to-date RRDtool release.

Once a suitable upstream version becomes available, the intention is to replace the custom library with the official implementation.

The current OpenWrt setup uses the existing RRDtool library for collectd data collection and the modified library for exporting RRD data through `rrd-ubus`.

## Status

**Proof of concept — functional, not yet production-ready.**

Successfully tested on OpenWrt with real collectd RRD data and the modified `luci-app-statistics` frontend.

Further testing, validation and security review are required before general deployment.

## Related Projects
- luci-app-statistics-plot
- luci-plot
- luci-plot-module
  
## License
See the source files for applicable license information. A repository-wide license declaration should be added after verification.
