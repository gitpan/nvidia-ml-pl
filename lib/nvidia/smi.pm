#####
# Copyright (c) 2011-2012, NVIDIA Corporation.  All rights reserved.
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
# nvidia::smi
# nvml_bindings <at> nvidia <dot> com
#
# Sample code that attempts to reproduce the output of nvidia-smi -q- x
# For many cases the output should match
#
# To run:
# $ perl
# use nvidia::smi;
# print nvidia::smi::XmlDeviceQuery();
#

package nvidia::smi;

use strict;
use warnings;

use nvidia::ml qw(:all);

#
# This helper function simplifies the code
# It converts error codes into error messages
# On success, it formats the result
#
sub handleOutput
{
    my $ret   = shift;
    my $value = shift;
    
    my %args = @_;
    my $prefix = $args{prefix} || '';
    my $postfix = $args{postfix} || '';
    my $strArr = $args{strings};
    my $errStr = $args{errorCode};
    my $scale = $args{scale} || 1;
    my $format = $args{format} || '%s';
    
    my $retString = nvmlErrorString($ret);
    if ($ret == $NVML_SUCCESS)
    {
        if (defined $strArr)
        {
            if (defined @$strArr[$value])
            {
                return $prefix . @$strArr[$value] . $postfix;
            }
            else
            {
                return $prefix . '???' . $postfix;
            }
        }
        else
        {
            if (1 != $scale)
            {
                $value = $value * $scale;
            }
            
            $value = sprintf($format, $value);

            return $prefix . $value . $postfix;
        }
    }
    else
    {
        if ($ret == $NVML_ERROR_NOT_SUPPORTED)
        {
            return "N/A";
        }
        else
        {
            return nvmlErrorString($ret);
        }
    }
}

my @computeModes = qw( Default Thread Prohibit Process );
my @months = qw( Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec );
my @wdays = qw( Sun Mon Tues Wed Thur Fri Sat );
my @enableStr = qw( Disabled Enabled );
my @supportedStr = qw( N/A Supported );

# The main function
sub XmlDeviceQuery
{
    #
    # initialize NVML
    #
    my $ret = nvmlInit();
    if ($ret != $NVML_SUCCESS)
    {
        return "nvmlInit(): " . nvmlErrorString($ret);
    }

    my $strResult = "";
    $strResult .= "<?xml version=\"1.0\" ?>\n";
    $strResult .= "<!DOCTYPE nvidia_smi_log SYSTEM \"nvsmi_device.dtd\">\n";
    $strResult .= "<nvidia_smi_log>\n";

    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime();
    $year += 1900;
    $strResult .= "  <timestamp>$wdays[$wday] $months[$mon] $mday $hour:$min:$sec $year</timestamp>\n";
    $strResult .= "  <driver_version>" . handleOutput(nvmlSystemGetDriverVersion()) . "</driver_version>\n";
    my $count;
    
    ($ret, $count) = nvmlDeviceGetCount();
    $strResult .= "  <attached_gpus>" . handleOutput($ret, $count) . "</attached_gpus>\n";

    for (my $i = 0; $i < $count; $i++)
    {
        my $handle;
        ($ret, $handle) = nvmlDeviceGetHandleByIndex($i);
        if ($ret != $NVML_SUCCESS)
        {
            return "Error: nvmlDeviceGetHandleByIndex: " . nvmlErrorString($ret);
        }
        
        my $info;
        ($ret, $info) = nvmlDeviceGetPciInfo($handle);
        
        #
        # C structures are converted to perl hash references
        #
        $strResult .= "  <gpu id=\"" . handleOutput($ret, $info->{'busId'}) . "\">\n";
        
        $strResult .= "    <product_name>" . handleOutput(nvmlDeviceGetName($handle)) . "</product_name>\n";
        
        my $mode;
        ($ret, $mode) = nvmlDeviceGetDisplayMode($handle);
        $strResult .= "    <display_mode>" . handleOutput($ret, $mode, strings=>\@enableStr) . "</display_mode>\n";
        
        ($ret, $mode) = nvmlDeviceGetPersistenceMode($handle);
        $strResult .= "    <persistence_mode>" . handleOutput($ret, $mode, strings=>\@enableStr) . "</persistence_mode>\n";
        
        $strResult .= "    <driver_model>\n";
        my $current;
        my $pending;
        ($ret, $current, $pending) = nvmlDeviceGetDriverModel($handle);
        $strResult .= "      <current_dm>" . handleOutput($ret, $current) . "</current_dm>\n";
        $strResult .= "      <pending_dm>" . handleOutput($ret, $pending) . "</pending_dm>\n";
        $strResult .= "    </driver_model>\n";
        
        $strResult .= "    <serial>" . handleOutput(nvmlDeviceGetSerial($handle)) . "</serial>\n";
        
        $strResult .= "    <uuid>" . handleOutput(nvmlDeviceGetUUID($handle)) . "</uuid>\n";
        
        $strResult .= "    <vbios_version>" . handleOutput(nvmlDeviceGetVbiosVersion($handle)) . "</vbios_version>\n";
        
        $strResult .= "    <inforom_version>\n";
        my $str;
        ($ret, $str) = nvmlDeviceGetInforomVersion($handle, $NVML_INFOROM_OEM);
        if ($str eq "")
        {
            $str = "N/A";
        }
        $strResult .= "        <oem_object>" . handleOutput($ret, $str) . "</oem_object>\n";
        ($ret, $str) = nvmlDeviceGetInforomVersion($handle, $NVML_INFOROM_ECC);
        if ($str eq "")
        {
            $str = "N/A";
        }
        $strResult .= "        <ecc_object>" . handleOutput($ret, $str) . "</ecc_object>\n";
        ($ret, $str) = nvmlDeviceGetInforomVersion($handle, $NVML_INFOROM_POWER);
        if ($str eq "")
        {
            $str = "N/A";
        }
        $strResult .= "        <pwr_object>" . handleOutput($ret, $str) . "</pwr_object>\n";
        $strResult .= "    </inforom_version>\n";
        
        $strResult .= "    <pci>\n";
        ($ret, $info) = nvmlDeviceGetPciInfo($handle);
        $strResult .= sprintf("      <pci_bus>%02X</pci_bus>\n", handleOutput($ret, $info->{"bus"}));
        $strResult .= sprintf("      <pci_device>%02X</pci_device>\n", handleOutput($ret, $info->{"device"}));
        $strResult .= sprintf("      <pci_domain>%04X</pci_domain>\n", handleOutput($ret, $info->{"domain"}));
        $strResult .= sprintf("      <pci_device_id>%08X</pci_device_id>\n", (handleOutput($ret, $info->{"pciDeviceId"})));
        $strResult .= sprintf("      <pci_sub_system_id>%08X</pci_sub_system_id>\n", (handleOutput($ret, $info->{"pciSubSystemId"})));
        $strResult .=  "      <pci_bus_id>" . handleOutput($ret, $info->{"busId"}) . "</pci_bus_id>\n";
        $strResult .=  "      <pci_gpu_link_info>\n";
        $strResult .=  "        <pcie_gen>\n";
        $strResult .=  "          <max_link_gen>" . handleOutput(nvmlDeviceGetMaxPcieLinkGeneration($handle)) . "</max_link_gen>\n";
        $strResult .=  "          <current_link_gen>" . handleOutput(nvmlDeviceGetCurrPcieLinkGeneration($handle)) . "</current_link_gen>\n";
        $strResult .=  "        </pcie_gen>\n";
        $strResult .=  "        <link_widths>\n";
        $strResult .=  "          <max_link_width>" . handleOutput(nvmlDeviceGetMaxPcieLinkWidth($handle), postfix=>'x') . "</max_link_width>\n";
        $strResult .=  "          <current_link_width>" . handleOutput(nvmlDeviceGetCurrPcieLinkWidth($handle), postfix=>'x') . "</current_link_width>\n";
        $strResult .=  "        </link_widths>\n";
        $strResult .=  "      </pci_gpu_link_info>\n";
        $strResult .=  "    </pci>\n";
        
        $strResult .= "    <fan_speed>" . handleOutput(nvmlDeviceGetFanSpeed($handle), postfix=>' %') . "</fan_speed>";
        
        $strResult .= "    <memory_usage>\n";
        ($ret, $info) = nvmlDeviceGetMemoryInfo($handle);
        $strResult .= "      <total>" . handleOutput($ret, int($info->{'total'}), scale=>(1 / 1024 / 1024), format=>'%d', postfix=>' MB') . "</total>\n";
        $strResult .= "      <used>" . handleOutput($ret, int($info->{'used'}), scale=>(1 / 1024 / 1024), format=>'%d', postfix=>' MB') . "</used>\n";
        $strResult .= "      <free>" . handleOutput($ret, int($info->{'free'}), scale=>(1 / 1024 / 1024), format=>'%d', postfix=>' MB') . "</free>\n";
        $strResult .= "    </memory_usage>\n";

        ($ret, $mode) = nvmlDeviceGetComputeMode($handle);
        $strResult .= "    <compute_mode>" . handleOutput($ret, $mode, strings=>\@computeModes) . "</compute_mode>\n";
        
        $strResult .= "    <utilization>\n";
        ($ret, $info) = nvmlDeviceGetUtilizationRates($handle);
        $strResult .= "      <gpu_util>" . handleOutput($ret, $info->{'gpu'}, postfix=>' %') . "</gpu_util>\n";
        $strResult .= "      <memory_util>" . handleOutput($ret, $info->{'memory'}, postfix=>' %') . "</memory_util>\n";
        $strResult .= "    </utilization>\n";
        
        $strResult .= "    <ecc_mode>\n";
        ($ret, $current, $pending) = nvmlDeviceGetEccMode($handle);
        $strResult .= "      <current_ecc>" . handleOutput($ret, $current, strings=>\@enableStr) . "</current_ecc>\n";
        $strResult .= "      <pending_ecc>" . handleOutput($ret, $pending, strings=>\@enableStr) . "</pending_ecc>\n";
        $strResult .= "    </ecc_mode>\n";
        
        $strResult .= "    <ecc_errors>\n";
        my @bitTypes = qw(single_bit double_bit);
        my @counterTypes = qw(volatile aggregate);
        
        # enum use 0 index
        for (my $c = 0; $c < @counterTypes; $c++)
        {
            my $counter = $counterTypes[$c];
            $strResult .= "      <$counter>\n";
            for (my $b = 0; $b < @bitTypes; $b++)
            {
                my $bit = $bitTypes[$b];
                $strResult .= "        <$bit>\n";
                my ($retTotal, $total) = nvmlDeviceGetTotalEccErrors($handle, $b, $c);
                ($ret, $info) = nvmlDeviceGetDetailedEccErrors($handle, $b, $c);
                $strResult .= "          <device_memory>" . handleOutput($ret, $info->{'deviceMemory'}) . "</device_memory>\n";
                $strResult .= "          <register_file>" . handleOutput($ret, $info->{'registerFile'}) . "</register_file>\n";
                $strResult .= "          <l1_cache>" . handleOutput($ret, $info->{'l1Cache'}) . "</l1_cache>\n";
                $strResult .= "          <l2_cache>" . handleOutput($ret, $info->{'l2Cache'}) . "</l2_cache>\n";
                $strResult .= "          <total>" . handleOutput($retTotal, $total) . "</total>\n";
                $strResult .= "        </$bit>\n";
            }
            $strResult .= "      </$counter>\n";
        }
        $strResult .= "    </ecc_errors>\n";
        
        $strResult .= "    <temperature>\n";
        $strResult .= "      <gpu_temp>" . handleOutput(nvmlDeviceGetTemperature($handle, $NVML_TEMPERATURE_GPU), postfix=>' C') . "</gpu_temp>\n";
        $strResult .= "    </temperature>\n";

        $strResult .= "    <power_readings>\n";
        $strResult .= "      <power_state>" . handleOutput(nvmlDeviceGetPowerState($handle), prefix=>'P') . "</power_state>\n";
        $strResult .= "      <power_management>" . handleOutput(nvmlDeviceGetPowerManagementMode($handle), strings=>\@supportedStr) . "</power_management>\n";
        $strResult .= "      <power_draw>" . handleOutput(nvmlDeviceGetPowerUsage($handle), scale=>(1 / 1000), postfix=>' W', format=>'%.2f') . "</power_draw>\n";
        $strResult .= "      <power_limit>" . handleOutput(nvmlDeviceGetPowerManagementLimit($handle), scale=>(1 / 1000), postfix=>' W', format=>'%d') . "</power_limit>\n";
        $strResult .= "    </power_readings>\n";

        $strResult .= "    <clocks>\n";
        $strResult .= "      <graphics_clock>" . handleOutput(nvmlDeviceGetClockInfo($handle, $NVML_CLOCK_GRAPHICS), postfix=>' MHz') . "</graphics_clock>\n";
        $strResult .= "      <sm_clock>" . handleOutput(nvmlDeviceGetClockInfo($handle, $NVML_CLOCK_SM), postfix=>' MHz') . "</sm_clock>\n";
        $strResult .= "      <mem_clock>" . handleOutput(nvmlDeviceGetClockInfo($handle, $NVML_CLOCK_MEM), postfix=>' MHz') . "</mem_clock>\n";
        $strResult .= "    </clocks>\n";

        $strResult .= "    <max_clocks>\n";
        $strResult .= "      <graphics_clock>" . handleOutput(nvmlDeviceGetMaxClockInfo($handle, $NVML_CLOCK_GRAPHICS), postfix=>' MHz') . "</graphics_clock>\n";
        $strResult .= "      <sm_clock>" . handleOutput(nvmlDeviceGetMaxClockInfo($handle, $NVML_CLOCK_SM), postfix=>' MHz') . "</sm_clock>\n";
        $strResult .= "      <mem_clock>" . handleOutput(nvmlDeviceGetMaxClockInfo($handle, $NVML_CLOCK_MEM), postfix=>' MHz') . "</mem_clock>\n";
        $strResult .= "    </max_clocks>\n";
        
        $strResult .= "    <performance_state>" . handleOutput(nvmlDeviceGetPerformanceState($handle), prefix=>'P') . "</performance_state>\n";

        $strResult .= "    <compute_processes>\n";

        #
        # Get compute running processes returns an array reference
        # This array is the correct size needed to contain all running compute processes
        #
        my $procstr = "";
        my $procs;
        ($ret, $procs) = nvmlDeviceGetComputeRunningProcesses($handle);
        if ($ret != $NVML_SUCCESS)
        {
            $procstr .= handleOutput($ret);
        }
        else
        {
            foreach (@$procs)
            {
                my $p = $_;
                $procstr .= '    <process_info>\n';
                $procstr .= '      <pid>' . $p->{'pid'} . '</pid>\n';
                my $name;
                
                #
                # Processes can come and go at any time
                # NVML cannot get the name of a process that no longer exists
                #
                ($ret, $name) = nvmlSystemGetProcessName($p->{'pid'});
                if ($ret == $NVML_ERROR_NOT_FOUND)
                {
                    # probably went away
                    next;
                }
                elsif ($ret != $NVML_SUCCESS)
                {
                    $name = handleError($ret);
                }
                $procstr .= '      <process_name>' . $name . '</process_name>\n';
                $procstr .= '      <used_memory>';
                if ($p->{'usedGpuMemory'} == undef)
                {
                    $procstr .= 'N\A';
                }
                else
                {
                    $procstr .= ($p->{'usedGpuMemory'} / 1024 / 1024) . " MB";
                }
                $procstr .= '</used_memory>\n';
                $procstr .= '    <\process_info>\n';
            }
        }
        
        $strResult .= $procstr;

        $strResult .= "    </compute_processes>\n";

        $strResult .= "  </gpu>\n";
    }

    $strResult .= "</nvidia_smi_log>\n";
    
    #
    # shutdown NVML
    #
    nvmlShutdown();
    
    return $strResult;
}

