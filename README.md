A decentralized lottery system built on the Stacks blockchain using the Clarity smart contract language.
Players buy tickets with STX, the prize pool grows, and a winner is drawn by the contract owner.

✨ Features

Lottery Participation

Players enter a round by paying the set entry fee.

Entries are recorded and indexed on-chain.

Entry Fee Management

Default fee: 1 STX (1,000,000 µSTX).

Contract owner can update entry fee via set-entry-fee.

Ownership Controls

Owner-only functions protected by only-owner.

Owner can withdraw mistakenly sent STX.

Round Tracking

Entries are tracked per round.

Each round maintains entry counts.

Planned: Owner draws a winner using a numeric seed.

Read-Only Helpers

get-current-round → returns the active round.

get-entry-fee → current ticket price.

get-round-count → number of entries in a round.

is-round-drawn → whether a round has been resolved.

🛠 Deployment
Prerequisites

Stacks CLI
 or Clarinet
.

Funded Stacks wallet for deploying contracts.

Steps
# Clone the repository
git clone https://github.com/your-username/communitylotto.git
cd communitylotto

# Compile contract
clarinet check

# Deploy to a devnet/testnet
clarinet deploy

📖 Usage
Entering the Lottery
(contract-call? .community-lotto enter-lottery)


Transfers the entry fee from the player to the contract and records participation.

Setting Entry Fee (Owner only)
(contract-call? .community-lotto set-entry-fee u2000000)


Updates entry fee to 2 STX.

Withdrawing (Owner only)
(contract-call? .community-lotto owner-withdraw u5000000 'SP3...ADDRESS)


Owner withdraws 5 STX to specified address.

Query Helpers
(contract-call? .community-lotto get-current-round)
(contract-call? .community-lotto get-entry-fee)
(contract-call? .community-lotto get-round-count u1)
(contract-call? .community-lotto is-round-drawn u1)
