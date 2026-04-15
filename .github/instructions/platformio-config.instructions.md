---
applyTo: "**/*.ini,boards/**/*.json,variants/**/platformio.ini,arch/**/*.ini"
---

Config inheritance chain (each layer extends the one above):
```
platformio.ini [arduino_base]
  └── arch/nrf52/nrf52.ini        [nrf52_base]
        └── arch/nrf52/nrf52840.ini [nrf52840_base]
              └── variants/<variant>/platformio.ini [env:<variant>]
```

Rules for editing config files:
- Always propagate parent flags with `${parent_env.build_flags}` — never drop them.
- The UF2 family ID for nRF52840 is always `0xADA52840`.
- `upload_protocol = nrfutil` must appear in every variant `platformio.ini`.
- `build_type = debug` is set in `nrf52.ini`; do not add a separate `release` environment.
- Optimisation is handled by `-Os` in `[arduino_base]`; do not duplicate it.
- `framework-arduinoadafruitnrf52` must remain pinned to `geeksville/Adafruit_nRF52_Arduino.git`, not the upstream Adafruit URL.
- Board JSON files live in `boards/<env_name>.json`; each references the correct softdevice (`sd_version`, `sd_fwid`, `sd_flags`, `ldscript`).
- Version flags `-DAPP_VERSION` and `-DAPP_VERSION_SHORT` are injected automatically by `scripts/python/platformio-custom.py` from `version.properties` — do not hard-code them in INI files.
