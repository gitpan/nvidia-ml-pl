nvidia::ml - Perl bindings to NVML, the NVIDIA Management Library

Provides a Perl interface to GPU management and monitoring functions.

This is a wrapper around the NVML library.
For information about the NVML library, see the NVML documentation.

To install:
perl Makefile.PL
make
make test
sudo make install

Read perldoc perlmodinstall for more information about installing

Run `perldoc nvidia::ml` for information about the module after installation

Release Notes:
Version 2.285.0
- Added new functions for NVML 2.285.  See NVML documentation for more information.
- Added nvidia::smi tool as a sample app.

