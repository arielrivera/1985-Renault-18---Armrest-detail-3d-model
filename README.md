# 1985 Renault 18 – Armrest Detail (3D Printable Model)

This project is an attempt to create a 3D-printable replacement part for a small detail in the armrest of a **1985 Renault 18**.

The original part is no longer available, so the goal is to reverse-engineer the shape from reference photos and measurements, model it in OpenSCAD, and export an STL file suitable for FDM or resin 3D printing.

## Status

🚧 **Still in development** – the model is a work in progress. Dimensions and fit are being refined through test prints and comparison with the original component.

## Files

- `design.scad` – OpenSCAD source file for the armrest detail.
- `Main.stl` – Exported STL ready for slicing/printing.
- `reference_images/` – Photos of the original part and the car interior used as modeling references.
- `r_and_d_archive/` – Earlier prototypes, test prints, and alternate design iterations.

## Reference Images

Below are a few reference photos showing the armrest area and the detail being replicated:

![Armrest reference 1](reference_images/renault01.jpg)
![Armrest reference 2](reference_images/renault02.jpg)
![Reference photo](reference_images/2F0328F7-FDB6-4803-9FCC-E9159196371D.jpeg)
![Reference photo](reference_images/4F73C7D6-7185-47E3-B726-2C952DA8C34F.jpeg)
![Reference photo](reference_images/77CA44A5-0630-4B1D-899C-DB1A8E7D39BC.jpeg)

## How to Generate an STL

You can open `design.scad` in [OpenSCAD](https://openscad.org/) and render/export an STL, or use a service like [Ochafik's online OpenSCAD renderer](https://ochafik.com/) to generate an STL file for printing if needed.

## License

This project is shared for personal/educational use. Print and modify at your own risk.