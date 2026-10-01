# Crypto Top 10

A small Omarchy bar widget that cycles through the ten highest-market-cap cryptocurrencies and shows their prices in euros.

## Features

- Click the widget to move to the next cryptocurrency.
- Right-click to refresh the market data immediately.
- Middle-click to return to the current #1 coin.
- Refreshes the top ten list once per hour.
- Retains the selected coin across hourly refreshes when it remains in the top ten.

The ranking and price data come from CoinGecko's public `/coins/markets` API, sorted by market capitalization. CoinGecko controls the ranking and endpoint availability; the list may change over time.

## Requirements

- Omarchy Quattro with third-party bar-widget plugins enabled
- `curl` and `jq`
- Internet access to `api.coingecko.com`

No API key is configured or stored by this plugin. It sends a public HTTPS GET request once at startup and then once per hour. The plugin runs inside Omarchy's unsandboxed shell process.

## Install

After publishing this repository to GitHub, install it with:

```sh
omarchy plugin add https://github.com/BugIdentiy/omarchy-crypto-top10.git --enable
```

The widget is inserted into the bar by enabling it. To move it:

```sh
omarchy bar move io.github.bugidentiy.crypto-top10 --section right
```

## Remove

```sh
omarchy plugin remove io.github.bugidentiy.crypto-top10
```

## License

MIT. See [LICENSE](LICENSE).
