# Asynchronous FIFO

## Overview

A dual-clock asynchronous FIFO implemented in SystemVerilog for reliable data transfer between independent clock domains.

## Specifications

| Parameter | Value |
|---|---|
| Data Width | 8 bits |
| FIFO Depth | 16 entries |
| Write Clock | Independent |
| Read Clock | Independent |
| Reset | Asynchronous |
| Pointer Encoding | Gray Code |

## Design Objectives

- Safe data transfer between asynchronous clock domains
- Independent write and read operations
- Full and empty detection
- Clock-domain crossing synchronization
- Parameterized data width and FIFO depth

## Verification Objectives

- Write and read functionality
- Full condition
- Empty condition
- Simultaneous read/write operation
- Independent clock frequencies
- Reset behavior
- Clock-domain crossing behavior
- Functional coverage