# Solitude Gang System

A comprehensive client-server gang system for DarkRP in Garry's Mod.

## Features

### Core Functionality
- **Gang Creation** - Create gangs with custom names ($50,000 cost)
- **Member Management** - Invite, kick, and manage gang members
- **Gang Hierarchy** - Leader-based gang structure
- **Gang Bank** - Shared bank account for the gang
- **Level System** - Gang progression with XP and levels
- **Member Limits** - Configurable maximum member count (default: 8)

### User Interface
- **Modern Gang Menu** - Comprehensive management interface with tabs
  - Overview: View gang statistics and info
  - Members: See all members, invite/kick players
  - Bank: Deposit and withdraw money
  - Settings: Leave or disband gang
- **HUD Display** - Real-time gang information on screen
- **Custom Theme** - Dark themed UI with customizable colors

### Commands
- `/gang` or `!gang` - Open gang menu
- `/gang help` - Show available commands
- `/gang leave` - Leave current gang
- `gang_menu` (console) - Open gang menu

### Leader Actions
- Create gang
- Invite players
- Kick members
- Withdraw from bank
- Disband gang

### Member Actions
- Accept/decline invitations
- Leave gang
- Deposit to gang bank
- View gang information

## File Structure

```
lua/
├── autorun/
│   └── solitudegang_load.lua          # Main loader
├── solitudegang/
│   ├── client/
│   │   └── hud.lua                    # HUD display and chat commands
│   ├── core/
│   │   ├── data.lua                   # Client-side data management
│   │   └── network.lua                # Network handlers
│   ├── elements/
│   │   ├── frame.lua                  # Base frame (original)
│   │   └── gangmenu.lua               # Main gang menu UI
│   ├── misc/
│   │   ├── font.lua                   # Font creation
│   │   └── util.lua                   # Utility functions
│   ├── server/
│   │   └── core.lua                   # Server-side gang logic
│   ├── settings/
│   │   └── theme.lua                  # UI theme configuration
│   ├── test/
│   │   └── frame.lua                  # Test commands
│   └── thirdparty/
│       └── bshadows.lua               # Shadow rendering library
```

## Configuration

Edit `lua/solitudegang/server/core.lua` to modify:

```lua
SolitudeGang.Config = {
    CreateCost = 50000,           -- Cost to create a gang
    MaxMembers = 8,               -- Maximum gang members
    MaxGangNameLength = 32,       -- Max characters in gang name
    MinGangNameLength = 3         -- Min characters in gang name
}
```

## Gang Data Structure

```lua
{
    id = number,                  -- Unique gang ID
    name = string,                -- Gang name
    leader = Player,              -- Gang leader
    members = {Player, ...},      -- All members
    created = number,             -- Creation timestamp
    level = number,               -- Gang level
    xp = number,                  -- Current XP
    bank = number,                -- Bank balance
    maxMembers = number           -- Member limit
}
```

## Network Strings

### Client → Server
- `SolitudeGang.CreateGang` - Create new gang
- `SolitudeGang.LeaveGang` - Leave current gang
- `SolitudeGang.InvitePlayer` - Invite player to gang
- `SolitudeGang.AcceptInvite` - Accept gang invitation
- `SolitudeGang.KickMember` - Kick member from gang
- `SolitudeGang.DisbandGang` - Disband gang
- `SolitudeGang.RequestGangData` - Request gang data
- `SolitudeGang.DepositMoney` - Deposit to gang bank
- `SolitudeGang.WithdrawMoney` - Withdraw from gang bank

### Server → Client
- `SolitudeGang.SendGangData` - Send gang data to client
- `SolitudeGang.CreateGangResponse` - Gang creation response
- `SolitudeGang.LeaveGangResponse` - Leave gang response
- `SolitudeGang.ReceiveInvite` - Receive gang invitation
- `SolitudeGang.GangDisbanded` - Gang disbanded notification
- `SolitudeGang.MemberKicked` - Member kicked notification

## Hooks

### Client Hooks
- `SolitudeGang.GangUpdated` - Called when gang data is updated
- `SolitudeGang.GangLeft` - Called when player leaves gang

### Server Hooks
- `PlayerDisconnected` - Clean up player data
- `PlayerSpawn` - Send gang data on spawn

## API Reference

### Client API

#### SolitudeGang.Data
```lua
SolitudeGang.Data:IsInGang()                    -- Check if player is in gang
SolitudeGang.Data:IsGangLeader()                -- Check if player is leader
SolitudeGang.Data:GetLocalGang()                -- Get current gang data
SolitudeGang.Data:GetMemberCount()              -- Get member count
SolitudeGang.Data:IsMemberOfLocalGang(ply)     -- Check if player is member
```

#### SolitudeGang.Net
```lua
SolitudeGang.Net:CreateGang(gangName)           -- Create new gang
SolitudeGang.Net:LeaveGang()                    -- Leave gang
SolitudeGang.Net:InvitePlayer(target)           -- Invite player
SolitudeGang.Net:AcceptInvite()                 -- Accept invitation
SolitudeGang.Net:KickMember(target)             -- Kick member
SolitudeGang.Net:DisbandGang()                  -- Disband gang
SolitudeGang.Net:DepositMoney(amount)           -- Deposit money
SolitudeGang.Net:WithdrawMoney(amount)          -- Withdraw money
```

### Server API

#### SolitudeGang.Server
```lua
SolitudeGang.Server:CreateGang(leader, gangName)           -- Create gang
SolitudeGang.Server:GetPlayerGang(ply)                     -- Get player's gang
SolitudeGang.Server:InvitePlayer(inviter, target)          -- Invite player
SolitudeGang.Server:AcceptInvite(ply)                      -- Accept invite
SolitudeGang.Server:LeaveGang(ply)                         -- Leave gang
SolitudeGang.Server:KickMember(leader, target)             -- Kick member
SolitudeGang.Server:DisbandGang(leader)                    -- Disband gang
SolitudeGang.Server:DepositMoney(ply, amount)              -- Deposit money
SolitudeGang.Server:WithdrawMoney(ply, amount)             -- Withdraw money
```

## DarkRP Integration

The system integrates with DarkRP for money management. It uses:
- `ply:getDarkRPVar("money")` to get player money
- `ply:setDarkRPVar("money", amount)` to set player money

## Customization

### Theme Colors
Edit `lua/solitudegang/settings/theme.lua`:
```lua
SolitudeGang.Theme = {
    primary = Color(60, 60, 60),
    background = Color(45, 45, 45),
    closeBtn = Color(255, 255, 255),
    text = {
        h1 = Color(220, 220, 220)
    }
}
```

### UI Sizes
```lua
SolitudeGang.UISizes = {
    navbar = { height = 48 }
}
```

## Future Enhancement Ideas

- Persistent data storage (MySQL/SQLite)
- Gang territories/zones
- Gang wars/rivalries
- Gang perks and upgrades
- Gang chat system
- Gang statistics tracking
- Gang ranks (officers, etc.)
- Gang logos/emblems
- Activity logs
- Alliances between gangs
- Gang quests/missions

## Credits

- Original frame design by Solitude Gang team
- bshadows library for UI shadows
- DarkRP integration

## License

Free to use and modify for your Garry's Mod server.
