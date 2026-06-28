# Medical Image Restoration: Pseudoinverse vs. Wiener Filtering

A MATLAB project that simulates motion-blurred and noisy X-ray imaging, then restores the image using two different deconvolution methods.

## What it does

1. **Degrade**: blurs a sinus X-ray with a simulated horizontal motion blur (manual sliding-window average, not a built-in filter), then adds Gaussian noise.
2. **Restore (Pseudoinverse)**: deconvolves the blurred+noisy image in the frequency domain using a thresholded pseudoinverse filter, to avoid amplifying near-zero frequencies.
3. **Restore (Wiener)**: builds a custom Wiener filter from scratch — estimates the image power spectrum from 10 shifted versions of the original, then applies the full Wiener formula — and compares the result against the pseudoinverse approach.

## Why

Motion blur and noise are common degradations in real medical imaging (patient movement, sensor noise). This project compares a naive restoration method (pseudoinverse) against a noise-aware one (Wiener filter) on the same degraded image, to see which holds up better.

## Run it

Requires MATLAB with the Image Processing Toolbox.

```
Projekt4_digimageprocessing.m
```

Run the whole script. It will pop up a sequence of figures: original, blurred, blurred+noisy, pseudoinverse-restored, Wiener-restored, and a side-by-side comparison of all three.

## Files

- `Projekt4_digimageprocessing.m` — main script
- `normal-paranasal-sinuses-x-ray_v2.png` — source image
- `chest_xray.tif`, `head_CT_slice.tif`, `normal-mri-brain-3.jpg` — other medical images used in related coursework
