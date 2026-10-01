#!/usr/bin/env bash
set -euo pipefail

curl -fsS --retry 2 --retry-all-errors --max-time 15 \
  'https://api.coingecko.com/api/v3/coins/markets?vs_currency=eur&order=market_cap_desc&per_page=10&page=1&sparkline=false' \
  | jq -e '[.[] | select(.current_price != null) | {
      id: .id,
      name: .name,
      symbol: .symbol,
      price: .current_price,
      rank: .market_cap_rank
    }] | if length > 0 then . else error("No market prices returned") end'
