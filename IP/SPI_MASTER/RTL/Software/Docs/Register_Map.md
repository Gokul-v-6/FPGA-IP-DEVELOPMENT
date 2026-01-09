# SPI Master IP (Mode-0) – Register Map

## Address Mapping
SPI IP is selected when:
- `mem_addr[22] == 1` (IO space)
- `mem_addr[12] == 1` (SPI offset)

SPI IP base address: `0x00401000`

---
## Register Summary

| Offset | Register | R/W | Description |
|------|--------|-----|-------------|
| 0x00 | CTRL   | R/W | Enable, start, clock divider |
| 0x04 | TXDATA | R/W | Transmit data |
| 0x08 | RXDATA | R   | Received data |
| 0x0C | STATUS | R/W | Busy and done flags |

---
## CTRL Register (0x00)

| Bits | Name | Access | Description |
|----|----|------|------------|
| 0 | EN | R/W | Enable SPI |
| 1 | START | R/W | Start transfer |
| 15:8 | CLKDIV | R/W | SPI clock divider |
| Others | – | – | Reserved |

Reset value: `0x00000000`

---
## TXDATA Register (0x04)

| Bits | Name | Access | Description |
|----|----|------|------------|
| 7:0 | TX | R/W | Transmit byte |

---
## RXDATA Register (0x08)

| Bits | Name | Access | Description |
|----|----|------|------------|
| 7:0 | RX | R | Received byte |

---
## STATUS Register (0x0C)

| Bits | Name | Access | Description |
|----|----|------|------------|
| 0 | BUSY | R | Transfer in progress |
| 1 | DONE | R/W1C | Transfer complete |
| 2 | TX_READY | R | TXDATA Register is Free |
