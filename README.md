# 🎭 Decentralized Caption Contest

A blockchain-powered meme caption contest where the community votes for the funniest captions and winners earn STX tokens! 🏆

## 🚀 Features

- 📸 **Contest Creation**: Upload memes/images with prize pools
- ✍️ **Caption Submission**: Submit your funniest captions
- 🗳️ **Community Voting**: Vote for the best captions
- 💰 **Token Rewards**: Winners automatically receive STX prizes
- ⏰ **Timed Contests**: Contests run for specified block durations

## 📋 Contract Functions

### Public Functions

| Function | Description | Parameters |
|----------|-------------|------------|
| `create-contest` | Create a new caption contest | `image-url`, `title`, `duration-blocks`, `prize-amount` |
| `submit-caption` | Submit a caption for a contest | `contest-id`, `caption-text` |
| `vote-caption` | Vote for your favorite caption | `contest-id`, `caption-id` |
| `end-contest` | End contest and distribute prizes | `contest-id` |

### Read-Only Functions

| Function | Description | Parameters |
|----------|-------------|------------|
| `get-contest` | Get contest details | `contest-id` |
| `get-caption` | Get caption details | `caption-id` |
| `get-user-vote` | Check user's vote for a contest | `voter`, `contest-id` |
| `get-contest-captions` | List all captions for a contest | `contest-id` |
| `get-active-contests` | List all active contests | none |

## 🎮 Usage Guide

### 1. Create a Contest 📝
```clarity
(contract-call? .Decentralized-Caption-Contest create-contest 
  u"https://example.com/meme.jpg" 
  u"Funny Cat Meme" 
  u144 
  u1000000)
```

### 2. Submit a Caption ✏️
```clarity
(contract-call? .Decentralized-Caption-Contest submit-caption 
  u1 
  u"When you realize it's Monday")
```

### 3. Vote for a Caption 🗳️
```clarity
(contract-call? .Decentralized-Caption-Contest vote-caption 
  u1 
  u1)
```

### 4. End Contest & Claim Prize 🏁
```clarity
(contract-call? .Decentralized-Caption-Contest end-contest u1)
```

## 🔧 Development Setup

### Prerequisites
- [Clarinet](https://github.com/hirosystems/clarinet) installed
- Stacks blockchain testnet access

### Installation
```bash
# Clone the repository
git clone https://github.com/loisjonde934/Decentralized-Caption-Contest
cd Decentralized-Caption-Contest

# Check contract syntax
clarinet check

# Run tests
clarinet test
```

## 📊 Contest Lifecycle

```
1. 🎯 Contest Created → 2. ✍️ Captions Submitted → 3. 🗳️ Community Votes → 4. 🏆 Winner Selected → 5. 💰 Prize Distributed
```

## 🎯 Example Workflow

1. **Alice** creates a contest with a funny cat image and 1000 STX prize
2. **Bob** and **Charlie** submit hilarious captions
3. **Community** votes for their favorite captions
4. **Contest ends** after specified blocks
5. **Winner** automatically receives the 1000 STX prize! 🎉

## 🛡️ Security Features

- ✅ Contest creators must lock prize STX upfront
- ✅ One vote per user per contest
- ✅ Automatic winner selection based on vote count
- ✅ Prize distribution only after contest ends
- ✅ No double-voting protection

## 📈 Contract Limits

- Max 20 contests and captions tracked simultaneously
- Contests can run for any duration (in blocks)
- Caption text limited to 256 UTF-8 characters
- Image URLs limited to 256 UTF-8 characters

## 🎪 Get Started

Ready to host the funniest caption contest on the blockchain? Deploy this contract and let the memes begin! 🚀

---
*Built with ❤️ on Stacks blockchain*
