
# Verse Scratch 

Dapp that lets users purchase scratch tickets using verse. The tickets will act as an NFT that can be scratched, transferred or gifted upon purchase. The scratch ticket can be scratched immediately in the browser. If the user wins a prize the prize can be redeemed instantly.

Repository contains 
- frontend client (VueJS)
- smart contracts 
- logic to generate new prize sets
- image generator for tickets

npm run design 
designs a new prize

## Designing a prize

To design and generate new prizes

```bash
  npm run design
```

this will generate a new prize based on selected configuration in designPrizes.js and store generated images in the 'tickets' folder.

## Starting local application

```bash
  cd webapp
  npm install
  npm run dev
```

## build application

```bash
  cd webapp
  npm run build
```
