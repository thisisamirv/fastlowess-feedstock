#!/bin/bash
set -ex

# Determine R executable
R_EXE=${R:-R}
$R_EXE --version

cd bindings/r

# Patch out unused BiocGenerics dependency
sed '/Imports: BiocGenerics/d' DESCRIPTION >DESCRIPTION.tmp && mv DESCRIPTION.tmp DESCRIPTION
sed '/importFrom(BiocGenerics,normalize)/d' NAMESPACE >NAMESPACE.tmp && mv NAMESPACE.tmp NAMESPACE
sed '/@importFrom BiocGenerics normalize/d' R/rfastlowess-package.R >rfastlowess-package.R.tmp && mv rfastlowess-package.R.tmp R/rfastlowess-package.R

# Extract vendored dependencies before R CMD INSTALL runs configure
(cd src && tar --extract --xz -f vendor.tar.xz)

# Unset CARGO_BUILD_TARGET to ensure configure and cargo use the same library path
unset CARGO_BUILD_TARGET
$R_EXE CMD INSTALL --build .
