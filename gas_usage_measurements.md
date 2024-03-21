# Gas Usage Measurements

## Recursive Version
- `test_transfer_from_excluded`: 3072140
- `test_transfer_both_excluded`: 3411790
- `test_transfer_to_excluded`: 2804880

## Loop Version
- `test_transfer_from_excluded`: 3416970
- `test_transfer_both_excluded`: 3930600
- `test_transfer_to_excluded`: 3188720

Notes:
- The recursive version generally consumes less gas compared to the loop version.
- The gas usage measurements were obtained using the latest version of the Cairo compiler.