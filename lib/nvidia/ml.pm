#####
# Copyright (c) 2011, NVIDIA Corporation.  All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
# 
#    * Redistributions of source code must retain the above copyright notice,
#      this list of conditions and the following disclaimer.
#    * Redistributions in binary form must reproduce the above copyright
#      notice, this list of conditions and the following disclaimer in the
#      documentation and/or other materials provided with the distribution.
#    * Neither the name of the NVIDIA Corporation nor the names of its
#      contributors may be used to endorse or promote products derived from
#      this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF 
# THE POSSIBILITY OF SUCH DAMAGE.
#####

#
# Perl NVML bindings
#
package nvidia::ml;

use warnings;
use strict;
use nvidia::ml::bindings;
require Exporter;

our @ISA = qw(Exporter);

our $VERSION = "2.1";

our @EXPORT_OK =
    qw(
     nvmlInit
     nvmlShutdown
     nvmlErrorString
     nvmlSystemGetDriverVersion
     nvmlUnitGetCount
     nvmlUnitGetHandleByIndex
     nvmlUnitGetUnitInfo
     nvmlUnitGetLedState
     nvmlUnitGetPsuInfo
     nvmlUnitGetTemperature
     nvmlUnitGetFanSpeedInfo
     nvmlUnitGetDevices
     nvmlDeviceGetCount
     nvmlDeviceGetHandleByIndex
     nvmlDeviceGetHandleBySerial
     nvmlDeviceGetHandleByPciBusId
     nvmlDeviceGetName
     nvmlDeviceGetSerial
     nvmlDeviceGetUUID
     nvmlDeviceGetInforomVersion
     nvmlDeviceGetDisplayMode
     nvmlDeviceGetPersistenceMode
     nvmlDeviceGetPciInfo
     nvmlDeviceGetClockInfo
     nvmlDeviceGetFanSpeed
     nvmlDeviceGetTemperature
     nvmlDeviceGetPowerState
     nvmlDeviceGetPowerManagementMode
     nvmlDeviceGetPowerManagementLimit
     nvmlDeviceGetPowerUsage
     nvmlDeviceGetMemoryInfo
     nvmlDeviceGetComputeMode
     nvmlDeviceGetEccMode
     nvmlDeviceGetTotalEccErrors
     nvmlDeviceGetDetailedEccErrors
     nvmlDeviceGetUtilizationRates
     nvmlDeviceGetDriverModel
     nvmlUnitSetLedState
     nvmlDeviceSetPersistenceMode
     nvmlDeviceSetComputeMode
     nvmlDeviceSetEccMode
     nvmlDeviceClearEccErrorCounts
     nvmlDeviceSetDriverModel
     
     $NVML_FEATURE_DISABLED
     $NVML_FEATURE_ENABLED
     $nvmlFlagDefault
     $nvmlFlagForce
     $NVML_TEMPERATURE_GPU
     $NVML_COMPUTEMODE_DEFAULT
     $NVML_COMPUTEMODE_EXCLUSIVE_THREAD
     $NVML_COMPUTEMODE_PROHIBITED
     $NVML_COMPUTEMODE_EXCLUSIVE_PROCESS
     $NVML_SINGLE_BIT_ECC
     $NVML_DOUBLE_BIT_ECC
     $NVML_VOLATILE_ECC
     $NVML_AGGREGATE_ECC
     $NVML_CLOCK_GRAPHICS
     $NVML_CLOCK_SM
     $NVML_CLOCK_MEM
     $NVML_DRIVER_WDDM
     $NVML_DRIVER_WDM
     $NVML_PSTATE_0
     $NVML_PSTATE_1
     $NVML_PSTATE_2
     $NVML_PSTATE_3
     $NVML_PSTATE_4
     $NVML_PSTATE_5
     $NVML_PSTATE_6
     $NVML_PSTATE_7
     $NVML_PSTATE_8
     $NVML_PSTATE_9
     $NVML_PSTATE_10
     $NVML_PSTATE_11
     $NVML_PSTATE_12
     $NVML_PSTATE_13
     $NVML_PSTATE_14
     $NVML_PSTATE_15
     $NVML_PSTATE_UNKNOWN
     $NVML_INFOROM_OEM
     $NVML_INFOROM_ECC
     $NVML_INFOROM_POWER
     $NVML_SUCCESS
     $NVML_ERROR_UNINITIALIZED
     $NVML_ERROR_INVALID_ARGUMENT
     $NVML_ERROR_NOT_SUPPORTED
     $NVML_ERROR_NO_PERMISSION
     $NVML_ERROR_ALREADY_INITIALIZED
     $NVML_ERROR_NOT_FOUND
     $NVML_ERROR_INSUFFICIENT_SIZE
     $NVML_ERROR_INSUFFICIENT_POWER
     $NVML_ERROR_UNKNOWN
     $NVML_FAN_NORMAL
     $NVML_FAN_FAILED
     $NVML_LED_COLOR_GREEN
     $NVML_LED_COLOR_AMBER
    );

# use nvidia::ml qw(:all);
our %EXPORT_TAGS = (all => [@EXPORT_OK]);
Exporter::export_ok_tags('all');

## Enums, constants, variables
foreach my $export (@EXPORT_OK)
{
    if ($export =~ /^\$(.+)$/)
    {
        # Map all variables to be exported to the swig produced bindings
        # New enums, constants and variables must be added to @EXPORT to be mapped
        my $MapExpr = "*" . $1 . " = *nvidia::ml::bindings::" . $1 . ";";
        eval $MapExpr;
    }
}


## Method definitions
*nvmlInit        = *nvidia::ml::bindings::nvmlInit;
*nvmlShutdown    = *nvidia::ml::bindings::nvmlShutdown;

sub nvmlErrorString
{
    my $code = shift;
    my %conversion =
                (
                    $nvidia::ml::NVML_SUCCESS                   => 'Success',
                    $nvidia::ml::NVML_ERROR_UNINITIALIZED       => 'Uninitialized',
                    $nvidia::ml::NVML_ERROR_INVALID_ARGUMENT    => 'Invalid Argument',
                    $nvidia::ml::NVML_ERROR_NOT_SUPPORTED       => 'N/A',
                    $nvidia::ml::NVML_ERROR_NO_PERMISSION       => 'Insufficient Permissions',
                    $nvidia::ml::NVML_ERROR_ALREADY_INITIALIZED => 'Already Initialized',
                    $nvidia::ml::NVML_ERROR_NOT_FOUND           => 'Not Found',
                    $nvidia::ml::NVML_ERROR_INSUFFICIENT_SIZE   => 'Insufficient Size',
                    $nvidia::ml::NVML_ERROR_UNKNOWN             => 'Unknown Error'
                );
    my $str = $conversion{$code};
    if (not defined $str)
    {
        $str = $conversion{$nvidia::ml::NVML_ERROR_UNKNOWN};
    }
    return $str;
}

sub nvmlSystemGetDriverVersion
{
    # NVML API 1.0 requires a buffer >80
    return nvidia::ml::bindings::nvmlSystemGetDriverVersion(81);
}

*nvmlUnitGetCount            = *nvidia::ml::bindings::nvmlUnitGetCount;
*nvmlUnitGetHandleByIndex    = *nvidia::ml::bindings::nvmlUnitGetHandleByIndex;

sub nvmlUnitGetUnitInfo
{
    my $handle = shift;
    my $info = new nvidia::ml::bindings::nvmlUnitInfo_t();
    my $ret = nvidia::ml::bindings::nvmlUnitGetUnitInfo($handle, $info);
    
    my %infohash = ();
    if ($ret == 0)
    {
        $infohash{'name'} = $info->swig_name_get();
        $infohash{'id'} = $info->swig_id_get();
        $infohash{'serial'} = $info->swig_serial_get();
        $infohash{'firmwareVersion'} = $info->swig_firmwareVersion_get();
    }
    
    return ($ret, \%infohash);
}
sub nvmlUnitGetLedState
{
    my $handle = shift;
    my $state = new nvidia::ml::bindings::nvmlLedState_t();
    my $ret = nvidia::ml::bindings::nvmlUnitGetLedState($handle, $state);
    
    my %infohash = ();
    if ($ret == 0)
    {
        $infohash{'cause'} = $state->swig_cause_get();
        $infohash{'color'} = $state->swig_color_get();
    }
    
    return ($ret, \%infohash);
}
sub nvmlUnitGetPsuInfo
{
    my $handle = shift;
    my $info = new nvidia::ml::bindings::nvmlPSUInfo_t();
    my $ret = nvidia::ml::bindings::nvmlUnitGetPsuInfo($handle, $info);
    
    my %infohash = ();
    if ($ret == 0)
    {
        $infohash{'state'} = $info->swig_state_get();
        $infohash{'current'} = $info->swig_current_get();
        $infohash{'voltage'} = $info->swig_voltage_get();
        $infohash{'power'} = $info->swig_power_get();
    }
    
    return ($ret, \%infohash);
}

*nvmlUnitGetTemperature        = *nvidia::ml::bindings::nvmlUnitGetTemperature;

sub nvmlUnitGetFanSpeedInfo
{
    my $handle = shift;

    # C malloc
    my $info = new nvidia::ml::bindings::nvmlUnitFanSpeeds_t();

    my $ret = nvidia::ml::bindings::nvmlUnitGetFanSpeedInfo($handle, $info);
    
    my @fanInfo = ();
    if ($ret == 0)
    {
        my $fans = $info->swig_fans_get();
        my $count = $info->swig_count_get();
        
        foreach my $i (0..$count-1)
        {
            my %infohash = ();
            my $fan = nvidia::ml::bindings::_getFanInfoByIndex($fans, $i);
            bless $fan, 'nvidia::ml::bindings::nvmlUnitFanInfo_t';
            $infohash{'state'} = $fan->swig_state_get();
            $infohash{'speed'} = $fan->swig_speed_get();
            push @fanInfo, \%infohash;
        }
    }
   
    # C free
    $info->DESTROY();
    
    return ($ret, \@fanInfo);
}

sub nvmlUnitGetDevices
{
    my $handle = shift;
    my $count;
    my $ret;
    my $devices;
    
    # first get the count
    ($ret, $count) = nvidia::ml::bindings::_nvmlUnitGetDevices($handle, 0, undef);
    if ($ret != $nvidia::ml::bindings::NVML_SUCCESS &&
        $ret != $nvidia::ml::bindings::NVML_ERROR_INSUFFICIENT_SIZE)
    {
        return ($ret, -1, undef);
    }
    
    # create an array of the needed size
    $devices = nvidia::ml::bindings::_createDeviceArray($count);
    
    # get the devices
    ($ret, $count) = nvidia::ml::bindings::_nvmlUnitGetDevices($handle, $count, $devices);
    
    my @devs = ();
    
    if ($ret == $nvidia::ml::bindings::NVML_SUCCESS)
    {
        foreach my $i (0..$count-1)
        {
            my $dev = nvidia::ml::bindings::_getDeviceByIndex($devices, $i);
            bless $dev, 'nvidia::ml::bindings::nvmlDevice_t';
            push @devs, $dev;
        }
    }
    
    nvidia::ml::bindings::_freeDeviceArray($devices);
    
    return ($ret, $count, \@devs);
}

*nvmlDeviceGetCount          = *nvidia::ml::bindings::nvmlDeviceGetCount;
*nvmlDeviceGetHandleByIndex  = *nvidia::ml::bindings::nvmlDeviceGetHandleByIndex;
*nvmlDeviceGetHandleBySerial = *nvidia::ml::bindings::nvmlDeviceGetHandleBySerial;

sub nvmlDeviceGetName
{
    my $handle = shift;
    return nvidia::ml::bindings::nvmlDeviceGetName($handle, 64);
}
sub nvmlDeviceGetSerial
{
    my $handle = shift;
    return nvidia::ml::bindings::nvmlDeviceGetSerial($handle, 30);
}
sub nvmlDeviceGetUUID
{
    my $handle = shift;
    return nvidia::ml::bindings::nvmlDeviceGetUUID($handle, 80);
}
sub nvmlDeviceGetInforomVersion
{
    my $handle = shift;
    my $object = shift;
    return nvidia::ml::bindings::nvmlDeviceGetInforomVersion($handle, $object, 100);
}

*nvmlDeviceGetDisplayMode     = *nvidia::ml::bindings::nvmlDeviceGetDisplayMode;
*nvmlDeviceGetPersistenceMode = *nvidia::ml::bindings::nvmlDeviceGetPersistenceMode;

sub nvmlDeviceGetPciInfo
{
    my $handle = shift;
    my $info = new nvidia::ml::bindings::nvmlPciInfo_t();
    my $ret = nvidia::ml::bindings::nvmlDeviceGetPciInfo($handle, $info);
    
    my %infohash = ();
    if ($ret == 0)
    {
        $infohash{'busId'} = $info->swig_busId_get();
        $infohash{'domain'} = $info->swig_domain_get();
        $infohash{'bus'} = $info->swig_bus_get();
        $infohash{'device'} = $info->swig_device_get();
        $infohash{'pciDeviceId'} = $info->swig_pciDeviceId_get();
    }
    
    return ($ret, \%infohash);
}

*nvmlDeviceGetClockInfo            = *nvidia::ml::bindings::nvmlDeviceGetClockInfo;
*nvmlDeviceGetFanSpeed             = *nvidia::ml::bindings::nvmlDeviceGetFanSpeed;
*nvmlDeviceGetTemperature          = *nvidia::ml::bindings::nvmlDeviceGetTemperature;
*nvmlDeviceGetPowerState           = *nvidia::ml::bindings::nvmlDeviceGetPowerState;
*nvmlDeviceGetPowerManagementMode  = *nvidia::ml::bindings::nvmlDeviceGetPowerManagementMode;
*nvmlDeviceGetPowerManagementLimit = *nvidia::ml::bindings::nvmlDeviceGetPowerManagementLimit;
*nvmlDeviceGetPowerUsage           = *nvidia::ml::bindings::nvmlDeviceGetPowerUsage;

sub nvmlDeviceGetMemoryInfo
{
    my $handle = shift;
    my $info = new nvidia::ml::bindings::nvmlMemory_t();
    my $ret = nvidia::ml::bindings::nvmlDeviceGetMemoryInfo($handle, $info);
    
    my %infohash = ();
    if ($ret == 0)
    {
        $infohash{'total'} = $info->swig_total_get();
        $infohash{'free'}  = $info->swig_free_get();
        $infohash{'used'}  = $info->swig_used_get();
    }
    
    return ($ret, \%infohash);
}

*nvmlDeviceGetComputeMode    = *nvidia::ml::bindings::nvmlDeviceGetComputeMode;
*nvmlDeviceGetEccMode        = *nvidia::ml::bindings::nvmlDeviceGetEccMode;
*nvmlDeviceGetTotalEccErrors = *nvidia::ml::bindings::nvmlDeviceGetTotalEccErrors;

sub nvmlDeviceGetDetailedEccErrors
{
    my $handle = shift;
    my $bitType = shift;
    my $counterType = shift;
    my $info = new nvidia::ml::bindings::nvmlEccErrorCounts_t();
    my $ret = nvidia::ml::bindings::nvmlDeviceGetDetailedEccErrors($handle, $bitType, $counterType, $info);
    
    my %infohash = ();
    if ($ret == 0)
    {
        $infohash{'l1Cache'}      = $info->swig_l1Cache_get();
        $infohash{'l2Cache'}      = $info->swig_l2Cache_get();
        $infohash{'deviceMemory'} = $info->swig_deviceMemory_get();
        $infohash{'registerFile'} = $info->swig_registerFile_get();
    }
    
    return ($ret, \%infohash);
}
sub nvmlDeviceGetUtilizationRates
{
    my $handle = shift;
    my $info = new nvidia::ml::bindings::nvmlUtilization_t();
    my $ret = nvidia::ml::bindings::nvmlDeviceGetUtilizationRates($handle, $info);
    
    my %infohash = ();
    if ($ret == 0)
    {
        $infohash{'gpu'}    = $info->swig_gpu_get();
        $infohash{'memory'} = $info->swig_memory_get();
    }
    
    return ($ret, \%infohash);
}

*nvmlDeviceGetDriverModel      = *nvidia::ml::bindings::nvmlDeviceGetDriverModel;

*nvmlUnitSetLedState           = *nvidia::ml::bindings::nvmlUnitSetLedState;
*nvmlDeviceSetPersistenceMode  = *nvidia::ml::bindings::nvmlDeviceSetPersistenceMode;
*nvmlDeviceSetComputeMode      = *nvidia::ml::bindings::nvmlDeviceSetComputeMode;
*nvmlDeviceSetEccMode          = *nvidia::ml::bindings::nvmlDeviceSetEccMode;
*nvmlDeviceClearEccErrorCounts = *nvidia::ml::bindings::nvmlDeviceClearEccErrorCounts;
*nvmlDeviceSetDriverModel      = *nvidia::ml::bindings::nvmlDeviceSetDriverModel;

1;
__END__

=head1 NAME

nvidia::ml - Perl bindings to NVML, the NVIDIA Management Library

=head1 SYNOPSIS

    use nvidia::ml qw(:all);
 
    nvmlInit();
 
    ($ret, $version) = nvmlSystemGetDriverVersion();
    die nvmlErrorString($ret) unless $ret == $NVML_SUCCESS;
    print "Driver version: " . $version . "\n";
 
    ($ret, $count) = nvmlDeviceGetCount();
    die nvmlErrorString($ret) unless $ret == $NVML_SUCCESS;
 
    for ($i=0; $i<$count; $i++)
    {
        ($ret, $handle) = nvmlDeviceGetHandleByIndex($i);
        next if $ret != $NVML_SUCCESS;
     
        ($ret, $speed) = nvmlDeviceGetFanSpeed($handle);
        next if $ret != $NVML_SUCCESS;
        print "Device " . $i . " fan speed: " . $speed . "%\n";
     
        ($ret, $info) = nvmlDeviceGetMemoryInfo($handle);
        next if $ret != $NVML_SUCCESS;
        $total = ($info->{"total"} / 1024 / 1024);
        print "Device " . $i . " total memory: " . $total . " MB\n";
    }
 
    nvmlShutdown();

=head1 DESCRIPTION

Provides a Perl interface to GPU management and monitoring functions.

This is a wrapper around the NVML library.  For information about the NVML library, see the NVML documentation.

=head1 REQUIRES

Exporter

=head1 EXPORTS

This module has no exports.  To add functions and constants to your namespace use:
use nvidia::ml qw(:all);

=head1 METHODS

See EXPORTS and NVML documentation.  Perl methods wrap NVML functions, implemented in a C shared library.  The functions use is the same with the following exceptions:

=over 4

=item Perl methods accept the input arguements of the C function it wraps only.  All C function output parameters are returned after the return code, left to right

 C:
 nvmlReturn_t nvmlDeviceGetEccMode(nvmlDevice_t device,
                                   nvmlEnableState_t *current,
                                   nvmlEnableState_t *pending);
 Perl:
 ($ret, $current, $pending) = nvmlDeviceGetEccMode($device); 

=item Perl handles string buffer creation

 C:
 nvmlReturn_t nvmlSystemGetDriverVersion(char* version,
                                         unsigned int length);
 Perl:
 ($ret, $version) = nvmlSystemGetDriverVersion();

=item C structs are converted to Perl hashes, nested as needed

 C:
 nvmlReturn_t DECLDIR nvmlDeviceGetMemoryInfo(nvmlDevice_t device,
                                              nvmlMemory_t *memory);
 typedef struct nvmlMemory_st {
     unsigned long long total;
     unsigned long long free;
     unsigned long long used;
 } nvmlMemory_t;
 Perl:
 ($ret, $memory) = nvmlDeviceGetMemoryInfo($device);
 print "Total memory " . $memory->{"total"} . "\n";
 print "Used memory " . $memory->{"used"} . "\n";
 print "Free memory " . $memory->{"free"} . "\n";

=back

=head1 VARIABLES

See EXPORTS and NVML documentation.  All NVML constants and enums are exposed.

=head1 COPYRIGHT

Copyright (c) 2011, NVIDIA Corporation.  All rights reserved.

=head1 LICENSE

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

=over 4

=item *
Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

=item *
Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

=item *
Neither the name of the NVIDIA Corporation nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

=back

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

=cut

